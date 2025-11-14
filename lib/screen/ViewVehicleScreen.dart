import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:trexo/screen/VehicleDetailsPage.dart';
import 'package:trexo/widget/vehicle_listing_card.dart';
import 'package:trexo/widget/search_and_filter_widget.dart';

class ViewVehicleScreen extends StatefulWidget {
  const ViewVehicleScreen({super.key});

  @override
  State<ViewVehicleScreen> createState() => _ViewVehicleScreenState();
}

class _ViewVehicleScreenState extends State<ViewVehicleScreen> {
  List<Map<String, dynamic>> vehicles = [];
  List<Map<String, dynamic>> filteredVehicles = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchVehicles();
  }

  Future<void> fetchVehicles() async {
    try {
      final res = await http.get(
        Uri.parse('http://209.38.124.176/api/view/vehicle'),
      );
      if (res.statusCode == 200) {
        final List<dynamic> data = jsonDecode(res.body);
        setState(() {
          vehicles = List<Map<String, dynamic>>.from(data);
          filteredVehicles = List<Map<String, dynamic>>.from(data);
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load vehicles');
      }
    } catch (e) {
      print('Error: $e');
      setState(() => isLoading = false);
    }
  }

  void _onSearchResultsChanged(List<Map<String, dynamic>> results) {
    setState(() {
      filteredVehicles = results;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    int crossAxisCount;
    if (screenWidth >= 1200) {
      crossAxisCount = 4;
    } else if (screenWidth >= 900) {
      crossAxisCount = 3;
    } else if (screenWidth >= 600) {
      crossAxisCount = 2;
    } else {
      crossAxisCount = 1;
    }

    return Scaffold(
      body: isLoading
        ? const Center(child: CircularProgressIndicator())
        : Column(
            children: [
              // Search and Filter Widget
              SearchAndFilterWidget(
                searchType: 'vehicle',
                onResultsChanged: _onSearchResultsChanged,
                allItems: vehicles,
              ),
              
              // Results Count
              if (!isLoading)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      Text(
                        '${filteredVehicles.length} vehicles found',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                ),
              
              // Vehicle Grid
              Expanded(
                child: filteredVehicles.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.search_off,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No vehicles found',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Try adjusting your search or filters',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    )
                  : GridView.builder(
                      padding: const EdgeInsets.all(12),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        mainAxisSpacing: 6,
                        crossAxisSpacing: 6,
                        childAspectRatio: 0.75,
                      ),
                      itemCount: filteredVehicles.length,
                      itemBuilder: (context, i) {
                        final item = filteredVehicles[i];
                        return VehicleListingCard(
                          imageUrl:
                              (item['imageUrls'] != null &&
                                      item['imageUrls'].isNotEmpty)
                                  ? item['imageUrls'][0]
                                  : 'https://via.placeholder.com/300x120.png?text=No+Image',
                          name: item['name'] ?? 'Unknown',
                          year: item['year']?.toString() ?? '2023',
                          variant: item['model'] ?? '',
                          price: (item['price'] ?? 0).toDouble(),
                          emi: item['emi'] ?? 'N/A',
                          kmDriven: item['kmDriven']?.toString() ?? '0',
                          fuelType: item['fuelType'] ?? 'Petrol',
                          transmission: item['transmission'] ?? 'Manual',
                          registration: item['rto'] ?? 'GJ',
                          location: item['location'] ?? 'Unknown',
                          badgeText: item['assured'] == true ? 'Assured' : 'Verified',
                          badgeDescription:
                              item['assured'] == true
                                  ? 'High quality, less driven'
                                  : 'Latest cars, 3 year warranty',
                          isAssured: item['assured'] == true,
                          isFavorite: false,
                          onFavorite: () {},
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) => VehicleDetailsPage(vehicle: item),
                              ),
                            );
                          },
                        );
                      },
                    ),
              ),
            ],
          ),
    );
  }
}
