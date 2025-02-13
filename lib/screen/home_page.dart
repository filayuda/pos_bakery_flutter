import 'package:cakeshop_ui/layout/appbars.dart';
import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Appbars(title: 'Home Page'),
      body: Center(
        child: Text('Home Page'),
      ),
    );
  }
}
