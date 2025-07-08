import 'package:flutter/material.dart';
// import 'package:trexo/widget/ResponsiveScaffold.dart';

class SimpleHeader extends StatelessWidget implements PreferredSizeWidget {
  const SimpleHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    return AppBar(
      backgroundColor: Colors.blue,
      elevation: 4,
      automaticallyImplyLeading: false,
      title: Row(
        children: [
          // 👈 Logo
          Image.asset('assets/images/logo.png', height: 100),
          const SizedBox(width: 8),
          // 🔥 Spacer takes up remaining space
          const Spacer(),

          // 👇 Desktop: search + nav buttons
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
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16),
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
              child: const Text("About", style: TextStyle(color: Colors.white)),
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

          // 👇 Mobile: search + menu
          if (isMobile) ...[
            IconButton(
              icon: const Icon(Icons.search, color: Colors.white),
              onPressed: () {
                showSearch(context: context, delegate: _MobileSearchDelegate());
              },
            ),
            Builder(
              builder:
                  (context) => IconButton(
                    icon: const Icon(Icons.menu, color: Colors.white),
                    onPressed: () => Scaffold.of(context).openDrawer(),
                  ),
            ),
          ],
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

// Same search delegate as before
class _MobileSearchDelegate extends SearchDelegate<String> {
  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(icon: const Icon(Icons.clear), onPressed: () => query = ''),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () => close(context, ''),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return Center(child: Text('You searched for "$query"'));
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return ListView(
      children: [ListTile(title: Text('Suggestion for "$query"'))],
    );
  }
}
