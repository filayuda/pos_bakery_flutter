import 'package:cakeshop_ui/home_screen.dart';
import 'package:cakeshop_ui/layout/appbars.dart';
import 'package:cakeshop_ui/screen/favorite_page.dart';
import 'package:cakeshop_ui/screen/order_page.dart';
import 'package:cakeshop_ui/profile_pagetest.dart';
import 'package:flutter/material.dart';

/// Notifier untuk mendeteksi perubahan data dari FavoritePage
final ValueNotifier<bool> refreshHomeNotifier = ValueNotifier(false);

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int _selectedIndex = 0;

  /// **Gunakan Stateful Widgets untuk memastikan rebuild saat data berubah**
  final List<Widget> _pages = [
    HomeScreen(), // HomeScreen akan mendengarkan perubahan data
    FavoritePage(onDataChanged: () {
      refreshHomeNotifier.value = true; // Trigger refresh
    }),
    ProfilePagetest(),
    OrderPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  String getAppBarTitle(int index) {
    switch (index) {
      case 0:
        return "Home Page";
      case 1:
        return "Master Page";
      case 2:
        return "Pembayaran Page";
      case 3:
        return "Order Page";
      default:
        return "Home Page";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Appbars(title: getAppBarTitle(_selectedIndex)),
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.orange,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.shopping_bag_rounded), label: "Products"),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: "Master"),
          BottomNavigationBarItem(
              icon: Icon(Icons.person), label: "Pembayaran"),
          BottomNavigationBarItem(
              icon: Icon(Icons.shopping_bag), label: "Order"),
        ],
      ),
    );
  }
}
