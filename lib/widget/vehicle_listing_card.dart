import 'package:flutter/material.dart';

class VehicleListingCard extends StatefulWidget {
  final String imageUrl;
  final String name;
  final String year;
  final String variant;
  final double price;
  final String emi;
  final String kmDriven;
  final String fuelType;
  final String transmission;
  final String registration;
  final String location;
  final String badgeText;
  final String badgeDescription;
  final bool isAssured;
  final VoidCallback? onFavorite;
  final bool isFavorite;
  final VoidCallback? onTap;

  const VehicleListingCard({
    super.key,
    required this.imageUrl,
    required this.name,
    required this.year,
    required this.variant,
    required this.price,
    required this.emi,
    required this.kmDriven,
    required this.fuelType,
    required this.transmission,
    required this.registration,
    required this.location,
    required this.badgeText,
    required this.badgeDescription,
    this.isAssured = true,
    this.onFavorite,
    this.isFavorite = false,
    this.onTap,
  });

  @override
  State<VehicleListingCard> createState() => _VehicleListingCardState();
}

class _VehicleListingCardState extends State<VehicleListingCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    setState(() => _isPressed = true);
    _animationController.forward();
  }

  void _onTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
    _animationController.reverse();
    widget.onTap?.call();
  }

  void _onTapCancel() {
    setState(() => _isPressed = false);
    _animationController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: GestureDetector(
            onTapDown: _onTapDown,
            onTapUp: _onTapUp,
            onTapCancel: _onTapCancel,
            child: Container(
              margin: const EdgeInsets.symmetric(
                vertical: 8,
              ), // Add vertical space between cards
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color.fromARGB(255, 255, 255, 255), // Light blue
                    Color.fromARGB(255, 255, 255, 255), // Blue
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                // border: Border.all(color: Colors.blueGrey.shade200, width: 2),
                boxShadow: [
                  // Main shadow (bottom right, dark)
                  BoxShadow(
                    color: Colors.black.withOpacity(0.18),
                    blurRadius: 18,
                    spreadRadius: 2,
                    offset: const Offset(8, 8),
                  ),
                  // Highlight shadow (top left, light)
                  BoxShadow(
                    color: Colors.white.withOpacity(0.7),
                    blurRadius: 12,
                    spreadRadius: 1,
                    offset: const Offset(-6, -6),
                  ),
                  // Optional: subtle colored shadow for depth
                  BoxShadow(
                    color: Colors.blueGrey.withOpacity(0.08),
                    blurRadius: 24,
                    spreadRadius: 4,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              child: ClipRRect(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Stack(
                    children: [
                      // Background Image
                      AspectRatio(
                        aspectRatio: 1.4,
                        child: Image.network(
                          widget.imageUrl,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          errorBuilder:
                              (context, error, stackTrace) => Container(
                                color: Colors.grey[300],
                                child: const Icon(
                                  Icons.directions_car,
                                  size: 60,
                                  color: Colors.grey,
                                ),
                              ),
                        ),
                      ),

                      // Gradient Overlay
                      AspectRatio(
                        aspectRatio: 1.4,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.black.withOpacity(0.7),
                              ],
                              stops: const [0.4, 1.0],
                            ),
                          ),
                        ),
                      ),

                      // Favorite Button
                      Positioned(
                        top: 12,
                        right: 12,
                        child: GestureDetector(
                          onTap: widget.onFavorite,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.9),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Icon(
                              widget.isFavorite
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              color:
                                  widget.isFavorite
                                      ? Colors.red
                                      : Colors.grey[600],
                              size: 20,
                            ),
                          ),
                        ),
                      ),

                      // Content Overlay
                      Positioned(
                        left: 16,
                        right: 16,
                        bottom: 16,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Vehicle Name and Year
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Text(
                                    '${widget.year} ${widget.name}',
                                    style: const TextStyle(
                                      color: Color.fromARGB(255, 0, 0, 0),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color.fromARGB(
                                      255,
                                      255,
                                      255,
                                      255,
                                    ).withOpacity(0.9),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    'EMI ${widget.emi}',
                                    style: const TextStyle(
                                      color: Colors.black87,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            if (widget.variant.isNotEmpty) ...[
                              const SizedBox(height: 2),
                              Text(
                                widget.variant,
                                style: TextStyle(
                                  color: const Color.fromARGB(
                                    255,
                                    0,
                                    0,
                                    0,
                                  ).withOpacity(0.9),
                                  fontSize: 14,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],

                            const SizedBox(height: 8),

                            // Price
                            Text(
                              '₹${widget.price.toStringAsFixed(2)}',
                              style: const TextStyle(
                                color: Color.fromARGB(255, 0, 0, 0),
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                              ),
                            ),

                            const SizedBox(height: 12),

                            // Pills Row
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: [
                                  _glassPill('${widget.kmDriven} km'),
                                  const SizedBox(width: 6),
                                  _glassPill(widget.fuelType),
                                  const SizedBox(width: 6),
                                  _glassPill(widget.transmission),
                                  const SizedBox(width: 6),
                                  _glassPill(widget.registration),
                                ],
                              ),
                            ),

                            const SizedBox(height: 8),

                            // Location
                            Row(
                              children: [
                                Icon(
                                  Icons.location_on,
                                  color: const Color.fromARGB(
                                    255,
                                    0,
                                    0,
                                    0,
                                  ).withOpacity(0.8),
                                  size: 14,
                                ),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    widget.location,
                                    style: TextStyle(
                                      color: const Color.fromARGB(
                                        255,
                                        0,
                                        0,
                                        0,
                                      ).withOpacity(0.9),
                                      fontSize: 12,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 12),

                            // Badge
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color:
                                    widget.isAssured
                                        ? Colors.green.withOpacity(0.9)
                                        : Colors.purpleAccent.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.verified,
                                    color: Colors.blue,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    widget.badgeText,
                                    style: const TextStyle(
                                      color: Color.fromARGB(255, 0, 0, 0),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                  if (widget.badgeDescription.isNotEmpty) ...[
                                    const SizedBox(width: 6),
                                    Text(
                                      '• ${widget.badgeDescription}',
                                      style: const TextStyle(
                                        color: Color.fromARGB(255, 0, 0, 0),
                                        fontSize: 11,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _glassPill(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 0, 0, 0).withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Color.fromARGB(255, 0, 0, 0),
          fontSize: 11,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
