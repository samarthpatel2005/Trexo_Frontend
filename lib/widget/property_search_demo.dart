import 'package:flutter/material.dart';

class PropertySearchDemo extends StatelessWidget {
  const PropertySearchDemo({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Enhanced Property Search'),
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            // Header
            Row(
              children: [
                Icon(Icons.home_work, size: 32, color: Colors.green[700]),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Enhanced Property Search & Filter System',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.green[800],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Description
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green[200]!),
              ),
              child: Text(
                'The enhanced property search system now provides comprehensive filtering capabilities with multiple search criteria, advanced sorting options, and mobile-responsive design.',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.green[700],
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            // Search Features
            _buildFeatureCard(
              'Smart Search Capabilities',
              Icons.search,
              Colors.blue,
              [
                'Search by property title, location, and description',
                'Search by address and area details',
                'Search by amenities and property features',
                'Search by tags and keywords',
                'Search by bedroom and bathroom count',
                'Search by furnishing type',
                'Real-time search as you type',
                'Intelligent text matching across all fields',
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Filter Features
            _buildFeatureCard(
              'Advanced Filtering Options',
              Icons.filter_list,
              Colors.orange,
              [
                'Filter by price range (minimum and maximum)',
                'Filter by property type (apartment, house, villa, etc.)',
                'Filter by location and address',
                'Filter by number of bedrooms (min/max range)',
                'Filter by number of bathrooms (min/max range)',
                'Filter by property area (square feet range)',
                'Filter by furnishing type (furnished, semi-furnished, unfurnished)',
                'Filter for featured properties only',
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Sorting Features
            _buildFeatureCard(
              'Smart Sorting Options',
              Icons.sort,
              Colors.purple,
              [
                'Sort by price: Low to High',
                'Sort by price: High to Low',
                'Sort by newest listings first',
                'Sort by area: Large to Small',
                'Sort by bedrooms: High to Low',
                'Maintain sort preferences during filtering',
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Mobile Features
            _buildFeatureCard(
              'Mobile-Optimized Experience',
              Icons.phone_android,
              Colors.teal,
              [
                'Responsive grid layout adapts to screen size',
                'Collapsible filter section for space efficiency',
                'Touch-friendly dropdowns and input fields',
                'Swipe-friendly property cards',
                'Clear visual feedback for filter states',
                'Easy one-tap filter clearing',
                'Loading indicators during search',
                'Empty state with helpful guidance',
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Usage Instructions
            Container(
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
                      Icon(Icons.info_outline, color: Colors.green[700]),
                      const SizedBox(width: 8),
                      Text(
                        'How to Use the Property Search',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.green[800],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ..._buildInstructionSteps([
                    'Navigate to the Property listings page',
                    'Enter your search query in the search bar (property title, location, etc.)',
                    'Tap the filter icon to access advanced filtering options',
                    'Set your price range, property type, and other preferences',
                    'Use bedroom/bathroom filters to narrow down options',
                    'Apply area range filter for size preferences',
                    'Enable "Featured Properties Only" for premium listings',
                    'Choose your preferred sorting option',
                    'Tap "Apply Filters" to see filtered results',
                    'Use "Clear All" to reset and start over',
                  ]),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Property Data Fields
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.data_object, color: Colors.grey[700]),
                      const SizedBox(width: 8),
                      Text(
                        'Searchable Property Fields',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      'Title', 'Location', 'Address', 'Description', 'Area',
                      'Bedrooms', 'Bathrooms', 'Property Type', 'Furnishing',
                      'Tags', 'Amenities', 'Price', 'Featured Status'
                    ].map((field) => Chip(
                      label: Text(field),
                      backgroundColor: Colors.green[100],
                      labelStyle: TextStyle(color: Colors.green[700]),
                    )).toList(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureCard(String title, IconData icon, Color color, List<String> features) {
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
              Icon(icon, color: color, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...features.map((feature) => Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.check_circle_outline,
                  color: color,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    feature,
                    style: TextStyle(
                      color: Colors.grey[700],
                      height: 1.3,
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

  List<Widget> _buildInstructionSteps(List<String> steps) {
    return steps.asMap().entries.map((entry) {
      int index = entry.key;
      String step = entry.value;
      return Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: Colors.green[700],
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '${index + 1}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                step,
                style: TextStyle(
                  color: Colors.grey[700],
                  height: 1.4,
                ),
              ),
            ),
          ],
        ),
      );
    }).toList();
  }
}