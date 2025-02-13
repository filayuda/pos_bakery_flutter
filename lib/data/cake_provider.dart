import 'package:flutter/material.dart';
import 'cake.dart';

class CakeProvider with ChangeNotifier {
  List<Cake> _cakes = listCakes;

  List<Cake> get cakes => _cakes;

  List<Cake> get favoriteCakes =>
      _cakes.where((cake) => cake.isFavorite).toList();

  void toggleFavorite(Cake cake) {
    cake.toggleFavorite();
    notifyListeners();
  }
}
