// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TextfieldWidget extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final bool isloading;
  final TextInputType? keyboardType;
  final bool obscureText;
  final Widget? suffixIcon;

  const TextfieldWidget({
    Key? key,
    required this.label,
    required this.controller,
    required this.isloading,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.suffixIcon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width - 120,
      height: 40,
      child: TextField(
        obscureText: obscureText,
        keyboardType: keyboardType,
        controller: controller,
        style: TextStyle(fontSize: 18),
        inputFormatters: keyboardType == TextInputType.number
            ? [FilteringTextInputFormatter.digitsOnly]
            : null,
        decoration: InputDecoration(
          border: OutlineInputBorder(),
          labelText: label,
          labelStyle: TextStyle(fontSize: 13),
          isDense: true,
          contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 10),
          suffixIcon: suffixIcon,
        ),
        enabled: isloading,
      ),
    );
  }
}
