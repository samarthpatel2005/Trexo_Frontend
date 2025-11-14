import 'dart:convert';
import 'package:http/http.dart' as http;

class SearchService {
  static const String baseUrl = 'http://209.38.124.176/api';

  // Vehicle search filters
  static Future<List<Map<String, dynamic>>> searchVehicles({
    String? query,
    String? fuelType,
    String? transmission,
    String? location,
    double? minPrice,
    double? maxPrice,
    int? minYear,
    int? maxYear,
    int? maxKmDriven,
    String? sortBy,
    bool? isAssured,
  }) async {
    try {
      // Get all vehicles first
      final response = await http.get(Uri.parse('$baseUrl/view/vehicle'));
      
      if (response.statusCode != 200) {
        throw Exception('Failed to load vehicles');
      }

      List<dynamic> allVehicles = jsonDecode(response.body);
      List<Map<String, dynamic>> vehicles = List<Map<String, dynamic>>.from(allVehicles);

      // Apply filters
      List<Map<String, dynamic>> filteredVehicles = vehicles.where((vehicle) {
        // Text search across multiple fields
        if (query != null && query.isNotEmpty) {
          final queryLower = query.toLowerCase();
          final searchFields = [
            vehicle['name']?.toString().toLowerCase() ?? '',
            vehicle['model']?.toString().toLowerCase() ?? '',
            vehicle['fuelType']?.toString().toLowerCase() ?? '',
            vehicle['transmission']?.toString().toLowerCase() ?? '',
            vehicle['location']?.toString().toLowerCase() ?? '',
            vehicle['rto']?.toString().toLowerCase() ?? '',
            vehicle['year']?.toString() ?? '',
            vehicle['kmDriven']?.toString() ?? '',
          ];
          
          if (!searchFields.any((field) => field.contains(queryLower))) {
            return false;
          }
        }

        // Fuel type filter
        if (fuelType != null && fuelType.isNotEmpty && fuelType != 'All') {
          if (vehicle['fuelType']?.toString().toLowerCase() != fuelType.toLowerCase()) {
            return false;
          }
        }

        // Transmission filter
        if (transmission != null && transmission.isNotEmpty && transmission != 'All') {
          if (vehicle['transmission']?.toString().toLowerCase() != transmission.toLowerCase()) {
            return false;
          }
        }

        // Location filter
        if (location != null && location.isNotEmpty && location != 'All') {
          final vehicleLocation = vehicle['location']?.toString().toLowerCase() ?? '';
          if (!vehicleLocation.contains(location.toLowerCase())) {
            return false;
          }
        }

        // Price range filter
        if (minPrice != null || maxPrice != null) {
          final price = (vehicle['price'] as num?)?.toDouble() ?? 0.0;
          if (minPrice != null && price < minPrice) return false;
          if (maxPrice != null && price > maxPrice) return false;
        }

        // Year range filter
        if (minYear != null || maxYear != null) {
          final year = vehicle['year'] as int? ?? 0;
          if (minYear != null && year < minYear) return false;
          if (maxYear != null && year > maxYear) return false;
        }

        // KM driven filter
        if (maxKmDriven != null) {
          final kmDriven = int.tryParse(vehicle['kmDriven']?.toString() ?? '0') ?? 0;
          if (kmDriven > maxKmDriven) return false;
        }

        // Assured filter
        if (isAssured != null) {
          final assured = vehicle['assured'] as bool? ?? false;
          if (assured != isAssured) return false;
        }

        return true;
      }).toList();

      // Apply sorting
      if (sortBy != null) {
        switch (sortBy) {
          case 'price_low_to_high':
            filteredVehicles.sort((a, b) {
              final priceA = (a['price'] as num?)?.toDouble() ?? 0.0;
              final priceB = (b['price'] as num?)?.toDouble() ?? 0.0;
              return priceA.compareTo(priceB);
            });
            break;
          case 'price_high_to_low':
            filteredVehicles.sort((a, b) {
              final priceA = (a['price'] as num?)?.toDouble() ?? 0.0;
              final priceB = (b['price'] as num?)?.toDouble() ?? 0.0;
              return priceB.compareTo(priceA);
            });
            break;
          case 'year_new_to_old':
            filteredVehicles.sort((a, b) {
              final yearA = a['year'] as int? ?? 0;
              final yearB = b['year'] as int? ?? 0;
              return yearB.compareTo(yearA);
            });
            break;
          case 'year_old_to_new':
            filteredVehicles.sort((a, b) {
              final yearA = a['year'] as int? ?? 0;
              final yearB = b['year'] as int? ?? 0;
              return yearA.compareTo(yearB);
            });
            break;
          case 'km_low_to_high':
            filteredVehicles.sort((a, b) {
              final kmA = int.tryParse(a['kmDriven']?.toString() ?? '0') ?? 0;
              final kmB = int.tryParse(b['kmDriven']?.toString() ?? '0') ?? 0;
              return kmA.compareTo(kmB);
            });
            break;
        }
      }

      return filteredVehicles;
    } catch (e) {
      print('Error searching vehicles: $e');
      return [];
    }
  }

  // Property search filters
  static Future<List<Map<String, dynamic>>> searchProperties({
    String? query,
    String? propertyType,
    String? location,
    double? minPrice,
    double? maxPrice,
    String? sortBy,
    int? minBedrooms,
    int? maxBedrooms,
    int? minBathrooms,
    int? maxBathrooms,
    String? furnishing,
    bool? isFeatured,
    String? minArea,
    String? maxArea,
  }) async {
    try {
      // Get all properties first
      final response = await http.get(Uri.parse('$baseUrl/view/property'));
      
      if (response.statusCode != 200) {
        throw Exception('Failed to load properties');
      }

      List<dynamic> allProperties = jsonDecode(response.body);
      List<Map<String, dynamic>> properties = List<Map<String, dynamic>>.from(allProperties);

      // Apply filters
      List<Map<String, dynamic>> filteredProperties = properties.where((property) {
        // Text search across multiple fields
        if (query != null && query.isNotEmpty) {
          final queryLower = query.toLowerCase();
          final searchFields = [
            property['title']?.toString().toLowerCase() ?? '',
            property['location']?.toString().toLowerCase() ?? '',
            property['description']?.toString().toLowerCase() ?? '',
            property['area']?.toString() ?? '',
            property['bedrooms']?.toString() ?? '',
            property['bathrooms']?.toString() ?? '',
            property['furnishing']?.toString().toLowerCase() ?? '',
            property['propertyType']?.toString().toLowerCase() ?? '',
            property['address']?.toString().toLowerCase() ?? '',
          ];
          
          // Also search in tags if available
          final tags = property['tags'] as List? ?? [];
          for (var tag in tags) {
            searchFields.add(tag.toString().toLowerCase());
          }
          
          // Also search in amenities if available
          final amenities = property['amenities'] as List? ?? [];
          for (var amenity in amenities) {
            searchFields.add(amenity.toString().toLowerCase());
          }
          
          if (!searchFields.any((field) => field.contains(queryLower))) {
            return false;
          }
        }

        // Property type filter
        if (propertyType != null && propertyType.isNotEmpty && propertyType != 'All') {
          final type = property['propertyType']?.toString().toLowerCase() ?? 
                      property['type']?.toString().toLowerCase() ?? '';
          if (type != propertyType.toLowerCase()) {
            return false;
          }
        }

        // Location filter
        if (location != null && location.isNotEmpty && location != 'All') {
          final propertyLocation = property['location']?.toString().toLowerCase() ?? '';
          final propertyAddress = property['address']?.toString().toLowerCase() ?? '';
          if (!propertyLocation.contains(location.toLowerCase()) && 
              !propertyAddress.contains(location.toLowerCase())) {
            return false;
          }
        }

        // Price range filter
        if (minPrice != null || maxPrice != null) {
          final price = (property['price'] as num?)?.toDouble() ?? 0.0;
          if (minPrice != null && price < minPrice) return false;
          if (maxPrice != null && price > maxPrice) return false;
        }

        // Bedroom filter
        if (minBedrooms != null || maxBedrooms != null) {
          final bedrooms = property['bedrooms'] as int? ?? 0;
          if (minBedrooms != null && bedrooms < minBedrooms) return false;
          if (maxBedrooms != null && bedrooms > maxBedrooms) return false;
        }

        // Bathroom filter
        if (minBathrooms != null || maxBathrooms != null) {
          final bathrooms = property['bathrooms'] as int? ?? 0;
          if (minBathrooms != null && bathrooms < minBathrooms) return false;
          if (maxBathrooms != null && bathrooms > maxBathrooms) return false;
        }

        // Furnishing filter
        if (furnishing != null && furnishing.isNotEmpty && furnishing != 'All') {
          final propertyFurnishing = property['furnishing']?.toString().toLowerCase() ?? '';
          if (propertyFurnishing != furnishing.toLowerCase()) {
            return false;
          }
        }

        // Featured filter
        if (isFeatured != null) {
          final featured = property['featured'] as bool? ?? false;
          if (featured != isFeatured) return false;
        }

        // Area filter
        if (minArea != null || maxArea != null) {
          final areaStr = property['area']?.toString() ?? '0';
          final area = double.tryParse(areaStr.replaceAll(RegExp(r'[^\d.]'), '')) ?? 0.0;
          final minAreaVal = double.tryParse(minArea ?? '0') ?? 0.0;
          final maxAreaVal = double.tryParse(maxArea ?? double.infinity.toString()) ?? double.infinity;
          if (area < minAreaVal || area > maxAreaVal) return false;
        }

        return true;
      }).toList();

      // Apply sorting
      if (sortBy != null) {
        switch (sortBy) {
          case 'price_low_to_high':
            filteredProperties.sort((a, b) {
              final priceA = (a['price'] as num?)?.toDouble() ?? 0.0;
              final priceB = (b['price'] as num?)?.toDouble() ?? 0.0;
              return priceA.compareTo(priceB);
            });
            break;
          case 'price_high_to_low':
            filteredProperties.sort((a, b) {
              final priceA = (a['price'] as num?)?.toDouble() ?? 0.0;
              final priceB = (b['price'] as num?)?.toDouble() ?? 0.0;
              return priceB.compareTo(priceA);
            });
            break;
          case 'newest_first':
            filteredProperties.sort((a, b) {
              final createdA = DateTime.tryParse(a['createdAt']?.toString() ?? '') ?? DateTime(1970);
              final createdB = DateTime.tryParse(b['createdAt']?.toString() ?? '') ?? DateTime(1970);
              return createdB.compareTo(createdA);
            });
            break;
          case 'area_large_to_small':
            filteredProperties.sort((a, b) {
              final areaA = double.tryParse(a['area']?.toString().replaceAll(RegExp(r'[^\d.]'), '') ?? '0') ?? 0.0;
              final areaB = double.tryParse(b['area']?.toString().replaceAll(RegExp(r'[^\d.]'), '') ?? '0') ?? 0.0;
              return areaB.compareTo(areaA);
            });
            break;
          case 'bedrooms_high_to_low':
            filteredProperties.sort((a, b) {
              final bedroomsA = a['bedrooms'] as int? ?? 0;
              final bedroomsB = b['bedrooms'] as int? ?? 0;
              return bedroomsB.compareTo(bedroomsA);
            });
            break;
        }
      }

      return filteredProperties;
    } catch (e) {
      print('Error searching properties: $e');
      return [];
    }
  }

  // Get unique filter options for vehicles
  static Future<Map<String, List<String>>> getVehicleFilterOptions() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/view/vehicle'));
      
      if (response.statusCode != 200) {
        return {
          'fuelTypes': [],
          'transmissions': [],
          'locations': [],
        };
      }

      List<dynamic> vehicles = jsonDecode(response.body);
      
      Set<String> fuelTypes = {};
      Set<String> transmissions = {};
      Set<String> locations = {};

      for (var vehicle in vehicles) {
        if (vehicle['fuelType'] != null) {
          fuelTypes.add(vehicle['fuelType'].toString());
        }
        if (vehicle['transmission'] != null) {
          transmissions.add(vehicle['transmission'].toString());
        }
        if (vehicle['location'] != null) {
          locations.add(vehicle['location'].toString());
        }
      }

      return {
        'fuelTypes': fuelTypes.toList()..sort(),
        'transmissions': transmissions.toList()..sort(),
        'locations': locations.toList()..sort(),
      };
    } catch (e) {
      print('Error getting vehicle filter options: $e');
      return {
        'fuelTypes': [],
        'transmissions': [],
        'locations': [],
      };
    }
  }

  // Get unique filter options for properties
  static Future<Map<String, List<String>>> getPropertyFilterOptions() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/view/property'));
      
      if (response.statusCode != 200) {
        return {
          'locations': [],
          'propertyTypes': [],
          'furnishingTypes': [],
        };
      }

      List<dynamic> properties = jsonDecode(response.body);
      
      Set<String> locations = {};
      Set<String> propertyTypes = {};
      Set<String> furnishingTypes = {};

      for (var property in properties) {
        if (property['location'] != null) {
          locations.add(property['location'].toString());
        }
        if (property['address'] != null) {
          locations.add(property['address'].toString());
        }
        if (property['propertyType'] != null) {
          propertyTypes.add(property['propertyType'].toString());
        }
        if (property['type'] != null) {
          propertyTypes.add(property['type'].toString());
        }
        if (property['furnishing'] != null) {
          furnishingTypes.add(property['furnishing'].toString());
        }
      }

      return {
        'locations': locations.toList()..sort(),
        'propertyTypes': propertyTypes.toList()..sort(),
        'furnishingTypes': furnishingTypes.toList()..sort(),
      };
    } catch (e) {
      print('Error getting property filter options: $e');
      return {
        'locations': [],
        'propertyTypes': [],
        'furnishingTypes': [],
      };
    }
  }
}