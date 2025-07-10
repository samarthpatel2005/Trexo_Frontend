import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:trexo/widget/header.dart';
import '../services/auth_service.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Map<String, dynamic>? userData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchUser();
  }

  void fetchUser() async {
    try {
      final data = await AuthService.getProfile(); 
      if (data != null) {
        setState(() {
          userData = data;
          isLoading = false;
        });
      } else {
        Fluttertoast.showToast(msg: "⚠️ Failed to fetch user profile");
        setState(() => isLoading = false);
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "❌ Something went wrong");
      setState(() => isLoading = false);
    }
  }

  void logout(BuildContext context) {
    Fluttertoast.showToast(msg: "Logged out");
    Navigator.popUntil(context, ModalRoute.withName('/'));
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: SimpleHeader(),
        body: isLoading
            ? const Center(child: CircularProgressIndicator())
            : userData == null
                ? const Center(child: Text("No data available"))
                : Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "User Information",
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Divider(),
                        const SizedBox(height: 16),
                        Text(
                          "👤 Name: ${userData!['name']}",
                          style: const TextStyle(fontSize: 18),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          "📧 Email: ${userData!['email']}",
                          style: const TextStyle(fontSize: 18),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          "📞 Phone: ${userData!['phone']}",
                          style: const TextStyle(fontSize: 18),
                        ),
                        const Spacer(),
                        Center(
                          child: ElevatedButton.icon(
                            onPressed: () async {
                              await AuthService.logout();
                              Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
                            },
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
                        ),
                      ],
                    ),
                  ),
      ),
    );
  }
}
