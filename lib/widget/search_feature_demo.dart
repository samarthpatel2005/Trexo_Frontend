import 'package:flutter/material.dart';

class SearchFeatureDemo extends StatelessWidget {
  const SearchFeatureDemo({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Search & Filter Features'),
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            // Header
            Text(
              'Enhanced Search & Filter System',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.blue[800],
              ),
            ),
            const SizedBox(height: 16),
            
            // Description
            Text(
              'The new search system provides comprehensive filtering and searching capabilities for both vehicles and properties.',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 24),
            
            // Vehicle Features
            _buildFeatureSection(
              'Vehicle Search Features',
              Icons.directions_car,
              Colors.blue,
              [
                'Search by name, model, location, fuel type, transmission',
                'Filter by price range (min/max)',
                'Filter by year range',
                'Filter by maximum KM driven',
                'Filter by fuel type (Petrol, Diesel, CNG, Electric, etc.)',
                'Filter by transmission (Manual, Automatic)',
                'Filter by location',
                'Show only assured vehicles',
                'Sort by price, year, or KM driven',
                'Real-time search as you type',
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Property Features
            _buildFeatureSection(
              'Property Search Features',
              Icons.home_work,
              Colors.green,
              [
                'Search by title, location, description, tags',
                'Filter by price range (min/max)',
                'Filter by property type (if available)',
                'Filter by number of bedrooms (min/max)',
                'Filter by location',
                'Sort by price or newest listings',
                'Real-time search as you type',
                'Advanced text search across all fields',
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Mobile Features
            _buildFeatureSection(
              'Mobile-Responsive Features',
              Icons.phone_android,
              Colors.purple,
              [
                'Collapsible filter section to save space',
                'Touch-friendly dropdowns and inputs',
                'Optimized layout for small screens',
                'Clear visual feedback during search',
                'Easy filter reset functionality',
                'Responsive grid layout adjusts to screen size',
                'Search results count display',
                'Empty state with helpful messages',
              ],
            ),
            
            const SizedBox(height: 32),
            
            // Usage Instructions
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.blue[700]),
                      const SizedBox(width: 8),
                      Text(
                        'How to Use',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[800],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '1. Navigate to the Vehicle or Property listings page\n'
                    '2. Use the search bar to type your query\n'
                    '3. Tap the filter icon to access advanced filters\n'
                    '4. Set your desired filters and tap "Apply Filters"\n'
                    '5. Results will update automatically\n'
                    '6. Use "Clear All" to reset all filters',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.blue[700],
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureSection(
    String title,
    IconData icon,
    Color color,
    List<String> features,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 28),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...features.map((feature) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.check_circle,
                  color: color,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    feature,
                    style: TextStyle(
                      color: Colors.grey[700],
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          )).toList(),
        ],
      ),
    );
  }
}