import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:cakeshop_ui/api/api_service.dart';
import 'package:cakeshop_ui/layout/appbars.dart';
import 'package:cakeshop_ui/screen/master/kategori/kategori_page.dart';
import 'package:cakeshop_ui/widget/textfield_widget.dart';

class KategoriAdd extends StatefulWidget {
  final Kategori? kategori;

  const KategoriAdd({
    Key? key,
    this.kategori,
  }) : super(key: key);

  @override
  State<KategoriAdd> createState() => _KategoriAddState();
}

class _KategoriAddState extends State<KategoriAdd> {
  final TextEditingController _name = TextEditingController();
  final TextEditingController _slug = TextEditingController();
  final TextEditingController _parent_code = TextEditingController();

  bool _isLoading = false;
  String? _errorMessage;
  bool isAlert = false;

  @override
  void initState() {
    super.initState();
    if (widget.kategori != null) {
      _name.text = widget.kategori!.name;
      _slug.text = widget.kategori!.slug;
      _parent_code.text = widget.kategori!.parentCode;
    }
  }

  Future<void> _addKategori() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final body = {
      'name': _name.text,
      'slug': _slug.text,
      'parent_code': _parent_code.text,
    };

    try {
      var response;
      if (widget.kategori == null) {
        response = await ApiService().post('admin/master/category', body: body);
      } else {
        response = await ApiService()
            .put('admin/master/category/${widget.kategori!.id}', body: body);
      }

      Map<String, dynamic> jsonResponse = jsonDecode(response.body);

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
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Appbars(title: 'Add Kategori'),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.only(top: 20),
          child: Column(
            children: [
              CircleAvatar(
                radius: 50,
                backgroundImage: AssetImage('assets/box1.jpeg'),
              ),
              SizedBox(height: 10),
              Text(
                'Form Add Kategori',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 20),
              TextfieldWidget(
                  label: 'Nama Kategori',
                  controller: _name,
                  isloading: !_isLoading),
              SizedBox(height: 10),
              TextfieldWidget(
                  label: 'Slug Kategori',
                  controller: _slug,
                  isloading: !_isLoading),
              SizedBox(height: 10),
              TextfieldWidget(
                  label: 'Code Kategori',
                  controller: _parent_code,
                  isloading: !_isLoading),
              SizedBox(height: 15),
              Container(
                width: MediaQuery.of(context).size.width - 120,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _addKategori,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.brown,
                    foregroundColor: Colors.white,
                  ),
                  child: _isLoading
                      ? CircularProgressIndicator(color: Colors.white)
                      : const Text('Login'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
