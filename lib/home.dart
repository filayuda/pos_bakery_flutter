import 'package:cakeshop_ui/home_screen.dart';
import 'package:cakeshop_ui/layout/appbars.dart';
import 'package:cakeshop_ui/profile_pagetest.dart';
// import 'package:cakeshop_ui/screen/cakery_screen.dart';
import 'package:cakeshop_ui/screen/favorite_page.dart';
import 'package:cakeshop_ui/screen/order_page.dart';
// import 'package:cakeshop_ui/widget/navbar_widget.dart';
import 'package:flutter/material.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const HomeScreen(),
    const FavoritePage(),
    const ProfilePagetest(),
    OrderPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Appbars(
        title: switch (_selectedIndex) {
          0 => "Home Page",
          1 => "Master Page",
          2 => "Profile Page",
          3 => "Order Page",
          _ => "Home Page",
        },
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.favorite), label: "Master"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
          BottomNavigationBarItem(
              icon: Icon(Icons.shopping_bag), label: "Order"),
        ],
      ),
    );
  }
}
