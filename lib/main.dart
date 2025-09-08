import 'package:events_feature/screens/events_home_screen.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Events demo project',
      debugShowCheckedModeBanner: false,
      home: EventsHomeScreen(),
    );
  }
}
