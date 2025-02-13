import 'dart:convert';
import 'package:cakeshop_ui/data/user.dart';
import 'package:cakeshop_ui/screen/login_page.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cakeshop_ui/api/api_service.dart';

class AuthProvider with ChangeNotifier {
  String? _token;
  User? _user;

  String? get token => _token;
  User? get user => _user;
  bool get isLoggedIn => _token != null;

  Future<void> loadUser(BuildContext context) async {
    final response = await ApiService().post("auth/me");
    final Map<String, dynamic> success = jsonDecode(response.body);

    // print('LOAD USER RESPONSE: $success');

    if (success['success']) {
      _user = User.fromJson(success['data']);
      notifyListeners();
    } else {
      logout(context);
    }
  }

  Future<void> logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove("auth_token");
    _token = null;
    _user = null;
    notifyListeners();

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );
  }
}
