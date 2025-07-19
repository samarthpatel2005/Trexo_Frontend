import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:trexo/screen/VehicleDetailsPage.dart';
// import 'package:trexo/widget/ResponsiveScaffold.dart';

class SimpleHeader extends StatefulWidget {
  final Function(List)? onSearchResults;

  const SimpleHeader({super.key, this.onSearchResults});

  @override
  State<SimpleHeader> createState() => _SimpleHeaderState();
}

class _SimpleHeaderState extends State<SimpleHeader>
    with SingleTickerProviderStateMixin {
  bool _isSearchExpanded = false;
  final TextEditingController _searchController = TextEditingController();
  late AnimationController _animationController;
  late Animation<double> _animation;
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _toggleSearch() {
    setState(() {
      _isSearchExpanded = !_isSearchExpanded;
      if (_isSearchExpanded) {
        _animationController.forward();
      } else {
        _animationController.reverse();
        _searchController.clear();
      }
    });
  }

  void _onSearchSubmitted(String value) async {
    if (value.isNotEmpty) {
      setState(() {
        _isSearching = true;
      });

      await _performSearch(value);

      setState(() {
        _isSearching = false;
      });
    }
    // Don't toggle search to keep results visible
  }

  Future<void> _performSearch(String query) async {
    try {
      List combinedResults = [];
      print('Searching for: $query');

      // Search vehicles
      try {
        final vehicleUrl =
            'http://209.38.124.176/api/view/search/vehicle?q=${Uri.encodeComponent(query)}';
        print('Vehicle search URL: $vehicleUrl');

        final vehicleResponse = await http.get(Uri.parse(vehicleUrl));

        print('Vehicle response status: ${vehicleResponse.statusCode}');
        print('Vehicle response body: ${vehicleResponse.body}');

        if (vehicleResponse.statusCode == 200) {
          final vehicleData = jsonDecode(vehicleResponse.body);
          if (vehicleData is List) {
            for (var vehicle in vehicleData) {
              vehicle['type'] = 'vehicle'; // Add type identifier
            }
            combinedResults.addAll(vehicleData);
            print('Found ${vehicleData.length} vehicles');
          }
        } else if (vehicleResponse.statusCode == 404) {
          // Search endpoint doesn't exist, try fallback search
          print('Search endpoint not found, trying fallback search');
          await _fallbackVehicleSearch(query, combinedResults);
        }
      } catch (e) {
        print('Vehicle search error: $e');
      }

      // Search properties
      try {
        final propertyUrl =
            'http://209.38.124.176/api/view/search/property?q=${Uri.encodeComponent(query)}';
        print('Property search URL: $propertyUrl');

        final propertyResponse = await http.get(Uri.parse(propertyUrl));

        print('Property response status: ${propertyResponse.statusCode}');
        print('Property response body: ${propertyResponse.body}');

        if (propertyResponse.statusCode == 200) {
          final propertyData = jsonDecode(propertyResponse.body);
          if (propertyData is List) {
            for (var property in propertyData) {
              property['type'] = 'property'; // Add type identifier
            }
            combinedResults.addAll(propertyData);
            print('Found ${propertyData.length} properties');
          }
        } else if (propertyResponse.statusCode == 404) {
          // Search endpoint doesn't exist, try fallback search
          print('Property search endpoint not found, trying fallback search');
          await _fallbackPropertySearch(query, combinedResults);
        }
      } catch (e) {
        print('Property search error: $e');
      }

      print('Total combined results: ${combinedResults.length}');

      // Show search results
      if (combinedResults.isNotEmpty) {
        _showSearchResults(combinedResults);
      } else {
        _showNoResultsDialog();
      }
    } catch (e) {
      print('Search error: $e');
      _showErrorDialog();
    }
  }

  Future<void> _fallbackVehicleSearch(
    String query,
    List combinedResults,
  ) async {
    try {
      // Get all vehicles and search locally
      final allVehiclesResponse = await http.get(
        Uri.parse('http://209.38.124.176/api/view/vehicle'),
      );

      if (allVehiclesResponse.statusCode == 200) {
        final allVehicles = jsonDecode(allVehiclesResponse.body);
        if (allVehicles is List) {
          final queryLower = query.toLowerCase();
          final filteredVehicles =
              allVehicles.where((vehicle) {
                final name = (vehicle['name'] ?? '').toString().toLowerCase();
                final model = (vehicle['model'] ?? '').toString().toLowerCase();
                final fuelType =
                    (vehicle['fuelType'] ?? '').toString().toLowerCase();
                final transmission =
                    (vehicle['transmission'] ?? '').toString().toLowerCase();
                final location =
                    (vehicle['location'] ?? '').toString().toLowerCase();
                final rto = (vehicle['rto'] ?? '').toString().toLowerCase();

                return name.contains(queryLower) ||
                    model.contains(queryLower) ||
                    fuelType.contains(queryLower) ||
                    transmission.contains(queryLower) ||
                    location.contains(queryLower) ||
                    rto.contains(queryLower);
              }).toList();

          for (var vehicle in filteredVehicles) {
            vehicle['type'] = 'vehicle';
          }
          combinedResults.addAll(filteredVehicles);
          print('Fallback search found ${filteredVehicles.length} vehicles');
        }
      }
    } catch (e) {
      print('Fallback vehicle search error: $e');
    }
  }

  Future<void> _fallbackPropertySearch(
    String query,
    List combinedResults,
  ) async {
    try {
      // Get all properties and search locally
      final allPropertiesResponse = await http.get(
        Uri.parse('http://209.38.124.176/api/view/property'),
      );

      if (allPropertiesResponse.statusCode == 200) {
        final allProperties = jsonDecode(allPropertiesResponse.body);
        if (allProperties is List) {
          final queryLower = query.toLowerCase();
          final filteredProperties =
              allProperties.where((property) {
                final title =
                    (property['title'] ?? '').toString().toLowerCase();
                final location =
                    (property['location'] ?? '').toString().toLowerCase();
                final description =
                    (property['description'] ?? '').toString().toLowerCase();
                final tags = property['tags'] ?? [];

                bool matchesTags = false;
                if (tags is List) {
                  matchesTags = tags.any(
                    (tag) => tag.toString().toLowerCase().contains(queryLower),
                  );
                }

                return title.contains(queryLower) ||
                    location.contains(queryLower) ||
                    description.contains(queryLower) ||
                    matchesTags;
              }).toList();

          for (var property in filteredProperties) {
            property['type'] = 'property';
          }
          combinedResults.addAll(filteredProperties);
          print(
            'Fallback search found ${filteredProperties.length} properties',
          );
        }
      }
    } catch (e) {
      print('Fallback property search error: $e');
    }
  }

  void _showSearchResults(List results) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => Container(
            height: MediaQuery.of(context).size.height * 0.8,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  child: Row(
                    children: [
                      Text(
                        'Search Results (${results.length})',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: results.length,
                    itemBuilder: (context, index) {
                      final item = results[index];
                      final isVehicle = item['type'] == 'vehicle';

                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor:
                              isVehicle ? Colors.blue[100] : Colors.green[100],
                          child: Icon(
                            isVehicle ? Icons.directions_car : Icons.home,
                            color: isVehicle ? Colors.blue : Colors.green,
                          ),
                        ),
                        title: Text(
                          isVehicle
                              ? '${item['year'] ?? ''} ${item['name'] ?? 'Unknown Vehicle'}'
                              : item['title'] ?? 'Unknown Property',
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (isVehicle) ...[
                              Text(
                                '${item['model'] ?? ''} - ${item['fuelType'] ?? ''}',
                              ),
                              Text(
                                '₹${item['price'] ?? '0'} • ${item['location'] ?? ''}',
                              ),
                            ] else ...[
                              Text('${item['location'] ?? ''}'),
                              Text('₹${item['price'] ?? '0'}'),
                            ],
                          ],
                        ),
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: isVehicle ? Colors.blue : Colors.green,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            isVehicle ? 'Vehicle' : 'Property',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        onTap: () {
                          print(
                            'Tapped on search result: ${item['name']} (${item['type']})',
                          );
                          print('Vehicle data: ${item.toString()}');
                          Navigator.pop(context);
                          if (isVehicle) {
                            // Navigate to vehicle details page
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) =>
                                        VehicleDetailsPage(vehicle: item),
                              ),
                            );
                          } else {
                            Navigator.pushNamed(
                              context,
                              '/property-details',
                              arguments: item,
                            );
                          }
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
    );
  }

  void _showNoResultsDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            icon: const Icon(Icons.search_off, size: 48, color: Colors.grey),
            title: const Text('No Results Found'),
            content: Text(
              'No vehicles or properties found matching "${_searchController.text}"',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
    );
  }

  void _showErrorDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            icon: const Icon(Icons.error_outline, size: 48, color: Colors.red),
            title: const Text('Search Error'),
            content: const Text(
              'Something went wrong while searching. Please try again.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: Colors.blue,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Logo - fade out when search is expanded on mobile
                if (!isMobile || !_isSearchExpanded) ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: AnimatedOpacity(
                      opacity: isMobile ? (1.0 - _animation.value) : 1.0,
                      duration: const Duration(milliseconds: 300),
                      child: Image.asset(
                        'assets/images/logo.png',
                        height: 1000,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ],

                // Spacer
                const Spacer(),

                // Desktop: search + nav buttons
                if (!isMobile) ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: SizedBox(
                      width: 250,
                      child: TextField(
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'Search vehicles & properties...',
                          hintStyle: const TextStyle(color: Colors.white70),
                          filled: true,
                          fillColor: Colors.blue[700],
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                            borderSide: BorderSide.none,
                          ),
                          prefixIcon:
                              _isSearching
                                  ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: Padding(
                                      padding: EdgeInsets.all(8),
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                              Colors.white,
                                            ),
                                      ),
                                    ),
                                  )
                                  : const Icon(
                                    Icons.search,
                                    color: Colors.white,
                                  ),
                        ),
                        onSubmitted: _onSearchSubmitted,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pushNamed(context, '/about'),
                    child: const Text(
                      "About",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  const SizedBox(width: 8),
                  TextButton(
                    onPressed: () => Navigator.pushNamed(context, '/profile'),
                    child: const Text(
                      "Profile",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  const SizedBox(width: 16),
                ],

                // Mobile: expandable search + menu
                if (isMobile) ...[
                  // Expanded search bar
                  if (_isSearchExpanded) ...[
                    Expanded(
                      child: Container(
                        height: 40,
                        margin: const EdgeInsets.symmetric(horizontal: 16),
                        child: TextField(
                          controller: _searchController,
                          autofocus: true,
                          style: const TextStyle(color: Colors.black),
                          decoration: InputDecoration(
                            hintText: 'Search vehicles & properties...',
                            hintStyle: const TextStyle(color: Colors.black),
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(24),
                              borderSide: BorderSide.none,
                            ),
                            prefixIcon:
                                _isSearching
                                    ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: Padding(
                                        padding: EdgeInsets.all(8),
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                Colors.blue,
                                              ),
                                        ),
                                      ),
                                    )
                                    : const Icon(
                                      Icons.search,
                                      color: Colors.black,
                                    ),
                            suffixIcon: IconButton(
                              icon: const Icon(
                                Icons.close,
                                color: Colors.black,
                              ),
                              onPressed: _toggleSearch,
                            ),
                          ),
                          onSubmitted: _onSearchSubmitted,
                        ),
                      ),
                    ),
                  ] else ...[
                    // Search icon
                    IconButton(
                      icon: const Icon(Icons.search, color: Colors.white),
                      onPressed: _toggleSearch,
                    ),
                    // Menu icon
                    Builder(
                      builder:
                          (context) => IconButton(
                            icon: const Icon(Icons.menu, color: Colors.white),
                            onPressed: () {
                              // Handle menu action - for now just show a snackbar
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Menu pressed')),
                              );
                            },
                          ),
                    ),
                    const SizedBox(width: 8),
                  ],
                ],
              ],
            );
          },
        ),
      ),
    );
  }
}

// Keep the search delegate as backup (not used in the new implementation)
// class _MobileSearchDelegate extends SearchDelegate<String> {
//   @override
//   List<Widget>? buildActions(BuildContext context) {
//     return [
//       IconButton(icon: const Icon(Icons.clear), onPressed: () => query = ''),
//     ];
//   }

//   @override
//   Widget? buildLeading(BuildContext context) {
//     return IconButton(
//       icon: const Icon(Icons.arrow_back),
//       onPressed: () => close(context, ''),
//     );
//   }

//   @override
//   Widget buildResults(BuildContext context) {
//     return Center(child: Text('You searched for "$query"'));
//   }

//   @override
//   Widget buildSuggestions(BuildContext context) {
//     return ListView(
//       children: [ListTile(title: Text('Suggestion for "$query"'))],
//     );
//   }
// }
