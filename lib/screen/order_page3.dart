import 'package:cakeshop_ui/api/api_service.dart';
import 'package:cakeshop_ui/data/order_provider.dart';
import 'package:cakeshop_ui/widget/order_item.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:convert';

class OrderPage extends StatefulWidget {
  @override
  _OrderPageState createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage> {
  double totalHarga = 0;

  @override
  void initState() {
    super.initState();
    _updateTotal();
  }

  void _updateTotal() {
    final orderProvider = Provider.of<OrderProvider>(context, listen: false);
    setState(() {
      totalHarga = orderProvider.orders.fold(0, (sum, order) {
        return sum +
            (double.parse(order['cake']['price'].toString()) *
                order['quantity']);
      });
    });
  }

  Future<void> sendOrder() async {
    final orderProvider = Provider.of<OrderProvider>(context, listen: false);
    final payload = orderProvider.generateOrderPayload();

    try {
      final response = await ApiService().post('admin/order', body: payload);
      Map<String, dynamic> jsonResponse = jsonDecode(response.body);

      if (jsonResponse['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Pesanan berhasil dikirim",
                style: TextStyle(color: Colors.white)),
            backgroundColor: Colors.green,
          ),
        );
        orderProvider.clearOrders();
        _updateTotal();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Gagal mengirim pesanan",
                style: TextStyle(color: Colors.white)),
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

  @override
  Widget build(BuildContext context) {
    final orderProvider = Provider.of<OrderProvider>(context);
    final orders = orderProvider.orders;

    return Scaffold(
      appBar: AppBar(title: Text("Pesanan Saya")),
      body: orders.isEmpty
          ? Center(child: Text("Belum ada pesanan"))
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: orders.length,
                    itemBuilder: (context, index) {
                      return OrderItem(
                        order: orders[index],
                        quantity: orders[index]['quantity'],
                        onQuantityChanged: _updateTotal, // Callback here
                      );
                    },
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border(
                      top: BorderSide(color: Colors.grey.shade300, width: 1),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Total Harga:",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        "Rp ${totalHarga.toStringAsFixed(0)}",
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.green),
                      ),
                    ],
                  ),
                ),
              ],
            ),
      floatingActionButton: orders.isNotEmpty
          ? FloatingActionButton.extended(
              onPressed: sendOrder,
              icon: Icon(Icons.send),
              label:
                  Text("Kirim Pesanan (Rp ${totalHarga.toStringAsFixed(0)})"),
            )
          : null,
    );
  }
}
