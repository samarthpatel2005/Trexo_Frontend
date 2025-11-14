import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:trexo/screen/PropertyDetailsPage.dart';
import 'package:trexo/widget/property_listing_card.dart';
import 'package:trexo/widget/search_and_filter_widget.dart';

class ViewPropertyScreen extends StatefulWidget {
  const ViewPropertyScreen({super.key});

  @override
  State<ViewPropertyScreen> createState() => _ViewPropertyScreenState();
}

class _ViewPropertyScreenState extends State<ViewPropertyScreen> {
  List<Map<String, dynamic>> properties = [];
  List<Map<String, dynamic>> filteredProperties = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchProperties();
  }

  Future<void> fetchProperties() async {
    try {
      final res = await http.get(
        Uri.parse('http://209.38.124.176/api/view/property'),
      );
      if (res.statusCode == 200) {
        final List<dynamic> data = jsonDecode(res.body);
        setState(() {
          properties = List<Map<String, dynamic>>.from(data);
          filteredProperties = List<Map<String, dynamic>>.from(data);
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

  void _onSearchResultsChanged(List<Map<String, dynamic>> results) {
    setState(() {
      filteredProperties = results;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final crossAxisCount = screenWidth <= 600 ? 1 : 3;
    final aspectRatio = crossAxisCount == 1 ? 1.1 : 0.75;

    return Scaffold(
      body: isLoading
        ? const Center(child: CircularProgressIndicator())
        : Column(
            children: [
              // Search and Filter Widget
              SearchAndFilterWidget(
                searchType: 'property',
                onResultsChanged: _onSearchResultsChanged,
                allItems: properties,
              ),
              
              // Results Count
              if (!isLoading)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      Text(
                        '${filteredProperties.length} properties found',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                ),
              
              // Property Grid
              Expanded(
                child: filteredProperties.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.search_off,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No properties found',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Try adjusting your search or filters',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    )
                  : GridView.builder(
                      padding: const EdgeInsets.all(12),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        mainAxisSpacing: 6,
                        crossAxisSpacing: 6,
                        childAspectRatio: aspectRatio,
                      ),
                      itemCount: filteredProperties.length,
                      itemBuilder: (context, i) {
                        final item = filteredProperties[i];
                        return PropertyListingCard(
                          imageUrl:
                              (item['imageUrls'] != null &&
                                      item['imageUrls'].isNotEmpty)
                                  ? item['imageUrls'][0]
                                  : 'https://via.placeholder.com/300x120.png?text=No+Image',
                          title: item['title'] ?? 'Unknown',
                          price: (item['price'] ?? 0).toDouble(),
                          location: item['location'] ?? 'Unknown',
                          area: item['area']?.toString(),
                          bedrooms: item['bedrooms']?.toString(),
                          bathrooms: item['bathrooms']?.toString(),
                          furnishing: item['furnishing']?.toString(),
                          badgeText: item['featured'] == true ? 'Featured' : null,
                          badgeDescription: item['featured'] == true ? 'Premium listing' : null,
                          isFavorite: false,
                          onFavorite: () {
                            // TODO: Implement favorite functionality
                          },
                          onDetailsPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text("Details of ${item['title']}")),
                            );
                          },
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) => PropertyDetailsPage(property: item),
                              ),
                            );
                          },
                        );
                      },
                    ),
              ),
            ],
          ),
    );
  }
}
