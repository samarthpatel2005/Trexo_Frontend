import 'package:flutter/material.dart';
import 'package:trexo/screen/VehicleDetailsPage.dart';
import 'package:trexo/services/liked_vehicles_service.dart';
import 'package:trexo/widget/vehicle_listing_card.dart';

class LikedVehiclesPage extends StatefulWidget {
  const LikedVehiclesPage({super.key});

  @override
  State<LikedVehiclesPage> createState() => _LikedVehiclesPageState();
}

class _LikedVehiclesPageState extends State<LikedVehiclesPage> {
  final LikedVehiclesService _likedService = LikedVehiclesService();
  List<Map<String, dynamic>> likedVehicles = [];

  @override
  void initState() {
    super.initState();
    _loadLikedVehicles();
  }

  void _loadLikedVehicles() async {
    final vehicles = await _likedService.getLikedVehicles();
    setState(() {
      likedVehicles = vehicles;
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
      backgroundColor: Colors.grey[50],
      body:
          likedVehicles.isEmpty
              ? _buildEmptyState()
              : GridView.builder(
                padding: const EdgeInsets.all(12),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  mainAxisSpacing: 6,
                  crossAxisSpacing: 6,
                  childAspectRatio: 0.75,
                ),
                itemCount: likedVehicles.length,
                itemBuilder: (context, index) {
                  final vehicle = likedVehicles[index];
                  return VehicleListingCard(
                    imageUrl:
                        (vehicle['imageUrls'] != null &&
                                vehicle['imageUrls'].isNotEmpty)
                            ? vehicle['imageUrls'][0]
                            : 'https://via.placeholder.com/300x120.png?text=No+Image',
                    name: vehicle['name'] ?? 'Unknown',
                    year: vehicle['registrationYear']?.toString() ?? '2023',
                    variant: vehicle['model'] ?? '',
                    price: (vehicle['price'] ?? 0).toDouble(),
                    emi: vehicle['emi'] ?? 'N/A',
                    kmDriven: vehicle['kmDriven']?.toString() ?? '0',
                    fuelType: vehicle['fuelType'] ?? 'Petrol',
                    transmission: vehicle['transmission'] ?? 'Manual',
                    registration: vehicle['rto'] ?? 'GJ',
                    location: vehicle['location'] ?? 'Unknown',
                    badgeText:
                        vehicle['assured'] == true ? 'Assured' : 'Verified',
                    badgeDescription:
                        vehicle['assured'] == true
                            ? 'High quality, less driven'
                            : 'Latest cars, 3 year warranty',
                    isAssured: vehicle['assured'] == true,
                    isFavorite: true, // Always true for liked vehicles
                    onFavorite: () async {
                      await _likedService.removeLikedVehicle(
                        vehicle['id'] ?? '',
                      );
                      _loadLikedVehicles(); // Refresh the list
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Removed from favorites'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => VehicleDetailsPage(vehicle: vehicle),
                        ),
                      ).then(
                        (_) => _loadLikedVehicles(),
                      ); // Refresh when returning
                    },
                  );
                },
              ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.favorite_border, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 20),
          Text(
            'No Liked Vehicles',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Start exploring vehicles and like your favorites!',
            style: TextStyle(fontSize: 16, color: Colors.grey[500]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
