import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cakeshop_ui/api/api_service.dart';
import 'package:cakeshop_ui/screen/master/pengguna/pengguna_add.dart';

class PenggunaPage extends StatefulWidget {
  final VoidCallback? onDataChanged;

  const PenggunaPage({super.key, this.onDataChanged});

  @override
  State<PenggunaPage> createState() => _PenggunaPageState();
}

class _PenggunaPageState extends State<PenggunaPage> {
  late Future<List<Pengguna>> futurePengguna;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  void fetchData() {
    setState(() {
      _isLoading = true;
      futurePengguna = fetchPengguna().whenComplete(() {
        setState(() {
          _isLoading = false;
        });
      });
    });
  }

  void refreshPengguna() {
    fetchData();
    widget.onDataChanged?.call();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(15),
        child: FutureBuilder<List<Pengguna>>(
          future: futurePengguna,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(
                child: Text('Error: ${snapshot.error}',
                    style: const TextStyle(color: Colors.red)),
              );
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('No users available'));
            } else {
              return Opacity(
                opacity: _isLoading ? 0.5 : 1.0,
                child: AbsorbPointer(
                  absorbing: _isLoading,
                  child: SimpleListView(
                    penggunaList: snapshot.data!,
                    onPenggunaChanged: refreshPengguna,
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

/// Fetch pengguna dari API
Future<List<Pengguna>> fetchPengguna({int perPage = 1000, int page = 1}) async {
  try {
    final response =
        await ApiService().get("admin/user", perPage: perPage, page: page);

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse = jsonDecode(response.body);

      if (jsonResponse['success'] == true) {
        final List<dynamic> dataList = jsonResponse['data'] ?? [];
        return dataList.map((item) => Pengguna.fromJson(item)).toList();
      } else {
        throw Exception(jsonResponse['message'] ?? 'Failed to load users');
      }
    } else {
      throw Exception(
          'Error: ${response.statusCode} - ${response.reasonPhrase}');
    }
  } catch (e) {
    throw Exception('Failed to fetch users: $e');
  }
}

/// Model Pengguna
class Pengguna {
  final int id;
  final String name;
  final String username;
  final DateTime joined_at;
  int? role_id;
  String? password;

  Pengguna({
    required this.id,
    required this.name,
    required this.username,
    required this.joined_at,
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

class SimpleListView extends StatelessWidget {
  final List<Pengguna> penggunaList;
  final VoidCallback onPenggunaChanged;

  const SimpleListView({
    Key? key,
    required this.penggunaList,
    required this.onPenggunaChanged,
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
                  MaterialPageRoute(builder: (context) => PenggunaAdd()),
                );
                if (result == true) onPenggunaChanged();
              },
              icon: const Icon(Icons.add, color: Colors.white),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Expanded(
          child: ListView.builder(
            itemCount: penggunaList.length,
            itemBuilder: (context, index) {
              final pengguna = penggunaList[index];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 3,
                child: ListTile(
                  title: Text(
                    pengguna.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Username: ${pengguna.username}"),
                      Text("Joined At: ${pengguna.joined_at.toString()}"),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        onPressed: () => _editPengguna(context, pengguna),
                        icon: const Icon(Icons.edit, color: Colors.orange),
                      ),
                      IconButton(
                        onPressed: () =>
                            _confirmDelete(context, pengguna.id, pengguna.name),
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

  void _editPengguna(BuildContext context, Pengguna pengguna) async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => PenggunaAdd(pengguna: pengguna)),
    );
    if (result == true) onPenggunaChanged();
  }

  void _confirmDelete(BuildContext context, int id, String name) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Pengguna'),
        content: Text('Apakah Anda yakin ingin menghapus pengguna $name?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal')),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deletePengguna(id);
            },
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _deletePengguna(int id) async {
    try {
      final response = await ApiService().delete("admin/user/$id");
      if (response.statusCode == 200) onPenggunaChanged();
    } catch (e) {
      print("Error deleting user: $e");
    }
  }
}
