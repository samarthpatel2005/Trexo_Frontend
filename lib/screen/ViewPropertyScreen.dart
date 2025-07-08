import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:trexo/widget/property_listing_card.dart';
// import 'package:trexo/widget/InteractiveCard.dart';

class ViewPropertyScreen extends StatefulWidget {
  const ViewPropertyScreen({super.key});

  @override
  State<ViewPropertyScreen> createState() => _ViewPropertyScreenState();
}

class _ViewPropertyScreenState extends State<ViewPropertyScreen> {
  List properties = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchProperties();
  }

  Future<void> fetchProperties() async {
    try {
      final res = await http.get(Uri.parse('http://localhost:5000/api/view/property'));
      if (res.statusCode == 200) {
        setState(() {
          properties = jsonDecode(res.body);
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load properties');
      }
    } catch (e) {
      print('Error: $e');
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final crossAxisCount = screenWidth <= 600 ? 1 : 3;
    final aspectRatio = crossAxisCount == 1 ? 1.1 : 0.75;

    return Scaffold(
      appBar: AppBar(title: const Text("View Properties")),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : properties.isEmpty
              ? const Center(child: Text("No properties available"))
              : GridView.builder(
                padding: const EdgeInsets.all(12),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  mainAxisSpacing: 6,
                  crossAxisSpacing: 6,
                  childAspectRatio: aspectRatio,
                ),
                itemCount: properties.length,
                itemBuilder: (context, i) {
                  final item = properties[i];
                  return PropertyListingCard(
                    imageUrl:
                        (item['imageUrls'] != null &&
                                item['imageUrls'].isNotEmpty)
                            ? item['imageUrls'][0]
                            : 'https://via.placeholder.com/300x120.png?text=No+Image',
                    title: item['title'] ?? 'Unknown',
                    price: (item['price'] ?? 0).toDouble(),
                    location: item['location'] ?? 'Unknown',
                    onDetailsPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Details of ${item['title']}")),
                      );
                    },
                  );
                },
              ),
    );
  }
}