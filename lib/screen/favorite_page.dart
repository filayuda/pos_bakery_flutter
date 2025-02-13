import 'package:cakeshop_ui/screen/master/kategori/kategori_page.dart';
import 'package:cakeshop_ui/screen/master/menu/menu_page.dart';
import 'package:cakeshop_ui/screen/master/pengguna/pengguna_page.dart';
import 'package:flutter/material.dart';

class FavoritePage extends StatefulWidget {
  const FavoritePage({super.key});

  @override
  State<FavoritePage> createState() => _FavoritePageState();
}

class _FavoritePageState extends State<FavoritePage>
    with SingleTickerProviderStateMixin {
  TabController? _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        padding: EdgeInsets.all(10),
        children: [
          Text(
            'Master',
            style: TextStyle(
              fontFamily: 'Varela',
              fontSize: 35,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 10),
          TabBar(
            controller: _tabController,
            indicatorColor: Colors.transparent,
            labelColor: Colors.orange,
            isScrollable: true,
            labelPadding: EdgeInsets.only(right: 25),
            unselectedLabelColor: Colors.grey,
            tabs: [
              Tab(
                key: Key('Kategori'),
                child: Text(
                  'Kategori',
                  style: TextStyle(
                    fontFamily: 'Varela',
                    fontSize: 21,
                  ),
                ),
              ),
              Tab(
                key: Key('Menu'),
                child: Text(
                  'Menu',
                  style: TextStyle(
                    fontFamily: 'Varela',
                    fontSize: 21,
                  ),
                ),
              ),
              Tab(
                key: Key('Pengguna'),
                child: Text(
                  'Pengguna',
                  style: TextStyle(
                    fontFamily: 'Varela',
                    fontSize: 21,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height - 50,
            width: double.infinity,
            child: TabBarView(
              controller: _tabController,
              children: [
                KategoriPage(),
                MenuPage(),
                PenggunaPage(),
              ],
            ),
          )
        ],
      ),
    );
  }
}
