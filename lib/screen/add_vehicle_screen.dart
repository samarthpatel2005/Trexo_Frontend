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
  final locationCtrl = TextEditingController(); // ✅ NEW

  bool hasInsurance = false; // ✅ NEW

  String fuelType = 'Petrol';
  String transmission = 'Manual';
  String bodyType = 'Sedan';

  final List<String> fuelTypes = ['Petrol', 'Diesel', 'CNG', 'Electric', 'Hybrid'];
  final List<String> transmissions = ['Manual', 'Automatic'];
  final List<String> bodyTypes = ['Sedan', 'SUV', 'Hatchback', 'Truck', 'Van', 'bike', 'Other'];

  final List<TextEditingController> imageUrlControllers = [];
  final List<String> vehicleTypes = ['Car', 'Bike', 'Truck', 'Van', 'Other'];
  String selectedType = 'Car';

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
      "description": descriptionCtrl.text.trim(),
      "imageUrls": imageUrlControllers
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
      "insurance": hasInsurance, // ✅ NEW
      "location": locationCtrl.text.trim(), // ✅ NEW
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

  Widget buildDropdown<T>({
    required String label,
    required T value,
    required List<T> items,
    required void Function(T?) onChanged,
  }) {
    return DropdownButtonFormField<T>(
      value: value,
      items: items.map((e) => DropdownMenuItem(value: e, child: Text(e.toString()))).toList(),
      onChanged: onChanged,
      decoration: InputDecoration(labelText: label),
    );
  }

  @override
  void dispose() {
    nameCtrl.dispose();
    modelCtrl.dispose();
    priceCtrl.dispose();
    descriptionCtrl.dispose();
    kmDrivenCtrl.dispose();
    registrationYearCtrl.dispose();
    mileageCtrl.dispose();
    seatingCtrl.dispose();
    colorCtrl.dispose();
    rtoCtrl.dispose();
    ownerCtrl.dispose();
    locationCtrl.dispose(); // ✅ Dispose
    for (var c in imageUrlControllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Vehicle')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Vehicle Name')),
            const SizedBox(height: 10),
            buildDropdown<String>(
              label: 'Vehicle Type',
              value: selectedType,
              items: vehicleTypes,
              onChanged: (val) => setState(() => selectedType = val ?? 'Car'),
            ),
            const SizedBox(height: 10),
            TextField(controller: priceCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Price')),
            const SizedBox(height: 10),
            TextField(controller: descriptionCtrl, maxLines: 3, decoration: const InputDecoration(labelText: 'Description')),
            const SizedBox(height: 10),
            buildDropdown<String>(
              label: 'Fuel Type',
              value: fuelType,
              items: fuelTypes,
              onChanged: (val) => setState(() => fuelType = val ?? 'Petrol'),
            ),
            const SizedBox(height: 10),
            buildDropdown<String>(
              label: 'Transmission',
              value: transmission,
              items: transmissions,
              onChanged: (val) => setState(() => transmission = val ?? 'Manual'),
            ),
            const SizedBox(height: 10),
            buildDropdown<String>(
              label: 'Body Type',
              value: bodyType,
              items: bodyTypes,
              onChanged: (val) => setState(() => bodyType = val ?? 'Sedan'),
            ),
            const SizedBox(height: 10),
            TextField(controller: registrationYearCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Registration Year')),
            const SizedBox(height: 10),
            TextField(controller: kmDrivenCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'KM Driven')),
            const SizedBox(height: 10),
            TextField(controller: mileageCtrl, decoration: const InputDecoration(labelText: 'Mileage')),
            const SizedBox(height: 10),
            TextField(controller: seatingCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Seating Capacity')),
            const SizedBox(height: 10),
            TextField(controller: colorCtrl, decoration: const InputDecoration(labelText: 'Color')),
            const SizedBox(height: 10),
            TextField(controller: rtoCtrl, decoration: const InputDecoration(labelText: 'RTO Code')),
            const SizedBox(height: 10),
            TextField(controller: ownerCtrl, decoration: const InputDecoration(labelText: 'Owner (e.g. First Owner)')),
            const SizedBox(height: 10),
            TextField(controller: locationCtrl, decoration: const InputDecoration(labelText: 'Location')), // ✅ NEW
            const SizedBox(height: 20),

            // ✅ Insurance Switch
            SwitchListTile(
              title: const Text("Insurance Available"),
              value: hasInsurance,
              onChanged: (val) => setState(() => hasInsurance = val),
              contentPadding: EdgeInsets.zero,
            ),
            const SizedBox(height: 20),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Image URLs (max 5)", style: TextStyle(fontWeight: FontWeight.bold)),
                ElevatedButton(onPressed: addImageUrlField, child: const Text("+ Add Image")),
              ],
            ),
            const SizedBox(height: 10),
            Column(
              children: List.generate(imageUrlControllers.length, (index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: TextField(
                    controller: imageUrlControllers[index],
                    decoration: const InputDecoration(labelText: "Image URL"),
                  ),
                );
              }),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: submitVehicle,
              icon: const Icon(Icons.send),
              label: const Text("Submit Vehicle"),
            ),
          ],
        ),
      ),
    );
  }
}
