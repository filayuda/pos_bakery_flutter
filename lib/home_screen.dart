import 'dart:convert';
import 'package:cakeshop_ui/api/api_service.dart';
import 'package:flutter/material.dart';
import 'package:cakeshop_ui/screen/cakery_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeState();
}

class _HomeState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  TabController? _tabController;
  List<Map<String, dynamic>> _listKategori = [];
  Map<int, List<Map<String, dynamic>>> _menuByCategory = {};

  @override
  void initState() {
    super.initState();
    fetchListKategori();
  }

  void fetchListKategori() async {
    try {
      List<Map<String, dynamic>> listKategori = await fetchKategori();
      setState(() {
        _listKategori = listKategori;
        _tabController?.dispose();
        _tabController =
            TabController(length: _listKategori.length, vsync: this);
      });

      for (var kategori in _listKategori) {
        fetchMenuByCategory(kategori['id']);
      }
    } catch (e) {
      print('Error fetching categories: $e');
    }
  }

  Future<void> fetchMenuByCategory(int categoryId) async {
    try {
      List<Map<String, dynamic>> menuList = await fetchMenu(categoryId);
      print('fetchMenuByCategory : $menuList');
      setState(() {
        _menuByCategory[categoryId] = menuList;
      });
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
      body: _tabController == null
          ? const Center(child: CircularProgressIndicator())
          : Column(
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
                TabBar(
                  controller: _tabController,
                  indicatorColor: Colors.transparent,
                  labelColor: Colors.orange,
                  isScrollable: true,
                  labelPadding: const EdgeInsets.symmetric(horizontal: 10),
                  unselectedLabelColor: Colors.grey,
                  tabs: _listKategori.map((kategori) {
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
                  child: TabBarView(
                    controller: _tabController,
                    children: _listKategori.map((kategori) {
                      int categoryId = kategori['id'];
                      List<Map<String, dynamic>> menuList =
                          _menuByCategory[categoryId] ?? [];
                      return CakeryScreen(subMenuList: menuList);
                    }).toList(),
                  ),
                ),
              ],
            ),
    );
  }
}

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
