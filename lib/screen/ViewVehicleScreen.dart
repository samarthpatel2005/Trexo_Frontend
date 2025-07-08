import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:trexo/screen/VehicleDetailsPage.dart';
// import 'package:trexo/widget/InteractiveCard.dart';
import 'package:trexo/widget/vehicle_listing_card.dart';

class ViewVehicleScreen extends StatefulWidget {
  const ViewVehicleScreen({super.key});

  @override
  State<ViewVehicleScreen> createState() => _ViewVehicleScreenState();
}

class _ViewVehicleScreenState extends State<ViewVehicleScreen> {
  List vehicles = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchVehicles();
  }

  Future<void> fetchVehicles() async {
    try {
      final res = await http.get(
        Uri.parse('http://13.203.148.184/api/view/vehicle'),
      );
      if (res.statusCode == 200) {
        setState(() {
          vehicles = jsonDecode(res.body);
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
      appBar: AppBar(title: const Text("View Vehicles")),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : vehicles.isEmpty
              ? const Center(child: Text("No vehicles available"))
              : GridView.builder(
                padding: const EdgeInsets.all(12),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  mainAxisSpacing: 6,
                  crossAxisSpacing: 6,
                  childAspectRatio: 0.75,
                ),
                itemCount: vehicles.length,
                itemBuilder: (context, i) {
                  final item = vehicles[i];
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
                    km: item['km'] ?? '0 km',
                    fuelType: item['fuelType'] ?? 'Petrol',
                    transmission: item['transmission'] ?? 'Manual',
                    registration: item['registration'] ?? 'GJ',
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
    );
  }
}
