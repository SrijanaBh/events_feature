import 'dart:convert';
import 'package:events_feature/screens/events_details_screen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class EventsHomeScreen extends StatelessWidget {
  const EventsHomeScreen({super.key});

  Future<List<dynamic>> fetchEventsData() async {
    print("------22222222222222222-----------");

    try {
      final url =
          'https://white-labels-app-server.vercel.app/api/events/list?club_id=222';
      final response = await http.get(
        Uri.parse(url),
        headers: {
          "x-auth-token":
              "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjoxMDk2MywidXNlcl9lbWFpbCI6InJhbXlhQGNsdWJyLmluIiwidXNlcl9tb2JpbGUiOiI5MTk1NTMxMzAyNjEiLCJ1c2VyX2NsdWJfaWQiOjIyMiwiaWF0IjoxNzU3MTQwMjM4LCJleHAiOjE3NTc3NDUwMzh9.Jy45T-nOpV8jUhGLL_MPz3Zxw-vjb-kpFx89SmzWjTM",
        },
      );
      print("-----------------");
      print(response.statusCode);

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return responseData["data"]; // This is the list of events
      } else {
        throw Exception("Failed to load events");
      }
    } catch (e, s) {
      print(e);
      print(s);
      rethrow;
      // TODO
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.grey[900],
        title: const Text(
          "Happening Events!",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      body: FutureBuilder<List<dynamic>>(
        future: fetchEventsData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Text(
                "Error: ${snapshot.error}",
                style: const TextStyle(color: Colors.red),
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                "No events available",
                style: TextStyle(color: Colors.white),
              ),
            );
          }

          final events = snapshot.data!;
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: events.map((event) {
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => EventDetailsScreen(event: event),
                        ),
                      );
                    },
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.9,
                      height: MediaQuery.of(context).size.height * 0.8,
                      margin: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.shade300,
                            blurRadius: 10,
                            spreadRadius: 2,
                            offset: const Offset(4, 4),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Stack(
                          children: [
                            // Background Image
                            Image.network(
                              event["img_path"] ?? '',
                              height: 400,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  Container(
                                    height: 400,
                                    width: double.infinity,
                                    color: Colors.grey[700],
                                    child: const Icon(
                                      Icons.broken_image,
                                      color: Colors.white,
                                      size: 40,
                                    ),
                                  ),
                            ),
                            // Gradient Overlay
                            Positioned(
                              bottom: 0,
                              left: 0,
                              right: 0,
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Colors.transparent,
                                      Colors.black.withOpacity(0.7),
                                    ],
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      event["title"] ?? "No Title",
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      event["slug"] ?? "",
                                      style: const TextStyle(
                                        color: Colors.white70,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          );
        },
      ),
    );
  }
}

/*return ListView.builder(
            itemCount: events.length,
            itemBuilder: (context, index) {
              final event = events[index];

              return GestureDetector(
                onTap: () {
                  // ✅ This passes the correct event from API to EventDetailsScreen
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => EventDetailsScreen(event: event),
                    ),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Event Image
                      if (event["img_path"] != null)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            event["img_path"],
                            height: 200,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Container(
                              height: 200,
                              color: Colors.grey,
                              child: const Icon(Icons.broken_image),
                            ),
                          ),
                        ),
                      const SizedBox(height: 8),

                      // Event Title
                      Text(
                        event["title"] ?? "No Title",
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                      ),

                      // Event Slug
                      Text(
                        event["slug"] ?? "",
                        style: const TextStyle(color: Colors.grey),
                      ),

                      const Divider(color: Colors.grey),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}







/*import 'dart:convert';
import 'package:events_feature/screens/events_details_screen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class EventsHomeScreen extends StatelessWidget {
  const EventsHomeScreen({super.key});

  Future<List<dynamic>> fetchEventsData() async {
    final url =
        'https://white-labels-app-server.vercel.app/api/events/list?club_id=222';
    final response = await http.get(
      Uri.parse(url),
      headers: {
        "x-auth-token":
            "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpYXQiOjE2ODE1NDUxNjN9.D4TE2NW6u8IiLAIDDdONehwppGeeVGy-ZUn6pVngR-s",
      },
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      final events = responseData["data"];
      print(events);

      return events;
    } else {
      throw response.body;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 10, 7, 7),
        title: Text(
          "Happening Events!",
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () async {
              await fetchEventsData();
            },
            icon: Icon(Icons.refresh),
          ),
        ],
      ),
      body: FutureBuilder(
        future: fetchEventsData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            ); // loading state
          } else if (snapshot.hasError) {
            return Center(child:Text("Error: ${snapshot.error}"));
          } else if (snapshot.hasData ||snapshot.data!.isEmpty) {
            final events = snapshot.data!;
            return ListView.builder(
              itemCount: events.length,
              itemBuilder: (context, index) {
                final event = events[index];
                print(event["title"]!);
                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12.0,
                    vertical: 8.0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => EventDetailsScreen(event: event),
                            ),
                          );
                        },
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            event["img_path"] ?? '',
                            width: MediaQuery.of(context).size.width,
                            height: 200,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                Container(
                                  height: 200,
                                  width: double.infinity,
                                  color: Colors.grey[300],
                                  child: const Icon(
                                    Icons.broken_image,
                                    size: 40,
                                  ),
                                ),
                          ),
                        ),
                      ),

                      // Adaptive image
                      /*ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          event["img_path"] ?? '',
                          width: MediaQuery.of(context).size.width,

                          height: 200,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Container(
                                height: 200,
                                width: double.infinity,
                                color: Colors.grey[300],
                                child: const Icon(Icons.broken_image, size: 40),
                              ),
                        ),
                      ),*/
                      const SizedBox(height: 8),
                      // Title
                      Text(
                        event["title"] ?? 'No Title',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      // Slug or subtitle
                      Text(
                        event["slug"] ?? '',
                        style: const TextStyle(color: Colors.grey),
                      ),
                      const Divider(height: 24),
                    ],
                  ),
                );
              },
            );

            /*return ListView.builder(
              itemCount: events.length,
              itemBuilder: (context, index) {
                final event = events[index];
                return ListTile(
                  leading: Image.network(event["img_path"], width: 180),
                  title: Text(event["title"]),
                  subtitle: Text(event["slug"]),
                );
              },
            );

            ListTile(
                  leading: Image.network(event["img_path"], width: 150),
                  title: Text(event["title"]),
                  subtitle: Text(event["slug"]),
                );*/
          } else {
            return Text("No data");
          }
        },
      ),
    );
  }
}
*/





/*
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
*/
*/
