import 'package:flutter/material.dart';
import 'package:cakeshop_ui/data/cake.dart';
import 'package:cakeshop_ui/screen/cakery_detail.dart';
import 'package:cakeshop_ui/data/order_provider.dart';
import 'package:provider/provider.dart';

class CakeryScreen extends StatelessWidget {
  final String subMenu;
  final String isFavorite;

  const CakeryScreen({
    super.key,
    this.subMenu = '',
    this.isFavorite = '',
  });

  @override
  Widget build(BuildContext context) {
    List<Cake> filteredCakes = isFavorite == 'true'
        ? listCakes.where((cake) => cake.isFavorite == true).toList()
        : listCakes.where((cake) => cake.subMenu == subMenu).toList();

    // final orderProvider = Provider.of<OrderProvider>(context);
    // int quantity = orderProvider.getQuantity(cake);

    return Scaffold(
      backgroundColor: Colors.white,
      body: ListView(
        children: [
          SizedBox(height: 15),
          SizedBox(
            width: MediaQuery.of(context).size.width - 40,
            height: MediaQuery.of(context).size.height - 50,
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 15,
                  childAspectRatio: 0.8),
              itemBuilder: (context, index) {
                return CakeCard(cake: filteredCakes[index]);
              },
              itemCount: filteredCakes.length,
            ),
          ),
          SizedBox(height: 15),
        ],
      ),
    );
  }
}

//cara menggunakan satestate
class CakeCard extends StatefulWidget {
  final Cake cake;

  const CakeCard({super.key, required this.cake});

  @override
  _CakeCardState createState() => _CakeCardState();
}

class _CakeCardState extends State<CakeCard> {
  int quantity = 0;

  @override
  Widget build(BuildContext context) {
    final orderProvider = Provider.of<OrderProvider>(context);

    return Padding(
      padding: EdgeInsets.all(5),
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(MaterialPageRoute(builder: (context) {
            return CakeryDetail(
              assetPath: widget.cake.imageUrl,
              cookiePrice: widget.cake.price,
              cookieName: widget.cake.name,
            );
          }));
        },
        child: Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 3,
                  blurRadius: 5,
                )
              ]),
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.all(5),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    widget.cake.isFavorite
                        ? Icon(Icons.favorite, color: Colors.orange)
                        : Icon(Icons.favorite_border, color: Colors.orange),
                  ],
                ),
              ),
              Hero(
                tag: widget.cake.imageUrl,
                child: Container(
                  height: MediaQuery.of(context).size.height * 0.2,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      image: DecorationImage(
                        image: AssetImage(widget.cake.imageUrl),
                        fit: BoxFit.contain,
                      )),
                ),
              ),
              SizedBox(height: 7),
              Text(
                'Rp ${widget.cake.price}',
                style: TextStyle(
                  color: Colors.orange,
                  fontFamily: 'Varela',
                  fontSize: 14,
                ),
              ),
              Text(
                widget.cake.name,
                style: TextStyle(
                  color: Color.fromARGB(255, 53, 53, 53),
                  fontFamily: 'Varela',
                  fontSize: 14,
                ),
              ),
              Padding(
                padding: EdgeInsets.all(8.0),
                child: Container(height: 1, color: Colors.grey),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 5),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.shopping_basket,
                          color: Colors.orange,
                          size: 16,
                        ),
                        SizedBox(width: 6),
                        Text(
                          'Beli',
                          style: TextStyle(
                            color: Colors.orange,
                            fontFamily: 'Varela',
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(width: 15),
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            if (quantity >= 0) {
                              setState(() {
                                quantity--;
                              });
                              orderProvider.updateQuantity(
                                  widget.cake, quantity);
                            }
                          },
                          child: Icon(
                            Icons.remove_circle_outline,
                            color: Colors.orange,
                            size: 16,
                          ),
                        ),
                        SizedBox(width: 6),
                        Text(
                          '$quantity',
                          style: TextStyle(
                            color: Colors.orange,
                            fontFamily: 'Varela',
                            fontSize: 12,
                          ),
                        ),
                        SizedBox(width: 6),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              quantity++;
                            });
                            orderProvider.addOrder(widget.cake, 1);
                          },
                          child: Icon(
                            Icons.add_circle_outline,
                            color: Colors.orange,
                            size: 16,
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
