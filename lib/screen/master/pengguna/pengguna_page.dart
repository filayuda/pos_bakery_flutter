// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:cakeshop_ui/api/api_service.dart';
import 'package:cakeshop_ui/screen/master/pengguna/pengguna_add.dart';

class Pengguna {
  int? id;
  String? name;
  String? username;
  DateTime? joined_at;
  int? role_id;
  String? password;

  Pengguna({
    this.id,
    this.name,
    this.username,
    this.joined_at,
    this.role_id,
    this.password,
  });

  factory Pengguna.fromJson(Map<String, dynamic> json) {
    return Pengguna(
      id: json['id'],
      name: json['name'],
      username: json['username'],
      joined_at: DateTime.parse(json['joined_at']),
      role_id: json['role_id'],
      password: json.containsKey('password') ? json['password'] : null,
    );
  }
}

Future<List<Pengguna>> fetchPengguna({int perPage = 1000, int page = 1}) async {
  try {
    final response = await ApiService().get(
      "admin/user",
      perPage: perPage,
      page: page,
    );
    var res = jsonDecode(response.body);

    if (res['success']) {
      final Map<String, dynamic> jsonResponse = res;
      final List<dynamic> dataList = jsonResponse['data'] ?? [];

      return dataList.map((item) => Pengguna.fromJson(item)).toList();
    } else {
      throw Exception('Error: ${res['message']}');
    }
  } catch (e) {
    throw Exception('Failed to fetch categories: $e');
  }
}

class PenggunaPage extends StatefulWidget {
  const PenggunaPage({super.key});

  @override
  State<PenggunaPage> createState() => _PenggunaState();
}

class _PenggunaState extends State<PenggunaPage> {
  late Future<List<Pengguna>> futurePengguna;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  void fetchData() {
    setState(() {
      _isLoading = true;
    });

    futurePengguna = fetchPengguna().whenComplete(
      () {
        setState(() {
          _isLoading = false;
        });
      },
    );
  }

  void refreshPengguna() {
    fetchData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        body: Padding(
          padding: EdgeInsets.all(15),
          child: FutureBuilder<List<Pengguna>>(
            future: futurePengguna,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(
                    child: Center(
                  child: Text(
                    'Error: ${snapshot.error}',
                    style: TextStyle(color: Colors.red),
                  ),
                ));
              } else {
                return Opacity(
                  opacity: _isLoading ? 0.5 : 1.0,
                  child: AbsorbPointer(
                    absorbing: _isLoading,
                    child: SimpleTable(
                      penggunaList: snapshot.data!,
                      onPenggunaAdded: refreshPengguna,
                    ),
                  ),
                );
              }
            },
          ),
        ));
  }
}

class SimpleTable extends StatelessWidget {
  final List<Pengguna> penggunaList;
  final VoidCallback onPenggunaAdded;
  final bool isLoading;

  const SimpleTable({
    Key? key,
    required this.penggunaList,
    required this.onPenggunaAdded,
    this.isLoading = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Container(
              width: 40,
              height: 40,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isLoading ? Colors.grey : Colors.orange,
                borderRadius: BorderRadius.circular(10),
              ),
              child: IconButton(
                iconSize: 20,
                onPressed: () async {
                  final result = await Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => PenggunaAdd()),
                  );

                  if (result == true) {
                    onPenggunaAdded();
                  }
                },
                icon: Icon(Icons.add),
                color: Colors.white,
              ),
            )
          ],
        ),
        SizedBox(height: 10),
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Table(
              border: TableBorder.all(
                color: Colors.grey,
                width: 1,
                borderRadius: BorderRadius.circular(10),
              ),
              columnWidths: {
                0: FlexColumnWidth(2),
                1: FlexColumnWidth(2),
                2: FlexColumnWidth(2),
                3: FlexColumnWidth(2),
              },
              children: [
                TableRow(
                  decoration: BoxDecoration(color: Colors.grey[300]),
                  children: [
                    tableCell('Name', isHeader: true),
                    tableCell('Username', isHeader: true),
                    tableCell('Joined At', isHeader: true),
                    tableCell('Action', isHeader: true),
                  ],
                ),
                ...penggunaList.map((pengguna) {
                  return TableRow(
                    children: [
                      tableCell(pengguna.name ?? '-'),
                      tableCell(pengguna.username ?? '-'),
                      tableCell(pengguna.joined_at.toString()),
                      tableCellAction(context, pengguna),
                    ],
                  );
                }).toList(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  TableCell tableCell(String text, {bool isHeader = false}) {
    return TableCell(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(
          text,
          style: TextStyle(
            fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  TableCell tableCellAction(BuildContext context, Pengguna pengguna) {
    return TableCell(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            iconSize: 20,
            onPressed: () => _viewDetail(context, pengguna),
            icon: Icon(Icons.details_rounded, color: Colors.blue),
          ),
          IconButton(
            iconSize: 20,
            // onPressed: () {},
            onPressed: () => _editPengguna(context, pengguna),
            icon: Icon(Icons.update, color: Colors.orange),
          ),
          // IconButton(
          //   iconSize: 20,
          //   onPressed: () => _confirmDelete(context, pengguna.id),
          //   icon: Icon(Icons.delete, color: Colors.red),
          // ),
        ],
      ),
    );
  }

  void _viewDetail(BuildContext context, Pengguna pengguna) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Detail Pengguna'),
        content: Text(
            "ID: ${pengguna.id}\nNama: ${pengguna.name}\nUsername: ${pengguna.username}\nJoined At: ${pengguna.joined_at}"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Tutup'),
          ),
        ],
      ),
    );
  }

  void _editPengguna(BuildContext context, Pengguna pengguna) async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => PenggunaAdd(pengguna: pengguna),
      ),
    );

    if (result == true) {
      onPenggunaAdded();
    }
  }

  void _confirmDelete(BuildContext context, int id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Hapus Pengguna'),
        content: Text('Apakah Anda yakin ingin menghapus pengguna ini ? '),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context), child: Text('Batal')),
          TextButton(
              onPressed: () {
                Navigator.pop(context);
                _deletePengguna(id);
              },
              child: Text(
                'Hapus',
                style: TextStyle(color: Colors.red),
              )),
        ],
      ),
    );
  }

  void _deletePengguna(int id) async {
    try {
      final response = await ApiService().delete("admin/user/$id");
      final res = jsonDecode(response.body);

      if (res['success']) {
        onPenggunaAdded();
      } else {
        throw Exception('Gagal menghapus pengguna');
      }
    } catch (e) {
      print('Error deleting pengguna: $e');
    }
  }
}
