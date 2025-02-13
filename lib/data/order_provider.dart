import 'package:flutter/material.dart';
import 'cake.dart';

class OrderProvider with ChangeNotifier {
  List<Map<String, dynamic>> _orders = [];
  List<Map<String, dynamic>> get orders => _orders;

  void addOrder(Cake cake, int quantity) {
    final index =
        _orders.indexWhere((order) => order['cake'].name == cake.name);

    if (index != -1) {
      _orders[index]['quantity'] += quantity;
    } else {
      _orders.add({'cake': cake, 'quantity': quantity});
    }

    notifyListeners();
  }

  int getQuantity(Cake cake) {
    final order = _orders.firstWhere(
      (order) => order['cake'].name == cake.name,
      orElse: () => {'quantity': 0},
    );

    return order['quantity'];
  }

  void updateQuantity(Cake cake, int quantity) {
    final index =
        _orders.indexWhere((order) => order['cake'].name == cake.name);

    if (index != -1) {
      if (quantity > 0) {
        _orders[index]['quantity'] = quantity;
      } else {
        _orders.removeAt(index);
      }
    }

    notifyListeners();
  }
}
