import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../services/auth_service.dart';

class ForgotPasswordScreen extends StatelessWidget {
  final emailCtrl = TextEditingController();

  ForgotPasswordScreen({super.key});

  void sendResetLink() async {
    final res = await AuthService.forgotPassword(emailCtrl.text);
    if (res.statusCode == 200) {
      Fluttertoast.showToast(msg: "Reset link sent");
    } else {
      Fluttertoast.showToast(msg: "Failed: ${res.body}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Forgot Password')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(controller: emailCtrl, decoration: const InputDecoration(labelText: 'Email')),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: sendResetLink, child: const Text('Send Reset Link'))
          ],
        ),
      ),
    );
  }
}
