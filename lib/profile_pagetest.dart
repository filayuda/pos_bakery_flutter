import 'dart:convert';
import 'package:cakeshop_ui/api/api_service.dart';
import 'package:cakeshop_ui/home.dart';
import 'package:flutter/material.dart';

class ProfilePagetest extends StatefulWidget {
  const ProfilePagetest({super.key});

  @override
  State<ProfilePagetest> createState() => _ProfilePagetestState();
}

class _ProfilePagetestState extends State<ProfilePagetest> {
  late Future<List<ListOrders>> futureOrder;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchData();
    refreshHomeNotifier.addListener(() {});
  }

  void fetchData() {
    setState(() {
      futureOrder = fetchListOrder().whenComplete(() {
        setState(() {
          _isLoading = false;
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Order List")),
      body: Padding(
        padding: const EdgeInsets.all(15),
        child: FutureBuilder<List<ListOrders>>(
          future: futureOrder,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(
                child: Text('Error: ${snapshot.error}',
                    style: const TextStyle(color: Colors.red)),
              );
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('No orders available'));
            } else {
              return Opacity(
                opacity: _isLoading ? 0.5 : 1.0,
                child: AbsorbPointer(
                  absorbing: _isLoading,
                  child: ListView.builder(
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      final order = snapshot.data![index];
                      return Card(
                        margin: EdgeInsets.symmetric(vertical: 8),
                        child: ListTile(
                          leading: CircleAvatar(
                            child: Text(order.id.toString()),
                          ),
                          title: Text(
                              "Order by: ${order.customer_name ?? 'Firmansya'}"),
                          subtitle: Text("Total Items: ${order.total_item}"),
                          trailing: Text(
                            order.created_at.toString(),
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              );
            }
          },
        ),
      ),
    );
  }
}

class ListOrders {
  final int id;
  final dynamic code;
  String? customer_name;
  final int total_item;
  final DateTime created_at;

  ListOrders({
    required this.id,
    required this.code,
    this.customer_name,
    required this.total_item,
    required this.created_at,
  });

  factory ListOrders.fromJson(Map<String, dynamic> json) {
    return ListOrders(
      id: json['id'],
      code: json['code'],
      customer_name: json['customer_name'],
      total_item: json['total_item'],
      created_at: DateTime.parse(json['created_at']),
    );
  }
}

Future<List<ListOrders>> fetchListOrder(
    {int perPage = 1000, int page = 1}) async {
  try {
    final response = await ApiService()
        .get('admin/order', queryParameters: {'status': 'pending'});

    if (response.body.isEmpty) {
      throw Exception("Empty response body");
    }
    final Map<String, dynamic> jsonResponse = jsonDecode(response.body);

    if (jsonResponse['success']) {
      List<dynamic> data = jsonResponse['data'];
      return data.map((order) => ListOrders.fromJson(order)).toList();
    } else {
      throw Exception("Failed to load orders: ${jsonResponse['message']}");
    }
  } catch (e) {
    print("Error fetching orders: $e");
    throw Exception("Error fetching orders: $e");
  }
}
