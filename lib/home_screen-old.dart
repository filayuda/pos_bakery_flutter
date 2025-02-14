// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:cakeshop_ui/api/api_service.dart';
import 'package:flutter/material.dart';

import 'package:cakeshop_ui/screen/cakery_screen.dart';

Future<List<String>> fetchKategori({int perPage = 1000, int page = 1}) async {
  try {
    final response = await ApiService().get(
      "admin/master/category",
      perPage: perPage,
      page: page,
    );
    final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
    final res = jsonResponse['data'];

    if (jsonResponse['success']) {
      final List<dynamic> dataList = res ?? [];
      List<String> categoryNames =
          dataList.map((item) => item['name'].toString()).toList();
      // var sum = categoryNames.length;

      return categoryNames;
    } else {
      throw Exception(
          'Error: ${response.statusCode} - ${response.reasonPhrase}');
    }
  } catch (e) {
    throw Exception('Failed to fetch categories: $e');
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeState();
}

class _HomeState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  TabController? _tabController;
  int _tabLength = 1;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    fetchListKategori();
  }

  void fetchListKategori() async {
    List<String> listKategori = await fetchKategori();
    int sumKategori = listKategori.length;

    // print('listKategori, $listKategori');

    setState(() {
      _tabLength = sumKategori;
      _tabController = TabController(length: _tabLength, vsync: this);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        padding: EdgeInsets.only(left: 20),
        children: [
          Text(
            'Menu',
            style: TextStyle(
              fontFamily: 'Varela',
              fontSize: 30,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(
            height: 10,
          ),
          TabBar(
            controller: _tabController,
            indicatorColor: Colors.transparent,
            labelColor: Colors.orange,
            isScrollable: true,
            labelPadding: EdgeInsets.only(right: 25),
            unselectedLabelColor: Colors.grey,
            tabs: List.generate(
              _tabLength,
              (index) => Tab(
                key: Key('tab_$index'),
                child: Text(
                  'Tab $index',
                  style: TextStyle(fontFamily: 'Varela', fontSize: 21),
                ),
              ),
            ),
            // tabs: [
            //   Tab(
            //     key: Key('cake'),
            //     child: Text(
            //       'Cake',
            //       style: TextStyle(
            //         fontFamily: 'Varela',
            //         fontSize: 21,
            //       ),
            //     ),
            //   ),
            //   Tab(
            //     key: Key('bakery'),
            //     child: Text(
            //       'Bakery',
            //       style: TextStyle(
            //         fontFamily: 'Varela',
            //         fontSize: 21,
            //       ),
            //     ),
            //   ),
            //   Tab(
            //     key: Key('ice'),
            //     child: Text(
            //       'Ice Cream',
            //       style: TextStyle(
            //         fontFamily: 'Varela',
            //         fontSize: 21,
            //       ),
            //     ),
            //   ),
            //   Tab(
            //     key: Key('favorite'),
            //     child: Text(
            //       'Favorite',
            //       style: TextStyle(
            //         fontFamily: 'Varela',
            //         fontSize: 21,
            //       ),
            //     ),
            //   ),
            // ],
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height - 50,
            width: double.infinity,
            // child: TabBarView(
            //   controller: _tabController,
            //   children: [
            //     CakeryScreen(subMenu: 'cake'),
            //     CakeryScreen(subMenu: 'bakery'),
            //     CakeryScreen(subMenu: 'ice'),
            //     CakeryScreen(isFavorite: 'true'),
            //   ],
            // ),
            child: TabBarView(
              controller: _tabController,
              children: List.generate(
                _tabLength,
                (index) => CakeryScreen(subMenu: 'tab_$index'),
              ),
            ),
          )
        ],
      ),
    );
  }
}
