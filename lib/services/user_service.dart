import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

const String baseUrl = "http://209.38.124.176/api";

class UserService {
  // Get authorization headers
  Future<Map<String, String>> _getHeaders() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');

    if (token == null) {
      throw Exception("No token found. Please login.");
    }

    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // Fetch user by ID - fetches all users and filters by ID
  Future<Map<String, dynamic>?> getUserById(String userId) async {
    try {
      final headers = await _getHeaders();
      
      // Try to get user directly from admin endpoint first
      try {
        final directResponse = await http.get(
          Uri.parse('$baseUrl/admin/user/$userId'),
          headers: headers,
        );

        if (directResponse.statusCode == 200) {
          return json.decode(directResponse.body);
        }
      } catch (e) {
        print('Direct user fetch failed, trying getAllUsers: $e');
      }
      
      // If direct fetch fails, get all users and filter
      final response = await http.get(
        Uri.parse('$baseUrl/admin/users'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> users = json.decode(response.body);
        
        // Find the user with matching ID
        for (var user in users) {
          if (user['_id'] == userId || user['id'] == userId) {
            print('Found user: $user');
            return user as Map<String, dynamic>;
          }
        }
        
        print('User not found in list');
        return null;
      } else {
        print('Failed to fetch users: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error fetching user: $e');
      return null;
    }
  }
}
