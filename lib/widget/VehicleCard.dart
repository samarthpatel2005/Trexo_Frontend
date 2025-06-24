import 'package:flutter/material.dart';
import 'package:trexo/screen/VehicleDetailsPage.dart';

class VehicleCard extends StatelessWidget {
  final String name;
  final String model;
  final double price;
  final int kmDriven;
  final String fuelType;
  final String transmission;
  final String rto;
  final String location;
  final List<String> imageUrls;
  final bool insurance;

  const VehicleCard({
    super.key,
    required this.name,
    required this.model,
    required this.price,
    required this.kmDriven,
    required this.fuelType,
    required this.transmission,
    required this.rto,
    required this.location,
    required this.imageUrls,
    required this.insurance,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(4),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          // ✅ Navigate to VehicleDetailsPage
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => VehicleDetailsPage(
                vehicle: {
                  'name': name,
                  'model': model,
                  'price': price,
                  'kmDriven': kmDriven,
                  'fuelType': fuelType,
                  'transmission': transmission,
                  'rto': rto,
                  'location': location,
                  'imageUrls': imageUrls,
                  'insurance': insurance,
                  'registrationYear': null, // You can pass actual values
                  'owner': null,
                  'batteryHealth': null,
                  'tireCondition': null,
                  'brakeCondition': null,
                  'engineCondition': null,
                  'steering': null,
                  'suspension': null,
                },
              ),
            ),
          );
        },
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Image Section
            Stack(
              children: [
                Image.network(
                  imageUrls.isNotEmpty ? imageUrls[0] : '',
                  height: 160,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    height: 160,
                    color: Colors.grey[200],
                    child: const Center(
                      child: Icon(Icons.broken_image, size: 40, color: Colors.grey),
                    ),
                  ),
                ),
                if (insurance)
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.green[700],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'Insured',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            
            // Content Section - Minimal padding for tighter layout
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title and Model
                  Text(
                    name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    model,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // Price
                  Text(
                    "₹${price.toStringAsFixed(2)} Lakh",
                    style: TextStyle(
                      color: Colors.green[700],
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  
                  const SizedBox(height: 10),
                  
                  // Info Chips
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      _infoChip("${(kmDriven / 1000).toStringAsFixed(1)}K km"),
                      _infoChip(fuelType),
                      _infoChip(transmission),
                      _infoChip(rto),
                    ],
                  ),
                  
                  const SizedBox(height: 10),
                  
                  // Location
                  Row(
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        size: 16,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          location,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[700],
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey[300]!, width: 0.5),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          color: Colors.grey[700],
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}