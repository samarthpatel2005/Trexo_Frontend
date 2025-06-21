import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../services/auth_service.dart';

class ResetPasswordScreen extends StatefulWidget {
  final String token;
  const ResetPasswordScreen({super.key, required this.token});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final passwordCtrl = TextEditingController();

  void resetPassword() async {
    final res = await AuthService.resetPassword(widget.token, passwordCtrl.text);
    if (res.statusCode == 200) {
      Fluttertoast.showToast(msg: 'Password reset successful');
    } else {
      Fluttertoast.showToast(msg: 'Failed: ${res.body}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reset Password')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(controller: passwordCtrl, decoration: const InputDecoration(labelText: 'New Password'), obscureText: true),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: resetPassword, child: const Text('Reset Password'))
          ],
        ),
      ),
    );
  }
}
