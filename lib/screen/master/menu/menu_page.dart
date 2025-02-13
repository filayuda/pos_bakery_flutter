// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';

import 'package:cakeshop_ui/api/api_service.dart';
import 'package:cakeshop_ui/screen/master/kategori/kategori_add.dart';
import 'package:cakeshop_ui/screen/master/menu/menu_add.dart';

Future<List<Menu>> fetchMenu({int perPage = 1000, int page = 1}) async {
  try {
    final response = await ApiService().get(
      "admin/master/menu",
      perPage: perPage,
      page: page,
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse = jsonDecode(response.body);

      if (jsonResponse['success'] == true) {
        final List<dynamic> dataList = jsonResponse['data'] ?? [];
        return dataList.map((item) => Menu.fromJson(item)).toList();
      } else {
        throw Exception(jsonResponse['message'] ?? 'Failed to load categories');
      }
    } else {
      throw Exception(
          'Error: ${response.statusCode} - ${response.reasonPhrase}');
    }
  } catch (e) {
    throw Exception('Failed to fetch categories: $e');
  }
}

class Menu {
  final int id;
  final String name;
  final Decimal price;
  final Decimal discount;
  final String status;
  final List<Map<String, dynamic>> categories;

  const Menu({
    required this.id,
    required this.name,
    required this.price,
    required this.discount,
    required this.status,
    required this.categories,
  });

  factory Menu.fromJson(Map<String, dynamic> json) {
    return Menu(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      price: Decimal.parse(json['price'].toString()),
      discount: Decimal.parse(json['discount'].toString()),
      status: json['status'] ?? '',
      categories: List<Map<String, dynamic>>.from(json['categories'] ?? []),
    );
  }
}

class MenuPage extends StatefulWidget {
  const MenuPage({super.key});

  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  late Future<List<Menu>> futureMenu;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  void fetchData() {
    setState(() {
      _isLoading = true;
    });

    futureMenu = fetchMenu().whenComplete(() {
      setState(() {
        _isLoading = false;
      });
    });
  }

  void refreshKategori() {
    fetchData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: Padding(
        padding: const EdgeInsets.all(15),
        child: FutureBuilder<List<Menu>>(
          future: futureMenu,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(
                  child: Text('Error: ${snapshot.error}',
                      style: TextStyle(color: Colors.red)));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(child: Text('No categories available'));
            } else {
              return Opacity(
                opacity: _isLoading ? 0.5 : 1.0,
                child: AbsorbPointer(
                  absorbing: _isLoading,
                  child: SimpleTable(
                    menuList: snapshot.data!,
                    onMenuAdded: refreshKategori,
                  ),
                ),
              );
            }
          },
        ),
      ),
    );
  }
}

class SimpleTable extends StatelessWidget {
  final List<Menu> menuList;
  final VoidCallback onMenuAdded;
  final bool isLoading;

  const SimpleTable({
    Key? key,
    required this.menuList,
    required this.onMenuAdded,
    this.isLoading = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Container(
              width: 40,
              height: 40,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isLoading ? Colors.grey : Colors.orange,
                borderRadius: BorderRadius.circular(10),
              ),
              child: IconButton(
                iconSize: 20,
                onPressed: () async {
                  final result = await Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => MenuAdd()),
                  );

                  if (result == true) {
                    onMenuAdded();
                  }
                },
                icon: Icon(Icons.add),
                color: Colors.white,
              ),
            )
          ],
        ),
        SizedBox(height: 10),
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minWidth: MediaQuery.of(context).size.width,
                maxWidth: double.infinity,
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: Table(
                  columnWidths: {
                    0: FlexColumnWidth(1.2),
                    1: FlexColumnWidth(2),
                    2: FlexColumnWidth(2),
                    3: FlexColumnWidth(2),
                    4: FlexColumnWidth(2),
                  },
                  border: TableBorder.all(
                    color: Colors.grey,
                    width: 1,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  children: [
                    TableRow(
                      decoration: BoxDecoration(color: Colors.grey[300]),
                      children: [
                        tableCell('Name', isHeader: true),
                        tableCell('Price', isHeader: true),
                        tableCell('Discount', isHeader: true),
                        tableCell('Status', isHeader: true),
                        tableCell('Action', isHeader: true),
                      ],
                    ),
                    ...menuList.map((menu) {
                      return TableRow(
                        children: [
                          tableCell(menu.name),
                          tableCell(menu.price.toString()),
                          tableCell(menu.discount.toString()),
                          tableCell(menu.status),
                          tableCellAction(context, menu),
                        ],
                      );
                    }).toList(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  TableCell tableCell(String text, {bool isHeader = false}) {
    return TableCell(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            text,
            style: TextStyle(
              fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  TableCell tableCellAction(BuildContext context, Menu menu) {
    return TableCell(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            onPressed: () => _viewDetail(context, menu),
            icon: Icon(Icons.details_rounded, color: Colors.blue),
          ),
          IconButton(
            onPressed: () => _editKategori(context, menu),
            icon: Icon(Icons.update, color: Colors.orange),
          ),
          IconButton(
            onPressed: () => _confirmDelete(context, menu.id, menu.name),
            icon: Icon(Icons.delete, color: Colors.red),
          ),
        ],
      ),
    );
  }

  void _viewDetail(BuildContext context, Menu menu) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Detail Kategori"),
        content: Text(
            "ID: ${menu.id}\nNama: ${menu.name}\nPrice: ${menu.price}\nDiscount: ${menu.discount}\nStatus: ${menu.status}"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Tutup"),
          ),
        ],
      ),
    );
  }

  void _editKategori(BuildContext context, Menu menu) async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => MenuAdd(menu: menu),
      ),
    );

    if (result == true) {
      onMenuAdded();
    }
  }

  void _confirmDelete(BuildContext context, int id, String name) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Hapus Menu'),
        content: Text('Apakah Anda yakin ingin menghapus menu $name ? '),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteMenu(id);
            },
            child: Text(
              'Hapus',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  void _deleteMenu(int id) async {
    try {
      final response = await ApiService().delete("admin/master/menu/$id");

      if (response.statusCode == 200) {
        onMenuAdded();
      } else {
        throw Exception('Gagal menghapus menu');
      }
    } catch (e) {
      print("Error deleting category: $e");
    }
  }
}
