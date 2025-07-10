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
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.horizontal(
                    right: Radius.circular(30),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      decoration: const BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.only(
                          bottomRight: Radius.circular(30),
                        ),
                      ),
                      padding: const EdgeInsets.only(
                        top: 50,
                        bottom: 20,
                        left: 20,
                        right: 20,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          CircleAvatar(
                            radius: 30,
                            backgroundImage: AssetImage(
                              'assets/images/logocopy-modified.png',
                            ), // replace with your image
                          ),
                          SizedBox(height: 10),
                          Text(
                            "Hello, User!",
                            style: TextStyle(color: Colors.white, fontSize: 20),
                          ),
                          SizedBox(height: 5),
                          Text(
                            "user@example.com",
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: ListView(
                        padding: EdgeInsets.zero,
                        children: [
                          _buildDrawerItem(
                            Icons.person,
                            "Profile",
                            context,
                            '/profile',
                          ),
                          _buildDrawerItem(
                            Icons.info_outline,
                            "About",
                            context,
                            '/about',
                          ),
                          const Divider(),
                          _buildDrawerItem(
                            Icons.settings,
                            "Settings",
                            context,
                            '/settings',
                          ),
                          _buildDrawerItem(
                            Icons.logout,
                            "Logout",
                            context,
                            '/logout',
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )
              : null,

      body: body,
    );
  }
}

Widget _buildDrawerItem(
  IconData icon,
  String title,
  BuildContext context,
  String route,
) {
  return ListTile(
    leading: Icon(icon, color: Colors.blue),
    title: Text(title),
    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
    onTap: () {
      Navigator.pop(context);
      Navigator.pushNamed(context, route);
    },
  );
}
