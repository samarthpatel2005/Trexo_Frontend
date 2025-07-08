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
      final data = await AuthService.getProfile(); // returns user data or null
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

  //   @override
  //   Widget build(BuildContext context) {
  //     return Scaffold(
  //       appBar: SimpleHeader(),
  //       body:
  //           isLoading
  //               ? const Center(child: CircularProgressIndicator())
  //               : userData == null
  //               ? const Center(child: Text("No data available"))
  //               : Padding(
  //                 padding: const EdgeInsets.all(24),
  //                 child: Column(
  //                   crossAxisAlignment: CrossAxisAlignment.start,
  //                   children: [
  //                     const Text(
  //                       "User Information",
  //                       style: TextStyle(
  //                         fontSize: 22,
  //                         fontWeight: FontWeight.bold,
  //                       ),
  //                     ),
  //                     const Divider(),
  //                     const SizedBox(height: 16),
  //                     Text(
  //                       "👤 Name: ${userData!['name']}",
  //                       style: const TextStyle(fontSize: 18),
  //                     ),
  //                     const SizedBox(height: 10),
  //                     Text(
  //                       "📧 Email: ${userData!['email']}",
  //                       style: const TextStyle(fontSize: 18),
  //                     ),
  //                     const SizedBox(height: 10),
  //                     Text(
  //                       "📞 Phone: ${userData!['phone']}",
  //                       style: const TextStyle(fontSize: 18),
  //                     ),
  //                     const Spacer(),
  //                     Center(
  //                       child: ElevatedButton.icon(
  //                         onPressed: () => logout(context),
  //                         icon: const Icon(Icons.logout),
  //                         label: const Text("Logout"),
  //                         style: ElevatedButton.styleFrom(
  //                           padding: const EdgeInsets.symmetric(
  //                             horizontal: 24,
  //                             vertical: 12,
  //                           ),
  //                           shape: RoundedRectangleBorder(
  //                             borderRadius: BorderRadius.circular(8),
  //                           ),
  //                         ),
  //                       ),
  //                     ),
  //                   ],
  //                 ),
  //               ),
  //     );
  //   }
  // }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : userData == null
              ? const Center(child: Text("No data available"))
              : SingleChildScrollView(
                child: Column(
                  children: [
                    // Top gradient with profile picture
                    // Top gradient with profile picture + back button
                    Stack(
                      children: [
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.only(top: 60, bottom: 40),
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Color(0xff62cff4), Color(0xFF2c67f2)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.vertical(
                              bottom: Radius.circular(40),
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const CircleAvatar(
                                radius: 50,
                                backgroundImage: AssetImage(
                                  'assets/images/logocopy.png',
                                ), // Replace with user's image if available
                              ),
                              const SizedBox(height: 16),
                            ],
                          ),
                        ),
                        // Back button (top-left corner)
                        Positioned(
                          top: 40,
                          left: 16,
                          child: IconButton(
                            icon: const Icon(
                              Icons.arrow_back,
                              color: Colors.white,
                              size: 28,
                            ),
                            onPressed: () {
                              Navigator.pushReplacementNamed(context, '/home');
                            },
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // User Info Card
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        children: [
                          Container(
                            margin: EdgeInsets.only(top: 24),
                            padding: EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(18),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 8,
                                  offset: Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                Text(
                                  "User Information",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                          infoCard(Icons.person, "Name", userData!['name']),
                          const SizedBox(height: 12),
                          infoCard(Icons.email, "Email", userData!['email']),
                          const SizedBox(height: 12),
                          infoCard(Icons.phone, "Phone", userData!['phone']),
                        ],
                      ),
                    ),

                    const SizedBox(height: 40),

                    // Logout Button
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: ElevatedButton.icon(
                        onPressed: () => logout(context),
                        icon: const Icon(Icons.logout, color: Colors.white),
                        label: const Text(
                          "Logout",
                          style: TextStyle(color: Colors.white, fontSize: 18),
                        ),
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size.fromHeight(50),
                          backgroundColor: const Color(0xFF2c67f2),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
    );
  }

  Widget infoCard(IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.blue),
          const SizedBox(width: 16),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 16))),
        ],
      ),
    );
  }
}
