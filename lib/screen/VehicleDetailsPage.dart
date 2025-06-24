import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:carousel_slider/carousel_slider.dart';

class VehicleDetailsPage extends StatelessWidget {
  final Map<String, dynamic> vehicle;

  const VehicleDetailsPage({super.key, required this.vehicle});

  String formatPrice(num price) => '₹${NumberFormat('#,##,000.00').format(price)} Lakh';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(vehicle['name'] ?? 'Vehicle Details')),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildImageCarousel(vehicle['imageUrls']),
            _buildHeaderSection(),
            _buildOverviewSection(),
            _buildQualityReportSection(),
            const SizedBox(height: 80),
          ],
        ),
      ),
      bottomSheet: Container(
        color: Colors.white,
        padding: const EdgeInsets.all(12),
        child: SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.purple),
            onPressed: () {},
            child: const Text("BOOK NOW", style: TextStyle(color: Colors.white)),
          ),
        ),
      ),
    );
  }

  Widget _buildImageCarousel(List images) {
    return CarouselSlider(
      items: images
          .map<Widget>((url) => Image.network(url, fit: BoxFit.cover, width: double.infinity))
          .toList(),
      options: CarouselOptions(
        height: 240,
        viewportFraction: 1.0,
        enableInfiniteScroll: false,
        enlargeCenterPage: false,
      ),
    );
  }

  Widget _buildHeaderSection() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('${vehicle['registrationYear']} ${vehicle['name']} ${vehicle['model']}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          Text('${vehicle['kmDriven']} km · ${vehicle['fuelType']} · ${vehicle['transmission']}'),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.location_on_outlined, size: 18, color: Colors.grey),
              const SizedBox(width: 4),
              Expanded(child: Text(vehicle['location'] ?? '', style: const TextStyle(fontSize: 14)))
            ],
          ),
          const SizedBox(height: 12),
          Text("Fixed on road price", style: TextStyle(color: Colors.grey[700])),
          const SizedBox(height: 4),
          Text(formatPrice(vehicle['price']), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildOverviewSection() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Car Overview", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 10),
          _overviewRow("Make Year", vehicle['registrationYear']?.toString() ?? '-'),
          _overviewRow("Fuel Type", vehicle['fuelType']),
          _overviewRow("Transmission", vehicle['transmission']),
          _overviewRow("No. of Owner", vehicle['owner']),
          _overviewRow("Insurance", vehicle['insurance'] == true ? 'Valid' : 'Not Available'),
          _overviewRow("RTO", vehicle['rto']),
          _overviewRow("Location", vehicle['location']),
        ],
      ),
    );
  }

  Widget _overviewRow(String title, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(child: Text(title, style: const TextStyle(fontWeight: FontWeight.w500))),
          Expanded(child: Text(value ?? '-', style: const TextStyle(color: Colors.grey))),
        ],
      ),
    );
  }

  Widget _buildQualityReportSection() {
    final points = [
      vehicle['batteryHealth'],
      vehicle['tireCondition'],
      vehicle['brakeCondition'],
      vehicle['engineCondition'],
      vehicle['steering'],
      vehicle['suspension']
    ];

    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Quality Report", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 10),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: points
                .where((e) => e != null && e.toString().isNotEmpty)
                .map((e) => Chip(
                      label: Text(e),
                      backgroundColor: Colors.green[50],
                    ))
                .toList(),
          )
        ],
      ),
    );
  }
}
