import 'package:cakeshop_ui/api/api_service.dart';
import 'package:cakeshop_ui/data/order_provider.dart';
import 'package:cakeshop_ui/home.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:convert';

class OrderPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final orderProvider = Provider.of<OrderProvider>(context);
    final orders = orderProvider.orders;

    // Calculate total price
    double totalPrice = 0;
    for (var order in orders) {
      totalPrice +=
          double.parse(order['cake']['price'].toString()) * order['quantity'];
    }

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
                          icon: Icon(Icons.remove, color: Colors.red),
                          onPressed: () {
                            if (order['quantity'] > 1) {
                              orderProvider.updateQuantity(
                                  order['cake'], order['quantity'] - 1);
                            }
                          },
                        ),
                        Text(order['quantity'].toString()),
                        IconButton(
                          icon: Icon(Icons.add, color: Colors.green),
                          onPressed: () {
                            orderProvider.updateQuantity(
                                order['cake'], order['quantity'] + 1);
                          },
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
      bottomNavigationBar: orders.isNotEmpty
          ? Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                "Total Harga: Rp ${totalPrice.toStringAsFixed(0)}",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
            )
          : null,
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
          SnackBar(
            content: Text(
              "Pesanan berhasil dikirim",
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.green,
          ),
        );
        orderProvider.clearOrders();
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => Home(initialIndex: 2)),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Gagal mengirim pesanan",
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Terjadi kesalahan: $e")),
      );
    }
  }
}
