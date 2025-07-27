import 'package:flutter/material.dart';
import 'package:trexo/screen/ViewPropertyScreen.dart';
import 'package:trexo/screen/ViewVehicleScreen.dart';
import 'package:trexo/screen/liked_vehicles.dart';
import 'package:trexo/screen/sell_dashboard.dart';
import 'package:trexo/widget/ResponsiveScaffold.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required email});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  int _selectedIndex = 0; // 0: Vehicle, 1: Property, 2: Sell, 3: Favorites

  Widget _getCurrentScreen() {
    switch (_selectedIndex) {
      case 0:
        return const ViewVehicleScreen();
      case 1:
        return const ViewPropertyScreen();
      case 2:
        return const SellDashboard();
      case 3:
        return const LikedVehiclesPage();
      default:
        return const ViewVehicleScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveScaffold(
      body: Stack(
        children: [
          Column(
            children: [
              const SizedBox(height: 20),

              // Show content
              Expanded(child: _getCurrentScreen()),
            ],
          ),
          // Footer Navigation Bar
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 80,
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildNavItem(
                    icon: Icons.directions_car,
                    label: 'Vehicle',
                    isSelected: _selectedIndex == 0,
                    onTap: () {
                      setState(() {
                        _selectedIndex = 0;
                      });
                    },
                  ),
                  _buildNavItem(
                    icon: Icons.home_work,
                    label: 'Property',
                    isSelected: _selectedIndex == 1,
                    onTap: () {
                      setState(() {
                        _selectedIndex = 1;
                      });
                    },
                  ),
                  _buildNavItem(
                    icon: Icons.add_circle,
                    label: 'Sell',
                    isSelected: _selectedIndex == 2,
                    onTap: () {
                      setState(() {
                        _selectedIndex = 2;
                      });
                    },
                  ),
                  _buildNavItem(
                    icon: Icons.favorite,
                    label: 'Favorites',
                    isSelected: _selectedIndex == 3,
                    onTap: () {
                      setState(() {
                        _selectedIndex = 3;
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 24,
              color: isSelected ? Colors.teal : Colors.grey[600],
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? Colors.teal : Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
