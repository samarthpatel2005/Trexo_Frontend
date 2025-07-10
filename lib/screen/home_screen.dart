import 'package:flutter/material.dart';
import 'package:trexo/screen/ViewPropertyScreen.dart';
import 'package:trexo/screen/ViewVehicleScreen.dart';
import 'package:trexo/screen/sell_dashboard.dart';
import 'package:trexo/widget/ResponsiveScaffold.dart';
import 'package:trexo/widget/header.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required email});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool showProperty = true;

  @override
  Widget build(BuildContext context) {
    return ResponsiveScaffold(
      body: Stack(
        children: [
          Column(
            children: [
              const SizedBox(height: 20),

              // Toggle Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () => setState(() => showProperty = true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          showProperty ? Colors.teal : Colors.grey[300],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                    child: const Text("Property"),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: () => setState(() => showProperty = false),
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          !showProperty ? Colors.teal : Colors.grey[300],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                    child: const Text("Vehicle"),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Show content
              Expanded(
                child: showProperty
                    ? const ViewPropertyScreen()
                    : const ViewVehicleScreen(),
              ),
            ],
          ),
          // Floating Action Button at bottom right
          Positioned(
            bottom: 24,
            right: 24,
            child: FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SellDashboard()),
                );
              },
              backgroundColor: Colors.teal,
              child: const Icon(Icons.add),
            ),
          ),
        ],
      ),
    );
  }
}