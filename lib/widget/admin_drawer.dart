import 'package:flutter/material.dart';

class AdminDrawer extends StatelessWidget {
  const AdminDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(color: Colors.blue),
            child: Column(
              children: const [
                Icon(Icons.admin_panel_settings, size: 60, color: Colors.white),
                SizedBox(height: 10),
                Text("Admin", style: TextStyle(color: Colors.white, fontSize: 18)),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home_work),
            title: const Text('Add Property'),
            onTap: () => Navigator.pushNamed(context, '/add-property'),
          ),
          ListTile(
            leading: const Icon(Icons.directions_car),
            title: const Text('Add Vehicle'),
            onTap: () => Navigator.pushNamed(context, '/add-vehicle'),
          ),
        ],
      ),
    );
  }
}
