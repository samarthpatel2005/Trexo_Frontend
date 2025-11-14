import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trexo/models/property.dart';

import '../models/user.dart';
import '../models/vehicle.dart';

const String baseUrl = "http://209.38.124.176/api/admin";

class AdminService {
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

  // ============= USERS MANAGEMENT =============

  // Fetch all users
  Future<List<User>> getAllUsers() async {
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse('$baseUrl/users'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final List<dynamic> usersJson = json.decode(response.body);
      return usersJson.map((json) => User.fromJson(json)).toList();
    } else {
      throw Exception(
        'Failed to fetch users: ${response.statusCode} - ${response.body}',
      );
    }
  }

  // Delete user
  Future<bool> deleteUser(String userId) async {
    final headers = await _getHeaders();
    final response = await http.delete(
      Uri.parse('$baseUrl/user/$userId'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      throw Exception(
        'Failed to delete user: ${response.statusCode} - ${response.body}',
      );
    }
  }

  // Verify user
  Future<bool> verifyUser(String userId) async {
    final headers = await _getHeaders();
    final response = await http.patch(
      Uri.parse('$baseUrl/user/$userId/verify'),
      headers: headers,
      body: json.encode({'isVerified': true}),
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      throw Exception(
        'Failed to verify user: ${response.statusCode} - ${response.body}',
      );
    }
  }

  // Unverify user
  Future<bool> unverifyUser(String userId) async {
    final headers = await _getHeaders();
    final response = await http.patch(
      Uri.parse('$baseUrl/user/$userId/verify'),
      headers: headers,
      body: json.encode({'isVerified': false}),
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      throw Exception(
        'Failed to unverify user: ${response.statusCode} - ${response.body}',
      );
    }
  }

  // ============= PROPERTIES MANAGEMENT =============

  // Fetch all properties
  Future<List<Property>> getAllProperties() async {
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse('$baseUrl/properties'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final List<dynamic> propertiesJson = json.decode(response.body);
      return propertiesJson.map((json) => Property.fromJson(json)).toList();
    } else {
      throw Exception(
        'Failed to fetch properties: ${response.statusCode} - ${response.body}',
      );
    }
  }

  // Delete property
  Future<bool> deleteProperty(String propertyId) async {
    final headers = await _getHeaders();
    final response = await http.delete(
      Uri.parse('$baseUrl/property/$propertyId'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      throw Exception(
        'Failed to delete property: ${response.statusCode} - ${response.body}',
      );
    }
  }

  // ============= VEHICLES MANAGEMENT =============

  // Fetch all vehicles
  Future<List<Vehicle>> getAllVehicles() async {
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse('$baseUrl/vehicles'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final List<dynamic> vehiclesJson = json.decode(response.body);
      return vehiclesJson.map((json) => Vehicle.fromJson(json)).toList();
    } else {
      throw Exception(
        'Failed to fetch vehicles: ${response.statusCode} - ${response.body}',
      );
    }
  }

  // Delete vehicle
  Future<bool> deleteVehicle(String vehicleId) async {
    final headers = await _getHeaders();
    final response = await http.delete(
      Uri.parse('$baseUrl/vehicle/$vehicleId'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      throw Exception(
        'Failed to delete vehicle: ${response.statusCode} - ${response.body}',
      );
    }
  }

  // ============= DASHBOARD STATS =============

  // Get current admin profile
  Future<Map<String, dynamic>> getCurrentAdminProfile() async {
    final headers = await _getHeaders();
    // Use the auth profile endpoint instead of non-existent admin profile endpoint
    final response = await http.get(
      Uri.parse('http://209.38.124.176/api/auth/profile'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception(
        'Failed to fetch admin profile: ${response.statusCode} - ${response.body}',
      );
    }
  }

  // Get dashboard statistics
  Future<Map<String, dynamic>> getDashboardStats() async {
    try {
      final users = await getAllUsers();
      final properties = await getAllProperties();
      final vehicles = await getAllVehicles();

      // Calculate statistics
      final now = DateTime.now();
      final lastWeek = now.subtract(const Duration(days: 7));

      final recentUsers =
          users.where((user) => user.createdAt.isAfter(lastWeek)).length;
      final recentProperties =
          properties
              .where((property) => property.createdAt.isAfter(lastWeek))
              .length;
      final recentVehicles =
          vehicles
              .where((vehicle) => vehicle.createdAt.isAfter(lastWeek))
              .length;

      final verifiedUsers = users.where((user) => user.isVerified).length;

      return {
        'totalUsers': users.length,
        'totalProperties': properties.length,
        'totalVehicles': vehicles.length,
        'recentUsers': recentUsers,
        'recentProperties': recentProperties,
        'recentVehicles': recentVehicles,
        'verifiedUsers': verifiedUsers,
        'unverifiedUsers': users.length - verifiedUsers,
      };
    } catch (e) {
      throw Exception('Failed to fetch dashboard stats: $e');
    }
  }
}