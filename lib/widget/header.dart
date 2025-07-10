import 'package:flutter/material.dart';
// import 'package:trexo/widget/ResponsiveScaffold.dart';

class SimpleHeader extends StatefulWidget implements PreferredSizeWidget {
  const SimpleHeader({super.key});

  @override
  State<SimpleHeader> createState() => _SimpleHeaderState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _SimpleHeaderState extends State<SimpleHeader>
    with SingleTickerProviderStateMixin {
  bool _isSearchExpanded = false;
  final TextEditingController _searchController = TextEditingController();
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _toggleSearch() {
    setState(() {
      _isSearchExpanded = !_isSearchExpanded;
      if (_isSearchExpanded) {
        _animationController.forward();
      } else {
        _animationController.reverse();
        _searchController.clear();
      }
    });
  }

  void _onSearchSubmitted(String value) {
    if (value.isNotEmpty) {
      showDialog(
        context: context,
        builder:
            (_) => AlertDialog(
              title: const Text('Search'),
              content: Text('You searched for "$value"'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('OK'),
                ),
              ],
            ),
      );
    }
    _toggleSearch();
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    return AppBar(
      backgroundColor: Colors.blue,
      elevation: 4,
      automaticallyImplyLeading: false,
      title: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return Row(
            children: [
              // Logo - fade out when search is expanded on mobile
              if (!isMobile || !_isSearchExpanded) ...[
                AnimatedOpacity(
                  opacity: isMobile ? (1.0 - _animation.value) : 1.0,
                  duration: const Duration(milliseconds: 300),
                  child: Image.asset('assets/images/logo.png', height: 100),
                ),
                const SizedBox(width: 8),
              ],

              // Spacer
              const Spacer(),

              // Desktop: search + nav buttons
              if (!isMobile) ...[
                SizedBox(
                  width: 250,
                  child: TextField(
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Search...',
                      hintStyle: const TextStyle(color: Colors.white70),
                      filled: true,
                      fillColor: Colors.blue[700],
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      prefixIcon: const Icon(Icons.search, color: Colors.white),
                    ),
                    onSubmitted: (value) {
                      showDialog(
                        context: context,
                        builder:
                            (_) => AlertDialog(
                              title: const Text('Search'),
                              content: Text('You searched for "$value"'),
                            ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 16),
                TextButton(
                  onPressed: () => Navigator.pushNamed(context, '/about'),
                  child: const Text(
                    "About",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                const SizedBox(width: 8),
                TextButton(
                  onPressed: () => Navigator.pushNamed(context, '/profile'),
                  child: const Text(
                    "Profile",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],

              // Mobile: expandable search + menu
              if (isMobile) ...[
                // Expanded search bar
                if (_isSearchExpanded) ...[
                  Expanded(
                    child: Container(
                      height: 40,
                      margin: const EdgeInsets.only(right: 12),
                      child: TextField(
                        controller: _searchController,
                        autofocus: true,
                        style: const TextStyle(color: Colors.black),
                        decoration: InputDecoration(
                          hintText: 'Search...',
                          hintStyle: const TextStyle(color: Colors.black),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                            borderSide: BorderSide.none,
                          ),
                          prefixIcon: const Icon(
                            Icons.search,
                            color: Colors.black,
                          ),
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.close, color: Colors.black),
                            onPressed: _toggleSearch,
                          ),
                        ),
                        onSubmitted: _onSearchSubmitted,
                      ),
                    ),
                  ),
                ] else ...[
                  // Search icon
                  IconButton(
                    icon: const Icon(Icons.search, color: Colors.white),
                    onPressed: _toggleSearch,
                  ),
                  // Menu icon
                  Builder(
                    builder:
                        (context) => IconButton(
                          icon: const Icon(Icons.menu, color: Colors.white),
                          onPressed: () => Scaffold.of(context).openDrawer(),
                        ),
                  ),
                ],
              ],
            ],
          );
        },
      ),
    );
  }
}

// Keep the search delegate as backup (not used in the new implementation)
// class _MobileSearchDelegate extends SearchDelegate<String> {
//   @override
//   List<Widget>? buildActions(BuildContext context) {
//     return [
//       IconButton(icon: const Icon(Icons.clear), onPressed: () => query = ''),
//     ];
//   }

//   @override
//   Widget? buildLeading(BuildContext context) {
//     return IconButton(
//       icon: const Icon(Icons.arrow_back),
//       onPressed: () => close(context, ''),
//     );
//   }

//   @override
//   Widget buildResults(BuildContext context) {
//     return Center(child: Text('You searched for "$query"'));
//   }

//   @override
//   Widget buildSuggestions(BuildContext context) {
//     return ListView(
//       children: [ListTile(title: Text('Suggestion for "$query"'))],
//     );
//   }
// }
