import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../services/auth_service.dart';
import 'login_screen.dart';

class OtpVerificationScreen extends StatelessWidget {
  final String email;
  final otpCtrl = TextEditingController();

  OtpVerificationScreen({super.key, required this.email});

  void verifyOtp(BuildContext context) async {
    final res = await AuthService.verifyOtp(email, otpCtrl.text);
    if (res.statusCode == 200) {
      Fluttertoast.showToast(msg: "Verified!");
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => LoginScreen()),
      );
    } else {
      Fluttertoast.showToast(msg: "Invalid OTP");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Verify OTP')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(controller: otpCtrl, decoration: const InputDecoration(labelText: 'OTP')),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: () => verifyOtp(context), child: const Text('Verify'))
          ],
        ),
      ),
    );
  }
}
