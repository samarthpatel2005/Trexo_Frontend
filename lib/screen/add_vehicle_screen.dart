import 'dart:convert';
import 'package:flutter/material.dart';
// import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trexo/services/sell.dart';

class AddVehicleScreen extends StatefulWidget {
  const AddVehicleScreen({super.key});

  @override
  State<AddVehicleScreen> createState() => _AddVehicleScreenState();
}

class _AddVehicleScreenState extends State<AddVehicleScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  // Controllers
  final nameCtrl = TextEditingController();
  final modelCtrl = TextEditingController();
  final priceCtrl = TextEditingController();
  final descriptionCtrl = TextEditingController();
  final kmDrivenCtrl = TextEditingController();
  final registrationYearCtrl = TextEditingController();
  final mileageCtrl = TextEditingController();
  final seatingCtrl = TextEditingController();
  final colorCtrl = TextEditingController();
  final rtoCtrl = TextEditingController();
  final ownerCtrl = TextEditingController();
  final locationCtrl = TextEditingController();

  bool hasInsurance = false;
  bool isLoading = false;

  String fuelType = 'Petrol';
  String transmission = 'Manual';
  String bodyType = 'Sedan';

  final List<String> fuelTypes = [
    'Petrol',
    'Diesel',
    'CNG',
    'Electric',
    'Hybrid',
  ];
  final List<String> transmissions = ['Manual', 'Automatic'];
  final List<String> bodyTypes = [
    'Sedan',
    'SUV',
    'Hatchback',
    'Truck',
    'Van',
    'Bike',
    'Other',
  ];

  final List<TextEditingController> imageUrlControllers = [];
  final List<String> vehicleTypes = ['Car', 'Bike', 'Truck', 'Van', 'Other'];
  String selectedType = 'Car';

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  // Responsive breakpoints
  bool isMobile(double width) => width < 600;
  bool isTablet(double width) => width >= 600 && width < 1024;
  bool isDesktop(double width) => width >= 1024;

  double getMaxWidth(double screenWidth) {
    if (isMobile(screenWidth)) return screenWidth * 0.95;
    if (isTablet(screenWidth)) return screenWidth * 0.8;
    return 800;
  }

  int getCrossAxisCount(double width) {
    if (isMobile(width)) return 1;
    if (isTablet(width)) return 2;
    return 3;
  }

  double getHorizontalPadding(double width) {
    if (isMobile(width)) return 16;
    if (isTablet(width)) return 24;
    return 32;
  }

  void addImageUrlField() {
    if (imageUrlControllers.length >= 5) {
      _showSnackBar('⚠️ Maximum 5 image URLs allowed', Colors.orange);
      return;
    }
    setState(() {
      imageUrlControllers.add(TextEditingController());
    });
  }

  void removeImageUrlField(int index) {
    setState(() {
      imageUrlControllers[index].dispose();
      imageUrlControllers.removeAt(index);
    });
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Future<void> submitVehicle() async {
    if (!_formKey.currentState!.validate()) {
      _showSnackBar('Please fill in all required fields', Colors.red);
      return;
    }

    setState(() => isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        _showSnackBar('⚠️ Not authorized. Please log in.', Colors.red);
        return;
      }

      final vehicleData = {
        "name": nameCtrl.text.trim(),
        "model": selectedType,
        "price": double.tryParse(priceCtrl.text.trim()) ?? 0,
        "description": descriptionCtrl.text.trim(),
        "imageUrls":
            imageUrlControllers
                .map((ctrl) => ctrl.text.trim())
                .where((url) => url.isNotEmpty)
                .toList(),
        "tags": [selectedType],
        "fuelType": fuelType,
        "transmission": transmission,
        "registrationYear": int.tryParse(registrationYearCtrl.text.trim()) ?? 0,
        "kmDriven": int.tryParse(kmDrivenCtrl.text.trim()) ?? 0,
        "owner": ownerCtrl.text.trim(),
        "rto": rtoCtrl.text.trim(),
        "color": colorCtrl.text.trim(),
        "mileage": mileageCtrl.text.trim(),
        "seatingCapacity": int.tryParse(seatingCtrl.text.trim()) ?? 0,
        "bodyType": bodyType,
        "insurance": hasInsurance,
        "location": locationCtrl.text.trim(),
      };

      final res = await AdminService.addVehicle(vehicleData, token);

      if (res.statusCode == 201) {
        _showSnackBar('✅ Vehicle added successfully!', Colors.green);
        Navigator.pop(context);
      } else {
        final err = jsonDecode(res.body);
        _showSnackBar(
          '❌ ${err['message'] ?? "Failed to add vehicle"}',
          Colors.red,
        );
      }
    } catch (e) {
      _showSnackBar('❌ Error: $e', Colors.red);
    } finally {
      setState(() => isLoading = false);
    }
  }

  Widget buildResponsiveField({
    required Widget child,
    required double screenWidth,
    int flex = 1,
  }) {
    if (isMobile(screenWidth)) {
      return Padding(padding: const EdgeInsets.only(bottom: 16), child: child);
    }
    return Expanded(
      flex: flex,
      child: Padding(padding: const EdgeInsets.all(8), child: child),
    );
  }

  Widget buildTextField({
    required TextEditingController controller,
    required String label,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? hint,
    IconData? icon,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon:
            icon != null ? Icon(icon, color: Colors.blue.shade700) : null,
        filled: true,
        fillColor: Colors.grey.shade50,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.blue.shade700, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
    );
  }

  Widget buildDropdown<T>({
    required String label,
    required T value,
    required List<T> items,
    required void Function(T?) onChanged,
    IconData? icon,
  }) {
    return DropdownButtonFormField<T>(
      value: value,
      items:
          items
              .map((e) => DropdownMenuItem(value: e, child: Text(e.toString())))
              .toList(),
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon:
            icon != null ? Icon(icon, color: Colors.blue.shade700) : null,
        filled: true,
        fillColor: Colors.grey.shade50,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.blue.shade700, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
    );
  }

  Widget buildImageUrlSection(double screenWidth) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.photo_library, color: Colors.blue.shade700),
                    const SizedBox(width: 8),
                    Text(
                      "Vehicle Images",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade800,
                      ),
                    ),
                  ],
                ),
                ElevatedButton.icon(
                  onPressed: addImageUrlField,
                  icon: const Icon(Icons.add, size: 18),
                  label: Text(isMobile(screenWidth) ? "Add" : "Add Image"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade700,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (imageUrlControllers.isEmpty)
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.grey.shade300,
                    style: BorderStyle.solid,
                  ),
                ),
                child: Center(
                  child: Column(
                    children: [
                      Icon(Icons.photo, size: 40, color: Colors.grey.shade500),
                      const SizedBox(height: 8),
                      Text(
                        "No images added yet",
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Click 'Add Image' to add vehicle photos",
                        style: TextStyle(
                          color: Colors.grey.shade500,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              ...imageUrlControllers.asMap().entries.map((entry) {
                int index = entry.key;
                TextEditingController controller = entry.value;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    children: [
                      Expanded(
                        child: buildTextField(
                          controller: controller,
                          label: "Image URL ${index + 1}",
                          hint: "Enter image URL",
                          icon: Icons.link,
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: () => removeImageUrlField(index),
                        icon: const Icon(Icons.delete, color: Colors.red),
                        tooltip: "Remove image",
                      ),
                    ],
                  ),
                );
              }).toList(),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text(
          'Add Vehicle',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: !isMobile(screenWidth),
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: getHorizontalPadding(screenWidth),
            vertical: 20,
          ),
          child: Center(
            child: Container(
              constraints: BoxConstraints(maxWidth: getMaxWidth(screenWidth)),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Section
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.blue.shade700, Colors.blue.shade500],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.blue.shade200,
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.directions_car,
                            size: isMobile(screenWidth) ? 40 : 50,
                            color: Colors.white,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            "Add New Vehicle",
                            style: TextStyle(
                              fontSize: isMobile(screenWidth) ? 20 : 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Fill in the details below to add a new vehicle to your inventory",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: isMobile(screenWidth) ? 14 : 16,
                              color: Colors.white.withOpacity(0.9),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Basic Information Section
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.info, color: Colors.blue.shade700),
                                const SizedBox(width: 8),
                                Text(
                                  "Basic Information",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey.shade800,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            if (isMobile(screenWidth))
                              Column(
                                children: [
                                  buildTextField(
                                    controller: nameCtrl,
                                    label: "Vehicle Name",
                                    hint: "Enter vehicle name",
                                    icon: Icons.drive_eta,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter vehicle name';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 16),
                                  buildDropdown<String>(
                                    label: 'Vehicle Type',
                                    value: selectedType,
                                    items: vehicleTypes,
                                    icon: Icons.category,
                                    onChanged:
                                        (val) => setState(
                                          () => selectedType = val ?? 'Car',
                                        ),
                                  ),
                                  const SizedBox(height: 16),
                                  buildTextField(
                                    controller: priceCtrl,
                                    label: "Price",
                                    hint: "Enter price in ₹",
                                    icon: Icons.currency_rupee,
                                    keyboardType: TextInputType.number,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter price';
                                      }
                                      return null;
                                    },
                                  ),
                                ],
                              )
                            else
                              Row(
                                children: [
                                  buildResponsiveField(
                                    child: buildTextField(
                                      controller: nameCtrl,
                                      label: "Vehicle Name",
                                      hint: "Enter vehicle name",
                                      icon: Icons.drive_eta,
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Please enter vehicle name';
                                        }
                                        return null;
                                      },
                                    ),
                                    screenWidth: screenWidth,
                                  ),
                                  buildResponsiveField(
                                    child: buildDropdown<String>(
                                      label: 'Vehicle Type',
                                      value: selectedType,
                                      items: vehicleTypes,
                                      icon: Icons.category,
                                      onChanged:
                                          (val) => setState(
                                            () => selectedType = val ?? 'Car',
                                          ),
                                    ),
                                    screenWidth: screenWidth,
                                  ),
                                  buildResponsiveField(
                                    child: buildTextField(
                                      controller: priceCtrl,
                                      label: "Price",
                                      hint: "Enter price in ₹",
                                      icon: Icons.currency_rupee,
                                      keyboardType: TextInputType.number,
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Please enter price';
                                        }
                                        return null;
                                      },
                                    ),
                                    screenWidth: screenWidth,
                                  ),
                                ],
                              ),
                            const SizedBox(height: 16),
                            buildTextField(
                              controller: descriptionCtrl,
                              label: "Description",
                              hint: "Enter vehicle description",
                              icon: Icons.description,
                              maxLines: 3,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter description';
                                }
                                return null;
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Technical Specifications Section
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.build, color: Colors.blue.shade700),
                                const SizedBox(width: 8),
                                Text(
                                  "Technical Specifications",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey.shade800,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            if (isMobile(screenWidth))
                              Column(
                                children: [
                                  buildDropdown<String>(
                                    label: 'Fuel Type',
                                    value: fuelType,
                                    items: fuelTypes,
                                    icon: Icons.local_gas_station,
                                    onChanged:
                                        (val) => setState(
                                          () => fuelType = val ?? 'Petrol',
                                        ),
                                  ),
                                  const SizedBox(height: 16),
                                  buildDropdown<String>(
                                    label: 'Transmission',
                                    value: transmission,
                                    items: transmissions,
                                    icon: Icons.settings,
                                    onChanged:
                                        (val) => setState(
                                          () => transmission = val ?? 'Manual',
                                        ),
                                  ),
                                  const SizedBox(height: 16),
                                  buildDropdown<String>(
                                    label: 'Body Type',
                                    value: bodyType,
                                    items: bodyTypes,
                                    icon: Icons.directions_car,
                                    onChanged:
                                        (val) => setState(
                                          () => bodyType = val ?? 'Sedan',
                                        ),
                                  ),
                                ],
                              )
                            else
                              Row(
                                children: [
                                  buildResponsiveField(
                                    child: buildDropdown<String>(
                                      label: 'Fuel Type',
                                      value: fuelType,
                                      items: fuelTypes,
                                      icon: Icons.local_gas_station,
                                      onChanged:
                                          (val) => setState(
                                            () => fuelType = val ?? 'Petrol',
                                          ),
                                    ),
                                    screenWidth: screenWidth,
                                  ),
                                  buildResponsiveField(
                                    child: buildDropdown<String>(
                                      label: 'Transmission',
                                      value: transmission,
                                      items: transmissions,
                                      icon: Icons.settings,
                                      onChanged:
                                          (val) => setState(
                                            () =>
                                                transmission = val ?? 'Manual',
                                          ),
                                    ),
                                    screenWidth: screenWidth,
                                  ),
                                  buildResponsiveField(
                                    child: buildDropdown<String>(
                                      label: 'Body Type',
                                      value: bodyType,
                                      items: bodyTypes,
                                      icon: Icons.directions_car,
                                      onChanged:
                                          (val) => setState(
                                            () => bodyType = val ?? 'Sedan',
                                          ),
                                    ),
                                    screenWidth: screenWidth,
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Vehicle Details Section
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.info_outline,
                                  color: Colors.blue.shade700,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  "Vehicle Details",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey.shade800,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            if (isMobile(screenWidth))
                              Column(
                                children: [
                                  buildTextField(
                                    controller: registrationYearCtrl,
                                    label: "Registration Year",
                                    hint: "Enter year",
                                    icon: Icons.date_range,
                                    keyboardType: TextInputType.number,
                                  ),
                                  const SizedBox(height: 16),
                                  buildTextField(
                                    controller: kmDrivenCtrl,
                                    label: "KM Driven",
                                    hint: "Enter kilometers",
                                    icon: Icons.speed,
                                    keyboardType: TextInputType.number,
                                  ),
                                  const SizedBox(height: 16),
                                  buildTextField(
                                    controller: mileageCtrl,
                                    label: "Mileage",
                                    hint: "Enter mileage",
                                    icon: Icons.local_gas_station,
                                  ),
                                ],
                              )
                            else
                              Row(
                                children: [
                                  buildResponsiveField(
                                    child: buildTextField(
                                      controller: registrationYearCtrl,
                                      label: "Registration Year",
                                      hint: "Enter year",
                                      icon: Icons.date_range,
                                      keyboardType: TextInputType.number,
                                    ),
                                    screenWidth: screenWidth,
                                  ),
                                  buildResponsiveField(
                                    child: buildTextField(
                                      controller: kmDrivenCtrl,
                                      label: "KM Driven",
                                      hint: "Enter kilometers",
                                      icon: Icons.speed,
                                      keyboardType: TextInputType.number,
                                    ),
                                    screenWidth: screenWidth,
                                  ),
                                  buildResponsiveField(
                                    child: buildTextField(
                                      controller: mileageCtrl,
                                      label: "Mileage",
                                      hint: "Enter mileage",
                                      icon: Icons.local_gas_station,
                                    ),
                                    screenWidth: screenWidth,
                                  ),
                                ],
                              ),
                            const SizedBox(height: 16),
                            if (isMobile(screenWidth))
                              Column(
                                children: [
                                  buildTextField(
                                    controller: seatingCtrl,
                                    label: "Seating Capacity",
                                    hint: "Enter seating capacity",
                                    icon: Icons.people,
                                    keyboardType: TextInputType.number,
                                  ),
                                  const SizedBox(height: 16),
                                  buildTextField(
                                    controller: colorCtrl,
                                    label: "Color",
                                    hint: "Enter color",
                                    icon: Icons.color_lens,
                                  ),
                                  const SizedBox(height: 16),
                                  buildTextField(
                                    controller: rtoCtrl,
                                    label: "RTO Code",
                                    hint: "Enter RTO code",
                                    icon: Icons.location_on,
                                  ),
                                ],
                              )
                            else
                              Row(
                                children: [
                                  buildResponsiveField(
                                    child: buildTextField(
                                      controller: seatingCtrl,
                                      label: "Seating Capacity",
                                      hint: "Enter seating capacity",
                                      icon: Icons.people,
                                      keyboardType: TextInputType.number,
                                    ),
                                    screenWidth: screenWidth,
                                  ),
                                  buildResponsiveField(
                                    child: buildTextField(
                                      controller: colorCtrl,
                                      label: "Color",
                                      hint: "Enter color",
                                      icon: Icons.color_lens,
                                    ),
                                    screenWidth: screenWidth,
                                  ),
                                  buildResponsiveField(
                                    child: buildTextField(
                                      controller: rtoCtrl,
                                      label: "RTO Code",
                                      hint: "Enter RTO code",
                                      icon: Icons.location_on,
                                    ),
                                    screenWidth: screenWidth,
                                  ),
                                ],
                              ),
                            const SizedBox(height: 16),
                            if (isMobile(screenWidth))
                              Column(
                                children: [
                                  buildTextField(
                                    controller: ownerCtrl,
                                    label: "Owner",
                                    hint: "e.g. First Owner",
                                    icon: Icons.person,
                                  ),
                                  const SizedBox(height: 16),
                                  buildTextField(
                                    controller: locationCtrl,
                                    label: "Location",
                                    hint: "Enter location",
                                    icon: Icons.location_city,
                                  ),
                                ],
                              )
                            else
                              Row(
                                children: [
                                  buildResponsiveField(
                                    child: buildTextField(
                                      controller: ownerCtrl,
                                      label: "Owner",
                                      hint: "e.g. First Owner",
                                      icon: Icons.person,
                                    ),
                                    screenWidth: screenWidth,
                                  ),
                                  buildResponsiveField(
                                    child: buildTextField(
                                      controller: locationCtrl,
                                      label: "Location",
                                      hint: "Enter location",
                                      icon: Icons.location_city,
                                    ),
                                    screenWidth: screenWidth,
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Image URL Section
                    buildImageUrlSection(screenWidth),
                    const SizedBox(height: 24),

                    // Insurance Switch & Submit Button
                    Row(
                      children: [
                        Switch(
                          value: hasInsurance,
                          onChanged:
                              (val) => setState(() => hasInsurance = val),
                          activeColor: Colors.blue.shade700,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          "Insurance Available",
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton.icon(
                        onPressed: isLoading ? null : submitVehicle,
                        icon:
                            isLoading
                                ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                                : const Icon(Icons.send),
                        label: Text(
                          isLoading ? "Submitting..." : "Submit Vehicle",
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue.shade700,
                          foregroundColor: Colors.white,
                          textStyle: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
