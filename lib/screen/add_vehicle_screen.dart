import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trexo/services/admin_service.dart';

class AddVehicleScreen extends StatefulWidget {
  const AddVehicleScreen({super.key});

  @override
  State<AddVehicleScreen> createState() => _AddVehicleScreenState();
}

class _AddVehicleScreenState extends State<AddVehicleScreen> {
  final nameCtrl = TextEditingController();
  final priceCtrl = TextEditingController();
  final featuresCtrl = TextEditingController();
  String selectedType = 'Car';

  final List<TextEditingController> imageUrlControllers = [];
  final List<String> vehicleTypes = ['Car', 'Bike', 'Truck', 'Van', 'Other'];

  void addImageUrlField() {
    if (imageUrlControllers.length >= 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('⚠️ Maximum 5 image URLs allowed')),
      );
      return;
    }
    setState(() {
      imageUrlControllers.add(TextEditingController());
    });
  }

  Future<void> submitVehicle() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) {
      Fluttertoast.showToast(msg: '⚠️ Not authorized. Please log in.');
      return;
    }

    final vehicleData = {
      "name": nameCtrl.text.trim(),
      "model": selectedType,
      "price": double.tryParse(priceCtrl.text.trim()) ?? 0,
      "description": featuresCtrl.text.trim(),
      "imageUrls": imageUrlControllers.map((ctrl) => ctrl.text.trim()).where((url) => url.isNotEmpty).toList(),
      "tags": [selectedType],
      "extraInfo": {},
    };

    try {
      final res = await AdminService.addVehicle(vehicleData, token);

      if (res.statusCode == 201) {
        Fluttertoast.showToast(msg: '✅ Vehicle added successfully!');
        Navigator.pop(context);
      } else {
        final err = jsonDecode(res.body);
        Fluttertoast.showToast(msg: '❌ ${err['message'] ?? "Failed to add vehicle"}');
      }
    } catch (e) {
      Fluttertoast.showToast(msg: '❌ Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Vehicle')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Vehicle Name')),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: selectedType,
              items: vehicleTypes.map((type) => DropdownMenuItem(value: type, child: Text(type))).toList(),
              onChanged: (val) => setState(() => selectedType = val ?? 'Car'),
              decoration: const InputDecoration(labelText: 'Vehicle Type'),
            ),
            const SizedBox(height: 10),
            TextField(controller: priceCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Price')),
            const SizedBox(height: 10),
            TextField(controller: featuresCtrl, maxLines: 4, decoration: const InputDecoration(labelText: 'Features / Description')),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Image URLs (max 5)", style: TextStyle(fontWeight: FontWeight.bold)),
                ElevatedButton(onPressed: addImageUrlField, child: const Text("+ Add Image URL"))
              ],
            ),
            const SizedBox(height: 10),
            Column(
              children: List.generate(imageUrlControllers.length, (index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: TextField(
                    controller: imageUrlControllers[index],
                    decoration: const InputDecoration(labelText: "Image URL"),
                  ),
                );
              }),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: submitVehicle,
              child: const Text("Submit Vehicle"),
            )
          ],
        ),
      ),
    );
  }
}
