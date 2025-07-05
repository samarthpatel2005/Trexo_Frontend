import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';

class PropertyDetailsPage extends StatelessWidget {
  final Map<String, dynamic> property;

  const PropertyDetailsPage({super.key, required this.property});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(property['title'] ?? 'Property Details')),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildImageCarousel(property['imageUrls']),
            _buildHeaderSection(),
            _buildOverviewSection(),
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
            child: const Text(
              "BOOK NOW",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImageCarousel(List? images) {
    if (images == null || images.isEmpty) {
      return Container(
        height: 160,
        color: Colors.grey[200],
        child: const Center(
          child: Icon(Icons.home, size: 60, color: Colors.grey),
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: CarouselSlider(
          items:
              images
                  .map<Widget>(
                    (url) => Image.network(
                      url,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: 160,
                    ),
                  )
                  .toList(),
          options: CarouselOptions(
            height: 160,
            viewportFraction: 1.0,
            enableInfiniteScroll: false,
            enlargeCenterPage: false,
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderSection() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            property['title'] ?? '',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          Text(
            property['location'] ?? '',
            style: const TextStyle(fontSize: 14),
          ),
          const SizedBox(height: 8),
          Text("Price", style: TextStyle(color: Colors.grey[700])),
          const SizedBox(height: 4),
          Text(
            '₹${property['price']?.toStringAsFixed(2) ?? '-'}',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
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
          const Text(
            "Property Overview",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 10),
          _overviewRow("Type", property['type']),
          _overviewRow("Area", property['area']),
          _overviewRow("Bedrooms", property['bedrooms']?.toString()),
          _overviewRow("Bathrooms", property['bathrooms']?.toString()),
          _overviewRow("Furnishing", property['furnishing']),
          _overviewRow("Status", property['status']),
        ],
      ),
    );
  }

  Widget _overviewRow(String title, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(
              value ?? '-',
              style: const TextStyle(color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }
}
