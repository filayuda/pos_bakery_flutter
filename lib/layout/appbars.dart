import 'package:cakeshop_ui/data/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Appbars extends StatefulWidget implements PreferredSizeWidget {
  final String title;

  const Appbars({
    super.key,
    required this.title,
  });

  @override
  _AppbarsState createState() => _AppbarsState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _AppbarsState extends State<Appbars> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      authProvider.loadUser(context).then((_) {
        print('User setelah loadUser: ${authProvider.user}');
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      title: Text(
        widget.title,
        style: const TextStyle(
          color: Colors.grey,
          fontFamily: 'Varela',
          fontSize: 15,
        ),
      ),
      actions: [
        Row(
          children: [
            Consumer<AuthProvider>(
              builder: (context, authProvider, child) {
                return Text(
                  authProvider.user?.username ?? 'Loading...',
                  style: const TextStyle(
                    color: Colors.orange,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                );
              },
            ),
            IconButton(
              onPressed: () {},
              icon: const Icon(
                Icons.notifications_none,
                color: Colors.grey,
              ),
            ),
            IconButton(
              onPressed: () {
                authProvider.logout(context);
              },
              icon: const Icon(
                Icons.logout,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
