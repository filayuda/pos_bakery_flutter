import 'package:cakeshop_ui/data/auth_provider.dart';
import 'package:cakeshop_ui/favorite_pagetest.dart';
import 'package:cakeshop_ui/home.dart';
import 'package:cakeshop_ui/home_screen.dart';
import 'package:cakeshop_ui/profile_pagetest.dart';
import 'package:cakeshop_ui/screen/login_page.dart';
import 'package:cakeshop_ui/screen/order_page.dart';
import 'package:flutter/material.dart';
import 'package:cakeshop_ui/layout/appbars.dart';
import 'package:cakeshop_ui/data/order_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized(); // Pastikan Flutter sudah siap
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Future<bool> isUserLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey("auth_token"); // Cek apakah token ada
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => OrderProvider()),
        ChangeNotifierProvider(create: (context) => AuthProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(fontFamily: 'Varela'),
        home: FutureBuilder<bool>(
          future: isUserLoggedIn(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              ); // Tampilkan loading saat cek login
            } else {
              return snapshot.data == true ? const Home() : const LoginPage();
            }
          },
        ),
      ),
    );
  }
}

// class HomePage extends StatefulWidget {
//   const HomePage({super.key});

//   @override
//   _HomePageState createState() => _HomePageState();
// }

// class _HomePageState extends State<HomePage> {
//   int _selectedIndex = 0;

//   final List<Widget> _pages = [
//     const HomeScreen(),
//     const FavoritePagetest(),
//     const ProfilePagetest(),
//     OrderPage(),
//   ];

//   void _onItemTapped(int index) {
//     setState(() {
//       _selectedIndex = index;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: Appbars(
//         title: switch (_selectedIndex) {
//           0 => "Home Page",
//           1 => "Favorite Page",
//           2 => "Profile Page",
//           3 => "Order Page",
//           _ => "Home Page",
//         },
//       ),
//       body: IndexedStack(
//         index: _selectedIndex,
//         children: _pages,
//       ),
//       bottomNavigationBar: BottomNavigationBar(
//         type: BottomNavigationBarType.fixed,
//         currentIndex: _selectedIndex,
//         onTap: _onItemTapped,
//         items: const [
//           BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
//           BottomNavigationBarItem(
//               icon: Icon(Icons.favorite), label: "Favorites"),
//           BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
//           BottomNavigationBarItem(
//               icon: Icon(Icons.shopping_bag), label: "Order"),
//         ],
//       ),
//     );
//   }
// }
