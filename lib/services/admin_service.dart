import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

const String baseUrl = "http://127.0.0.1:5000/api/admin";

class AdminService {
  // Fetch all users
  Future<List<Map<String, dynamic>>> getAllUsers() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token'); // Assuming token is stored like this

    if (token == null) {
      throw Exception("No token found. Please login.");
    }

    final response = await http.get(
      Uri.parse('$baseUrl/users'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> users = json.decode(response.body);
      return users.map((user) => user as Map<String, dynamic>).toList();
    } else {
      throw Exception('Failed to fetch users: ${response.statusCode} - ${response.body}');
    }
  }
}
