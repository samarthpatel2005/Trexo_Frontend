import 'package:flutter/material.dart';

import 'home_screen.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About Trexo'),
        backgroundColor: Colors.blue,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(
                builder: (context) => const HomeScreen(email: ""),
              ),
              (route) => false,
            );
          },
        ),
      ),
      backgroundColor: Colors.grey[100],
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Banner (optional image)
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: Colors.indigo[50],
              ),
              child: const Center(
                child: Icon(
                  Icons.directions_car_filled_rounded,
                  size: 80,
                  color: Colors.indigo,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // App Title
            const Text(
              "Welcome to Trexo",
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Colors.indigo,
              ),
            ),
            const SizedBox(height: 12),

            // Description
            const Text(
              "Trexo is your trusted marketplace for buying and selling vehicles and properties. Whether you're looking for your next car or a dream home, Trexo connects buyers and sellers with ease, security, and speed.",
              style: TextStyle(
                fontSize: 16,
                color: Colors.black87,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),

            // Features
            const Text(
              "Why Trexo?",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.indigo,
              ),
            ),
            const SizedBox(height: 16),

            _buildFeatureTile(
              icon: Icons.verified,
              title: "Verified Listings",
              subtitle:
                  "Every vehicle and property is checked for accuracy and legitimacy.",
            ),
            _buildFeatureTile(
              icon: Icons.shield_rounded,
              title: "Safe & Secure",
              subtitle: "Your data and transactions are protected end-to-end.",
            ),
            _buildFeatureTile(
              icon: Icons.speed,
              title: "Quick Search",
              subtitle:
                  "Find exactly what you’re looking for in seconds with our powerful filters.",
            ),
            _buildFeatureTile(
              icon: Icons.support_agent,
              title: "24/7 Support",
              subtitle: "Get help anytime from our friendly support team.",
            ),
            const SizedBox(height: 32),

            // Closing Message
            const Center(
              child: Text(
                "Thank you for choosing Trexo.\nWe’re here to move your journey forward!",
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.black54,
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureTile({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.indigo.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.indigo, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 14, color: Colors.black87),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
