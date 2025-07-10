import 'dart:convert';
import 'package:http/http.dart' as http;

class AdminService {
  static const baseUrl = 'http://13.203.148.184/api/sell';

  static Future<http.Response> addProperty(Map<String, dynamic> data, String token) async {
    return await http.post(
      Uri.parse('$baseUrl/property'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(data),
    );
  }

  static Future<http.Response> addVehicle(Map<String, dynamic> data, String token) async {
    return await http.post(
      Uri.parse('$baseUrl/vehicle'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(data),
    );
  }
}
