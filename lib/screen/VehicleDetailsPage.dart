import 'dart:math';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:trexo/services/liked_vehicles_service.dart';
import 'package:trexo/services/user_service.dart';
import 'package:url_launcher/url_launcher.dart';

class VehicleDetailsPage extends StatefulWidget {
  final Map<String, dynamic> vehicle;

  const VehicleDetailsPage({super.key, required this.vehicle});

  @override
  State<VehicleDetailsPage> createState() => _VehicleDetailsPageState();
}

class _VehicleDetailsPageState extends State<VehicleDetailsPage>
    with TickerProviderStateMixin {
  late ScrollController _scrollController;
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  bool _isFavorite = false;
  final LikedVehiclesService _likedService = LikedVehiclesService();
  final UserService _userService = UserService();
  
  // Owner details
  Map<String, dynamic>? _ownerDetails;
  bool _isLoadingOwner = true;

  // EMI Calculator variables
  double _loanAmount = 0;
  double _downPayment = 0;
  int _loanTenure = 36; // months
  double _interestRate = 10.5; // percentage
  double _calculatedEMI = 0;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
    );

    // Check if vehicle is already liked
    _checkIfVehicleLiked();

    // Initialize EMI calculation
    _initializeEMICalculation();
    
    // Fetch owner details
    _fetchOwnerDetails();

    // Start animations
    _fadeController.forward();
    _slideController.forward();
  }
  
  Future<void> _fetchOwnerDetails() async {
    setState(() {
      _isLoadingOwner = true;
    });
    
    try {
      print('Vehicle data: ${widget.vehicle}');
      
      // Check if createdBy is already populated with user data (object)
      final createdBy = widget.vehicle['createdBy'];
      
      if (createdBy != null) {
        // If createdBy is a Map (populated user object), use it directly
        if (createdBy is Map<String, dynamic>) {
          print('createdBy is already populated: $createdBy');
          setState(() {
            _ownerDetails = createdBy;
            _isLoadingOwner = false;
          });
          return;
        }
        
        // If createdBy is a String (user ID), fetch from API
        if (createdBy is String && createdBy.isNotEmpty) {
          print('Fetching user with ID: $createdBy');
          final userDetails = await _userService.getUserById(createdBy);
          print('Fetched user details: $userDetails');
          setState(() {
            _ownerDetails = userDetails;
            _isLoadingOwner = false;
          });
          return;
        }
      }
      
      // Check if createdByUser field exists
      if (widget.vehicle['createdByUser'] != null) {
        setState(() {
          _ownerDetails = widget.vehicle['createdByUser'];
          _isLoadingOwner = false;
        });
        return;
      }
      
      setState(() {
        _isLoadingOwner = false;
      });
    } catch (e) {
      print('Error fetching owner details: $e');
      setState(() {
        _isLoadingOwner = false;
      });
    }
  }

  void _initializeEMICalculation() {
    final vehiclePrice = widget.vehicle['price'] ?? 0;
    _downPayment = vehiclePrice * 0.2; // 20% down payment
    _loanAmount = vehiclePrice - _downPayment;
    _calculateEMI();
  }
  
  Future<void> _openWhatsApp() async {
    if (_ownerDetails == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Owner details not available'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    String phone = _ownerDetails!['phone']?.toString() ?? '';
    
    // Remove any non-digit characters
    phone = phone.replaceAll(RegExp(r'[^\d]'), '');
    
    // Add country code if not present (assuming India +91)
    if (phone.length == 10) {
      phone = '91$phone';
    }
    
    final vehicleName = widget.vehicle['name'] ?? 'Vehicle';
    final vehicleModel = widget.vehicle['model'] ?? '';
    final message = Uri.encodeComponent(
      'Hi, I am interested in your $vehicleName $vehicleModel listed on Trexo.'
    );
    
    final whatsappUrl = 'https://wa.me/$phone?text=$message';
    
    try {
      final uri = Uri.parse(whatsappUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        throw 'Could not launch WhatsApp';
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not open WhatsApp: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _calculateEMI() {
    if (_loanAmount <= 0 || _loanTenure <= 0 || _interestRate <= 0) {
      _calculatedEMI = 0;
      return;
    }

    double monthlyRate = _interestRate / (12 * 100);
    double emi =
        (_loanAmount * monthlyRate * pow(1 + monthlyRate, _loanTenure)) /
        (pow(1 + monthlyRate, _loanTenure) - 1);

    setState(() {
      _calculatedEMI = emi;
    });
  }

  void _showEMICalculator() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      enableDrag: true,
      isDismissible: true,
      builder:
          (context) => GestureDetector(
            onTap: () {}, // Prevent dismissal when tapping inside
            child: _buildEMICalculatorBottomSheet(),
          ),
    );
  }

  void _checkIfVehicleLiked() async {
    final vehicleId = widget.vehicle['id'] ?? widget.vehicle['name'] ?? '';
    final isLiked = await _likedService.isVehicleLiked(vehicleId);
    setState(() {
      _isFavorite = isLiked;
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  String formatPrice(num price) =>
      '₹${NumberFormat('#,##,000.00').format(price)}';

  Widget _buildHeader() {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          const Text(
            'Vehicle Details',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  icon: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: Icon(
                      _isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: _isFavorite ? Colors.red : Colors.black,
                      key: ValueKey(_isFavorite),
                    ),
                  ),
                  onPressed: () async {
                    setState(() {
                      _isFavorite = !_isFavorite;
                    });

                    final vehicleId =
                        widget.vehicle['id'] ?? widget.vehicle['name'] ?? '';

                    if (_isFavorite) {
                      // Add to favorites
                      final success = await _likedService.addLikedVehicle(
                        widget.vehicle,
                      );
                      if (success) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Added to favorites'),
                            duration: Duration(seconds: 2),
                            backgroundColor: Colors.green,
                          ),
                        );
                      } else {
                        // Revert state if failed
                        setState(() {
                          _isFavorite = false;
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Failed to add to favorites'),
                            duration: Duration(seconds: 2),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    } else {
                      // Remove from favorites
                      final success = await _likedService.removeLikedVehicle(
                        vehicleId,
                      );
                      if (success) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Removed from favorites'),
                            duration: Duration(seconds: 2),
                            backgroundColor: Colors.orange,
                          ),
                        );
                      } else {
                        // Revert state if failed
                        setState(() {
                          _isFavorite = true;
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Failed to remove from favorites'),
                            duration: Duration(seconds: 2),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    }
                  },
                ),
              ),
              const SizedBox(width: 8),
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  icon: const Icon(Icons.share, color: Colors.black),
                  onPressed: () {
                    // Share functionality
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildImageCarousel() {
    return Container(
      height: 280,
      margin: const EdgeInsets.all(16),
      child: _ImageCarouselWithArrows(
        imageUrls: widget.vehicle['imageUrls'] ?? [],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        body: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                controller: _scrollController,
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: Column(
                      children: [
                        _buildImageCarousel(),
                        _buildMainInfoCard(),
                        _buildOwnerDetailsCard(),
                        _buildPriceSection(context),
                        _buildSpecsGrid(),
                        _buildOverviewSection(),
                        _buildQualityReportSection(),
                        _buildDescriptionSection(),
                        _buildShareSection(),
                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        floatingActionButton: _buildFloatingButtons(),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      ),
    );
  }

  Widget _buildMainInfoCard() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${widget.vehicle['registrationYear']} ${widget.vehicle['name']} ${widget.vehicle['model']}',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _modernIconText(Icons.speed, '${widget.vehicle['kmDriven']} km'),
              _modernDot(),
              _modernIconText(
                Icons.local_gas_station,
                widget.vehicle['fuelType'],
              ),
              _modernDot(),
              _modernIconText(Icons.settings, widget.vehicle['transmission']),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.location_on, size: 20, color: Colors.purple[600]),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  widget.vehicle['location'] ?? '',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[700],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _modernIconText(IconData icon, String? text) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: Colors.purple[50],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 16, color: Colors.purple[600]),
        ),
        const SizedBox(width: 8),
        Text(
          text ?? '-',
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  Widget _modernDot() => Container(
    margin: const EdgeInsets.symmetric(horizontal: 12),
    width: 4,
    height: 4,
    decoration: BoxDecoration(
      color: Colors.grey[400],
      borderRadius: BorderRadius.circular(2),
    ),
  );

  Widget _buildOwnerDetailsCard() {
    if (_isLoadingOwner) {
      return Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 20,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_ownerDetails == null) {
      return const SizedBox.shrink();
    }

    final ownerName = _ownerDetails!['name'] ?? 'N/A';
    final ownerPhone = _ownerDetails!['phone'] ?? 'N/A';
    final ownerEmail = _ownerDetails!['email'] ?? 'N/A';

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.person,
                  color: Colors.blue[600],
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Owner Details',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.verified,
                      color: Colors.green[600],
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Verified',
                      style: TextStyle(
                        color: Colors.green[600],
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildOwnerDetailRow(Icons.person_outline, 'Name', ownerName),
          const SizedBox(height: 12),
          _buildOwnerDetailRow(Icons.phone_outlined, 'Phone', ownerPhone),
          const SizedBox(height: 12),
          _buildOwnerDetailRow(Icons.email_outlined, 'Email', ownerEmail),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[600],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
              ),
              icon: const Icon(Icons.chat, size: 20),
              label: const Text(
                'Contact on WhatsApp',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onPressed: _openWhatsApp,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOwnerDetailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 20, color: Colors.grey[700]),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPriceSection(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.purple[50]!, Colors.purple[100]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.purple.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.purple[600],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  "ASSURED PRICE",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              const Icon(Icons.verified, color: Colors.green, size: 20),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            formatPrice(widget.vehicle['price']),
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.purple[800],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Includes RC transfer, insurance & more",
            style: TextStyle(
              color: Colors.grey[700],
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Starting EMI",
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                      Text(
                        "₹${NumberFormat('#,##,000').format(_calculatedEMI)}/month",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.purple[700],
                        ),
                      ),
                    ],
                  ),
                ),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple[600],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Icon(Icons.calculate, size: 18),
                  label: const Text("Calculate EMI"),
                  onPressed: _showEMICalculator,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpecsGrid() {
    final specs = [
      {
        'icon': Icons.calendar_today,
        'label': 'Year',
        'value': widget.vehicle['registrationYear']?.toString(),
      },
      {
        'icon': Icons.person,
        'label': 'Owner',
        'value': widget.vehicle['owner'],
      },
      {
        'icon': Icons.security,
        'label': 'Insurance',
        'value': widget.vehicle['insurance'] == true ? 'Valid' : 'Expired',
      },
      {'icon': Icons.place, 'label': 'RTO', 'value': widget.vehicle['rto']},
    ];

    return Container(
      margin: const EdgeInsets.all(16),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 1.5,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: specs.length,
        itemBuilder: (context, index) {
          final spec = specs[index];
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  spec['icon'] as IconData,
                  color: Colors.purple[600],
                  size: 24,
                ),
                const SizedBox(height: 8),
                Text(
                  spec['label'] as String,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  spec['value']?.toString() ?? '-',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildOverviewSection() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, color: Colors.purple[600], size: 24),
              const SizedBox(width: 12),
              const Text(
                "Vehicle Overview",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _modernOverviewRow(
            "Make Year",
            widget.vehicle['registrationYear']?.toString(),
          ),
          _modernOverviewRow("Fuel Type", widget.vehicle['fuelType']),
          _modernOverviewRow("Transmission", widget.vehicle['transmission']),
          _modernOverviewRow("Number of Owners", widget.vehicle['owner']),
          _modernOverviewRow(
            "Insurance Status",
            widget.vehicle['insurance'] == true ? 'Valid' : 'Not Available',
          ),
          _modernOverviewRow("RTO Code", widget.vehicle['rto']),
          _modernOverviewRow("Location", widget.vehicle['location']),
        ],
      ),
    );
  }

  Widget _modernOverviewRow(String title, String? value) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey[200]!, width: 1)),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 16,
                color: Colors.black87,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              value ?? '-',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[700],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQualityReportSection() {
    final points = [
      widget.vehicle['batteryHealth'],
      widget.vehicle['tireCondition'],
      widget.vehicle['brakeCondition'],
      widget.vehicle['engineCondition'],
      widget.vehicle['steering'],
      widget.vehicle['suspension'],
    ];

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.verified_outlined, color: Colors.green[600], size: 24),
              const SizedBox(width: 12),
              const Text(
                "Quality Report",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children:
                points
                    .where((e) => e != null && e.toString().isNotEmpty)
                    .map(
                      (e) => Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green[50],
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.green[200]!),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.check_circle,
                              color: Colors.green[600],
                              size: 16,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              e.toString(),
                              style: TextStyle(
                                color: Colors.green[800],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                    .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildDescriptionSection() {
    final description = widget.vehicle['description'] ?? '';

    if (description.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.description_outlined,
                color: Colors.purple[600],
                size: 24,
              ),
              const SizedBox(width: 12),
              const Text(
                "Description",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            description,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[700],
              height: 1.5,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShareSection() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Share with friends",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _shareButton(Icons.camera_alt, "Screenshot", Colors.purple),
              const SizedBox(width: 12),
              _shareButton(Icons.facebook, "Facebook", Colors.blue),
              const SizedBox(width: 12),
              _shareButton(Icons.email, "Email", Colors.deepPurple),
              const SizedBox(width: 12),
              _shareButton(Icons.link, "Copy Link", Colors.green),
            ],
          ),
        ],
      ),
    );
  }

  Widget _shareButton(IconData icon, String label, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: color,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFloatingButtons() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 56,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.green[400]!, Colors.green[600]!],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.green.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                icon: const Icon(Icons.book_online, color: Colors.white),
                label: const Text(
                  "BOOK NOW",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                onPressed: _openWhatsApp,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEMICalculatorBottomSheet() {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12),
            height: 4,
            width: 40,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Container(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'EMI Calculator',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Vehicle Price
                  _buildEMIInputCard(
                    'Vehicle Price',
                    '₹${NumberFormat('#,##,000').format(widget.vehicle['price'])}',
                    null,
                    false,
                  ),

                  // Down Payment
                  _buildEMIInputCard(
                    'Down Payment',
                    '₹${NumberFormat('#,##,000').format(_downPayment)}',
                    (value) {
                      setState(() {
                        _downPayment =
                            double.tryParse(value.replaceAll(',', '')) ?? 0;
                        _loanAmount =
                            (widget.vehicle['price'] ?? 0) - _downPayment;
                        _calculateEMI();
                      });
                    },
                    true,
                  ),

                  // Loan Amount
                  _buildEMIInputCard(
                    'Loan Amount',
                    '₹${NumberFormat('#,##,000').format(_loanAmount)}',
                    null,
                    false,
                  ),

                  // Interest Rate
                  _buildSliderCard(
                    'Interest Rate',
                    '${_interestRate.toStringAsFixed(1)}%',
                    _interestRate,
                    5.0,
                    20.0,
                    (value) {
                      setState(() {
                        _interestRate = value;
                        _calculateEMI();
                      });
                    },
                  ),

                  // Loan Tenure
                  _buildSliderCard(
                    'Loan Tenure',
                    '$_loanTenure months (${(_loanTenure / 12).toStringAsFixed(1)} years)',
                    _loanTenure.toDouble(),
                    12.0,
                    84.0,
                    (value) {
                      setState(() {
                        _loanTenure = value.round();
                        _calculateEMI();
                      });
                    },
                  ),

                  // EMI Result
                  Container(
                    margin: const EdgeInsets.only(top: 20),
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.purple[50]!, Colors.purple[100]!],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.purple[200]!),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Monthly EMI',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                            Text(
                              '₹${NumberFormat('#,##,000').format(_calculatedEMI)}',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.purple[700],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildEMIDetail(
                              'Total Interest',
                              '₹${NumberFormat('#,##,000').format((_calculatedEMI * _loanTenure) - _loanAmount)}',
                            ),
                            _buildEMIDetail(
                              'Total Amount',
                              '₹${NumberFormat('#,##,000').format(_calculatedEMI * _loanTenure)}',
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEMIInputCard(
    String title,
    String value,
    Function(String)? onChanged,
    bool isEditable,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          isEditable
              ? TextFormField(
                initialValue: value.replaceAll('₹', '').replaceAll(',', ''),
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  prefixText: '₹',
                  isDense: true,
                ),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                onChanged: onChanged,
              )
              : Text(
                value,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
        ],
      ),
    );
  }

  Widget _buildSliderCard(
    String title,
    String value,
    double currentValue,
    double min,
    double max,
    Function(double) onChanged,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.purple[600],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            height: 40, // Fixed height to ensure slider is touchable
            child: SliderTheme(
              data: SliderTheme.of(context).copyWith(
                activeTrackColor: Colors.purple[600],
                inactiveTrackColor: Colors.grey[300],
                thumbColor: Colors.purple[600],
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12),
                overlayColor: Colors.purple[600]!.withOpacity(0.2),
                overlayShape: const RoundSliderOverlayShape(overlayRadius: 20),
                trackHeight: 6,
                valueIndicatorColor: Colors.purple[600],
                valueIndicatorTextStyle: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              child: Slider(
                value: currentValue.clamp(min, max),
                min: min,
                max: max,
                divisions: title.contains('Rate') ? 30 : (max - min).round(),
                label: value,
                onChanged: onChanged,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title.contains('Rate')
                    ? '${min.toStringAsFixed(1)}%'
                    : '${min.round()} months',
                style: TextStyle(fontSize: 12, color: Colors.grey[500]),
              ),
              Text(
                title.contains('Rate')
                    ? '${max.toStringAsFixed(1)}%'
                    : '${max.round()} months',
                style: TextStyle(fontSize: 12, color: Colors.grey[500]),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEMIDetail(String title, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ],
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
        const SizedBox(height: 24),
        CarouselSlider(
          carouselController: _controller,
          items:
              images.isNotEmpty
                  ? images
                      .map<Widget>(
                        (url) => Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 10,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: Image.network(
                              url,
                              fit: BoxFit.cover,
                              width: double.infinity,
                            ),
                          ),
                        ),
                      )
                      .toList()
                  : [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(20),
                      ),
                      width: double.infinity,
                      height: 280,
                      child: const Icon(
                        Icons.directions_car,
                        size: 100,
                        color: Colors.grey,
                      ),
                    ),
                  ],
          options: CarouselOptions(
            height: 280,
            viewportFraction: 0.9,
            enableInfiniteScroll: true,
            enlargeCenterPage: true,
            enlargeFactor: 0.2,
            onPageChanged: (index, reason) {
              setState(() {
                _current = index;
              });
            },
          ),
        ),
        if (images.length > 1)
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children:
                  images.asMap().entries.map((entry) {
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: _current == entry.key ? 24 : 8,
                      height: 8,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        color:
                            _current == entry.key
                                ? Colors.white
                                : Colors.white.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    );
                  }).toList(),
            ),
          ),
        Positioned(
          left: 20,
          bottom: 60,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.7),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.threesixty, color: Colors.white, size: 18),
                const SizedBox(width: 6),
                const Text(
                  '360° View',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
