import 'package:flutter/material.dart';
import 'package:flutter_launch/flutter_launch.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:cakeshop_ui/widget/navbar_widget.dart';

class CakeryDetail extends StatelessWidget {
  final String assetPath;
  final String cookiePrice;
  final String cookieName;

  const CakeryDetail({
    super.key,
    required this.assetPath,
    required this.cookiePrice,
    required this.cookieName,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: Icon(
            Icons.arrow_back,
            color: Colors.grey,
          ),
        ),
        title: Text(
          'Pilihan',
          style: TextStyle(
            color: Colors.grey,
            fontFamily: 'Varela',
            fontSize: 20,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: Icon(
              Icons.notifications_none,
              color: Colors.grey,
            ),
          ),
        ],
      ),
      body: ListView(
        children: [
          SizedBox(
            height: 15,
          ),
          Padding(
            padding: EdgeInsets.only(left: 20),
            child: Text(
              'Kue',
              style: TextStyle(
                fontFamily: 'Varela',
                fontSize: 42,
                color: Colors.orange,
              ),
            ),
          ),
          SizedBox(
            height: 15,
          ),
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: 20,
            ),
            child: Hero(
              tag: assetPath,
              child: Container(
                height: 300,
                width: 200,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  image: DecorationImage(
                    image: AssetImage(assetPath),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: 20),
          Center(
            child: Text(
              'Rp $cookiePrice',
              style: TextStyle(
                fontFamily: 'Varela',
                fontSize: 22,
                color: Colors.orange,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(height: 15),
          Center(
            child: Text(
              cookieName,
              style: TextStyle(
                fontFamily: 'Varela',
                fontSize: 24,
                color: Colors.black,
              ),
            ),
          ),
          SizedBox(height: 20),
          Center(
            child: SizedBox(
              width: MediaQuery.of(context).size.width - 50,
              child: Text(
                'Bolu atau kue bolu adalah kue berbahan dasar tepung, gula, dan telur. Kue bolu dan ksajda sadsj jsajdasd ajsdw wdsi aiwjiad ijaisd jiasjd kkwa',
                maxLines: 4,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Varela',
                  fontSize: 16,
                  color: Colors.amber,
                ),
              ),
            ),
          ),
          SizedBox(height: 20),
          Center(
            child: Container(
              width: MediaQuery.of(context).size.width - 100,
              height: 50,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(25),
                color: Colors.orange,
              ),
              child: Center(
                child: InkWell(
                  onTap: () async {
                    await FlutterLaunch.launchWhatsapp(
                        phone: '6289601621991',
                        message: 'Halo kak, saya ingin pesan kue $cookieName');
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        FontAwesomeIcons.whatsapp,
                        size: 30,
                        color: Colors.green,
                      ),
                      SizedBox(width: 10),
                      Text(
                        'Pesan Via Whatsapp',
                        style: TextStyle(
                          fontFamily: 'Varela',
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          )
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: const Color.fromARGB(220, 230, 113, 4),
        shape: const CircleBorder(
          side: BorderSide(
            color: Color.fromARGB(255, 211, 108, 13),
            width: 2,
          ),
        ),
        child: Icon(Icons.fastfood),
      ),
      bottomNavigationBar: NavbarWidget(),
    );
  }
}
