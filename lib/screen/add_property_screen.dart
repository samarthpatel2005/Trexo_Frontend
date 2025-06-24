import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trexo/services/admin_service.dart';

class AddPropertyScreen extends StatefulWidget {
  const AddPropertyScreen({super.key});

  @override
  State<AddPropertyScreen> createState() => _AddPropertyScreenState();
}

class _AddPropertyScreenState extends State<AddPropertyScreen> {
  final titleCtrl = TextEditingController();
  final priceCtrl = TextEditingController();
  final locationCtrl = TextEditingController();
  final descCtrl = TextEditingController();

  // Extra Info Controllers
  final sizeCtrl = TextEditingController();
  final roomsCtrl = TextEditingController();
  final typeCtrl = TextEditingController();

  final List<TextEditingController> imageUrlControllers = [];

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

  Future<void> submitProperty() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) {
      Fluttertoast.showToast(msg: '⚠️ Not authorized. Please log in.');
      return;
    }

    final propertyData = {
      "title": titleCtrl.text.trim(),
      "price": double.tryParse(priceCtrl.text.trim()) ?? 0,
      "location": locationCtrl.text.trim(),
      "description": descCtrl.text.trim(),
      "imageUrls": imageUrlControllers
          .map((ctrl) => ctrl.text.trim())
          .where((url) => url.isNotEmpty)
          .toList(),
      "tags": [locationCtrl.text.trim()],
      "extraInfo": {
        "size": sizeCtrl.text.trim(),
        "rooms": roomsCtrl.text.trim(),
        "type": typeCtrl.text.trim(),
      },
    };

    try {
      final res = await AdminService.addProperty(propertyData, token);

      if (res.statusCode == 201) {
        Fluttertoast.showToast(msg: '✅ Property added successfully!');
        Navigator.pop(context);
      } else {
        final err = jsonDecode(res.body);
        Fluttertoast.showToast(msg: '❌ ${err['message'] ?? "Failed to add property"}');
      }
    } catch (e) {
      Fluttertoast.showToast(msg: '❌ Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Property')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            TextField(controller: titleCtrl, decoration: const InputDecoration(labelText: 'Title')),
            const SizedBox(height: 10),
            TextField(controller: priceCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Price')),
            const SizedBox(height: 10),
            TextField(controller: locationCtrl, decoration: const InputDecoration(labelText: 'Location')),
            const SizedBox(height: 10),
            TextField(controller: descCtrl, maxLines: 4, decoration: const InputDecoration(labelText: 'Description')),
            const SizedBox(height: 10),

            // 🔽 Extra Info Fields
            TextField(controller: sizeCtrl, decoration: const InputDecoration(labelText: 'Size (e.g. 1200 sq.ft)')),
            const SizedBox(height: 10),
            TextField(controller: roomsCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Number of Rooms')),
            const SizedBox(height: 10),
            TextField(controller: typeCtrl, decoration: const InputDecoration(labelText: 'Property Type (Apartment, Villa, etc)')),
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
              onPressed: submitProperty,
              child: const Text("Submit Property"),
            )
          ],
        ),
      ),
    );
  }
}
