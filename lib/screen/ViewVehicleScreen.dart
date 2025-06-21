import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:trexo/widget/InteractiveCard.dart';

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
        throw Exception('Failed to load vehicles');
      }
    } catch (e) {
      print('Error: $e');
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("View Vehicles")),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : vehicles.isEmpty
              ? const Center(child: Text("No vehicles available"))
              : ListView.builder(
                  padding: const EdgeInsets.all(10),
                  itemCount: vehicles.length,
                  itemBuilder: (_, i) {
                    final item = vehicles[i];
                    return InteractiveListingCard(
                      title: item['name'],
                      price: (item['price'] ?? 0).toDouble(),
                      location: item['model'],
                      imageUrls: List<String>.from(item['imageUrls'] ?? []),
                    );
                  },
                ),
    );
  }
}
