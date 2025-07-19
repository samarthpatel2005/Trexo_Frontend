import 'package:flutter/material.dart';
import 'package:trexo/screen/VehicleDetailsPage.dart';
// import 'package:trexo/screen/ViewAllScreen.dart';
import 'package:trexo/screen/ViewPropertyScreen.dart';
import 'package:trexo/screen/ViewVehicleScreen.dart';
import 'package:trexo/screen/about.dart';
import 'package:trexo/screen/add_property_screen.dart';
import 'package:trexo/screen/add_vehicle_screen.dart';
// import 'package:trexo/screen/admin_dashboard.dart';
import 'package:trexo/screen/home_screen.dart';
import 'package:trexo/screen/login_screen.dart';
import 'package:trexo/screen/profile_page.dart';
import 'package:trexo/screen/signup_screen.dart';
import 'package:trexo/screen/splash_screen.dart'; // ✅ splash screen import

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

      // ✅ Set splash screen as initial route
      initialRoute: '/',

      routes: {
        '/': (context) => const SplashScreen(), // 🔁 NEW ENTRY POINT
        '/signup': (context) => const SignupScreen(),
        '/login': (context) => const LoginScreen(),
        '/home':
            (context) =>
                const HomeScreen(email: ''), // use user email if needed
        '/profile': (context) => const ProfilePage(),
        '/about': (context) => const AboutPage(),
        // '/admindashboard': (context) => const AdminDashboard(),
        '/add-vehicle': (context) => const AddVehicleScreen(),
        '/add-property': (context) => const AddPropertyScreen(),
        '/view-property': (context) => const ViewPropertyScreen(),
        '/view-vehicle': (context) => const ViewVehicleScreen(),
        '/vehicle-details': (context) {
          final args = ModalRoute.of(context)!.settings.arguments;
          // Handle both old format (Map with 'vehicle' key) and new format (direct vehicle object)
          final vehicle =
              args is Map<String, dynamic>
                  ? (args.containsKey('vehicle') ? args['vehicle'] : args)
                  : args;
          return VehicleDetailsPage(vehicle: vehicle);
        },
        '/property-details': (context) {
          final args = ModalRoute.of(context)!.settings.arguments;
          // Simple property details page - you can create a proper one later
          return Scaffold(
            appBar: AppBar(title: const Text('Property Details')),
            body: Center(
              child: Text('Property Details Page\n${args.toString()}'),
            ),
          );
        },
      },
    );
  }
}
