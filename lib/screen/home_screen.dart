import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:trexo/widget/ResponsiveScaffold.dart';
import 'package:trexo/widget/header.dart';

class HomeScreen extends StatelessWidget {
  final String email;

  const HomeScreen({super.key, required this.email});

  void logout(BuildContext context) {
    Fluttertoast.showToast(msg: "Logged out");
    Navigator.pop(context);
  }

  void goToViewAll(BuildContext context) {
    Navigator.pushNamed(context, '/view-all');
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveScaffold(
      body: Center(
        child: Card(
          margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
          elevation: 6,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.home, size: 60, color: Colors.blue),
                const SizedBox(height: 16),
                const Text(
                  "Welcome to the App!",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Text("Logged in as", style: TextStyle(color: Colors.grey[700])),
                const SizedBox(height: 5),
                Text(
                  email,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 30),
                ElevatedButton.icon(
                  onPressed: () => goToViewAll(context),
                  icon: const Icon(Icons.list_alt),
                  label: const Text("View All Listings"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () => logout(context),
                  icon: const Icon(Icons.logout),
                  label: const Text("Logout"),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
