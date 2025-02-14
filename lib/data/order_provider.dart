import 'package:flutter/material.dart';

class OrderProvider with ChangeNotifier {
  List<Map<String, dynamic>> _orders = [];
  List<Map<String, dynamic>> get orders => _orders;

  void addOrder(Map<String, dynamic> cake, int quantity) {
    final index =
        _orders.indexWhere((order) => order['cake']['id'] == cake['id']);

    if (index != -1) {
      _orders[index]['quantity'] += quantity;
    } else {
      _orders.add({'cake': cake, 'quantity': quantity});
    }

    notifyListeners();
  }

  int getQuantity(Map<String, dynamic> cake) {
    final order = _orders.firstWhere(
      (order) => order['cake']['id'] == cake['id'],
      orElse: () => {'quantity': 0},
    );

    return order['quantity'];
  }

  void updateQuantity(Map<String, dynamic> cake, int quantity) {
    final index =
        _orders.indexWhere((order) => order['cake']['id'] == cake['id']);

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
