import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cakeshop_ui/api/api_service.dart';
import 'package:cakeshop_ui/screen/master/kategori/kategori_add.dart';

class KategoriPage extends StatefulWidget {
  final VoidCallback? onDataChanged;

  const KategoriPage({super.key, this.onDataChanged});

  @override
  State<KategoriPage> createState() => _KategoriPageState();
}

class _KategoriPageState extends State<KategoriPage> {
  late Future<List<Kategori>> futureKategori;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  void fetchData() {
    setState(() {
      _isLoading = true;
      futureKategori = fetchKategori().whenComplete(() {
        setState(() {
          _isLoading = false;
        });
      });
    });
  }

  void refreshKategori() {
    fetchData();
    widget.onDataChanged?.call();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(15),
        child: FutureBuilder<List<Kategori>>(
          future: futureKategori,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(
                child: Text('Error: ${snapshot.error}',
                    style: const TextStyle(color: Colors.red)),
              );
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('No categories available'));
            } else {
              return Opacity(
                opacity: _isLoading ? 0.5 : 1.0,
                child: AbsorbPointer(
                  absorbing: _isLoading,
                  child: SimpleListView(
                    kategoriList: snapshot.data!,
                    onKategoriChanged: refreshKategori,
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

/// Fetch kategori dari API
Future<List<Kategori>> fetchKategori({int perPage = 1000, int page = 1}) async {
  try {
    final response = await ApiService()
        .get("admin/master/category", perPage: perPage, page: page);

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

/// Model Kategori
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

class SimpleListView extends StatelessWidget {
  final List<Kategori> kategoriList;
  final VoidCallback onKategoriChanged;

  const SimpleListView({
    Key? key,
    required this.kategoriList,
    required this.onKategoriChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Align(
          alignment: Alignment.centerRight,
          child: Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.orange,
              borderRadius: BorderRadius.circular(10),
            ),
            child: IconButton(
              iconSize: 20,
              onPressed: () async {
                final result = await Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => KategoriAdd()),
                );
                if (result == true) onKategoriChanged();
              },
              icon: const Icon(Icons.add, color: Colors.white),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Expanded(
          child: ListView.builder(
            itemCount: kategoriList.length,
            itemBuilder: (context, index) {
              final kategori = kategoriList[index];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 3,
                child: ListTile(
                  title: Text(
                    kategori.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Slug: ${kategori.slug}"),
                      Text("Parent Code: ${kategori.parentCode}"),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        onPressed: () => _editKategori(context, kategori),
                        icon: const Icon(Icons.edit, color: Colors.orange),
                      ),
                      IconButton(
                        onPressed: () =>
                            _confirmDelete(context, kategori.id, kategori.name),
                        icon: const Icon(Icons.delete, color: Colors.red),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  void _editKategori(BuildContext context, Kategori kategori) async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => KategoriAdd(kategori: kategori)),
    );
    if (result == true) onKategoriChanged();
  }

  void _confirmDelete(BuildContext context, int id, String name) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Kategori'),
        content: Text('Apakah Anda yakin ingin menghapus kategori $name?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal')),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteKategori(id);
            },
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _deleteKategori(int id) async {
    try {
      final response = await ApiService().delete("admin/master/category/$id");
      if (response.statusCode == 200) onKategoriChanged();
    } catch (e) {
      print("Error deleting category: $e");
    }
  }
}

/// Widget untuk TableCell
class _TableCell extends StatelessWidget {
  final String text;
  final bool isHeader;

  const _TableCell({required this.text, this.isHeader = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        text,
        style: TextStyle(
            fontWeight: isHeader ? FontWeight.bold : FontWeight.normal),
      ),
    );
  }
}

/// Widget untuk Action Buttons di Table
Widget _TableCellAction(BuildContext context, Kategori kategori) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      IconButton(
        onPressed: () => _editKategori(context, kategori),
        icon: const Icon(Icons.edit, color: Colors.orange),
      ),
      IconButton(
        onPressed: () => _confirmDelete(context, kategori.id),
        icon: const Icon(Icons.delete, color: Colors.red),
      ),
    ],
  );
}

void _editKategori(BuildContext context, Kategori kategori) async {
  final result = await Navigator.of(context).push(
    MaterialPageRoute(
      builder: (context) => KategoriAdd(kategori: kategori),
    ),
  );

  if (result == true) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Kategori berhasil diperbarui')),
    );
  }
}

void _confirmDelete(BuildContext context, int id) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text("Hapus Kategori"),
      content: const Text("Apakah Anda yakin ingin menghapus kategori ini?"),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Batal")),
        TextButton(
          onPressed: () {
            Navigator.pop(context);
            _deleteKategori(context, id);
          },
          child: const Text("Hapus", style: TextStyle(color: Colors.red)),
        ),
      ],
    ),
  );
}

void _deleteKategori(BuildContext context, int id) async {
  await ApiService().delete("admin/master/category/$id");
  ScaffoldMessenger.of(context)
      .showSnackBar(const SnackBar(content: Text('Kategori berhasil dihapus')));
}
