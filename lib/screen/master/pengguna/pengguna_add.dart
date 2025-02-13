// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:cakeshop_ui/api/api_service.dart';
import 'package:cakeshop_ui/layout/appbars.dart';
import 'package:cakeshop_ui/screen/master/pengguna/pengguna_page.dart';
import 'package:cakeshop_ui/widget/textfield_widget.dart';

class PenggunaAdd extends StatefulWidget {
  final Pengguna? pengguna;

  const PenggunaAdd({
    Key? key,
    this.pengguna,
  }) : super(key: key);

  @override
  State<PenggunaAdd> createState() => _PenggunaAddState();
}

class _PenggunaAddState extends State<PenggunaAdd> {
  TextEditingController _name = TextEditingController();
  TextEditingController _username = TextEditingController();
  TextEditingController _password = TextEditingController();
  bool isloading = false;
  List<dynamic> _role = [];
  String? _selectedRole;
  bool _isPasswordVisible = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    fetchPengguna().then((_) {
      if (widget.pengguna != null) {
        setState(() {
          _selectedRole = widget.pengguna!.role_id.toString();
        });
      }
    });

    if (widget.pengguna != null) {
      _name.text = widget.pengguna!.name ?? '';
      _username.text = widget.pengguna!.username ?? '';
      _password.text = widget.pengguna!.password ?? '';
    }
  }

  Future<void> fetchPengguna() async {
    try {
      var response = await ApiService().get('admin/master/role/all');

      Map<String, dynamic> jsonResponse = jsonDecode(response.body);
      if (jsonResponse.containsKey('data') && jsonResponse['data'] is List) {
        setState(() {
          _role = jsonResponse['data'];
          if (_role.isNotEmpty) {
            _selectedRole = _role.first['id'].toString();
          }
        });
      } else {
        throw Exception("Invalid API response format");
      }
    } catch (e) {
      setState(() {
        _errorMessage = "Gagal mengambil data Pengguna: $e";
      });
    }
  }

  Future<void> _addPengguna() async {
    setState(() {
      isloading = true;
      _errorMessage = null;
    });

    final body;
    if (widget.pengguna != null) {
      body = {
        'name': _name.text,
        'username': _username.text,
        'role_id': _selectedRole,
      };
    } else {
      body = {
        'name': _name.text,
        'username': _username.text,
        'role_id': _selectedRole,
        'password': _password.text,
      };
    }

    try {
      var response;
      if (widget.pengguna != null) {
        response = await ApiService()
            .put('admin/user/${widget.pengguna!.id}', body: body);
      } else {
        response = await ApiService().post('admin/user', body: body);
      }
      var jsonResponse = jsonDecode(response.body);

      if (jsonResponse['success']) {
        Navigator.of(context).pop(true);
      } else {
        setState(() {
          _errorMessage = jsonResponse['message'] ?? "Terjadi kesalahan";
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = "Gagal menyimpan data: $e";
      });
    } finally {
      setState(() {
        isloading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Appbars(title: 'Pengguna Add'),
      body: Center(
        child: Padding(
          padding: EdgeInsets.only(top: 20),
          child: Column(
            children: [
              CircleAvatar(
                radius: 50,
                backgroundImage: AssetImage('assets/box1.jpeg'),
              ),
              SizedBox(height: 10),
              Text(
                'Form Add Pengguna',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 20),
              TextfieldWidget(
                label: 'Name',
                controller: _name,
                isloading: !isloading,
              ),
              SizedBox(height: 10),
              TextfieldWidget(
                label: 'Username',
                controller: _username,
                isloading: !isloading,
              ),
              SizedBox(height: 10),
              Container(
                width: MediaQuery.of(context).size.width - 120,
                height: 40,
                child: DropdownButtonFormField<String>(
                  value: _selectedRole,
                  items: [
                    DropdownMenuItem(
                      value: null,
                      child: Text(
                        'Pilih Role',
                        style: TextStyle(
                          color: Colors.grey,
                        ),
                      ),
                    ),
                    ..._role.map((roles) {
                      return DropdownMenuItem(
                        value: roles['id'].toString(),
                        child: Text(roles['name']),
                      );
                    }).toList(),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedRole = value;
                    });
                  },
                  decoration: InputDecoration(
                    labelText: 'Pengguna',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 10),
                  ),
                ),
              ),
              SizedBox(height: 10),
              widget.pengguna == null
                  ? TextfieldWidget(
                      label: 'Password',
                      controller: _password,
                      isloading: !isloading,
                      obscureText: !_isPasswordVisible,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isPasswordVisible
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ),
                        onPressed: () {
                          setState(() {
                            _isPasswordVisible = !_isPasswordVisible;
                          });
                        },
                      ),
                    )
                  : SizedBox.shrink(),
              SizedBox(height: 15),
              Container(
                width: MediaQuery.of(context).size.width - 120,
                child: ElevatedButton(
                  onPressed: isloading ? null : _addPengguna,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.brown,
                    foregroundColor: Colors.white,
                  ),
                  child: isloading
                      ? CircularProgressIndicator(color: Colors.white)
                      : const Text('Submit'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
