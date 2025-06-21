// import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trexo/services/admin_service.dart';
import 'package:trexo/widget/InteractiveCard.dart';

class ViewAllScreen extends StatefulWidget {
  const ViewAllScreen({super.key});

  @override
  State<ViewAllScreen> createState() => _ViewAllScreenState();
}

class _ViewAllScreenState extends State<ViewAllScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  List properties = [];
  List vehicles = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    fetchData();
  }

  Future<void> fetchData() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';

    try {
      final propRes = await AdminService.getProperties();
      final vehRes = await AdminService.getVehicles();

      setState(() {
        properties = propRes;
        vehicles = vehRes;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      print("Error: $e");
    }
  }

  Widget buildPropertyCard(Map data) {
    return InteractiveListingCard(
      title: data['title'] ?? '',
      price: (data['price'] ?? 0).toDouble(),
      location: data['location'] ?? '',
      imageUrls: List<String>.from(data['imageUrls'] ?? []),
    );
  }

  Widget buildVehicleCard(Map data) {
    return InteractiveListingCard(
      title: data['name'] ?? '',
      price: (data['price'] ?? 0).toDouble(),
      location: data['model'] ?? '',
      imageUrls: List<String>.from(data['imageUrls'] ?? []),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("All Listings"),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: "Properties"),
            Tab(text: "Vehicles"),
          ],
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                properties.isEmpty
                    ? const Center(child: Text("No properties found"))
                    : ListView.builder(
                        padding: const EdgeInsets.all(8),
                        itemCount: properties.length,
                        itemBuilder: (_, i) => buildPropertyCard(properties[i]),
                      ),
                vehicles.isEmpty
                    ? const Center(child: Text("No vehicles found"))
                    : ListView.builder(
                        padding: const EdgeInsets.all(8),
                        itemCount: vehicles.length,
                        itemBuilder: (_, i) => buildVehicleCard(vehicles[i]),
                      ),
              ],
            ),
    );
  }
}
