// import 'package:flutter/material.dart';

// class CustomHeader extends StatelessWidget {
//   const CustomHeader({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       decoration: const BoxDecoration(
//         gradient: LinearGradient(
//           colors: [Color(0xFFd2fbd8), Color(0xFFa5f1cd)],
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//         ),
//       ),
//       child: SafeArea(
//         child: Scaffold(
//           backgroundColor: Colors.transparent,
//           body: Center(
//             child: SingleChildScrollView(
//               padding: const EdgeInsets.symmetric(horizontal: 24),
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Image.asset('assets/images/trexo_logo.png', height: 120),
//                   const SizedBox(height: 40),
//                   // Additional widgets can be added here
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:trexo/screen/profilepage.dart';

class CustomHeader extends StatelessWidget implements PreferredSizeWidget {
  const CustomHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 2,
      automaticallyImplyLeading: false,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // App Logo or Name
          Row(
            children: [
              Image.asset(
                'assets/images/trexo_logo.png', // Your app logo path
                height: 100,
              ),
              const SizedBox(width: 8),
            ],
          ),
          // Profile Icon
          IconButton(
            icon: CircleAvatar(
              radius: 20,
              backgroundImage: AssetImage(
                'assets/images/profile_pic.jpg',
              ), // Your profile picture path
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const Profilepage()),
              );
            },
          ),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
