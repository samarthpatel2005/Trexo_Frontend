import 'package:flutter/material.dart';
import 'package:trexo/screen/VehicleDetailsPage.dart';
import 'package:trexo/screen/ViewAllScreen.dart';
import 'package:trexo/screen/ViewPropertyScreen.dart';
import 'package:trexo/screen/ViewVehicleScreen.dart';
import 'package:trexo/screen/about.dart';
import 'package:trexo/screen/admin_dashboard.dart';
import 'package:trexo/screen/signup_screen.dart';
import 'package:trexo/screen/login_screen.dart';
import 'package:trexo/screen/home_screen.dart';
import 'package:trexo/screen/profile_page.dart';
import 'package:trexo/screen/add_vehicle_screen.dart';
import 'package:trexo/screen/add_property_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Trexo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue),

      // Default screen
      initialRoute: '/signup',

      // Route definitions
      routes: {
        '/signup': (context) => const SignupScreen(),
        '/login': (context) => const LoginScreen(),
        '/home': (context) => const HomeScreen(email: ''), // 👈 Replace with dynamic email in Login
        '/profile': (context) => const ProfilePage(),
        '/about': (context) => const AboutPage(),
        '/admin': (context) => const AdminDashboard(), // ✅ Add this
        '/add-vehicle': (context) => const AddVehicleScreen(),
        '/add-property': (context) => const AddPropertyScreen(),
        '/view-all': (context) => const ViewAllScreen(), 
        '/view-property': (context) => const ViewPropertyScreen(),
        '/view-vehicle': (context) => const ViewVehicleScreen(),
        '/vehicle-details': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
          return VehicleDetailsPage(vehicle: args);
        },
      },
    );
  }
}
