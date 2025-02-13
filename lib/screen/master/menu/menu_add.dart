// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';
import 'dart:io';
import 'package:cakeshop_ui/api/api_service.dart';
import 'package:cakeshop_ui/layout/appbars.dart';
import 'package:cakeshop_ui/widget/textfield_widget.dart';
import 'package:flutter/material.dart';
import 'package:cakeshop_ui/screen/master/menu/menu_page.dart';
import 'package:image_picker/image_picker.dart';

class MenuAdd extends StatefulWidget {
  final Menu? menu;

  const MenuAdd({
    Key? key,
    this.menu,
  }) : super(key: key);

  @override
  State<MenuAdd> createState() => _MenuAddState();
}

class _MenuAddState extends State<MenuAdd> {
  final TextEditingController _name = TextEditingController();
  final TextEditingController _description = TextEditingController();
  final TextEditingController _price = TextEditingController();
  final TextEditingController _discount = TextEditingController();
  final TextEditingController _thumbnail = TextEditingController();
  // final TextEditingController _status = TextEditingController();

  bool _isLoading = false;
  String? _errorMessage;
  List<dynamic> _categories = [];
  String? _selectedCategory;
  final List<String> statusList = ['active', 'inactive'];
  String _selectedStatus = 'active';

  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _fetchCategories().then((_) {
      if (widget.menu != null && widget.menu!.categories.isNotEmpty) {
        setState(() {
          _selectedCategory = widget.menu!.categories.first['id'].toString();
        });
      }
    });

    if (widget.menu != null) {
      _name.text = widget.menu!.name;
      _price.text = widget.menu!.price.toString();
      _discount.text = widget.menu!.discount.toString();
      _selectedStatus = widget.menu!.status;
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _fetchCategories() async {
    try {
      var response = await ApiService().get('admin/master/category');
      // print(response.body); // Debugging output
      Map<String, dynamic> jsonResponse = jsonDecode(response.body);
      if (jsonResponse.containsKey('data') && jsonResponse['data'] is List) {
        setState(() {
          _categories = jsonResponse['data'];
          if (_categories.isNotEmpty) {
            _selectedCategory = _categories.first['id'].toString();
          }
        });
      } else {
        throw Exception("Invalid API response format");
      }
    } catch (e) {
      setState(() {
        _errorMessage = "Gagal mengambil data kategori: $e";
      });
    }
  }

  Future<void> _addMenu() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final body = {
      'name': _name.text,
      'description': _description.text,
      'price': _price.text,
      'discount': _discount.text,
      'category_ids[]': _selectedCategory ?? '',
      'status': _selectedStatus,
    };

    try {
      var response;
      if (widget.menu == null) {
        response = await ApiService().uploadMultipart(
          'admin/master/menu',
          fields: body,
          imageFile: _selectedImage,
        );
      } else {
        response = await ApiService().uploadMultipart(
          'admin/master/menu/${widget.menu!.id}',
          fields: body,
          imageFile: _selectedImage,
        );
      }

      var responseBody = await response.stream.bytesToString();
      var jsonResponse = jsonDecode(responseBody);
      print('Response: $jsonResponse');

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
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Appbars(title: 'Add menu'),
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
                'Form Add menu',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 20),
              TextfieldWidget(
                  label: 'Nama', controller: _name, isloading: !_isLoading),
              SizedBox(height: 10),
              TextfieldWidget(
                  label: 'Description',
                  controller: _description,
                  isloading: !_isLoading),
              SizedBox(height: 10),
              TextfieldWidget(
                label: 'Price',
                controller: _price,
                isloading: !_isLoading,
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 15),
              TextfieldWidget(
                label: 'Discount',
                controller: _discount,
                isloading: !_isLoading,
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 15),
              Container(
                width: MediaQuery.of(context).size.width - 120,
                height: 40,
                child: DropdownButtonFormField<String>(
                  value: _selectedCategory,
                  items: [
                    DropdownMenuItem(
                      value: null,
                      child: Text('Choose Category',
                          style: TextStyle(color: Colors.grey)),
                    ),
                    ..._categories.map((category) {
                      return DropdownMenuItem(
                        value: category['id'].toString(),
                        child: Text(category['name']),
                      );
                    }).toList(),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedCategory = value;
                    });
                  },
                  decoration: InputDecoration(
                    labelText: 'Category',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 10),
                  ),
                ),
              ),
              SizedBox(height: 15),
              Container(
                width: MediaQuery.of(context).size.width - 120,
                height: 40,
                child: DropdownButtonFormField<String>(
                  value: _selectedStatus,
                  items: statusList.map((status) {
                    return DropdownMenuItem(
                      value: status,
                      child: Text(status.toUpperCase()),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedStatus = value!;
                    });
                  },
                  decoration: InputDecoration(
                    labelText: 'Status',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 10),
                  ),
                ),
              ),
              SizedBox(height: 15),
              Container(
                width: MediaQuery.of(context).size.width - 120,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _addMenu,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.brown,
                    foregroundColor: Colors.white,
                  ),
                  child: _isLoading
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
