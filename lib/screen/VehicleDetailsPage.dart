import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class VehicleDetailsPage extends StatelessWidget {
  final Map<String, dynamic> vehicle;

  const VehicleDetailsPage({super.key, required this.vehicle});

  String formatPrice(num price) =>
      '₹${NumberFormat('#,##,000.00').format(price)}';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(vehicle['name'] ?? 'Vehicle Details'),
        actions: [
          IconButton(icon: const Icon(Icons.favorite_border), onPressed: () {}),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _ImageCarouselWithArrows(imageUrls: vehicle['imageUrls'] ?? []),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              '${vehicle['registrationYear']} ${vehicle['name']} ${vehicle['model']}',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          _iconText(Icons.speed, '${vehicle['kmDriven']} km'),
                          _dot(),
                          _iconText(
                            Icons.local_gas_station,
                            vehicle['fuelType'],
                          ),
                          _dot(),
                          _iconText(Icons.settings, vehicle['transmission']),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on_outlined,
                            size: 18,
                            color: Colors.grey,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              vehicle['location'] ?? '',
                              style: const TextStyle(fontSize: 14),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            _buildPriceSection(context),
            _buildOverviewSection(),
            _buildQualityReportSection(),
            _buildShareSection(),
            const SizedBox(height: 80),
          ],
        ),
      ),
      bottomSheet: _buildBottomButtons(context),
    );
  }

  Widget _iconText(IconData icon, String? text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey[700]),
        const SizedBox(width: 4),
        Text(text ?? '-', style: const TextStyle(fontSize: 13)),
      ],
    );
  }

  Widget _dot() => const Padding(
    padding: EdgeInsets.symmetric(horizontal: 6),
    child: Text('·', style: TextStyle(fontSize: 16, color: Colors.grey)),
  );

  Widget _buildPriceSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Card(
        color: Colors.purple[50],
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text(
                    "Fixed on road price",
                    style: TextStyle(
                      color: Colors.black54,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.purple[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      "Assured",
                      style: TextStyle(fontSize: 12, color: Colors.purple),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                formatPrice(vehicle['price']),
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.purple,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "Includes RC transfer, insurance & more",
                style: TextStyle(color: Colors.grey[700], fontSize: 13),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Text(
                    "or ",
                    style: TextStyle(color: Colors.grey[700], fontSize: 13),
                  ),
                  Text(
                    "₹16,326/m ",
                    style: TextStyle(
                      color: Colors.purple[700],
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  Text(
                    "Starting EMI",
                    style: TextStyle(color: Colors.grey[700], fontSize: 13),
                  ),
                  const Spacer(),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple[100],
                      foregroundColor: Colors.purple[900],
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      textStyle: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    onPressed: () {},
                    child: const Text("Calculate your EMI"),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomButtons(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(12),
      child: SizedBox(
        width: double.infinity,
        height: 48,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.purple,
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
          onPressed: () {},
          child: const Text(
            "BOOK NOW",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  Widget _buildOverviewSection() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Card(
        elevation: 1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Car Overview",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 10),
              _overviewRow(
                "Make Year",
                vehicle['registrationYear']?.toString() ?? '-',
              ),
              _overviewRow("Fuel Type", vehicle['fuelType']),
              _overviewRow("Transmission", vehicle['transmission']),
              _overviewRow("No. of Owner", vehicle['owner']),
              _overviewRow(
                "Insurance",
                vehicle['insurance'] == true ? 'Valid' : 'Not Available',
              ),
              _overviewRow("RTO", vehicle['rto']),
              _overviewRow("Location", vehicle['location']),
            ],
          ),
        ),
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

  Widget _buildQualityReportSection() {
    final points = [
      vehicle['batteryHealth'],
      vehicle['tireCondition'],
      vehicle['brakeCondition'],
      vehicle['engineCondition'],
      vehicle['steering'],
      vehicle['suspension'],
    ];

    return Padding(
      padding: const EdgeInsets.all(12),
      child: Card(
        elevation: 1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Quality Report",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children:
                    points
                        .where((e) => e != null && e.toString().isNotEmpty)
                        .map(
                          (e) => Chip(
                            label: Text(e),
                            backgroundColor: Colors.green[50],
                          ),
                        )
                        .toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildShareSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          const Text(
            "Share with a friend :",
            style: TextStyle(fontWeight: FontWeight.w500, fontSize: 15),
          ),
          const SizedBox(width: 12),
          IconButton(
            icon: const Icon(Icons.camera_alt, color: Colors.purple),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.facebook, color: Colors.blue),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.email, color: Colors.deepPurple),
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}

class _ImageCarouselWithArrows extends StatefulWidget {
  final List imageUrls;
  const _ImageCarouselWithArrows({Key? key, required this.imageUrls})
    : super(key: key);

  @override
  State<_ImageCarouselWithArrows> createState() =>
      _ImageCarouselWithArrowsState();
}

class _ImageCarouselWithArrowsState extends State<_ImageCarouselWithArrows> {
  int _current = 0;
  final CarouselSliderController _controller = CarouselSliderController();

  @override
  Widget build(BuildContext context) {
    final List<String> images = List<String>.from(widget.imageUrls);
    return Stack(
      children: [
        CarouselSlider(
          carouselController: _controller,
          items:
              images.isNotEmpty
                  ? images
                      .map<Widget>(
                        (url) => Image.network(
                          url,
                          fit: BoxFit.cover,
                          width: double.infinity,
                        ),
                      )
                      .toList()
                  : [
                    Container(
                      color: Colors.grey[200],
                      width: double.infinity,
                      height: 240,
                      child: const Icon(
                        Icons.directions_car,
                        size: 100,
                        color: Colors.grey,
                      ),
                    ),
                  ],
          options: CarouselOptions(
            height: 240,
            viewportFraction: 1.0,
            enableInfiniteScroll: false,
            enlargeCenterPage: false,
            onPageChanged: (index, reason) {
              setState(() {
                _current = index;
              });
            },
          ),
        ),
        if (images.length > 1)
          Positioned(
            left: 8,
            top: 0,
            bottom: 0,
            child: Center(
              child: IconButton(
                icon: const Icon(
                  Icons.arrow_back_ios,
                  color: Colors.black54,
                  size: 28,
                ),
                onPressed:
                    _current > 0
                        ? () => _controller.previousPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.ease,
                        )
                        : null,
              ),
            ),
          ),
        if (images.length > 1)
          Positioned(
            right: 8,
            top: 0,
            bottom: 0,
            child: Center(
              child: IconButton(
                icon: const Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.black54,
                ),
                onPressed:
                    _current < images.length - 1
                        ? () => _controller.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.ease,
                        )
                        : null,
              ),
            ),
          ),
        Positioned(
          left: 16,
          bottom: 16,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Row(
              children: [
                Icon(Icons.threesixty, color: Colors.white, size: 18),
                SizedBox(width: 4),
                Text(
                  'Click to view 360°',
                  style: TextStyle(color: Colors.white, fontSize: 12),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}