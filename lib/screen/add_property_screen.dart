import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trexo/services/sell.dart';
import 'package:trexo/widget/image_picker_widget.dart';

class AddPropertyScreen extends StatefulWidget {
  const AddPropertyScreen({super.key});

  @override
  State<AddPropertyScreen> createState() => _AddPropertyScreenState();
}

class _AddPropertyScreenState extends State<AddPropertyScreen> {
  final _formKey = GlobalKey<FormState>();
  final titleCtrl = TextEditingController();
  final priceCtrl = TextEditingController();
  final locationCtrl = TextEditingController();
  final descCtrl = TextEditingController();
  final sizeCtrl = TextEditingController();
  final roomsCtrl = TextEditingController();
  final typeCtrl = TextEditingController();
  List<File> selectedImages = []; // Replace imageUrlControllers with selectedImages

  bool _isLoading = false;
  String? _selectedPropertyType;

  final List<String> _propertyTypes = [
    'Apartment',
    'Villa',
    'House',
    'Condo',
    'Studio',
    'Penthouse',
    'Townhouse',
    'Duplex',
  ];

  @override
  void initState() {
    super.initState();
  }

  Future<void> submitProperty() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) {
      Fluttertoast.showToast(msg: '⚠️ Not authorized. Please log in.');
      setState(() {
        _isLoading = false;
      });
      return;
    }

    // Check if at least one image is selected
    if (selectedImages.isEmpty) {
      Fluttertoast.showToast(msg: '⚠️ Please select at least one image');
      setState(() {
        _isLoading = false;
      });
      return;
    }

    final propertyData = {
      "title": titleCtrl.text.trim(),
      "price": double.tryParse(priceCtrl.text.trim()) ?? 0,
      "location": locationCtrl.text.trim(),
      "description": descCtrl.text.trim(),
      "tags": [locationCtrl.text.trim()],
      "extraInfo": {
        "size": sizeCtrl.text.trim(),
        "rooms": roomsCtrl.text.trim(),
        "type": _selectedPropertyType ?? typeCtrl.text.trim(),
      },
    };

    try {
      final res = await AdminService.addProperty(propertyData, token, selectedImages);

      if (res.statusCode == 201) {
        Fluttertoast.showToast(msg: '✅ Property added successfully!');
        Navigator.pop(context);
      } else {
        final err = jsonDecode(res.body);
        Fluttertoast.showToast(
          msg: '❌ ${err['message'] ?? "Failed to add property"}',
        );
      }
    } catch (e) {
      Fluttertoast.showToast(msg: '❌ Error: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? hint,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        validator: validator,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: Icon(icon, color: Theme.of(context).primaryColor),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: Theme.of(context).primaryColor,
              width: 2,
            ),
          ),
          filled: true,
          fillColor: Colors.grey.shade50,
        ),
      ),
    );
  }

  Widget _buildDropdownField() {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: DropdownButtonFormField<String>(
        value: _selectedPropertyType,
        decoration: InputDecoration(
          labelText: 'Property Type',
          prefixIcon: Icon(Icons.home, color: Theme.of(context).primaryColor),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: Theme.of(context).primaryColor,
              width: 2,
            ),
          ),
          filled: true,
          fillColor: Colors.grey.shade50,
        ),
        items:
            _propertyTypes.map((String type) {
              return DropdownMenuItem<String>(value: type, child: Text(type));
            }).toList(),
        onChanged: (String? newValue) {
          setState(() {
            _selectedPropertyType = newValue;
          });
        },
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please select a property type';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildImageUrlSection() {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: ImagePickerWidget(
        selectedImages: selectedImages,
        onImagesChanged: (images) {
          setState(() {
            selectedImages = images;
          });
        },
        title: "Property Images",
        maxImages: 5,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 1200;
    final isTablet = screenWidth > 600 && screenWidth <= 1200;

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text(
          'Add Property',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Container(
        width: double.infinity,
        child: SingleChildScrollView(
          child: Center(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: isDesktop ? 800 : (isTablet ? 600 : double.infinity),
              ),
              margin: EdgeInsets.symmetric(
                horizontal: isDesktop ? 40 : (isTablet ? 30 : 20),
                vertical: 20,
              ),
              child: Card(
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: EdgeInsets.all(
                    isDesktop ? 40 : (isTablet ? 30 : 24),
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Theme.of(context).primaryColor.withOpacity(0.1),
                                Theme.of(
                                  context,
                                ).primaryColor.withOpacity(0.05),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            children: [
                              Icon(
                                Icons.home_work,
                                size: 48,
                                color: Theme.of(context).primaryColor,
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Add New Property',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Fill in the details to list your property',
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 32),
                        // Form Fields
                        if (isDesktop || isTablet) ...[
                          // Desktop/Tablet Layout - Two columns
                          Row(
                            children: [
                              Expanded(
                                child: _buildTextField(
                                  controller: titleCtrl,
                                  label: 'Property Title',
                                  icon: Icons.title,
                                  hint: 'Beautiful 3BHK Apartment',
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter a title';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _buildTextField(
                                  controller: priceCtrl,
                                  label: 'Price',
                                  icon: Icons.monetization_on,
                                  hint: '50000',
                                  keyboardType: TextInputType.number,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter a price';
                                    }
                                    if (double.tryParse(value) == null) {
                                      return 'Please enter a valid number';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: _buildTextField(
                                  controller: locationCtrl,
                                  label: 'Location',
                                  icon: Icons.location_on,
                                  hint: 'Mumbai, Maharashtra',
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter a location';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _buildTextField(
                                  controller: sizeCtrl,
                                  label: 'Property Size',
                                  icon: Icons.square_foot,
                                  hint: '1200 sq.ft',
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter property size';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: _buildTextField(
                                  controller: roomsCtrl,
                                  label: 'Number of Rooms',
                                  icon: Icons.bed,
                                  hint: '3',
                                  keyboardType: TextInputType.number,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter number of rooms';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(child: _buildDropdownField()),
                            ],
                          ),
                        ] else ...[
                          // Mobile Layout - Single column
                          _buildTextField(
                            controller: titleCtrl,
                            label: 'Property Title',
                            icon: Icons.title,
                            hint: 'Beautiful 3BHK Apartment',
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter a title';
                              }
                              return null;
                            },
                          ),
                          _buildTextField(
                            controller: priceCtrl,
                            label: 'Price',
                            icon: Icons.monetization_on,
                            hint: '50000',
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter a price';
                              }
                              if (double.tryParse(value) == null) {
                                return 'Please enter a valid number';
                              }
                              return null;
                            },
                          ),
                          _buildTextField(
                            controller: locationCtrl,
                            label: 'Location',
                            icon: Icons.location_on,
                            hint: 'Mumbai, Maharashtra',
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter a location';
                              }
                              return null;
                            },
                          ),
                          _buildTextField(
                            controller: sizeCtrl,
                            label: 'Property Size',
                            icon: Icons.square_foot,
                            hint: '1200 sq.ft',
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter property size';
                              }
                              return null;
                            },
                          ),
                          _buildTextField(
                            controller: roomsCtrl,
                            label: 'Number of Rooms',
                            icon: Icons.bed,
                            hint: '3',
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter number of rooms';
                              }
                              return null;
                            },
                          ),
                          _buildDropdownField(),
                        ],
                        // Description field (full width for all layouts)
                        _buildTextField(
                          controller: descCtrl,
                          label: 'Description',
                          icon: Icons.description,
                          hint: 'Describe your property in detail...',
                          maxLines: 4,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a description';
                            }
                            return null;
                          },
                        ),

                        // Image URL section
                        _buildImageUrlSection(),

                        // Submit button
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : submitProperty,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(context).primaryColor,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 2,
                            ),
                            child:
                                _isLoading
                                    ? const Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        SizedBox(
                                          height: 20,
                                          width: 20,
                                          child: CircularProgressIndicator(
                                            color: Colors.white,
                                            strokeWidth: 2,
                                          ),
                                        ),
                                        SizedBox(width: 12),
                                        Text(
                                          'Adding Property...',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    )
                                    : const Text(
                                      'Add Property',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
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
        ),
      ),
    );
  }

  @override
  void dispose() {
    titleCtrl.dispose();
    priceCtrl.dispose();
    locationCtrl.dispose();
    descCtrl.dispose();
    sizeCtrl.dispose();
    roomsCtrl.dispose();
    typeCtrl.dispose();
    super.dispose();
  }
}
