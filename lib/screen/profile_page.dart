import 'package:cakeshop_ui/layout/appbars.dart';
import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Appbars(title: 'Profile Page'),
      body: Center(
        child: Text('Profile Page'),
      ),
    );
  }
}
