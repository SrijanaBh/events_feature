import 'package:events_feature/screens/featured_screen.dart';
import 'package:flutter/material.dart';
import 'package:marquee/marquee.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Explore Now !",
            style: TextStyle(
              color: Colors.green,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          // Marquee Text
          SizedBox(
            height: 30,
            child: Marquee(
              text:
                  '🔥   Flash Deals on Wines !  *  🎉   Latest Events in the Club !! *  🎊   Book now !  *  🍽️ Table booking now easy !!  *   📩 Book any number of tickets on one QR code  !',
              style: const TextStyle(
                fontSize: 16,
                color: Colors.white70,
                fontWeight: FontWeight.w600,
              ),
              scrollAxis: Axis.horizontal,
              crossAxisAlignment: CrossAxisAlignment.start,
              blankSpace: 60.0,
              velocity: 50.0,
              pauseAfterRound: Duration(seconds: 1),
              startPadding: 10.0,
              accelerationDuration: Duration(seconds: 1),
              accelerationCurve: Curves.linear,
              decelerationDuration: Duration(milliseconds: 500),
              decelerationCurve: Curves.easeOut,
            ),
          ),

          //const SizedBox(height: 250),
          const SizedBox(height: 16),
          // Placeholder for the rest of the home page
          //const Center(
          //child: Text(
          //"Welcome to the Home Page !",
          //style: TextStyle(color: Colors.white, fontSize: 18),
          //),
          //),
          const Expanded(child: FeaturedEvents())
        ],
      ),
    );
  }
}





/*import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        "Welcome to the Home Page!",
        style: TextStyle(color: Colors.white, fontSize: 18),
      ),
    );
  }
}
*/