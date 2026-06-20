import 'package:flutter/material.dart';

import 'dart:async';
import 'package:shimmer/shimmer.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _fadeController;

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..forward();

    Timer(const Duration(seconds: 4), () {
      Navigator.pushReplacementNamed(context, '/home');
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color.fromARGB(255, 90, 90, 90),
              Color.fromARGB(220, 1, 1, 3),
              Color.fromARGB(246, 1, 1, 3),
              Color.fromARGB(255, 1, 1, 1),
              Color.fromARGB(248, 10, 10, 10),
              Color.fromARGB(255, 8, 8, 8),
              Color.fromARGB(255, 8, 8, 8),
              //Color.fromARGB(255, 8, 8, 8),
              // Color.fromARGB(255, 8, 8, 8),
              //Color.fromARGB(255, 8, 8, 8),
              // Color.fromARGB(255, 8, 8, 8),
            ],
            begin: Alignment.topRight,
            end: Alignment.bottomRight,
            transform: GradientRotation(145),
          ),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ⭐ SHIMMER LOGO IMAGE ⭐
              Shimmer.fromColors(
                baseColor: const Color.fromARGB(255, 247, 245, 245),
                highlightColor: const Color.fromARGB(255, 3, 3, 3),
                period: const Duration(seconds: 4),
                child: Image.asset(
                  // "assets/logo.png",
                  "assets/big_bull_logo.webp",
                  width: 260,
                  height: 260,
                  fit: BoxFit.contain,
                ),
              ),

              // ⭐ No gap between logo + text
              SizedBox.shrink(),

              // ⭐ SHIMMER TEXT ⭐
              Shimmer.fromColors(
                baseColor: const Color.fromARGB(255, 252, 250, 250),
               highlightColor: const Color.fromARGB(255, 41, 40, 40),
              // highlightColor: Color.fromARGB(255, 148, 168, 146),
                period: const Duration(seconds: 3),
                child: const Text(
                  "BIG BULL",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
