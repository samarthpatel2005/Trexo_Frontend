import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class LikedVehiclesService {
  static const String _likedVehiclesKey = 'liked_vehicles';

  // Singleton pattern
  static final LikedVehiclesService _instance =
      LikedVehiclesService._internal();
  factory LikedVehiclesService() => _instance;
  LikedVehiclesService._internal();

  // Get all liked vehicles
  Future<List<Map<String, dynamic>>> getLikedVehicles() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? likedVehiclesJson = prefs.getString(_likedVehiclesKey);

      if (likedVehiclesJson != null) {
        final List<dynamic> decoded = json.decode(likedVehiclesJson);
        return decoded.cast<Map<String, dynamic>>();
      }
    } catch (e) {
      print('Error loading liked vehicles: $e');
    }
    return [];
  }

  // Get all liked vehicles synchronously (for immediate access)
  List<Map<String, dynamic>> getLikedVehiclesSync() {
    // This will return empty list initially, but we'll load async
    return _cachedLikedVehicles;
  }

  // Cache for immediate access
  List<Map<String, dynamic>> _cachedLikedVehicles = [];

  // Initialize cache
  Future<void> initializeCache() async {
    _cachedLikedVehicles = await getLikedVehicles();
  }

  // Add a vehicle to liked list
  Future<bool> addLikedVehicle(Map<String, dynamic> vehicle) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      List<Map<String, dynamic>> likedVehicles = await getLikedVehicles();

      // Check if vehicle is already liked
      final vehicleId = vehicle['id'] ?? vehicle['name'] ?? '';
      if (!await isVehicleLiked(vehicleId)) {
        // Add unique ID if not present
        if (!vehicle.containsKey('id')) {
          vehicle['id'] = DateTime.now().millisecondsSinceEpoch.toString();
        }

        likedVehicles.add(vehicle);
        _cachedLikedVehicles = likedVehicles; // Update cache
        final String encodedData = json.encode(likedVehicles);
        return await prefs.setString(_likedVehiclesKey, encodedData);
      }
      return true; // Already liked
    } catch (e) {
      print('Error adding liked vehicle: $e');
      return false;
    }
  }

  // Remove a vehicle from liked list
  Future<bool> removeLikedVehicle(String vehicleId) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      List<Map<String, dynamic>> likedVehicles = await getLikedVehicles();

      likedVehicles.removeWhere(
        (vehicle) => (vehicle['id'] ?? vehicle['name'] ?? '') == vehicleId,
      );

      _cachedLikedVehicles = likedVehicles; // Update cache
      final String encodedData = json.encode(likedVehicles);
      return await prefs.setString(_likedVehiclesKey, encodedData);
    } catch (e) {
      print('Error removing liked vehicle: $e');
      return false;
    }
  }

  // Check if a vehicle is liked
  Future<bool> isVehicleLiked(String vehicleId) async {
    List<Map<String, dynamic>> likedVehicles = await getLikedVehicles();
    return likedVehicles.any(
      (vehicle) => (vehicle['id'] ?? vehicle['name'] ?? '') == vehicleId,
    );
  }

  // Check if a vehicle is liked (sync version using cache)
  bool isVehicleLikedSync(String vehicleId) {
    return _cachedLikedVehicles.any(
      (vehicle) => (vehicle['id'] ?? vehicle['name'] ?? '') == vehicleId,
    );
  }

  // Get liked vehicle count
  Future<int> getLikedVehiclesCount() async {
    final vehicles = await getLikedVehicles();
    return vehicles.length;
  }

  // Clear all liked vehicles
  Future<bool> clearAllLikedVehicles() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      return await prefs.remove(_likedVehiclesKey);
    } catch (e) {
      print('Error clearing liked vehicles: $e');
      return false;
    }
  }
}
