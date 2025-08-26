import 'package:events_feature/screens/events_details_screen.dart';
import 'package:flutter/material.dart';

class EventsHomeScreen extends StatelessWidget {
  const EventsHomeScreen({super.key});

  final List<Map<String, String>> events = const [
    {
      'image': 'assets/al-elmes-ULHxWq8reao-unsplash.jpg',
      'date': 'Aug 30, 2025',
      'time': '7:00 PM',
      'title': 'Live Music Festival',
    },
    {
      'image': 'assets/pablo-heimplatz-ZODcBkEohk8-unsplash.jpg',
      'date': 'Sep 5, 2025',
      'time': '6:00 PM',
      'title': 'Food & Wine Expo',
    },
    {
      'image': 'assets/priscilla-du-preez-W3SEyZODn8U-unsplash.jpg',
      'date': 'Sep 12, 2025',
      'time': '5:30 PM',
      'title': 'Tech Conference 2025',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Happening Events!',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color.fromARGB(255, 240, 5, 5),
      ),
      body: ListView.builder(
        itemCount: events.length,
        itemBuilder: (context, index) {
          final event = events[index];

          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => EventDetailsScreen(event: event),
                ),
              );
            },
            child: Card(
              margin: const EdgeInsets.all(12),
              child: Stack(
                children: [
                  Image.asset(
                    event['image']!,
                    fit: BoxFit.cover,
                    height: 200,
                    width: double.infinity,
                  ),
                  Container(
                    height: 200,
                    padding: const EdgeInsets.all(16),
                    alignment: Alignment.bottomLeft,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.7),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          event['title']!,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${event['date']} | ${event['time']}',
                          style: const TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
