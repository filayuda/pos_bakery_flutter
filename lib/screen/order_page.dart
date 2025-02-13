import 'package:cakeshop_ui/data/order_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class OrderPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final orderProvider = Provider.of<OrderProvider>(context);
    final orders = orderProvider.orders;

    return Scaffold(
      body: orders.isEmpty
          ? Center(child: Text("Belum ada pesanan"))
          : ListView.builder(
              itemCount: orders.length,
              itemBuilder: (context, index) {
                final order = orders[index];
                return Card(
                  margin: EdgeInsets.all(10),
                  child: ListTile(
                    leading: Image.asset(order['cake'].imageUrl, width: 50),
                    title: Text(order['cake'].name),
                    subtitle: Text(
                        "Rp ${order['cake'].price} x ${order['quantity']}"),
                    trailing: Text(
                      "Rp ${(double.parse(order['cake'].price) * order['quantity']).toStringAsFixed(0)}",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
