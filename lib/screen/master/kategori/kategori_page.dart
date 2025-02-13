import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:cakeshop_ui/api/api_service.dart';
import 'package:cakeshop_ui/screen/master/kategori/kategori_add.dart';

Future<List<Kategori>> fetchKategori({int perPage = 1000, int page = 1}) async {
  try {
    final response = await ApiService().get(
      "admin/master/category",
      perPage: perPage,
      page: page,
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse = jsonDecode(response.body);

      if (jsonResponse['success'] == true) {
        final List<dynamic> dataList = jsonResponse['data'] ?? [];
        return dataList.map((item) => Kategori.fromJson(item)).toList();
      } else {
        throw Exception(jsonResponse['message'] ?? 'Failed to load categories');
      }
    } else {
      throw Exception(
          'Error: ${response.statusCode} - ${response.reasonPhrase}');
    }
  } catch (e) {
    throw Exception('Failed to fetch categories: $e');
  }
}

class Kategori {
  final int id;
  final String name;
  final String slug;
  final String parentCode;

  const Kategori({
    required this.id,
    required this.name,
    required this.slug,
    required this.parentCode,
  });

  factory Kategori.fromJson(Map<String, dynamic> json) {
    return Kategori(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      slug: json['slug'] ?? '',
      parentCode: json['parent_code'] ?? '',
    );
  }
}

class KategoriPage extends StatefulWidget {
  const KategoriPage({super.key});

  @override
  State<KategoriPage> createState() => _KategoriPageState();
}

class _KategoriPageState extends State<KategoriPage> {
  late Future<List<Kategori>> futureKategori;
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

    futureKategori = fetchKategori().whenComplete(() {
      setState(() {
        _isLoading = false;
      });
    });
  }

  void refreshKategori() {
    fetchData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: Padding(
        padding: const EdgeInsets.all(15),
        child: FutureBuilder<List<Kategori>>(
          future: futureKategori,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(
                  child: Text('Error: ${snapshot.error}',
                      style: TextStyle(color: Colors.red)));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(child: Text('No categories available'));
            } else {
              return Opacity(
                opacity: _isLoading ? 0.5 : 1.0,
                child: AbsorbPointer(
                  absorbing: _isLoading,
                  child: SimpleTable(
                    kategoriList: snapshot.data!,
                    onKategoriAdded: refreshKategori,
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

class SimpleTable extends StatelessWidget {
  final List<Kategori> kategoriList;
  final VoidCallback onKategoriAdded;
  final bool isLoading;

  const SimpleTable({
    Key? key,
    required this.kategoriList,
    required this.onKategoriAdded,
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
                    MaterialPageRoute(builder: (context) => KategoriAdd()),
                  );

                  if (result == true) {
                    onKategoriAdded();
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
                1: FlexColumnWidth(3),
                2: FlexColumnWidth(3),
                3: FlexColumnWidth(4),
              },
              children: [
                TableRow(
                  decoration: BoxDecoration(color: Colors.grey[300]),
                  children: [
                    tableCell('Name', isHeader: true),
                    tableCell('Slug', isHeader: true),
                    tableCell('Parent Code', isHeader: true),
                    tableCell('Action', isHeader: true),
                  ],
                ),
                ...kategoriList.map((kategori) {
                  return TableRow(
                    children: [
                      tableCell(kategori.name),
                      tableCell(kategori.slug),
                      tableCell(kategori.parentCode),
                      tableCellAction(context, kategori),
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

  TableCell tableCellAction(BuildContext context, Kategori kategori) {
    return TableCell(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            onPressed: () => _viewDetail(context, kategori),
            icon: Icon(Icons.details_rounded, color: Colors.blue),
          ),
          IconButton(
            onPressed: () => _editKategori(context, kategori),
            icon: Icon(Icons.update, color: Colors.orange),
          ),
          IconButton(
            onPressed: () => _confirmDelete(context, kategori.id),
            icon: Icon(Icons.delete, color: Colors.red),
          ),
        ],
      ),
    );
  }

  void _viewDetail(BuildContext context, Kategori kategori) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Detail Kategori"),
        content: Text(
            "ID: ${kategori.id}\nNama: ${kategori.name}\nSlug: ${kategori.slug}\nParent Code: ${kategori.parentCode}"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Tutup"),
          ),
        ],
      ),
    );
  }

  void _editKategori(BuildContext context, Kategori kategori) async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => KategoriAdd(kategori: kategori),
      ),
    );

    if (result == true) {
      onKategoriAdded();
    }
  }

  void _confirmDelete(BuildContext context, int id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Hapus Kategori"),
        content: Text("Apakah Anda yakin ingin menghapus kategori ini?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Batal"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteKategori(id);
            },
            child: Text("Hapus", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _deleteKategori(int id) async {
    try {
      final response = await ApiService().delete("admin/master/category/$id");

      if (response.statusCode == 200) {
        onKategoriAdded();
      } else {
        throw Exception('Gagal menghapus kategori');
      }
    } catch (e) {
      print("Error deleting category: $e");
    }
  }
}
