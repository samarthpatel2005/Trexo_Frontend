import 'package:flutter/material.dart';
import 'header.dart'; // Make sure SimpleHeader is updated as per previous messages

class ResponsiveScaffold extends StatelessWidget {
  final Widget body;

  const ResponsiveScaffold({super.key, required this.body});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const SimpleHeader(),
      drawer:
          MediaQuery.of(context).size.width < 600
              ? Drawer(
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    const DrawerHeader(
                      decoration: BoxDecoration(color: Colors.blue),
                      child: Text(
                        "MyApp Menu",
                        style: TextStyle(color: Colors.white, fontSize: 24),
                      ),
                    ),
                    ListTile(
                      leading: const Icon(Icons.person),
                      title: const Text('Profile'),
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.pushNamed(context, '/profile');
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.info_outline),
                      title: const Text('About'),
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.pushNamed(context, '/about');
                      },
                    ),
                  ],
                ),
              )
              : null,
      body: body,
    );
  }
}
