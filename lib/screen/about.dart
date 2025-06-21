// about_page.dart
import 'package:flutter/material.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("About")),
      body: const Padding(
        padding: EdgeInsets.all(24),
        child: Text(
          "This is a demo application developed in Flutter to showcase responsive navigation, login/signup flow, and user profile fetching.",
          style: TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}
