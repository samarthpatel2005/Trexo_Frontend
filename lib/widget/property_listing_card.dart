import 'package:flutter/material.dart';

class PropertyListingCard extends StatelessWidget {
  final String imageUrl;
  final String title;
  final double price;
  final String location;
  final String? badgeText;
  final String? badgeDescription;
  final VoidCallback? onDetailsPressed;
  final VoidCallback? onTap;
  final bool isFavorite;
  final VoidCallback? onFavorite;
  final String? area;
  final String? bedrooms;
  final String? bathrooms;
  final String? furnishing;

  const PropertyListingCard({
    super.key,
    required this.imageUrl,
    required this.title,
    required this.price,
    required this.location,
    this.badgeText,
    this.badgeDescription,
    this.onDetailsPressed,
    this.onTap,
    this.isFavorite = false,
    this.onFavorite,
    this.area,
    this.bedrooms,
    this.bathrooms,
    this.furnishing,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.white, Colors.grey[50]!],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildImageSection(),
                _buildContentSection(),
                if (badgeText != null && badgeDescription != null)
                  _buildBadgeSection(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImageSection() {
    return Stack(
      children: [
        Container(
          height: 200,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
            child: Image.network(
              imageUrl,
              fit: BoxFit.cover,
              errorBuilder:
                  (context, error, stackTrace) => Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Colors.grey[300]!, Colors.grey[400]!],
                      ),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.home_rounded,
                        size: 60,
                        color: Colors.white,
                      ),
                    ),
                  ),
            ),
          ),
        ),
        // Gradient overlay
        Container(
          height: 200,
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.transparent, Colors.black.withOpacity(0.1)],
            ),
          ),
        ),
        // Favorite button
        Positioned(
          top: 16,
          right: 16,
          child: GestureDetector(
            onTap: onFavorite,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                isFavorite ? Icons.favorite : Icons.favorite_border,
                color: isFavorite ? Colors.red[400] : Colors.grey[600],
                size: 20,
              ),
            ),
          ),
        ),
        // Price badge
        Positioned(
          bottom: 16,
          left: 16,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.95),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              '₹${_formatPrice(price)}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.indigo[800],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildContentSection() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: Colors.black87,
              height: 1.2,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                Icons.location_on_rounded,
                size: 16,
                color: Colors.grey[600],
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  location,
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildFeaturesPills(),
        ],
      ),
    );
  }

  Widget _buildFeaturesPills() {
    List<String> features = [];
    if (area != null && area!.isNotEmpty) features.add(area!);
    if (bedrooms != null && bedrooms!.isNotEmpty)
      features.add('${bedrooms!} BHK');
    if (bathrooms != null && bathrooms!.isNotEmpty)
      features.add('${bathrooms!} Bath');
    if (furnishing != null && furnishing!.isNotEmpty) features.add(furnishing!);

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: features.map((feature) => _buildFeaturesPill(feature)).toList(),
    );
  }
Widget _buildFeaturesPill([String? feature]) {
  final List<Map<String, dynamic>> features = [];

  if (area != null && area!.isNotEmpty) {
    features.add({'icon': Icons.square_foot, 'label': 'Area', 'value': area});
  }
  if (bedrooms != null && bedrooms!.isNotEmpty) {
    features.add({'icon': Icons.bed, 'label': 'Bedrooms', 'value': bedrooms});
  }
  if (bathrooms != null && bathrooms!.isNotEmpty) {
    features.add({'icon': Icons.bathtub, 'label': 'Bathrooms', 'value': bathrooms});
  }
  if (furnishing != null && furnishing!.isNotEmpty) {
    features.add({'icon': Icons.weekend, 'label': 'Furnishing', 'value': furnishing});
  }

  if (features.isEmpty) return const SizedBox();

  return Padding(
    padding: const EdgeInsets.only(top: 4.0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Property Overview',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: features.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 4, // Adjust for layout height
            mainAxisSpacing: 10,
            crossAxisSpacing: 12,
          ),
          itemBuilder: (context, index) {
            final feature = features[index];
            return Row(
              children: [
                Icon(
                  feature['icon'],
                  color: Colors.indigo,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        feature['label'],
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.black54,
                        ),
                      ),
                      Text(
                        feature['value'] ?? '',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ],
    ),
  );
}


  Widget _buildBadgeSection() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [Colors.green[50]!, Colors.teal[50]!]),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.green[100]!, width: 1),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.green[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.verified_rounded,
              color: Colors.green[700],
              size: 16,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  badgeText!,
                  style: TextStyle(
                    color: Colors.green[800],
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  badgeDescription!,
                  style: TextStyle(fontSize: 12, color: Colors.green[600]),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatPrice(double price) {
    if (price >= 10000000) {
      return '${(price / 10000000).toStringAsFixed(1)}Cr';
    } else if (price >= 100000) {
      return '${(price / 100000).toStringAsFixed(1)}L';
    } else if (price >= 1000) {
      return '${(price / 1000).toStringAsFixed(1)}K';
    } else {
      return price.toStringAsFixed(0);
    }
  }
}
