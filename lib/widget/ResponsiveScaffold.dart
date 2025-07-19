import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import 'header.dart';

class ResponsiveScaffold extends StatefulWidget {
  final Widget body;

  const ResponsiveScaffold({super.key, required this.body});

  @override
  State<ResponsiveScaffold> createState() => _ResponsiveScaffoldState();
}

class _ResponsiveScaffoldState extends State<ResponsiveScaffold> {
  Map<String, dynamic>? userData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchUser();
  }

  void fetchUser() async {
    final data = await AuthService.getProfile();
    setState(() {
      userData = data;
      isLoading = false;
    });
  }

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
                        children: [
                          const CircleAvatar(
                            radius: 30,
                            backgroundImage: AssetImage(
                              'assets/images/logocopy-modified.png',
                            ),
                          ),
                          const SizedBox(height: 10),
                          isLoading
                              ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                              : Text(
                                "Hello, ${userData?['name'] ?? 'User'}!",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                ),
                              ),
                          const SizedBox(height: 5),
                          isLoading
                              ? Container(height: 14)
                              : Text(
                                userData?['email'] ?? 'user@example.com',
                                style: const TextStyle(
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
                        ],
                      ),
                    ),
                  ],
                ),
              )
              : null,
      body: widget.body,
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
