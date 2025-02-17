import 'package:cakeshop_ui/api/api_service.dart';
import 'package:cakeshop_ui/data/order_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class OrderPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final orderProvider = Provider.of<OrderProvider>(context);
    final orders = orderProvider.orders;

    // print("orders: $orders");

    return Scaffold(
      appBar: AppBar(title: Text("Pesanan Saya")),
      body: orders.isEmpty
          ? Center(child: Text("Belum ada pesanan"))
          : ListView.builder(
              itemCount: orders.length,
              itemBuilder: (context, index) {
                final order = orders[index];

                return Card(
                  margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  child: ListTile(
                    leading: order['cake']['thumbnail'] != null
                        ? Image.network(order['cake']['thumbnail'],
                            width: 50, height: 50, fit: BoxFit.cover)
                        : Icon(Icons.image, size: 50, color: Colors.grey),
                    title: Text(order['cake']['name'] ?? "Nama tidak tersedia"),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Rp ${order['cake']['price']} x ${order['quantity']}",
                        ),
                        if (order['note'] != "-")
                          Text(
                            "Catatan: ${order['note']}",
                            style: TextStyle(color: Colors.grey, fontSize: 12),
                          ),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "Rp ${(double.parse(order['cake']['price'].toString()) * order['quantity']).toStringAsFixed(0)}",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            orderProvider.updateQuantity(order['cake'], 0);
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: orders.isNotEmpty
          ? FloatingActionButton.extended(
              onPressed: () => sendOrder(context),
              icon: Icon(Icons.send),
              label: Text("Kirim Pesanan"),
            )
          : null,
    );
  }

  Future<void> sendOrder(BuildContext context) async {
    final orderProvider = Provider.of<OrderProvider>(context, listen: false);
    final payload = orderProvider.generateOrderPayload();

    try {
      final response = await ApiService().post('admin/order', body: payload);
      Map<String, dynamic> jsonResponse = jsonDecode(response.body);

      if (jsonResponse['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Pesanan berhasil dikirim!")),
        );
        orderProvider.clearOrders();
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Gagal mengirim pesanan: ${response.body}")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Terjadi kesalahan: $e")),
      );
    }
  }
}
