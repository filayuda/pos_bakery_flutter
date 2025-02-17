import 'package:cakeshop_ui/screen/master/kategori/kategori_page.dart';
import 'package:cakeshop_ui/screen/master/menu/menu_page.dart';
import 'package:cakeshop_ui/screen/master/pengguna/pengguna_page.dart';
import 'package:flutter/material.dart';

class FavoritePage extends StatefulWidget {
  /// **Tambahkan callback untuk memberitahu perubahan ke HomeScreen**
  final VoidCallback? onDataChanged;

  const FavoritePage({super.key, this.onDataChanged});

  @override
  State<FavoritePage> createState() => _FavoritePageState();
}

class _FavoritePageState extends State<FavoritePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  /// **Method untuk trigger perubahan data**
  void _triggerDataChange() {
    if (widget.onDataChanged != null) {
      widget.onDataChanged!(); // Panggil callback ke HomeScreen
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Master',
              style: TextStyle(
                fontFamily: 'Varela',
                fontSize: 35,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          TabBar(
            controller: _tabController,
            indicatorColor: Colors.orange,
            labelColor: Colors.orange,
            isScrollable: true,
            labelPadding: const EdgeInsets.symmetric(horizontal: 15),
            unselectedLabelColor: Colors.grey,
            tabs: const [
              Tab(
                key: Key('Kategori'),
                text: 'Kategori',
              ),
              Tab(
                key: Key('Menu'),
                text: 'Menu',
              ),
              Tab(
                key: Key('Pengguna'),
                text: 'Pengguna',
              ),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                KategoriPage(onDataChanged: _triggerDataChange),
                MenuPage(onDataChanged: _triggerDataChange),
                PenggunaPage(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
