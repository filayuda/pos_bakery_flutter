import 'package:cakeshop_ui/screen/cakery_screen.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeState();
}

class _HomeState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  TabController? _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
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
            tabs: [
              Tab(
                key: Key('cake'),
                child: Text(
                  'Cake',
                  style: TextStyle(
                    fontFamily: 'Varela',
                    fontSize: 21,
                  ),
                ),
              ),
              Tab(
                key: Key('bakery'),
                child: Text(
                  'Bakery',
                  style: TextStyle(
                    fontFamily: 'Varela',
                    fontSize: 21,
                  ),
                ),
              ),
              Tab(
                key: Key('ice'),
                child: Text(
                  'Ice Cream',
                  style: TextStyle(
                    fontFamily: 'Varela',
                    fontSize: 21,
                  ),
                ),
              ),
              Tab(
                key: Key('favorite'),
                child: Text(
                  'Favorite',
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
                CakeryScreen(subMenu: 'cake'),
                CakeryScreen(subMenu: 'bakery'),
                CakeryScreen(subMenu: 'ice'),
                CakeryScreen(isFavorite: 'true'),
              ],
            ),
          )
        ],
      ),
    );
  }
}
