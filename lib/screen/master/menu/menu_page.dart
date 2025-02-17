import 'dart:convert';
import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';

import 'package:cakeshop_ui/api/api_service.dart';
import 'package:cakeshop_ui/screen/master/menu/menu_add.dart';

Future<List<Menu>> fetchMenu({int perPage = 1000, int page = 1}) async {
  try {
    final response = await ApiService()
        .get("admin/master/menu", perPage: perPage, page: page);

    if (response.statusCode == 200 && response.body.isNotEmpty) {
      final Map<String, dynamic> jsonResponse = jsonDecode(response.body);

      if (jsonResponse['success'] == true) {
        final List<dynamic> dataList = jsonResponse['data'] ?? [];
        return dataList.map((item) => Menu.fromJson(item)).toList();
      } else {
        throw Exception(jsonResponse['message'] ?? 'Failed to load menus');
      }
    } else {
      throw Exception(
          'Error: ${response.statusCode} - ${response.reasonPhrase}');
    }
  } catch (e) {
    throw Exception('Failed to fetch menus: $e');
  }
}

class Menu {
  final int id;
  final String name;
  final Decimal price;
  final Decimal discount;
  final String status;
  final List<dynamic> categories;

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
      categories: json['categories'] ?? [],
    );
  }
}

class MenuPage extends StatefulWidget {
  final VoidCallback onDataChanged;

  const MenuPage({super.key, required this.onDataChanged});

  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  late Future<List<Menu>> futureMenu;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  void fetchData() {
    setState(() => _isLoading = true);
    futureMenu =
        fetchMenu().whenComplete(() => setState(() => _isLoading = false));
  }

  void refreshMenu() {
    fetchData();
    widget.onDataChanged(); // Panggil callback ke parent
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(15),
        child: FutureBuilder<List<Menu>>(
          future: futureMenu,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(
                child: Text('Error: ${snapshot.error}',
                    style: const TextStyle(color: Colors.red)),
              );
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('No menus available'));
            } else {
              return Opacity(
                opacity: _isLoading ? 0.5 : 1.0,
                child: AbsorbPointer(
                  absorbing: _isLoading,
                  child: MenuList(
                      menuList: snapshot.data!, onMenuChanged: refreshMenu),
                ),
              );
            }
          },
        ),
      ),
    );
  }
}

class MenuList extends StatelessWidget {
  final List<Menu> menuList;
  final VoidCallback onMenuChanged;

  const MenuList({
    Key? key,
    required this.menuList,
    required this.onMenuChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Align(
          alignment: Alignment.centerRight,
          child: ElevatedButton(
            onPressed: () async {
              final result = await Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const MenuAdd()),
              );
              if (result == true) onMenuChanged();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Icon(Icons.add, color: Colors.white),
          ),
        ),
        const SizedBox(height: 10),
        Expanded(
          child: ListView.builder(
            itemCount: menuList.length,
            itemBuilder: (context, index) {
              final menu = menuList[index];
              return Card(
                elevation: 2,
                margin: const EdgeInsets.symmetric(vertical: 5),
                child: ListTile(
                  title: Text(menu.name,
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold)),
                  subtitle: Text(
                      "Price: ${menu.price} | Discount: ${menu.discount} | Status: ${menu.status}"),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.details_rounded,
                            color: Colors.blue),
                        onPressed: () => _viewDetail(context, menu),
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.orange),
                        onPressed: () => _editMenu(context, menu),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () =>
                            _confirmDelete(context, menu.id, menu.name),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  void _viewDetail(BuildContext context, Menu menu) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Detail Menu"),
        content: Text(
          "ID: ${menu.id}\nNama: ${menu.name}\nPrice: ${menu.price}\nDiscount: ${menu.discount}\nStatus: ${menu.status}",
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Tutup")),
        ],
      ),
    );
  }

  void _editMenu(BuildContext context, Menu menu) async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => MenuAdd(menu: menu)),
    );
    if (result == true) onMenuChanged();
  }

  void _confirmDelete(BuildContext context, int id, String name) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Menu'),
        content: Text('Apakah Anda yakin ingin menghapus menu $name?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal')),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteMenu(id);
            },
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _deleteMenu(int id) async {
    try {
      final response = await ApiService().delete("admin/master/menu/$id");
      if (response.statusCode == 200) onMenuChanged();
    } catch (e) {
      print("Error deleting menu: $e");
    }
  }
}
