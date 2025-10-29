// import 'package:events_feature/screens/home_screen.dart';
// import 'package:events_feature/screens/login_page.dart';
// import 'package:flutter/material.dart';

// class AuthWrapper extends StatefulWidget {
//   const AuthWrapper({super.key});

//   @override
//   State<AuthWrapper> createState() => _AuthWrapperState();
// }

// class _AuthWrapperState extends State<AuthWrapper> {
//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       // final user = FirebaseAuth.instance.currentUser;
//       // if (user == null) {
//       //   // Show login popup
//       //   _showLoginPopup();
//       // }
//     });
//   }

//   void _showLoginPopup() {
//     showDialog(
//       context: context,
//       barrierDismissible: false, // Prevent closing without login
//       builder: (_) => const LoginScreen(),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return const MainHomeScreen(); // Always render home, but gate access with popup
//   }
// }
