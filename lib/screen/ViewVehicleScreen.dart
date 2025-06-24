import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:trexo/widget/VehicleCard.dart'; // Update path as needed

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
      final res = await http.get(Uri.parse('http://localhost:5000/api/view/vehicle'));
      if (res.statusCode == 200) {
        setState(() {
          vehicles = jsonDecode(res.body);
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
      }
    } catch (e) {
      print('Error: $e');
      setState(() => isLoading = false);
    }
  }

  int _getCrossAxisCount(double width) {
    if (width >= 1200) return 4;
    if (width >= 900) return 3;
    if (width >= 600) return 2;
    return 1;
  }

  double _getChildAspectRatio(double width) {
    // Adjust aspect ratio based on screen size for better card proportions
    if (width >= 1200) return 0.75; // Desktop - more compact
    if (width >= 900) return 0.72;  // Tablet landscape
    if (width >= 600) return 0.70;  // Tablet portrait
    return 0.68; // Mobile - slightly taller for better content visibility
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text("View Vehicles"),
        elevation: 2,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : vehicles.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.directions_car_outlined, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        "No vehicles available",
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                    ],
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  child: GridView.builder(
                    physics: const BouncingScrollPhysics(),
                    itemCount: vehicles.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: _getCrossAxisCount(screenWidth),
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                      childAspectRatio: _getChildAspectRatio(screenWidth),
                    ),
                    itemBuilder: (context, index) {
                      final item = vehicles[index];
                      return VehicleCard(
                        name: item['name'] ?? 'Unnamed',
                        model: item['model'] ?? '',
                        price: (item['price'] ?? 0).toDouble(),
                        kmDriven: item['kmDriven'] ?? 0,
                        fuelType: item['fuelType'] ?? '',
                        transmission: item['transmission'] ?? '',
                        rto: item['rto'] ?? '',
                        insurance: item['insurance'] ?? false,
                        location: item['location'] ?? 'Unknown location',
                        imageUrls: List<String>.from(item['imageUrls'] ?? []),
                      );
                    },
                  ),
                ),
    );
  }
}