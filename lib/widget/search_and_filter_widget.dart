import 'package:flutter/material.dart';
import '../services/search_service.dart';

class SearchAndFilterWidget extends StatefulWidget {
  final String searchType; // 'vehicle' or 'property'
  final Function(List<Map<String, dynamic>>) onResultsChanged;
  final List<Map<String, dynamic>> allItems;

  const SearchAndFilterWidget({
    Key? key,
    required this.searchType,
    required this.onResultsChanged,
    required this.allItems,
  }) : super(key: key);

  @override
  State<SearchAndFilterWidget> createState() => _SearchAndFilterWidgetState();
}

class _SearchAndFilterWidgetState extends State<SearchAndFilterWidget> {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  bool _showFilters = false;

  // Vehicle filters
  String? _selectedFuelType;
  String? _selectedTransmission;
  String? _selectedLocation;
  double? _minPrice;
  double? _maxPrice;
  int? _minYear;
  int? _maxYear;
  int? _maxKmDriven;
  String? _sortBy;
  bool? _isAssured;

  // Property filters
  String? _selectedPropertyType;
  String? _selectedFurnishing;
  int? _minBedrooms;
  int? _maxBedrooms;
  int? _minBathrooms;
  int? _maxBathrooms;
  String? _minArea;
  String? _maxArea;
  bool? _isFeatured;

  // Filter options
  List<String> _fuelTypes = [];
  List<String> _transmissions = [];
  List<String> _locations = [];
  List<String> _propertyTypes = [];
  List<String> _furnishingTypes = [];

  @override
  void initState() {
    super.initState();
    _loadFilterOptions();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadFilterOptions() async {
    if (widget.searchType == 'vehicle') {
      final options = await SearchService.getVehicleFilterOptions();
      setState(() {
        _fuelTypes = ['All', ...options['fuelTypes'] ?? []];
        _transmissions = ['All', ...options['transmissions'] ?? []];
        _locations = ['All', ...options['locations'] ?? []];
      });
    } else {
      final options = await SearchService.getPropertyFilterOptions();
      setState(() {
        _locations = ['All', ...options['locations'] ?? []];
        _propertyTypes = ['All', ...options['propertyTypes'] ?? []];
        _furnishingTypes = ['All', ...options['furnishingTypes'] ?? []];
      });
    }
  }

  void _onSearchChanged() {
    if (_searchController.text.isEmpty) {
      _performSearch();
    }
  }

  Future<void> _performSearch() async {
    setState(() {
      _isSearching = true;
    });

    try {
      List<Map<String, dynamic>> results;

      if (widget.searchType == 'vehicle') {
        results = await SearchService.searchVehicles(
          query: _searchController.text.isEmpty ? null : _searchController.text,
          fuelType: _selectedFuelType,
          transmission: _selectedTransmission,
          location: _selectedLocation,
          minPrice: _minPrice,
          maxPrice: _maxPrice,
          minYear: _minYear,
          maxYear: _maxYear,
          maxKmDriven: _maxKmDriven,
          sortBy: _sortBy,
          isAssured: _isAssured,
        );
      } else {
        results = await SearchService.searchProperties(
          query: _searchController.text.isEmpty ? null : _searchController.text,
          propertyType: _selectedPropertyType,
          location: _selectedLocation,
          minPrice: _minPrice,
          maxPrice: _maxPrice,
          sortBy: _sortBy,
          minBedrooms: _minBedrooms,
          maxBedrooms: _maxBedrooms,
          minBathrooms: _minBathrooms,
          maxBathrooms: _maxBathrooms,
          furnishing: _selectedFurnishing,
          isFeatured: _isFeatured,
          minArea: _minArea,
          maxArea: _maxArea,
        );
      }

      widget.onResultsChanged(results);
    } catch (e) {
      print('Search error: $e');
      widget.onResultsChanged([]);
    } finally {
      setState(() {
        _isSearching = false;
      });
    }
  }

  void _clearFilters() {
    setState(() {
      _selectedFuelType = null;
      _selectedTransmission = null;
      _selectedLocation = null;
      _selectedPropertyType = null;
      _selectedFurnishing = null;
      _minPrice = null;
      _maxPrice = null;
      _minYear = null;
      _maxYear = null;
      _maxKmDriven = null;
      _minBedrooms = null;
      _maxBedrooms = null;
      _minBathrooms = null;
      _maxBathrooms = null;
      _minArea = null;
      _maxArea = null;
      _sortBy = null;
      _isAssured = null;
      _isFeatured = null;
      _searchController.clear();
    });
    _performSearch();
  }

  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText:
              widget.searchType == 'vehicle'
                  ? 'Search vehicles by name, model, location...'
                  : 'Search properties by title, location, description...',
          hintStyle: TextStyle(color: Colors.grey[600]),
          prefixIcon:
              _isSearching
                  ? const Padding(
                    padding: EdgeInsets.all(12),
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                  : const Icon(Icons.search, color: Colors.blue),
          suffixIcon: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_searchController.text.isNotEmpty)
                IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    _performSearch();
                  },
                ),
              IconButton(
                icon: Icon(
                  _showFilters ? Icons.filter_list_off : Icons.filter_list,
                  color: _showFilters ? Colors.blue : Colors.grey[600],
                ),
                onPressed: () {
                  setState(() {
                    _showFilters = !_showFilters;
                  });
                },
              ),
            ],
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.grey[50],
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
        onSubmitted: (_) => _performSearch(),
      ),
    );
  }

  Widget _buildFiltersSection() {
    if (!_showFilters) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.7,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Fixed header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(Icons.tune, color: Colors.blue[700]),
                const SizedBox(width: 8),
                Text(
                  'Filters',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: _clearFilters,
                  child: const Text('Clear All'),
                ),
              ],
            ),
          ),

          // Scrollable content
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Common filters
                  _buildPriceRangeFilter(),
                  const SizedBox(height: 16),
                  _buildLocationFilter(),
                  const SizedBox(height: 16),
                  _buildSortFilter(),

                  // Vehicle specific filters
                  if (widget.searchType == 'vehicle') ...[
                    const SizedBox(height: 16),
                    _buildVehicleFilters(),
                  ],

                  // Property specific filters
                  if (widget.searchType == 'property') ...[
                    const SizedBox(height: 16),
                    _buildPropertyFilters(),
                  ],

                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _performSearch,
                      icon: const Icon(Icons.search),
                      label: const Text('Apply Filters'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[700],
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceRangeFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Price Range',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Min Price',
                  prefixText: '₹',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  _minPrice = double.tryParse(value);
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Max Price',
                  prefixText: '₹',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  _maxPrice = double.tryParse(value);
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLocationFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Location',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: _selectedLocation,
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 8,
            ),
          ),
          hint: const Text('Select Location'),
          items:
              _locations.map((location) {
                return DropdownMenuItem(value: location, child: Text(location));
              }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedLocation = value == 'All' ? null : value;
            });
          },
        ),
      ],
    );
  }

  Widget _buildSortFilter() {
    final sortOptions =
        widget.searchType == 'vehicle'
            ? [
              'Price: Low to High',
              'Price: High to Low',
              'Year: Newest First',
              'Year: Oldest First',
              'KM: Low to High',
            ]
            : [
              'Price: Low to High',
              'Price: High to Low',
              'Newest First',
              'Area: Large to Small',
              'Bedrooms: High to Low',
            ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Sort By',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: _sortBy,
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 8,
            ),
          ),
          hint: const Text('Select Sort Order'),
          items:
              sortOptions.map((option) {
                String value;
                switch (option) {
                  case 'Price: Low to High':
                    value = 'price_low_to_high';
                    break;
                  case 'Price: High to Low':
                    value = 'price_high_to_low';
                    break;
                  case 'Year: Newest First':
                    value = 'year_new_to_old';
                    break;
                  case 'Year: Oldest First':
                    value = 'year_old_to_new';
                    break;
                  case 'KM: Low to High':
                    value = 'km_low_to_high';
                    break;
                  case 'Newest First':
                    value = 'newest_first';
                    break;
                  case 'Area: Large to Small':
                    value = 'area_large_to_small';
                    break;
                  case 'Bedrooms: High to Low':
                    value = 'bedrooms_high_to_low';
                    break;
                  default:
                    value = option;
                }
                return DropdownMenuItem(value: value, child: Text(option));
              }).toList(),
          onChanged: (value) {
            setState(() {
              _sortBy = value;
            });
          },
        ),
      ],
    );
  }

  Widget _buildVehicleFilters() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Fuel Type',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: _selectedFuelType,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                    hint: const Text('Any'),
                    items:
                        _fuelTypes.map((fuelType) {
                          return DropdownMenuItem(
                            value: fuelType,
                            child: Text(fuelType),
                          );
                        }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedFuelType = value == 'All' ? null : value;
                      });
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Transmission',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: _selectedTransmission,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                    hint: const Text('Any'),
                    items:
                        _transmissions.map((transmission) {
                          return DropdownMenuItem(
                            value: transmission,
                            child: Text(transmission),
                          );
                        }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedTransmission = value == 'All' ? null : value;
                      });
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Year Range',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: 'Min Year',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                          ),
                          keyboardType: TextInputType.number,
                          onChanged: (value) {
                            _minYear = int.tryParse(value);
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: 'Max Year',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                          ),
                          keyboardType: TextInputType.number,
                          onChanged: (value) {
                            _maxYear = int.tryParse(value);
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Max KM Driven',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              decoration: InputDecoration(
                hintText: 'Maximum kilometers',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
              ),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                _maxKmDriven = int.tryParse(value);
              },
            ),
          ],
        ),
        const SizedBox(height: 16),
        CheckboxListTile(
          title: const Text('Assured Vehicles Only'),
          value: _isAssured ?? false,
          onChanged: (value) {
            setState(() {
              _isAssured = value;
            });
          },
          controlAffinity: ListTileControlAffinity.leading,
          contentPadding: EdgeInsets.zero,
        ),
      ],
    );
  }

  Widget _buildPropertyFilters() {
    return Column(
      children: [
        // Property Type and Furnishing Row
        Row(
          children: [
            if (_propertyTypes.isNotEmpty) ...[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Property Type',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[700],
                      ),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: _selectedPropertyType,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
                      hint: const Text('Any Type'),
                      items:
                          _propertyTypes.map((type) {
                            return DropdownMenuItem(
                              value: type,
                              child: Text(type),
                            );
                          }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedPropertyType = value == 'All' ? null : value;
                        });
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
            ],
            if (_furnishingTypes.isNotEmpty) ...[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Furnishing',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[700],
                      ),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: _selectedFurnishing,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
                      hint: const Text('Any'),
                      items:
                          _furnishingTypes.map((furnishing) {
                            return DropdownMenuItem(
                              value: furnishing,
                              child: Text(furnishing),
                            );
                          }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedFurnishing = value == 'All' ? null : value;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ],
            if (_propertyTypes.isEmpty && _furnishingTypes.isEmpty)
              const Expanded(child: SizedBox()),
          ],
        ),
        const SizedBox(height: 16),

        // Bedrooms and Bathrooms Row
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Bedrooms',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: 'Min',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                          ),
                          keyboardType: TextInputType.number,
                          onChanged: (value) {
                            _minBedrooms = int.tryParse(value);
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: 'Max',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                          ),
                          keyboardType: TextInputType.number,
                          onChanged: (value) {
                            _maxBedrooms = int.tryParse(value);
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Bathrooms',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: 'Min',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                          ),
                          keyboardType: TextInputType.number,
                          onChanged: (value) {
                            _minBathrooms = int.tryParse(value);
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: 'Max',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                          ),
                          keyboardType: TextInputType.number,
                          onChanged: (value) {
                            _maxBathrooms = int.tryParse(value);
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Area Range
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Area Range (sq ft)',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Min Area',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      _minArea = value.isEmpty ? null : value;
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Max Area',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      _maxArea = value.isEmpty ? null : value;
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Featured Properties Toggle
        CheckboxListTile(
          title: const Text('Featured Properties Only'),
          value: _isFeatured ?? false,
          onChanged: (value) {
            setState(() {
              _isFeatured = value;
            });
          },
          controlAffinity: ListTileControlAffinity.leading,
          contentPadding: EdgeInsets.zero,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [_buildSearchBar(), _buildFiltersSection()]);
  }
}
