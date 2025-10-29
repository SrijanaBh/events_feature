import 'dart:convert';
import 'package:events_feature/controllers/looping_appbar_title.dart';
import 'package:events_feature/core/theme/colors.dart';
import 'package:events_feature/screens/events_details_screen.dart';
import 'package:events_feature/utils/date_time_format.dart';
import 'package:events_feature/utils/session_manager.dart'; // ✅ Import SessionManager
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class EventsHomeScreen extends StatefulWidget {
  const EventsHomeScreen({super.key});

  @override
  State<EventsHomeScreen> createState() => _EventsHomeScreenState();
}

class _EventsHomeScreenState extends State<EventsHomeScreen> {
  String? authToken;

  @override
  void initState() {
    super.initState();
    _loadToken();
  }

  /// 🔹 Load token dynamically from SessionManager
  Future<void> _loadToken() async {
    final session = SessionManager();
    await session.loadSession();

    setState(() {
      authToken = session.authToken;
    });

    debugPrint("✅ Loaded Token for Events Page: $authToken");
  }

  /// 🔹 Fetch Events using the stored dynamic token
  Future<List<dynamic>> fetchEventsData() async {
    try {
      if (authToken == null || authToken!.isEmpty) {
        throw Exception("User not logged in or token missing");
      }

      final url = 'api/events/list';
      final response = await http.get(
        Uri.parse('https://white-labels-app-server.vercel.app/api/events/list'),
        headers: {
          "x-auth-token": authToken!, // ✅ Use dynamic token
        },
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return responseData["data"];
      } else {
        throw Exception("Failed to load events (${response.statusCode})");
      }
    } catch (e, s) {
      debugPrint("❌ Error fetching events: $e");
      debugPrintStack(stackTrace: s);
      rethrow;
    }
  }

  String formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return "${date.day}/${date.month}/${date.year}";
    } catch (_) {
      return "";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.black,
        //centerTitle: false,
        //leading: const Padding(padding: EdgeInsets.all(8.0)),
        title: const LoopingTypingAppBarTitle(
          messages: [
            "Happening Events !",
            "Explore More !",
            "Don't Miss Out !"
          ],
          typingSpeed: Duration(microseconds: 25),
        ),
      ),
      body: authToken == null
          ? const Center(
              child: Text(
                "Please log in to view events",
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            )
          : FutureBuilder<List<dynamic>>(
              future: fetchEventsData(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      "Error: ${snapshot.error}",
                      style: const TextStyle(color: Colors.redAccent),
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

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  itemCount: events.length,
                  itemBuilder: (context, index) {
                    final event = events[index];
                    String fromDate = formatDate(event["from_date"] ?? "");
                    String toDate = formatDate(event["to_date"] ?? "");
                    final fromDateC = formatDateTime(fromDate);
                    final toDateC = formatDateTime(toDate);

                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                EventDetailsScreen(eventId: event["id"]),
                          ),
                        );
                      },
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 20),
                        decoration: BoxDecoration(
                          color: Colors.grey[900],
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.green.withOpacity(0.4),
                              blurRadius: 6,
                              spreadRadius: 1,
                              offset: const Offset(2, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // --- Event Image (Top) ---
                            ClipRRect(
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(16),
                              ),
                              child: Image.network(
                                event["img_path"] ?? '',
                                height: 450,
                                width: double.infinity,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    Container(
                                  height: 500,
                                  width: double.infinity,
                                  color: Colors.grey[900],
                                  child: const Icon(
                                    Icons.broken_image,
                                    color: Colors.white,
                                    size: 40,
                                  ),
                                ),
                              ),
                            ),

                            // --- Details Below Image ---
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Event Title
                                  Text(
                                    event["title"] ?? "No Title",
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 8),

                                  // Event Slug
                                  if ((event["slug"] ?? "").isNotEmpty)
                                    Text(
                                      event["slug"],
                                      style: const TextStyle(
                                        color: Colors.white70,
                                        fontSize: 14,
                                      ),
                                    ),
                                  const SizedBox(height: 10),

                                  // Dates Row
                                  if (fromDate.isNotEmpty && toDate.isNotEmpty)
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.calendar_today,
                                          color: Colors.green,
                                          size: 18,
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          "$fromDateC → $toDateC",
                                          style: const TextStyle(
                                            color: Colors.green,
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                ],
                              ),
                            ),
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





/*
import 'dart:convert';
import 'package:events_feature/controllers/looping_appbar_title.dart';
import 'package:events_feature/core/theme/colors.dart';
import 'package:events_feature/screens/events_details_screen.dart';
import 'package:events_feature/utils/date_time_format.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class EventsHomeScreen extends StatelessWidget {
  const EventsHomeScreen({super.key});

  Future<List<dynamic>> fetchEventsData() async {
    try {
      final url = 'https://white-labels-app-server.vercel.app/api/events/list';
      final response = await http.get(
        Uri.parse(url),
        headers: {
          "x-auth-token":
              "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjoxMTAwNywidXNlcl9lbWFpbCI6InJpcHdpbmtsZTVAZ21haWwuY29tIiwidXNlcl9tb2JpbGUiOiI5MTkxNzcyNzIxMzMiLCJ1c2VyX2NsdWJfaWQiOjIyMiwiaWF0IjoxNzYwMzMzMzEzLCJleHAiOjE3NjA5MzgxMTN9.a_bN5P_xKkNYtitRRfnRhBiz5o94CkQfX7OFyYiB9pE",
        },
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return responseData["data"];
      } else {
        throw Exception("Failed to load events");
      }
    } catch (e, s) {
      print(e);
      print(s);
      rethrow;
    }
  }

  String formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return "${date.day}/${date.month}/${date.year}";
    } catch (_) {
      return "";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.black,
        centerTitle: false,
        leading: const Padding(padding: EdgeInsets.all(8.0)),
        title: const LoopingTypingAppBarTitle(
          messages: [
            "Happening Events !",
            "Explore More !",
            "Don't Miss Out !",
          ],
          typingSpeed: Duration(microseconds: 25),
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
                style: const TextStyle(color: Colors.green),
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

          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            itemCount: events.length,
            itemBuilder: (context, index) {
              final event = events[index];
              String fromDate = formatDate(event["from_date"] ?? "");
              String toDate = formatDate(event["to_date"] ?? "");
              final fromDateC = formatDateTime(fromDate);
              final toDateC = formatDateTime(toDate);

              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => EventDetailsScreen(eventId: event["id"]),
                    ),
                  );
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.grey[900],
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.green.withOpacity(0.4),
                        blurRadius: 6,
                        spreadRadius: 1,
                        offset: const Offset(2, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // --- Event Image (Top) ---
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(16),
                        ),
                        child: Image.network(
                          event["img_path"] ?? '',
                          height: 500,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Container(
                                height: 200,
                                color: Colors.grey[700],
                                child: const Icon(
                                  Icons.broken_image,
                                  color: Colors.white,
                                  size: 40,
                                ),
                              ),
                        ),
                      ),

                      // --- Details Below Image ---
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Event Title
                            Text(
                              event["title"] ?? "No Title",
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),

                            // Event Slug
                            if ((event["slug"] ?? "").isNotEmpty)
                              Text(
                                event["slug"],
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14,
                                ),
                              ),
                            const SizedBox(height: 10),

                            // Dates Row
                            if (fromDate.isNotEmpty && toDate.isNotEmpty)
                              Row(
                                children: [
                                  const Icon(
                                    Icons.calendar_today,
                                    color: Colors.green,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    "$fromDateC → $toDateC",
                                    style: const TextStyle(
                                      color: Colors.green,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ),
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

*/

/*
import 'dart:convert';
import 'package:events_feature/controllers/looping_appbar_title.dart';
import 'package:events_feature/core/theme/colors.dart';
import 'package:events_feature/screens/events_details_screen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class EventsHomeScreen extends StatelessWidget {
  const EventsHomeScreen({super.key});

  Future<List<dynamic>> fetchEventsData() async {
    try {
      final url = 'https://white-labels-app-server.vercel.app/api/events/list';
      final response = await http.get(
        Uri.parse(url),
        headers: {
          "x-auth-token":
              "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjoxMTAwNywidXNlcl9lbWFpbCI6InJpcHdpbmtsZTVAZ21haWwuY29tIiwidXNlcl9tb2JpbGUiOiI5MTkxNzcyNzIxMzMiLCJ1c2VyX2NsdWJfaWQiOjIyMiwiaWF0IjoxNzU5NDg3MzEzLCJleHAiOjE3NjAwOTIxMTN9.mdkoAHAk1fXGC0hYlRUBNfTbLflKWNbu1oUEbp5rNZs",
        },
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return responseData["data"];
      } else {
        throw Exception("Failed to load events");
      }
    } catch (e, s) {
      print(e);
      print(s);
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.black,
        centerTitle: false,
        leading: const Padding(padding: EdgeInsets.all(8.0)),
        title: const LoopingTypingAppBarTitle(
          messages: [
            "Happening Events !",
            "Explore More !",
            "Don't Miss Out !",
          ],
          typingSpeed: Duration(microseconds: 25),
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
                style: const TextStyle(color: Colors.green),
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
          return SizedBox(
            height: MediaQuery.of(context).size.height * 0.85,
            child: PageView.builder(
              itemCount: events.length,
              controller: PageController(viewportFraction: 0.95),
              itemBuilder: (context, index) {
                final event = events[index];

                // 🗓️ Format dates (safe parse)
                String formatDate(String dateStr) {
                  try {
                    final date = DateTime.parse(dateStr);
                    return "${date.day}/${date.month}/${date.year}";
                  } catch (_) {
                    return "";
                  }
                }

                final fromDate = formatDate(event["from_date"] ?? "");
                final toDate = formatDate(event["to_date"] ?? "");

                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            EventDetailsScreen(eventId: event["id"]),
                      ),
                    );
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.green.withOpacity(0.5),
                          blurRadius: 10,
                          spreadRadius: 3,
                          offset: const Offset(5, 6),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Stack(
                        children: [
                          // --- Event Image ---
                          Image.network(
                            event["img_path"] ?? '',
                            height: 620,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                Container(
                                  height: 400,
                                  color: Colors.grey[700],
                                  child: const Icon(
                                    Icons.broken_image,
                                    color: Colors.white,
                                    size: 40,
                                  ),
                                ),
                          ),

                          // 🗓️ --- Date Badge (Top Left) ---
                          if (fromDate.isNotEmpty && toDate.isNotEmpty)
                            Positioned(
                              top: 16,
                              left: 16,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.6),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.calendar_today,
                                      color: Colors.white,
                                      size: 16,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      "$fromDate → $toDate",
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                          // --- Title and Venue (Bottom) ---
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
              },
            ),
          );
        },
      ),
    );
  }
}

*/

/*
import 'dart:convert';
//import 'package:events_feature/controllers/typing_logic.dart';
import 'package:events_feature/controllers/looping_appbar_title.dart';
import 'package:events_feature/core/theme/colors.dart';
//import 'package:events_feature/screens/edit_profile_page.dart';
import 'package:events_feature/screens/events_details_screen.dart';
//import 'package:events_feature/screens/settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class EventsHomeScreen extends StatelessWidget {
  const EventsHomeScreen({super.key});

  Future<List<dynamic>> fetchEventsData() async {
    try {
      final url = 'https://white-labels-app-server.vercel.app/api/events/list';
      final response = await http.get(
        Uri.parse(url),
        headers: {
          "x-auth-token":
              "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjoxMTAwNywidXNlcl9lbWFpbCI6InJpcHdpbmtsZTVAZ21haWwuY29tIiwidXNlcl9tb2JpbGUiOiI5MTkxNzcyNzIxMzMiLCJ1c2VyX2NsdWJfaWQiOjIyMiwiaWF0IjoxNzU5NDg3MzEzLCJleHAiOjE3NjAwOTIxMTN9.mdkoAHAk1fXGC0hYlRUBNfTbLflKWNbu1oUEbp5rNZs",
        },
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return responseData["data"]; // This is the  event
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
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.grey[900],
        leading: Padding(padding: const EdgeInsets.all(8.0)),
        title: const LoopingTypingAppBarTitle(
          messages: [
            "Happening Events !",
            "Explore More !",
            "Don't Miss Out !",
          ],
          typingSpeed: Duration(microseconds: 5),
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
                style: const TextStyle(color: Colors.green),
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
          return SizedBox(
            height: MediaQuery.of(context).size.height * 0.85,
            child: PageView.builder(
              itemCount: events.length,
              controller: PageController(
                viewportFraction: 0.95,
              ), // Adjust for slight margin
              itemBuilder: (context, index) {
                final event = events[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            EventDetailsScreen(eventId: event["id"]),
                      ),
                    );
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.green.withOpacity(0.5),
                          blurRadius: 10,
                          spreadRadius: 3,
                          offset: const Offset(5, 6),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Stack(
                        children: [
                          Image.network(
                            event["img_path"] ?? '',
                            height: 620,
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
              },
            ),
          );
        },
      ),
    );
  }
}
*/