import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:trexo/widget/InteractiveCard.dart';

class ViewPropertyScreen extends StatefulWidget {
  const ViewPropertyScreen({super.key});

  @override
  State<ViewPropertyScreen> createState() => _ViewPropertyScreenState();
}

class _ViewPropertyScreenState extends State<ViewPropertyScreen> {
  List properties = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchProperties();
  }

  Future<void> fetchProperties() async {
    try {
      final res = await http.get(Uri.parse('http://localhost:5000/api/view/property'));
      if (res.statusCode == 200) {
        setState(() {
          properties = jsonDecode(res.body);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("View Properties")),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : properties.isEmpty
              ? const Center(child: Text("No properties available"))
              : ListView.builder(
                  padding: const EdgeInsets.all(10),
                  itemCount: properties.length,
                  itemBuilder: (_, i) {
                    final item = properties[i];
                    return InteractiveListingCard(
                      title: item['title'],
                      price: (item['price'] ?? 0).toDouble(),
                      location: item['location'],
                      imageUrls: List<String>.from(item['imageUrls'] ?? []),
                    );
                  },
                ),
    );
  }
}
