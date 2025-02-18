import 'package:cakeshop_ui/data/order_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class OrderItem extends StatelessWidget {
  final Map<String, dynamic> order;
  final int quantity;
  final VoidCallback onQuantityChanged;

  OrderItem({
    required this.order,
    required this.quantity,
    required this.onQuantityChanged,
  });

  @override
  Widget build(BuildContext context) {
    final orderProvider = Provider.of<OrderProvider>(context, listen: false);

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
            Text("Rp ${order['cake']['price']} x $quantity"),
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
            IconButton(
              icon: Icon(Icons.remove, color: Colors.red),
              onPressed: () {
                if (quantity > 1) {
                  orderProvider.updateQuantity(order['cake'], quantity - 1);
                  onQuantityChanged(); // Memperbarui total harga
                }
              },
            ),
            Text("$quantity",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            IconButton(
              icon: Icon(Icons.add, color: Colors.green),
              onPressed: () {
                orderProvider.updateQuantity(order['cake'], quantity + 1);
                onQuantityChanged(); // Memperbarui total harga
              },
            ),
            IconButton(
              icon: Icon(Icons.delete, color: Colors.red),
              onPressed: () {
                Provider.of<OrderProvider>(context, listen: false)
                    .updateQuantity(order['cake'], 0);
              },
            ),
          ],
        ),
      ),
    );
  }
}
