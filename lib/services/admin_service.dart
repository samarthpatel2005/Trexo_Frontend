import 'dart:convert';
import 'package:http/http.dart' as http;

class AdminService {
  static const baseUrl = 'http://127.0.0.1:5000/api/admin';

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

  static Future<List<dynamic>> getProperties([String? token]) async {
  final res = await http.get(
    Uri.parse('http://127.0.0.1:5000/api/auth/properties'),
    headers: {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    },
  );
  if (res.statusCode == 200) {
    return jsonDecode(res.body);
  } else {
    throw Exception('Failed to load properties');
  }
}

static Future<List<dynamic>> getVehicles([String? token]) async {
  final res = await http.get(
    Uri.parse('http://127.0.0.1:5000/api/auth/vehicles'),
    headers: {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    },
  );
  if (res.statusCode == 200) {
    return jsonDecode(res.body);
  } else {
    throw Exception('Failed to load vehicles');
  }
}

}

