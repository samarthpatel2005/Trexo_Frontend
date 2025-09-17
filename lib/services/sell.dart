import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class AdminService {
  static const baseUrl = 'http://209.38.124.176/api/sell';

  static Future<http.Response> addProperty(Map<String, dynamic> data, String token, List<File> imageFiles) async {
    var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/property'));
    
    // Add headers
    request.headers['Authorization'] = 'Bearer $token';
    
    // Add text fields
    data.forEach((key, value) {
      if (value != null) {
        if (value is List) {
          // Convert arrays to JSON string
          request.fields[key] = jsonEncode(value);
        } else {
          request.fields[key] = value.toString();
        }
      }
    });
    
    // Add image files
    for (int i = 0; i < imageFiles.length; i++) {
      var file = await http.MultipartFile.fromPath(
        'images', // This matches the backend field name
        imageFiles[i].path,
      );
      request.files.add(file);
    }
    
    var response = await request.send();
    return await http.Response.fromStream(response);
  }

  static Future<http.Response> addVehicle(Map<String, dynamic> data, String token, List<File> imageFiles) async {
    var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/vehicle'));
    
    // Add headers
    request.headers['Authorization'] = 'Bearer $token';
    
    // Add text fields
    data.forEach((key, value) {
      if (value != null) {
        if (value is List) {
          // Convert arrays to JSON string
          request.fields[key] = jsonEncode(value);
        } else {
          request.fields[key] = value.toString();
        }
      }
    });
    
    // Add image files
    for (int i = 0; i < imageFiles.length; i++) {
      var file = await http.MultipartFile.fromPath(
        'images', // This matches the backend field name
        imageFiles[i].path,
      );
      request.files.add(file);
    }
    
    var response = await request.send();
    return await http.Response.fromStream(response);
  }
}
