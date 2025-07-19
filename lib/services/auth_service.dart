import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

const String baseUrl = "http://127.0.0.1:5000/api/auth";

class AuthService {
  static const Map<String, String> _headers = {
    'Content-Type': 'application/json',
  };

  // ✅ Signup
  static Future<http.Response> signup(Map<String, dynamic> data) async {
    try {
      return await http.post(
        Uri.parse('$baseUrl/signup'),
        headers: _headers,
        body: jsonEncode(data),
      );
    } catch (e) {
      print('Signup error: $e');
      rethrow;
    }
  }

  // ✅ Verify OTP
  static Future<http.Response> verifyOtp(String email, String otp) async {
    try {
      return await http.post(
        Uri.parse('$baseUrl/verify-otp'),
        headers: _headers,
        body: jsonEncode({'email': email, 'otp': otp}),
      );
    } catch (e) {
      print('Verify OTP error: $e');
      rethrow;
    }
  }

  // ✅ Login (no decoding here)
  static Future<http.Response> login(String email, String password) async {
    try {
      return await http.post(
        Uri.parse('$baseUrl/login'),
        headers: _headers,
        body: jsonEncode({'email': email, 'password': password}),
      );
    } catch (e) {
      print('Login error: $e');
      rethrow;
    }
  }

  // ✅ Forgot Password
  static Future<http.Response> forgotPassword(String email) async {
    try {
      return await http.post(
        Uri.parse('$baseUrl/forgot-password'),
        headers: _headers,
        body: jsonEncode({'email': email}),
      );
    } catch (e) {
      print('Forgot Password error: $e');
      rethrow;
    }
  }

  // ✅ Reset Password
  static Future<http.Response> resetPassword(String token, String password) async {
    try {
      return await http.post(
        Uri.parse('$baseUrl/reset-password/$token'),
        headers: _headers,
        body: jsonEncode({'password': password}),
      );
    } catch (e) {
      print('Reset Password error: $e');
      rethrow;
    }
  }

  // ✅ Get Profile
  static Future<Map<String, dynamic>?> getProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) return null;

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/profile'),
        headers: {
          ..._headers,
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        print('Get profile failed: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Get profile error: $e');
      return null;
    }
  }

  // ✅ Logout
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('userRole');
    await prefs.remove('userEmail');
  }

  static Future<http.Response> getProperties([String? token]) async {
    return await http.get(
      Uri.parse('$baseUrl/properties'),
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );
  }

  static Future<http.Response> getVehicles([String? token]) async {
    return await http.get(
      Uri.parse('$baseUrl/vehicles'),
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );
  }
}
