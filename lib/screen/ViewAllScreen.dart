// import 'dart:convert';

// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:trexo/services/admin_service.dart';
// import 'package:trexo/widget/property_listing_card.dart';
// import 'package:trexo/widget/vehicle_listing_card.dart';
// // import 'package:trexo/widget/InteractiveCard.dart';

// class ViewAllScreen extends StatefulWidget {
//   const ViewAllScreen({super.key});

//   @override
//   State<ViewAllScreen> createState() => _ViewAllScreenState();
// }

// class _ViewAllScreenState extends State<ViewAllScreen>
//     with TickerProviderStateMixin {
//   late TabController _tabController;
//   List properties = [];
//   List vehicles = [];
//   bool isLoading = true;

//   @override
//   void initState() {
//     super.initState();
//     _tabController = TabController(length: 2, vsync: this);
//     fetchData();
//   }

//   Future<void> fetchData() async {
//     final prefs = await SharedPreferences.getInstance();
//     final token = prefs.getString('token') ?? '';

//     try {
//       final propRes = await AdminService.getProperties(token);
//       final vehRes = await AdminService.getVehicles(token);

//       if (propRes.statusCode == 200 && vehRes.statusCode == 200) {
//         setState(() {
//           properties = jsonDecode(propRes.body);
//           vehicles = jsonDecode(vehRes.body);
//           isLoading = false;
//         });
//       } else {
//         setState(() => isLoading = false);
//         print("Failed to load data");
//       }
//     } catch (e) {
//       setState(() => isLoading = false);
//       print("Error: $e");
//     }
//   }

//   Widget buildPropertyCard(Map data) {
//     return PropertyListingCard(
//       imageUrl:
//           (data['imageUrls'] != null && data['imageUrls'].isNotEmpty)
//               ? data['imageUrls'][0]
//               : 'https://via.placeholder.com/300x120.png?text=No+Image',
//       title: data['title'] ?? '',
//       price: (data['price'] ?? 0).toDouble(),
//       location: data['location'] ?? '',
//       onDetailsPressed: () {},
//     );
//   }

//   Widget buildVehicleCard(Map data) {
//     return VehicleListingCard(
//       imageUrl:
//           (data['imageUrls'] != null && data['imageUrls'].isNotEmpty)
//               ? data['imageUrls'][0]
//               : 'https://via.placeholder.com/300x120.png?text=No+Image',
//       name: data['name'] ?? '',
//       year: data['year']?.toString() ?? '2023',
//       variant: data['model'] ?? '',
//       price: (data['price'] ?? 0).toDouble(),
//       emi: data['emi'] ?? 'N/A',
//       km: data['km'] ?? '0 km',
//       fuelType: data['fuelType'] ?? 'Petrol',
//       transmission: data['transmission'] ?? 'Manual',
//       registration: data['registration'] ?? 'GJ',
//       location: data['location'] ?? 'Unknown',
//       badgeText: data['assured'] == true ? 'Assured' : 'Verified',
//       badgeDescription:
//           data['assured'] == true
//               ? 'High quality, less driven'
//               : 'Latest cars, 3 year warranty',
//       isAssured: data['assured'] == true,
//       isFavorite: false,
//       onFavorite: () {},
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("All Listings"),
//         bottom: TabBar(
//           controller: _tabController,
//           tabs: const [Tab(text: "Properties"), Tab(text: "Vehicles")],
//         ),
//       ),
//       body:
//           isLoading
//               ? const Center(child: CircularProgressIndicator())
//               : TabBarView(
//                 controller: _tabController,
//                 children: [
//                   properties.isEmpty
//                       ? const Center(child: Text("No properties found"))
//                       : ListView.builder(
//                         padding: const EdgeInsets.all(8),
//                         itemCount: properties.length,
//                         itemBuilder: (_, i) => buildPropertyCard(properties[i]),
//                       ),
//                   vehicles.isEmpty
//                       ? const Center(child: Text("No vehicles found"))
//                       : ListView.builder(
//                         padding: const EdgeInsets.all(8),
//                         itemCount: vehicles.length,
//                         itemBuilder: (_, i) => buildVehicleCard(vehicles[i]),
//                       ),
//                 ],
//               ),
//     );
//   }
// }