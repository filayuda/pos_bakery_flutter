import 'dart:convert';
import 'package:cakeshop_ui/api/api_service.dart';
import 'package:flutter/material.dart';
import 'package:cakeshop_ui/screen/cakery_screen.dart';
import 'package:cakeshop_ui/home.dart'; // Untuk refreshHomeNotifier

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeState();
}

class _HomeState extends State<HomeScreen> with TickerProviderStateMixin {
  late Future<List<Map<String, dynamic>>> _futureKategori;
  TabController? _tabController;
  Map<int, List<Map<String, dynamic>>> _menuByCategory = {};
  List<Map<String, dynamic>> _kategoriList = [];

  @override
  void initState() {
    super.initState();
    _loadData(); // Load pertama kali

    /// **Tambahkan listener untuk merespon perubahan dari FavoritePage**
    refreshHomeNotifier.addListener(() {
      if (refreshHomeNotifier.value) {
        _loadData(); // Reload data
        refreshHomeNotifier.value = false; // Reset notifier
      }
    });
  }

  void _loadData() {
    _futureKategori = fetchListKategori();
    _futureKategori.then((kategoriList) {
      if (mounted) {
        setState(() {
          _kategoriList = kategoriList;

          // **Pastikan untuk me-reset TabController sebelum membuat yang baru**
          _tabController?.dispose();
          _tabController =
              TabController(length: kategoriList.length, vsync: this);
        });

        // **Ambil menu berdasarkan kategori**
        for (var kategori in kategoriList) {
          fetchMenuByCategory(kategori['id']);
        }
      }
    });
  }

  Future<List<Map<String, dynamic>>> fetchListKategori() async {
    try {
      return await fetchKategori();
    } catch (e) {
      print('Error fetching categories: $e');
      return [];
    }
  }

  Future<void> fetchMenuByCategory(int categoryId) async {
    try {
      List<Map<String, dynamic>> menuList = await fetchMenu(categoryId);
      if (mounted) {
        setState(() {
          _menuByCategory[categoryId] = menuList;
        });
      }
    } catch (e) {
      print('Error fetching menu: $e');
    }
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _futureKategori,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("Tidak ada kategori tersedia."));
          }

          return Column(
            children: [
              const Padding(
                padding: EdgeInsets.only(left: 20, top: 20),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Menu',
                    style: TextStyle(
                      fontFamily: 'Varela',
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              if (_tabController != null)
                TabBar(
                  controller: _tabController,
                  indicatorColor: Colors.transparent,
                  labelColor: Colors.orange,
                  isScrollable: true,
                  labelPadding: const EdgeInsets.symmetric(horizontal: 10),
                  unselectedLabelColor: Colors.grey,
                  tabs: _kategoriList.map((kategori) {
                    return Tab(
                      key: Key('tab_${kategori['id']}'),
                      child: Text(
                        kategori['name'],
                        style:
                            const TextStyle(fontFamily: 'Varela', fontSize: 21),
                      ),
                    );
                  }).toList(),
                ),
              Expanded(
                child: _tabController == null
                    ? const Center(child: CircularProgressIndicator())
                    : TabBarView(
                        controller: _tabController,
                        children: _kategoriList.map((kategori) {
                          int categoryId = kategori['id'];
                          List<Map<String, dynamic>> menuList =
                              _menuByCategory[categoryId] ?? [];
                          return CakeryScreen(subMenuList: menuList);
                        }).toList(),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// **🔥 Kode API yang Diperbaiki**
Future<List<Map<String, dynamic>>> fetchKategori(
    {int perPage = 1000, int page = 1}) async {
  try {
    final response = await ApiService().get(
      "admin/master/category",
      perPage: perPage,
      page: page,
    );
    final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
    final List<dynamic> res = jsonResponse['data'] ?? [];

    if (jsonResponse['success']) {
      return res
          .map((item) => {"id": item['id'], "name": item['name'].toString()})
          .toList();
    } else {
      throw Exception(
          'Error: ${response.statusCode} - ${response.reasonPhrase}');
    }
  } catch (e) {
    throw Exception('Failed to fetch categories: $e');
  }
}

Future<List<Map<String, dynamic>>> fetchMenu(int categoryId,
    {int perPage = 1000, int page = 1}) async {
  try {
    final response = await ApiService().get("admin/daftar-menu/$categoryId");
    final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
    final List<dynamic> res = jsonResponse['data'] ?? [];

    if (jsonResponse['success']) {
      return res.map((item) => Map<String, dynamic>.from(item)).toList();
    } else {
      throw Exception(
          'Error: ${response.statusCode} - ${response.reasonPhrase}');
    }
  } catch (e) {
    throw Exception('Failed to fetch menu: $e');
  }
}
