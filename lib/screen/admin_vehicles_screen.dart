import 'package:flutter/material.dart';

import '../models/vehicle.dart';
import '../services/admin_service.dart';
import '../widget/admin_auth_guard.dart';

class AdminVehiclesScreen extends StatefulWidget {
  const AdminVehiclesScreen({Key? key}) : super(key: key);

  @override
  State<AdminVehiclesScreen> createState() => _AdminVehiclesScreenState();
}

class _AdminVehiclesScreenState extends State<AdminVehiclesScreen> {
  late Future<List<Vehicle>> _vehiclesFuture;
  final AdminService _adminService = AdminService();
  final TextEditingController _searchController = TextEditingController();
  List<Vehicle> _allVehicles = [];
  List<Vehicle> _filteredVehicles = [];
  String _selectedFuelFilter = 'All';
  String _selectedPriceFilter = 'All';
  bool _isGridView = true;

  @override
  void initState() {
    super.initState();
    _loadVehicles();
  }

  void _loadVehicles() {
    _vehiclesFuture = _adminService.getAllVehicles();
    _vehiclesFuture.then((vehicles) {
      setState(() {
        _allVehicles = vehicles;
        _filteredVehicles = vehicles;
      });
    });
  }

  void _filterVehicles(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredVehicles = _allVehicles;
      } else {
        _filteredVehicles =
            _allVehicles
                .where(
                  (vehicle) =>
                      vehicle.name.toLowerCase().contains(
                        query.toLowerCase(),
                      ) ||
                      vehicle.model.toLowerCase().contains(
                        query.toLowerCase(),
                      ) ||
                      vehicle.location.toLowerCase().contains(
                        query.toLowerCase(),
                      ) ||
                      (vehicle.fuelType?.toLowerCase().contains(
                            query.toLowerCase(),
                          ) ??
                          false),
                )
                .toList();
      }
    });
  }

  void _applyFuelFilter(String filter) {
    setState(() {
      _selectedFuelFilter = filter;
      _applyFilters();
    });
  }

  void _applyPriceFilter(String filter) {
    setState(() {
      _selectedPriceFilter = filter;
      _applyFilters();
    });
  }

  void _applyFilters() {
    List<Vehicle> filtered = _allVehicles;

    // Apply fuel filter
    if (_selectedFuelFilter != 'All') {
      filtered =
          filtered
              .where((vehicle) => vehicle.fuelType == _selectedFuelFilter)
              .toList();
    }

    // Apply price filter
    switch (_selectedPriceFilter) {
      case 'Under 1L':
        filtered = filtered.where((vehicle) => vehicle.price < 100000).toList();
        break;
      case '1L - 5L':
        filtered =
            filtered
                .where(
                  (vehicle) =>
                      vehicle.price >= 100000 && vehicle.price <= 500000,
                )
                .toList();
        break;
      case '5L - 10L':
        filtered =
            filtered
                .where(
                  (vehicle) =>
                      vehicle.price >= 500000 && vehicle.price <= 1000000,
                )
                .toList();
        break;
      case 'Above 10L':
        filtered =
            filtered.where((vehicle) => vehicle.price > 1000000).toList();
        break;
    }

    setState(() {
      _filteredVehicles = filtered;
    });
  }

  Future<void> _deleteVehicle(String vehicleId) async {
    try {
      final confirmed = await _showDeleteConfirmation();
      if (confirmed) {
        await _adminService.deleteVehicle(vehicleId);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Vehicle deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );
        _loadVehicles();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error deleting vehicle: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<bool> _showDeleteConfirmation() async {
    return await showDialog<bool>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Confirm Delete'),
              content: const Text(
                'Are you sure you want to delete this vehicle? This action cannot be undone.',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  child: const Text('Delete'),
                ),
              ],
            );
          },
        ) ??
        false;
  }

  void _showVehicleDetails(Vehicle vehicle) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: Container(
            width: MediaQuery.of(context).size.width * 0.9,
            height: MediaQuery.of(context).size.height * 0.9,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Vehicle Details',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                const Divider(),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Images
                        if (vehicle.imageUrls.isNotEmpty)
                          Container(
                            height: 200,
                            margin: const EdgeInsets.only(bottom: 16),
                            child: PageView.builder(
                              itemCount: vehicle.imageUrls.length,
                              itemBuilder: (context, index) {
                                return Container(
                                  margin: const EdgeInsets.only(right: 8),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    image: DecorationImage(
                                      image: NetworkImage(
                                        vehicle.imageUrls[index],
                                      ),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),

                        // Basic Info
                        _buildSectionTitle('Basic Information'),
                        _buildDetailRow('Name', vehicle.name),
                        _buildDetailRow('Model', vehicle.model),
                        _buildDetailRow('Price', vehicle.formattedPrice),
                        _buildDetailRow('Location', vehicle.location),
                        _buildDetailRow('Description', vehicle.description),

                        // Vehicle Specifications
                        _buildSectionTitle('Specifications'),
                        if (vehicle.fuelType != null)
                          _buildDetailRow('Fuel Type', vehicle.fuelType!),
                        if (vehicle.transmission != null)
                          _buildDetailRow(
                            'Transmission',
                            vehicle.transmission!,
                          ),
                        if (vehicle.registrationYear != null)
                          _buildDetailRow(
                            'Registration Year',
                            vehicle.registrationYear.toString(),
                          ),
                        if (vehicle.kmDriven != null)
                          _buildDetailRow(
                            'KM Driven',
                            '${vehicle.kmDriven} km',
                          ),
                        if (vehicle.color != null)
                          _buildDetailRow('Color', vehicle.color!),
                        if (vehicle.mileage != null)
                          _buildDetailRow('Mileage', vehicle.mileage!),
                        if (vehicle.seatingCapacity != null)
                          _buildDetailRow(
                            'Seating Capacity',
                            vehicle.seatingCapacity.toString(),
                          ),
                        if (vehicle.bodyType != null)
                          _buildDetailRow('Body Type', vehicle.bodyType!),

                        // Features
                        _buildSectionTitle('Features'),
                        if (vehicle.airbags != null)
                          _buildDetailRow(
                            'Airbags',
                            vehicle.airbags.toString(),
                          ),
                        if (vehicle.abs != null)
                          _buildDetailRow('ABS', vehicle.abs! ? 'Yes' : 'No'),
                        if (vehicle.infotainmentSystem != null)
                          _buildDetailRow(
                            'Infotainment System',
                            vehicle.infotainmentSystem! ? 'Yes' : 'No',
                          ),
                        if (vehicle.ac != null)
                          _buildDetailRow('AC', vehicle.ac!),
                        if (vehicle.rearParkingCamera != null)
                          _buildDetailRow(
                            'Rear Parking Camera',
                            vehicle.rearParkingCamera! ? 'Yes' : 'No',
                          ),
                        if (vehicle.sunroof != null)
                          _buildDetailRow(
                            'Sunroof',
                            vehicle.sunroof! ? 'Yes' : 'No',
                          ),
                        if (vehicle.alloyWheels != null)
                          _buildDetailRow(
                            'Alloy Wheels',
                            vehicle.alloyWheels! ? 'Yes' : 'No',
                          ),

                        // Condition
                        _buildSectionTitle('Condition'),
                        if (vehicle.batteryHealth != null)
                          _buildDetailRow(
                            'Battery Health',
                            vehicle.batteryHealth!,
                          ),
                        if (vehicle.tireCondition != null)
                          _buildDetailRow(
                            'Tire Condition',
                            vehicle.tireCondition!,
                          ),
                        if (vehicle.brakeCondition != null)
                          _buildDetailRow(
                            'Brake Condition',
                            vehicle.brakeCondition!,
                          ),
                        if (vehicle.engineCondition != null)
                          _buildDetailRow(
                            'Engine Condition',
                            vehicle.engineCondition!,
                          ),
                        if (vehicle.steering != null)
                          _buildDetailRow('Steering', vehicle.steering!),
                        if (vehicle.suspension != null)
                          _buildDetailRow('Suspension', vehicle.suspension!),

                        // Additional Info
                        _buildSectionTitle('Additional Information'),
                        if (vehicle.owner != null)
                          _buildDetailRow('Owner', vehicle.owner!),
                        if (vehicle.rto != null)
                          _buildDetailRow('RTO', vehicle.rto!),
                        if (vehicle.insurance != null)
                          _buildDetailRow(
                            'Insurance',
                            vehicle.insurance! ? 'Available' : 'Not Available',
                          ),

                        // Tags
                        if (vehicle.tags.isNotEmpty) ...[
                          _buildSectionTitle('Tags'),
                          Wrap(
                            spacing: 8,
                            runSpacing: 4,
                            children:
                                vehicle.tags
                                    .map(
                                      (tag) => Chip(
                                        label: Text(tag),
                                        backgroundColor: Colors.orange.shade100,
                                      ),
                                    )
                                    .toList(),
                          ),
                        ],

                        const SizedBox(height: 16),
                        _buildDetailRow(
                          'Created',
                          _formatDate(vehicle.createdAt),
                        ),
                        _buildDetailRow(
                          'Last Updated',
                          _formatDate(vehicle.updatedAt),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 18,
          color: Colors.orange,
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Widget _buildGridView() {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.75,
      ),
      itemCount: _filteredVehicles.length,
      itemBuilder: (context, index) {
        final vehicle = _filteredVehicles[index];
        return Card(
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image
              Expanded(
                flex: 3,
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(12),
                    ),
                    image:
                        vehicle.imageUrls.isNotEmpty
                            ? DecorationImage(
                              image: NetworkImage(vehicle.imageUrls.first),
                              fit: BoxFit.cover,
                            )
                            : null,
                    color:
                        vehicle.imageUrls.isEmpty ? Colors.grey.shade300 : null,
                  ),
                  child:
                      vehicle.imageUrls.isEmpty
                          ? const Icon(
                            Icons.directions_car,
                            size: 48,
                            color: Colors.grey,
                          )
                          : Stack(
                            children: [
                              Positioned(
                                top: 8,
                                right: 8,
                                child: PopupMenuButton(
                                  icon: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withOpacity(0.6),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: const Icon(
                                      Icons.more_vert,
                                      color: Colors.white,
                                      size: 18,
                                    ),
                                  ),
                                  itemBuilder:
                                      (context) => [
                                        const PopupMenuItem(
                                          value: 'view',
                                          child: Row(
                                            children: [
                                              Icon(Icons.visibility, size: 18),
                                              SizedBox(width: 8),
                                              Text('View Details'),
                                            ],
                                          ),
                                        ),
                                        const PopupMenuItem(
                                          value: 'delete',
                                          child: Row(
                                            children: [
                                              Icon(
                                                Icons.delete,
                                                color: Colors.red,
                                                size: 18,
                                              ),
                                              SizedBox(width: 8),
                                              Text(
                                                'Delete',
                                                style: TextStyle(
                                                  color: Colors.red,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                  onSelected: (value) {
                                    switch (value) {
                                      case 'view':
                                        _showVehicleDetails(vehicle);
                                        break;
                                      case 'delete':
                                        _deleteVehicle(vehicle.id);
                                        break;
                                    }
                                  },
                                ),
                              ),
                            ],
                          ),
                ),
              ),
              // Vehicle Info
              Expanded(
                flex: 2,
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${vehicle.name} ${vehicle.model}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        vehicle.formattedPrice,
                        style: TextStyle(
                          color: Colors.orange.shade700,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        vehicle.yearAndKm,
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 11,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        vehicle.location,
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 11,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildListView() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _filteredVehicles.length,
      itemBuilder: (context, index) {
        final vehicle = _filteredVehicles[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                image:
                    vehicle.imageUrls.isNotEmpty
                        ? DecorationImage(
                          image: NetworkImage(vehicle.imageUrls.first),
                          fit: BoxFit.cover,
                        )
                        : null,
                color: vehicle.imageUrls.isEmpty ? Colors.grey.shade300 : null,
              ),
              child:
                  vehicle.imageUrls.isEmpty
                      ? const Icon(Icons.directions_car, color: Colors.grey)
                      : null,
            ),
            title: Text(
              '${vehicle.name} ${vehicle.model}',
              style: const TextStyle(fontWeight: FontWeight.bold),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(
                  vehicle.formattedPrice,
                  style: TextStyle(
                    color: Colors.orange.shade700,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(vehicle.yearAndKm),
                const SizedBox(height: 2),
                Text(
                  '${vehicle.fuelType ?? 'N/A'} • ${vehicle.transmission ?? 'N/A'}',
                ),
                const SizedBox(height: 2),
                Text(vehicle.location),
              ],
            ),
            trailing: PopupMenuButton(
              itemBuilder:
                  (context) => [
                    const PopupMenuItem(
                      value: 'view',
                      child: Row(
                        children: [
                          Icon(Icons.visibility, size: 18),
                          SizedBox(width: 8),
                          Text('View Details'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, color: Colors.red, size: 18),
                          SizedBox(width: 8),
                          Text('Delete', style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                  ],
              onSelected: (value) {
                switch (value) {
                  case 'view':
                    _showVehicleDetails(vehicle);
                    break;
                  case 'delete':
                    _deleteVehicle(vehicle.id);
                    break;
                }
              },
            ),
            onTap: () => _showVehicleDetails(vehicle),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AdminAuthGuard(
      child: Scaffold(
        backgroundColor: Colors.grey[100],
        appBar: AppBar(
          title: const Text(
            'Vehicles Management',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
          ),
          backgroundColor: Colors.orange,
          elevation: 0,
          actions: [
            IconButton(
              icon: Icon(
                _isGridView ? Icons.view_list : Icons.grid_view,
                color: Colors.white,
              ),
              onPressed: () {
                setState(() {
                  _isGridView = !_isGridView;
                });
              },
            ),
            IconButton(
              icon: const Icon(Icons.refresh, color: Colors.white),
              onPressed: _loadVehicles,
            ),
          ],
        ),
        body: Column(
          children: [
            // Search and Filter Section
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Search Bar
                  TextField(
                    controller: _searchController,
                    onChanged: _filterVehicles,
                    decoration: InputDecoration(
                      hintText:
                          'Search vehicles by name, model, location, or fuel type...',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon:
                          _searchController.text.isNotEmpty
                              ? IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () {
                                  _searchController.clear();
                                  _filterVehicles('');
                                },
                              )
                              : null,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Filter Chips
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        // Fuel Type Filters
                        ...['All', 'Petrol', 'Diesel', 'Electric', 'CNG'].map(
                          (filter) => Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: FilterChip(
                              label: Text(filter),
                              selected: _selectedFuelFilter == filter,
                              onSelected:
                                  (selected) => _applyFuelFilter(filter),
                              selectedColor: Colors.orange.shade100,
                              checkmarkColor: Colors.orange,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Price Filters
                        ...['Under 1L', '1L - 5L', '5L - 10L', 'Above 10L'].map(
                          (filter) => Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: FilterChip(
                              label: Text(filter),
                              selected: _selectedPriceFilter == filter,
                              onSelected:
                                  (selected) => _applyPriceFilter(filter),
                              selectedColor: Colors.green.shade100,
                              checkmarkColor: Colors.green,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Vehicles List
            Expanded(
              child: FutureBuilder<List<Vehicle>>(
                future: _vehiclesFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Colors.orange,
                        ),
                      ),
                    );
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error,
                            color: Colors.red.shade600,
                            size: 64,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Error loading vehicles',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.red.shade800,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 32),
                            child: Text(
                              '${snapshot.error}',
                              style: TextStyle(color: Colors.red.shade600),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: _loadVehicles,
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    );
                  }

                  if (_filteredVehicles.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.directions_car_outlined,
                            size: 64,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No vehicles found',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Try adjusting your search or filter criteria',
                            style: TextStyle(color: Colors.grey.shade500),
                          ),
                        ],
                      ),
                    );
                  }

                  return _isGridView ? _buildGridView() : _buildListView();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}