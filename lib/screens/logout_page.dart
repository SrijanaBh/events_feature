import 'package:flutter/material.dart';
import 'login_page.dart'; // Ensure this path is correct
import '../utils/auth_manager.dart'; // Import your AuthManager file

class LogoutPage extends StatefulWidget {
  const LogoutPage({super.key});

  @override
  State<LogoutPage> createState() => _LogoutPageState();
}

class _LogoutPageState extends State<LogoutPage> {
  @override
  void initState() {
    super.initState();

    // Short delay to show logout success message
    Future.delayed(const Duration(seconds: 1), () async {
      if (!mounted) return;

      // 🔹 Clear stored tokens and logout
      await AuthManager.logout();

      // 🔹 Close all previous screens
      Navigator.popUntil(context, (route) => route.isFirst);

      // 🔹 Show LoginScreen as a bottom sheet
      await showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => Padding(
          // Prevent keyboard from covering fields
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
            height: MediaQuery.of(context).size.height * 0.55,
            decoration: const BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
            ),
            child: const LoginScreen(),
          ),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle, color: Colors.greenAccent, size: 80),
            SizedBox(height: 16),
            Text(
              "Logged out successfully",
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 10),
            Text(
              "Redirecting to login...",
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}


/*
import 'package:flutter/material.dart';
import 'login_page.dart'; // Ensure this path is correct
import '../utils/auth_manager.dart'; // Import your AuthManager file

class LogoutPage extends StatefulWidget {
  const LogoutPage({super.key});

  @override
  State<LogoutPage> createState() => _LogoutPageState();
}

class _LogoutPageState extends State<LogoutPage> {
  @override
  void initState() {
    super.initState();

    // Wait briefly to show "logged out" message before redirecting
    Future.delayed(const Duration(seconds: 1), () async {
      if (!mounted) return;

      // 🔹 Clear stored tokens and logout
      await AuthManager.logout();

      // 🔹 Redirect to LoginScreen (replace all previous routes)
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle, color: Colors.greenAccent, size: 80),
            SizedBox(height: 16),
            Text(
              "Logged out successfully",
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 10),
            Text(
              "Redirecting to login...",
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}

*/




/*
import 'package:flutter/material.dart';
import 'login_page.dart'; // Ensure correct path

class LogoutPage extends StatefulWidget {
  const LogoutPage({super.key});

  @override
  State<LogoutPage> createState() => _LogoutPageState();
}

class _LogoutPageState extends State<LogoutPage> {
  @override
  void initState() {
    super.initState();

    // Short delay to show logout success message
    Future.delayed(const Duration(seconds: 1), () async {
      if (!mounted) return;

      // Close any previous screens
      Navigator.popUntil(context, (route) => route.isFirst);

      // Show login as a modal bottom sheet
      await showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => Padding(
          // Add padding so keyboard doesn’t cover fields
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
            height:
                MediaQuery.of(context).size.height *
                0.45, // 🔹 smaller height (55%)
            decoration: const BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
            ),
            child: const LoginScreen(),
          ),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle, color: Colors.greenAccent, size: 80),
            SizedBox(height: 16),
            Text(
              "Logged out successfully",
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 10),
            Text(
              "Redirecting to login...",
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}
*/

