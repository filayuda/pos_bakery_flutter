import 'package:cakeshop_ui/data/order_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CakeryScreen extends StatelessWidget {
  final List<Map<String, dynamic>> subMenuList;

  const CakeryScreen({super.key, required this.subMenuList});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 15,
            childAspectRatio: 0.7,
          ),
          itemCount: subMenuList.length,
          itemBuilder: (context, index) {
            return SubMenuCard(subMenu: subMenuList[index]);
          },
        ),
      ),
    );
  }
}

class SubMenuCard extends StatefulWidget {
  final Map<String, dynamic> subMenu;

  const SubMenuCard({super.key, required this.subMenu});

  @override
  _SubMenuCardState createState() => _SubMenuCardState();
}

class _SubMenuCardState extends State<SubMenuCard> {
  @override
  Widget build(BuildContext context) {
    final orderProvider = Provider.of<OrderProvider>(context);

    // Ambil jumlah quantity dari provider
    int quantity = orderProvider.getQuantity(widget.subMenu);

    return InkWell(
      onTap: () {
        // Aksi saat submenu dipilih
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
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            widget.subMenu['thumbnail'] != null
                ? Expanded(
                    child: ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(15),
                        topRight: Radius.circular(15),
                      ),
                      child: Image.network(
                        widget.subMenu['thumbnail'],
                        fit: BoxFit.cover,
                      ),
                    ),
                  )
                : Expanded(
                    child: ClipRRect(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(15),
                          topRight: Radius.circular(15),
                        ),
                        child: Image.asset(
                          'assets/box1.jpeg',
                          fit: BoxFit.cover,
                        )),
                  ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    widget.subMenu['name'] ?? 'Unknown',
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'Price: ${widget.subMenu['price'] ?? 'N/A'}',
                    style: const TextStyle(
                      color: Colors.green,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 10),
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
                                if (quantity > 0) {
                                  orderProvider.updateQuantity(
                                      widget.subMenu, quantity - 1);
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
                                orderProvider.addOrder(widget.subMenu, 1);
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
          ],
        ),
      ),
    );
  }
}
