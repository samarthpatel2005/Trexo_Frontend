import 'package:flutter/material.dart';
import 'package:trexo/register_page.dart';
import 'login_page.dart'; // Import your new file

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const LoginPage(), // Start here
      routes: {
        '/register': (context) => const RegisterPage(), // define this separately
      },
    );
  }
}
