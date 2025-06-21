// import 'package:flutter/material.dart';

// class SimpleHeader extends StatelessWidget implements PreferredSizeWidget {
//   const SimpleHeader({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return AppBar(
//       backgroundColor: Colors.blue,
//       elevation: 4,
//       title: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           // 👈 Left: Logo and App Name
//           Row(
//             children: [
//               Image.asset('assets/images/logo.png', height: 100),
//               const SizedBox(width: 10),
//               // const Text("MyApp", style: TextStyle(color: Colors.white)),
//             ],
//           ),

//           // 👉 Right: Navigation Buttons
//           Row(
//             children: [
//               TextButton(
//                 onPressed: () => Navigator.pushNamed(context, '/about'),
//                 child: const Text("About", style: TextStyle(color: Colors.white)),
//               ),
//               const SizedBox(width: 8),
//               TextButton(
//                 onPressed: () => Navigator.pushNamed(context, '/profile'),
//                 child: const Text("Profile", style: TextStyle(color: Colors.white)),
//               ),
//             ],
//           )
//         ],
//       ),
//     );
//   }

//   @override
//   Size get preferredSize => const Size.fromHeight(kToolbarHeight);
// }
import 'package:flutter/material.dart';

class SimpleHeader extends StatelessWidget implements PreferredSizeWidget {
  const SimpleHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    return AppBar(
      backgroundColor: Colors.blue,
      elevation: 4,
      automaticallyImplyLeading: false, // ❌ Disable default drawer icon
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // 👈 Left: Logo + (Menu button for mobile)
          Row(
            children: [
              Image.asset('assets/images/logo.png', height: 100),
              const SizedBox(width: 180),
              if (isMobile)
                IconButton(
                  icon: const Icon(Icons.search, color: Colors.white),
                  onPressed: () {
                    showSearch(
                      context: context,
                      delegate: _MobileSearchDelegate(),
                    );
                  },
                ),
              if (isMobile) // 👇 Only show on mobile
                Builder(
                  builder:
                      (context) => IconButton(
                        icon: const Icon(Icons.menu, color: Colors.white),
                        onPressed: () => Scaffold.of(context).openDrawer(),
                      ),
                ),
            ],
          ),

          // 👉 Right: Navigation buttons (desktop only)
          if (!isMobile)
            Row(
              children: [
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
            ),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

// A simple SearchDelegate for mobile search functionality
class _MobileSearchDelegate extends SearchDelegate<String> {
  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, '');
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    // Replace with your search result logic
    return Center(child: Text('You searched for "$query"'));
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    // Replace with your search suggestions logic
    return ListView(
      children: [ListTile(title: Text('Suggestion for "$query"'))],
    );
  }
}
