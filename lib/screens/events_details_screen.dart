import 'dart:convert';
import 'package:events_feature/models/event_models.dart';
import 'package:events_feature/utils/session_manager.dart'; // ✅ Import SessionManager
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'tickets_selection_screen.dart';
import 'package:flutter_html/flutter_html.dart';

class EventDetailsScreen extends StatefulWidget {
  final int eventId;

  const EventDetailsScreen({super.key, required this.eventId});

  @override
  State<EventDetailsScreen> createState() => _EventDetailsScreenState();
}

class _EventDetailsScreenState extends State<EventDetailsScreen> {
  EventModel? _event;
  bool _isLoading = true;
  String? authToken;

  @override
  void initState() {
    super.initState();
    _loadTokenAndFetchEvent();
  }

  /// 🔹 Load token first, then fetch event details
  Future<void> _loadTokenAndFetchEvent() async {
    final session = SessionManager();
    await session.loadSession();

    setState(() {
      authToken = session.authToken;
    });

    debugPrint("🔑 Loaded Token for EventDetails: $authToken");

    if (authToken == null || authToken!.isEmpty) {
      setState(() => _isLoading = false);
      return;
    }

    await fetchEventDetails();
  }

  /// 🔹 Fetch Event Details Dynamically
  Future<void> fetchEventDetails() async {
    try {
      final url =
          "https://white-labels-app-server.vercel.app/api/events/getEventById?event_id=${widget.eventId}";
      final response = await http.get(
        Uri.parse(url),
        headers: {"x-auth-token": authToken!},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body)["data"];
        setState(() {
          _event = EventModel.fromJson(data);
          _isLoading = false;
        });
      } else {
        throw Exception(
          "Failed to load event details (${response.statusCode})",
        );
      }
    } catch (e) {
      debugPrint("❌ Error fetching event: $e");
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator(color: Colors.green)),
      );
    }

    if (authToken == null || authToken!.isEmpty) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Text(
            "Please log in to view event details.",
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
        ),
      );
    }

    if (_event == null) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Text(
            "Failed to load event details.",
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
    }

    final event = _event!;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(event.title),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Image Section ---
            Container(
              margin: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.green.withOpacity(0.5),
                    blurRadius: 10,
                    spreadRadius: 2,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.network(
                  event.imgPath,
                  width: double.infinity,
                  height: 350,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    height: 350,
                    color: Colors.grey[800],
                    child: const Icon(
                      Icons.broken_image,
                      color: Colors.white,
                      size: 50,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 10),

            // --- Slug ---
            if (event.slug.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  event.slug,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),

            const SizedBox(height: 16),

            // --- Dates ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  const Icon(
                    Icons.calendar_today,
                    color: Colors.green,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    "${event.fromDate.toLocal().toString().split(' ')[0]} → ${event.toDate.toLocal().toString().split(' ')[0]}",
                    style: const TextStyle(
                      color: Colors.green,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // --- Time ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  const Icon(Icons.access_time, color: Colors.green, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    "${event.startTime} - ${event.endTime}",
                    style: const TextStyle(
                      color: Colors.green,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // --- Venue ---
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                "VENUE:",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            ),
            if (event.venue.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.location_on,
                      color: Colors.green,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        event.venue,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 20),

            // --- Description ---
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                "DESCRIPTION:",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            ),
            if (event.description.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Html(
                  data: event.description,
                  style: {
                    "body": Style(
                      color: Colors.white70,
                      fontSize: FontSize(15),
                      lineHeight: LineHeight(1.4),
                      textAlign: TextAlign.justify,
                      fontFamily: 'Roboto',
                    ),
                  },
                ),
              ),

            const SizedBox(height: 20),

            // --- Artists ---
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                "ARTISTS:",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            ),
            ListTile(
              title: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  _artistButton("Artist 1"),
                  const SizedBox(width: 20),
                  _artistButton("Artist 2"),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // --- Images ---
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                "IMAGES:",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            ),
            const SizedBox(height: 12),
            _buildImageRow(context),

            const SizedBox(height: 30),

            // --- Book Now Button ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.black,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(20),
                      ),
                    ),
                    builder: (context) => SizedBox(
                      height: MediaQuery.of(context).size.height * 0.8,
                      child: TicketSelectionScreen(event: event),
                    ),
                  );
                },
                child: const Text(
                  "Book Now",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 🔹 Small reusable widgets

  Widget _artistButton(String name) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        //backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        shadowColor: Colors.transparent,
        side: const BorderSide(color: Colors.white70),
      ),
      onPressed: () {},
      child: Text(name),
    );
  }

  Widget _buildImageRow(BuildContext context) {
    final images = [
      'assets/priscilla-du-preez-W3SEyZODn8U-unsplash.jpg',
      'assets/pablo-heimplatz-ZODcBkEohk8-unsplash.jpg',
      'assets/al-elmes-ULHxWq8reao-unsplash.jpg',
    ];

    final imageWidth = (MediaQuery.of(context).size.width - 64) / 3;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: images
            .map(
              (path) => ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset(
                  path,
                  width: imageWidth,
                  height: 100,
                  fit: BoxFit.cover,
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}

/*
import 'dart:convert';
import 'package:events_feature/models/event_models.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'tickets_selection_screen.dart';
import 'package:flutter_html/flutter_html.dart';

class EventDetailsScreen extends StatefulWidget {
  final int eventId;

  const EventDetailsScreen({super.key, required this.eventId});

  @override
  State<EventDetailsScreen> createState() => _EventDetailsScreenState();
}

class _EventDetailsScreenState extends State<EventDetailsScreen> {
  EventModel? _event;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchEventDetails();
  }

  Future<void> fetchEventDetails() async {
    try {
      final url =
          "https://white-labels-app-server.vercel.app/api/events/getEventById?event_id=${widget.eventId}";
      final response = await http.get(
        Uri.parse(url),
        headers: {
          "x-auth-token":
              "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjoxMTAwNywidXNlcl9lbWFpbCI6InJpcHdpbmtsZTVAZ21haWwuY29tIiwidXNlcl9tb2JpbGUiOiI5MTkxNzcyNzIxMzMiLCJ1c2VyX2NsdWJfaWQiOjIyMiwiaWF0IjoxNzYwMzMzMzEzLCJleHAiOjE3NjA5MzgxMTN9.a_bN5P_xKkNYtitRRfnRhBiz5o94CkQfX7OFyYiB9pE",
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body)["data"];
        setState(() {
          _event = EventModel.fromJson(data);
          _isLoading = false;
        });
      } else {
        throw Exception("Failed to load event details");
      }
    } catch (e) {
      debugPrint("Error fetching event: $e");
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_event == null) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Text(
            "Failed to load event",
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
    }

    final event = _event!;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(event.title),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            Container(
              margin: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.green.withOpacity(0.5),
                    blurRadius: 10,
                    spreadRadius: 2,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.network(
                  event.imgPath,
                  width: double.infinity,
                  height: 350,
                  fit: BoxFit.cover,
                ),
              ),
            ),

            const SizedBox(height: 10),

            // Slug
            if (event.slug.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  event.slug,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),

            const SizedBox(height: 16),

            // Dates
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  const Icon(
                    Icons.calendar_today,
                    color: Colors.green,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    "${event.fromDate.toLocal().toString().split(' ')[0]} → ${event.toDate.toLocal().toString().split(' ')[0]}",
                    style: const TextStyle(
                      color: Colors.green,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // Time
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  const Icon(Icons.access_time, color: Colors.green, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    "${event.startTime} - ${event.endTime}",
                    style: const TextStyle(
                      color: Colors.green,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),
            Text(
              "   VENUE :",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            const SizedBox(width: 8),

            // Venue
            if (event.venue.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.location_on,
                      color: Colors.green,
                      size: 20,
                    ),
                    const SizedBox(width: 8),

                    Expanded(
                      child: Text(
                        event.venue,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 16),
            Text(
              "   DESCRIPTION :",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            const SizedBox(width: 8),

            if (event.description.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Html(
                  data: event.description,
                  style: {
                    "body": Style(
                      color: Colors.white70,
                      fontSize: FontSize(15),
                      lineHeight: LineHeight(1.4),
                      textAlign: TextAlign.justify,
                      fontFamily: 'Roboto',
                    ),
                    "p": Style(margin: Margins.only(bottom: 8)),
                  },
                ),
              ),

            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                "ARTISTS",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ListTile(
              title: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green, // transparent background
                      foregroundColor: Colors.white, // text color
                      shadowColor: Colors.transparent, // remove shadow
                      side: const BorderSide(
                        color: Colors.grey,
                      ), // optional border
                    ),
                    onPressed: () {
                      // TODO: handle button press
                    },
                    child: const Text("Artist 1"),
                  ),
                  const SizedBox(width: 30),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      shadowColor: Colors.transparent,
                      side: const BorderSide(color: Colors.grey),
                    ),
                    onPressed: () {
                      // TODO: handle button press
                    },
                    child: const Text("Artist 2"),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                "IMAGES",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // First image
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.asset(
                      'assets/priscilla-du-preez-W3SEyZODn8U-unsplash.jpg',
                      width:
                          (MediaQuery.of(context).size.width - 64) /
                          3, // divide space equally
                      height: 100,
                      fit: BoxFit.cover,
                    ),
                  ),
                  // Second image
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.asset(
                      'assets/pablo-heimplatz-ZODcBkEohk8-unsplash.jpg',
                      width: (MediaQuery.of(context).size.width - 64) / 3,
                      height: 100,
                      fit: BoxFit.cover,
                    ),
                  ),
                  // Third image
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.asset(
                      'assets/al-elmes-ULHxWq8reao-unsplash.jpg',
                      width: (MediaQuery.of(context).size.width - 64) / 3,
                      height: 100,
                      fit: BoxFit.cover,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // Book Now Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.black,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(20),
                      ),
                    ),
                    builder: (context) {
                      return SizedBox(
                        height: MediaQuery.of(context).size.height * 0.8,
                        child: TicketSelectionScreen(event: event),
                      );
                    },
                  );
                },
                child: const Text(
                  "Book Now",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

*/

/*
import 'dart:convert';
import 'package:events_feature/utils/date_time_format.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:events_feature/models/event_models.dart';
import 'tickets_selection_screen.dart';

class EventDetailsScreen extends StatefulWidget {
  final int eventId; // <-- accept eventId instead of full EventModel

  const EventDetailsScreen({super.key, required this.eventId});

  @override
  State<EventDetailsScreen> createState() => _EventDetailsScreenState();
}

class _EventDetailsScreenState extends State<EventDetailsScreen> {
  EventModel? _event;
  bool _isLoading = true;
  bool _bookNow = false;

  @override
  void initState() {
    super.initState();
    fetchEventDetails();
  }

  Future<void> fetchEventDetails() async {
    try {
      final url =
          "https://white-labels-app-server.vercel.app/api/events/getEventById?event_id=${widget.eventId}";
      final response = await http.get(
        Uri.parse(url),
        headers: {
          "x-auth-token":
              "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjoxMTAwNywidXNlcl9lbWFpbCI6InJpcHdpbmtsZTVAZ21haWwuY29tIiwidXNlcl9tb2JpbGUiOiI5MTkxNzcyNzIxMzMiLCJ1c2VyX2NsdWJfaWQiOjIyMiwiaWF0IjoxNzU5NDg3MzEzLCJleHAiOjE3NjAwOTIxMTN9.mdkoAHAk1fXGC0hYlRUBNfTbLflKWNbu1oUEbp5rNZs",
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body)["data"];
        setState(() {
          _event = EventModel.fromJson(data);
          _isLoading = false;
        });
      } else {
        throw Exception("Failed to load event details");
      }
    } catch (e) {
      debugPrint("Error fetching event: $e");
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_event == null) {
      return const Scaffold(body: Center(child: Text("Failed to load event")));
    }

    final event = _event!;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(event.title),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20), // curved border
                boxShadow: [
                  BoxShadow(
                    color: Colors.green.withOpacity(0.5), // green shadow
                    blurRadius: 10,
                    spreadRadius: 2,
                    offset: const Offset(0, 5), // shadow position
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(
                  20,
                ), // match same border radius
                child: Image.network(
                  event.imgPath,
                  width: double.infinity,
                  height: 350,
                  fit: BoxFit.cover,
                ),
              ),
            ),

            const SizedBox(height: 16),

            // From - To Date
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                " ${event.fromDate.toLocal().toString().split(' ')[0]} "
                " ${event.toDate.toLocal().toString().split(' ')[0]}",
                style: const TextStyle(
                  color: Colors.green,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Time
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                " ${event.startTime} - ${event.endTime}",
                style: const TextStyle(
                  color: Colors.green,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                "ARTISTS",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            //const SizedBox(height: 20),
            ListTile(
              title: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green, // transparent background
                      foregroundColor: Colors.white, // text color
                      shadowColor: Colors.transparent, // remove shadow
                      side: const BorderSide(
                        color: Colors.grey,
                      ), // optional border
                    ),
                    onPressed: () {
                      // TODO: handle button press
                    },
                    child: const Text("Artist 1"),
                  ),
                  const SizedBox(width: 30),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      shadowColor: Colors.transparent,
                      side: const BorderSide(color: Colors.grey),
                    ),
                    onPressed: () {
                      // TODO: handle button press
                    },
                    child: const Text("Artist 2"),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                "IMAGES",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // First image
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.asset(
                      'assets/priscilla-du-preez-W3SEyZODn8U-unsplash.jpg',
                      width:
                          (MediaQuery.of(context).size.width - 64) /
                          3, // divide space equally
                      height: 100,
                      fit: BoxFit.cover,
                    ),
                  ),
                  // Second image
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.asset(
                      'assets/pablo-heimplatz-ZODcBkEohk8-unsplash.jpg',
                      width: (MediaQuery.of(context).size.width - 64) / 3,
                      height: 100,
                      fit: BoxFit.cover,
                    ),
                  ),
                  // Third image
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.asset(
                      'assets/al-elmes-ULHxWq8reao-unsplash.jpg',
                      width: (MediaQuery.of(context).size.width - 64) / 3,
                      height: 100,
                      fit: BoxFit.cover,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green, // button background color
                  foregroundColor: Colors.white, // text color
                  minimumSize: const Size(
                    double.infinity,
                    50,
                  ), // full width button
                ),
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true, // full screen height if needed
                    backgroundColor:
                        Colors.black, // matches scaffold background
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(20),
                      ),
                    ),
                    builder: (context) {
                      return SizedBox(
                        height:
                            MediaQuery.of(context).size.height *
                            0.8, // 80% of screen
                        child: TicketSelectionScreen(
                          event: event,
                        ), // your ticket selection screen
                      );
                    },
                  );
                },
                child: const Text(
                  "Book Now",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
*/






/*
import 'dart:convert';
import 'package:events_feature/utils/date_time_format.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_html/flutter_html.dart';
import 'package:events_feature/models/event_models.dart';
import 'package:events_feature/models/get_tickets_price_events.dart';
import 'package:events_feature/utils/session_manager.dart';
import 'tickets_selection_screen.dart';

class EventDetailsScreen extends StatefulWidget {
  final int eventId;

  const EventDetailsScreen({
    super.key,
    required this.eventId,
  });

  @override
  State<EventDetailsScreen> createState() => _EventDetailsScreenState();
}

class _EventDetailsScreenState extends State<EventDetailsScreen> {
  EventModel? _event;
  Map<String, dynamic>? _layout;

  List<GetEventTicketDetails> _tickets = [];
  bool _ticketsLoading = true;

  bool _isLoading = true;
  bool _layoutLoading = true;

  String? authToken;

  @override
  void initState() {
    super.initState();
    _loadToken();
  }

  /// Load Auth Token
  Future<void> _loadToken() async {
    final session = SessionManager();
    await session.loadSession();

    setState(() {
      authToken = session.authToken;
    });

    await fetchEventDetails();
    await fetchLayout();
    await fetchTickets();
  }

  /// Fetch Event Details
  Future<void> fetchEventDetails() async {
    if (authToken == null) return;

    try {
      final url =
          "https://white-labels-app-server.vercel.app/api/events/getEventById?event_id=${widget.eventId}";

      final response = await http.get(
        Uri.parse(url),
        headers: {
          "x-auth-token": authToken!,
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body)["data"];
        setState(() => _event = EventModel.fromJson(data));
      } else {
        throw Exception("Failed to load event details");
      }
    } catch (e) {
      debugPrint("Error fetching event: $e");
    }

    setState(() => _isLoading = false);
  }

  /// Fetch Layout
  Future<void> fetchLayout() async {
    try {
      final url =
          "https://white-labels-app-server.vercel.app/api/seatlayout/getSeatLayoutByEvent?event_id=${widget.eventId}";

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body)["result"];

        if (result is List && result.isNotEmpty) {
          setState(() => _layout = result[0]);
        }
      }
    } catch (e) {
      debugPrint("Layout fetch error: $e");
    }

    setState(() => _layoutLoading = false);
  }

  /// Fetch Event Ticket Types
  /*Future<void> fetchTickets() async {
    try {
      final url =
          "https://white-labels-app-server.vercel.app/api/events/getEventById?event_id=${widget.eventId}";

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body)["data"];

        setState(() {
          _tickets = (data as List)
              .map((e) => GetEventTicketDetails.fromJson(e))
              .toList();
        });
      }
    } catch (e) {
      debugPrint("Error fetching tickets: $e");
    }

    setState(() => _ticketsLoading = false);
  }*/
  Future<void> fetchTickets() async {
    try {
      final url =
          "https://white-labels-app-server.vercel.app/api/events/getEventById?event_id=${widget.eventId}";

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);

        final ticketsJson = body["data"]["tickets"] ?? [];

        setState(() {
          _tickets = (ticketsJson as List)
              .map((e) => GetEventTicketDetails.fromJson(e))
              .toList();
        });
      }
    } catch (e) {
      debugPrint("Error fetching tickets: $e");
    }

    setState(() => _ticketsLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_event == null) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Text("Failed to load event",
              style: TextStyle(color: Colors.white)),
        ),
      );
    }

    final event = _event!;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(event.title),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// IMAGE
            Container(
              margin: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.green.withOpacity(0.5),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.network(
                  event.imgPath,
                  width: double.infinity,
                  height: 350,
                  fit: BoxFit.cover,
                ),
              ),
            ),

            /// SLUG
            if (event.slug.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  event.slug,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),

            const SizedBox(height: 20),

            /// DATE
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  const Icon(Icons.calendar_today, color: Colors.green),
                  const SizedBox(width: 8),
                  Text(
                    "${formatDateTime((event.fromDate).toString())} → ${formatDateTime((event.toDate).toString())}",
                    style: const TextStyle(
                        color: Colors.green,
                        fontSize: 17,
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            /// TIME
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  const Icon(Icons.access_time, color: Colors.green),
                  const SizedBox(width: 8),
                  Text(
                    "${formatDateTime((event.startTime).toString())} - ${formatDateTime((event.endTime).toString())}",
                    style: const TextStyle(
                        color: Colors.green,
                        fontSize: 17,
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            /// VENUE TITLE
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text("VENUE:",
                  style: TextStyle(color: Colors.white, fontSize: 20)),
            ),

            const SizedBox(height: 12),

            /// VENUE
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  const Icon(Icons.location_on, color: Colors.green),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      event.venue,
                      style: const TextStyle(
                          color: Colors.green,
                          fontSize: 17,
                          fontWeight: FontWeight.bold),
                    ),
                  )
                ],
              ),
            ),

            const SizedBox(height: 20),

            /// DESCRIPTION TITLE
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text("DESCRIPTION :",
                  style: TextStyle(color: Colors.white, fontSize: 20)),
            ),

            /// DESCRIPTION
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Html(
                data: event.description,
                style: {
                  "body": Style(
                    color: Colors.white70,
                    fontSize: FontSize(15),
                  ),
                },
              ),
            ),

            //const SizedBox(height: 25),
            Text("    ARTISTS :",
                style: TextStyle(color: Colors.white, fontSize: 20)),
            ListTile(
              title: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          Colors.transparent, // transparent background
                      foregroundColor: Colors.white, // text color
                      shadowColor: Colors.transparent, // remove shadow
                      side: const BorderSide(
                        color: Colors.grey,
                      ), // optional border
                    ),
                    onPressed: () {
                      // TODO: handle button press
                    },
                    child: const Text("Artist 1"),
                  ),
                  const SizedBox(width: 30),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      foregroundColor: Colors.white,
                      shadowColor: Colors.transparent,
                      side: const BorderSide(color: Colors.grey),
                    ),
                    onPressed: () {
                      // TODO: handle button press
                    },
                    child: const Text("Artist 2"),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Text("    IMAGES :",
                style: TextStyle(color: Colors.white, fontSize: 20)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // First image
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.asset(
                      'assets/priscilla-du-preez-W3SEyZODn8U-unsplash.jpg',
                      width: (MediaQuery.of(context).size.width - 64) /
                          3, // divide space equally
                      height: 100,
                      fit: BoxFit.cover,
                    ),
                  ),
                  // Second image
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.asset(
                      'assets/pablo-heimplatz-ZODcBkEohk8-unsplash.jpg',
                      width: (MediaQuery.of(context).size.width - 64) / 3,
                      height: 100,
                      fit: BoxFit.cover,
                    ),
                  ),
                  // Third image
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.asset(
                      'assets/al-elmes-ULHxWq8reao-unsplash.jpg',
                      width: (MediaQuery.of(context).size.width - 64) / 3,
                      height: 100,
                      fit: BoxFit.cover,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            /// BOOK NOW BUTTON
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  if (_ticketsLoading) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Loading tickets...")),
                    );
                    return;
                  }

                  if (_tickets.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("No tickets available")),
                    );
                    return;
                  }

                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.black,
                    shape: const RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(20)),
                    ),
                    builder: (context) {
                      return SizedBox(
                        height: MediaQuery.of(context).size.height * 0.85,
                        child: TicketSelectionScreen(
                          event: event,
                          tickets: _tickets,
                        ),
                      );
                    },
                  );
                },
                child: const Text(
                  "Book Now",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
*/
/*
import 'dart:convert';
import 'package:events_feature/models/event_models.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'tickets_selection_screen.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:events_feature/utils/session_manager.dart';

class EventDetailsScreen extends StatefulWidget {
  final int eventId;

  const EventDetailsScreen({
    super.key,
    required this.eventId,
  });

  @override
  State<EventDetailsScreen> createState() => _EventDetailsScreenState();
}

class _EventDetailsScreenState extends State<EventDetailsScreen> {
  EventModel? _event;
  Map<String, dynamic>? _layout;

  bool _isLoading = true;
  bool _layoutLoading = true;

  String? authToken;

  @override
  void initState() {
    super.initState();
    _loadToken();
  }

  Future<void> _loadToken() async {
    final session = SessionManager();
    await session.loadSession();

    setState(() {
      authToken = session.authToken;
    });

    await fetchEventDetails();
    await fetchLayout();
  }

  /// Fetch Event Details
  Future<void> fetchEventDetails() async {
    if (authToken == null) return;

    try {
      final url =
          "https://white-labels-app-server.vercel.app/api/events/getEventById?event_id=${widget.eventId}";

      final response = await http.get(
        Uri.parse(url),
        headers: {
          "x-auth-token": authToken!,
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body)["data"];
        setState(() {
          _event = EventModel.fromJson(data);
        });

        fetchLayout();
      } else {
        throw Exception("Failed to load event details");
      }
    } catch (e) {
      debugPrint("Error fetching event: $e");
    }

    setState(() => _isLoading = false);
  }

  /// Fetch Layout
  Future<void> fetchLayout() async {
    try {
      final url =
          "https://white-labels-app-server.vercel.app/api/seatlayout/getSeatLayoutByEvent?event_id=${widget.eventId}";

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body)["result"];

        if (result is List && result.isNotEmpty) {
          setState(() {
            _layout = result[0];
          });
        }
      }
    } catch (e) {
      debugPrint("Layout fetch error: $e");
    }

    setState(() => _layoutLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_event == null) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Text(
            "Failed to load event",
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
    }

    final event = _event!;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(event.title),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// IMAGE
            Container(
              margin: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.green.withOpacity(0.5),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.network(
                  event.imgPath,
                  width: double.infinity,
                  height: 350,
                  fit: BoxFit.cover,
                ),
              ),
            ),

            /// SLUG
            if (event.slug.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  event.slug,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),

            const SizedBox(height: 20),

            /// DATE
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  const Icon(Icons.calendar_today, color: Colors.green),
                  const SizedBox(width: 8),
                  Text(
                    "${event.fromDate.toString().split(' ')[0]} → ${event.toDate.toString().split(' ')[0]}",
                    style: const TextStyle(
                        color: Colors.green,
                        fontSize: 17,
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            /// TIME
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  const Icon(Icons.access_time, color: Colors.green),
                  const SizedBox(width: 8),
                  Text(
                    "${event.startTime} - ${event.endTime}",
                    style: const TextStyle(
                        color: Colors.green,
                        fontSize: 17,
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            /// VENUE TITLE
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                "VENUE:",
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
            ),

            const SizedBox(height: 12),

            /// VENUE ROW FIXED
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  const Icon(Icons.location_on, color: Colors.green),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      event.venue,
                      style: const TextStyle(
                          color: Colors.green,
                          fontSize: 17,
                          fontWeight: FontWeight.bold),
                    ),
                  )
                ],
              ),
            ),

            const SizedBox(height: 20),

            /// DESCRIPTION TITLE
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                "DESCRIPTION:",
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
            ),

            /// DESCRIPTION
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Html(
                data: event.description,
                style: {
                  "body": Style(
                    color: Colors.white70,
                    fontSize: FontSize(15),
                  ),
                },
              ),
            ),

            const SizedBox(height: 25),

            /// BOOK NOW BUTTON
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  if (_layoutLoading) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Loading layout...")),
                    );
                    return;
                  }

                  if (_layout == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("No layout available for this event"),
                      ),
                    );
                    return;
                  }

                  final layoutId = _layout!["id"]; // ✔ FIXED

                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.black,
                    shape: const RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(20)),
                    ),
                    builder: (context) {
                      return SizedBox(
                        height: MediaQuery.of(context).size.height * 0.8,
                        child: TicketSelectionScreen(
                          event: event,
                          tickets: _tickets,
                          //layoutID: layoutId, // ✔ FIXED PASSING
                        ),
                      );
                    },
                  );
                },
                child: const Text(
                  "Book Now",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
*/
/*
import 'dart:convert';
import 'package:events_feature/models/event_models.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'tickets_selection_screen.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:events_feature/utils/session_manager.dart';

class EventDetailsScreen extends StatefulWidget {
  final int eventId;

  const EventDetailsScreen({
    super.key,
    required this.eventId,
  });

  @override
  State<EventDetailsScreen> createState() => _EventDetailsScreenState();
}

class _EventDetailsScreenState extends State<EventDetailsScreen> {
  EventModel? _event;
  Map<String, dynamic>? _layout;

  bool _isLoading = true;
  bool _layoutLoading = true;

  String? authToken;

  @override
  void initState() {
    super.initState();
    _loadToken();
  }

  /// Load token before API calls
  Future<void> _loadToken() async {
    final session = SessionManager();
    await session.loadSession();

    setState(() {
      authToken = session.authToken;
    });

    debugPrint("Token Loaded: $authToken");

    fetchEventDetails(); // IMPORTANT: Must call here
  }

  /// Fetch Event Details
  Future<void> fetchEventDetails() async {
    if (authToken == null) return;

    try {
      final url =
          "https://white-labels-app-server.vercel.app/api/events/getEventById?event_id=${widget.eventId}";

      final response = await http.get(
        Uri.parse(url),
        headers: {
          "x-auth-token": authToken!,
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body)["data"];
        setState(() {
          _event = EventModel.fromJson(data);
        });

        fetchLayout();
      } else {
        throw Exception("Failed to load event details");
      }
    } catch (e) {
      debugPrint("Error fetching event: $e");
    }

    setState(() => _isLoading = false);
  }

  /// Fetch Layout
  Future<void> fetchLayout() async {
    try {
      final url =
          "https://white-labels-app-server.vercel.app/api/seatlayout/getSeatLayoutByEvent?event_id=${widget.eventId}";

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body)["result"];

        if (result is List && result.isNotEmpty) {
          setState(() {
            _layout = result[0]; // Store layout map
          });
        }
      }
    } catch (e) {
      debugPrint("Layout fetch error: $e");
    }

    setState(() => _layoutLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_event == null) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Text(
            "Failed to load event",
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
    }

    final event = _event!;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(event.title),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // IMAGE
            Container(
              margin: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.green.withOpacity(0.5),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.network(
                  event.imgPath,
                  width: double.infinity,
                  height: 350,
                  fit: BoxFit.cover,
                ),
              ),
            ),

            if (event.slug.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  event.slug,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),

            const SizedBox(height: 20),

            // DATE
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  const Icon(Icons.calendar_today, color: Colors.green),
                  const SizedBox(width: 8),
                  Text(
                    "${event.fromDate.toString().split(' ')[0]} → ${event.toDate.toString().split(' ')[0]}",
                    style: const TextStyle(
                        color: Colors.green,
                        fontSize: 17,
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            // TIME
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  const Icon(Icons.access_time, color: Colors.green),
                  const SizedBox(width: 8),
                  Text(
                    "${event.startTime} - ${event.endTime}",
                    style: const TextStyle(
                        color: Colors.green,
                        fontSize: 17,
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Text("    VENUE :",
                style: TextStyle(color: Colors.white, fontSize: 20)),
            const SizedBox(height: 20),

            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.local_bar_sharp, color: Colors.green),
                const SizedBox(width: 8),
                Text(event.venue,
                    style: TextStyle(
                        color: Colors.green,
                        fontSize: 17,
                        fontWeight: FontWeight.bold))
              ],
            ),

            const SizedBox(height: 20),
            Text("    DESCRIPTION :",
                style: TextStyle(color: Colors.white, fontSize: 20)),

            // DESCRIPTION
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Html(
                data: event.description,
                style: {
                  "body": Style(
                    color: Colors.white70,
                    fontSize: FontSize(15),
                  ),
                },
              ),
            ),
            //const SizedBox(height: 20),
            Text("    ARTISTS :",
                style: TextStyle(color: Colors.white, fontSize: 20)),
            ListTile(
              title: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          Colors.transparent, // transparent background
                      foregroundColor: Colors.white, // text color
                      shadowColor: Colors.transparent, // remove shadow
                      side: const BorderSide(
                        color: Colors.grey,
                      ), // optional border
                    ),
                    onPressed: () {
                      // TODO: handle button press
                    },
                    child: const Text("Artist 1"),
                  ),
                  const SizedBox(width: 30),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      foregroundColor: Colors.white,
                      shadowColor: Colors.transparent,
                      side: const BorderSide(color: Colors.grey),
                    ),
                    onPressed: () {
                      // TODO: handle button press
                    },
                    child: const Text("Artist 2"),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Text("    IMAGES :",
                style: TextStyle(color: Colors.white, fontSize: 20)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // First image
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.asset(
                      'assets/priscilla-du-preez-W3SEyZODn8U-unsplash.jpg',
                      width: (MediaQuery.of(context).size.width - 64) /
                          3, // divide space equally
                      height: 100,
                      fit: BoxFit.cover,
                    ),
                  ),
                  // Second image
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.asset(
                      'assets/pablo-heimplatz-ZODcBkEohk8-unsplash.jpg',
                      width: (MediaQuery.of(context).size.width - 64) / 3,
                      height: 100,
                      fit: BoxFit.cover,
                    ),
                  ),
                  // Third image
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.asset(
                      'assets/al-elmes-ULHxWq8reao-unsplash.jpg',
                      width: (MediaQuery.of(context).size.width - 64) / 3,
                      height: 100,
                      fit: BoxFit.cover,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // BOOK NOW BUTTON
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  if (_layoutLoading) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Loading layout..."),
                      ),
                    );
                    return;
                  }

                  if (_layout == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("No layout available for this event"),
                      ),
                    );
                    return;
                  }

                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.black,
                    shape: const RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(20)),
                    ),
                    builder: (context) {
                      return SizedBox(
                        height: MediaQuery.of(context).size.height * 0.8,
                        child: TicketSelectionScreen(
                          event: event,
                          //layoutId: _layout!["id"], // ← Corrected
                        ),
                      );
                    },
                  );
                },
                child: const Text(
                  "Book Now",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
*/
/*
import 'dart:convert';
import 'package:events_feature/models/event_models.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'tickets_selection_screen.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:events_feature/utils/session_manager.dart';

class EventDetailsScreen extends StatefulWidget {
  final int eventId;

  const EventDetailsScreen({super.key, required this.eventId});

  @override
  State<EventDetailsScreen> createState() => _EventDetailsScreenState();
}

class _EventDetailsScreenState extends State<EventDetailsScreen> {
  EventModel? _event;
  Map<String, dynamic>? _layout;

  bool _isLoading = true;
  bool _layoutLoading = true;

  String? _authToken; // 🔥 FIX: Local token variable

  @override
  void initState() {
    super.initState();
    _init();
  }

  /// 🔹 Load auth token then fetch event
  Future<void> _init() async {
    final session = SessionManager();
    await session.loadSession();

    _authToken = session.authToken;

    if (_authToken == null || _authToken!.isEmpty) {
      debugPrint("❌ No Auth Token Found!");
      setState(() => _isLoading = false);
      return;
    }

    debugPrint("✅ Loaded Token: $_authToken");

    await fetchEventDetails();
  }

  // ───────────────────────────────────────────────
  // 🔹 Fetch Event Details
  // ───────────────────────────────────────────────
  Future<void> fetchEventDetails() async {
    try {
      final url =
          "https://white-labels-app-server.vercel.app/api/events/getEventById?event_id=${widget.eventId}";

      final response = await http.get(
        Uri.parse(url),
        headers: {
          "x-auth-token": _authToken!, // 🔥 FIXED
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body)["data"];
        setState(() {
          _event = EventModel.fromJson(data);
        });

        fetchLayout(); // After event
      } else {
        throw Exception("Failed to load event details");
      }
    } catch (e) {
      debugPrint("❌ Event Fetch Error: $e");
    }

    setState(() => _isLoading = false);
  }

  // ───────────────────────────────────────────────
  // 🔹 Fetch Layout
  // ───────────────────────────────────────────────
  Future<void> fetchLayout() async {
    try {
      final url =
          "https://white-labels-app-server.vercel.app/api/seatlayout/getSeatLayoutByEvent?event_id=${widget.eventId}";

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body)["result"];

        if (result is List && result.isNotEmpty) {
          setState(() {
            _layout = result[0];
          });
        }
      }
    } catch (e) {
      debugPrint("❌ Layout Fetch Error: $e");
    }

    setState(() => _layoutLoading = false);
  }

  // ───────────────────────────────────────────────
  // 🔹 UI
  // ───────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_event == null) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Text(
            "Failed to load event",
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
    }

    final event = _event!;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(event.title),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // IMAGE
            Container(
              margin: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.green.withOpacity(0.5),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.network(
                  event.imgPath,
                  width: double.infinity,
                  height: 350,
                  fit: BoxFit.cover,
                ),
              ),
            ),

            const SizedBox(height: 10),

            if (event.slug.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  event.slug,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),

            const SizedBox(height: 20),

            // DATE
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  const Icon(Icons.calendar_today, color: Colors.green),
                  const SizedBox(width: 8),
                  Text(
                    "${event.fromDate.toString().split(' ')[0]} → ${event.toDate.toString().split(' ')[0]}",
                    style: const TextStyle(
                      color: Colors.green,
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            // TIME
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  const Icon(Icons.access_time, color: Colors.green),
                  const SizedBox(width: 8),
                  Text(
                    "${event.startTime} - ${event.endTime}",
                    style: const TextStyle(
                      color: Colors.green,
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // DESCRIPTION
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Html(
                data: event.description,
                style: {
                  "body": Style(
                    color: Colors.white70,
                    fontSize: FontSize(15),
                  ),
                },
              ),
            ),

            const SizedBox(height: 30), const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                "ARTISTS",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            //const SizedBox(height: 20),
            ListTile(
              title: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green, // transparent background
                      foregroundColor: Colors.white, // text color
                      shadowColor: Colors.transparent, // remove shadow
                      side: const BorderSide(
                        color: Colors.grey,
                      ), // optional border
                    ),
                    onPressed: () {
                      // TODO: handle button press
                    },
                    child: const Text("Artist 1"),
                  ),
                  const SizedBox(width: 30),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      shadowColor: Colors.transparent,
                      side: const BorderSide(color: Colors.grey),
                    ),
                    onPressed: () {
                      // TODO: handle button press
                    },
                    child: const Text("Artist 2"),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                "IMAGES",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // First image
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.asset(
                      'assets/priscilla-du-preez-W3SEyZODn8U-unsplash.jpg',
                      width:
                          (MediaQuery.of(context).size.width - 64) /
                          3, // divide space equally
                      height: 100,
                      fit: BoxFit.cover,
                    ),
                  ),
                  // Second image
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.asset(
                      'assets/pablo-heimplatz-ZODcBkEohk8-unsplash.jpg',
                      width: (MediaQuery.of(context).size.width - 64) / 3,
                      height: 100,
                      fit: BoxFit.cover,
                    ),
                  ),
                  // Third image
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.asset(
                      'assets/al-elmes-ULHxWq8reao-unsplash.jpg',
                      width: (MediaQuery.of(context).size.width - 64) / 3,
                      height: 100,
                      fit: BoxFit.cover,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green, // button background color
                  foregroundColor: Colors.white, // text color
                  minimumSize: const Size(
                    double.infinity,
                    50,
                  ), // full width button
                ),
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true, // full screen height if needed
                    backgroundColor:
                        Colors.black, // matches scaffold background
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(20),
                      ),
                    ),
                    builder: (context) {
                      return SizedBox(
                        height:
                            MediaQuery.of(context).size.height *
                            0.8, // 80% of screen
                        child: TicketSelectionScreen(
                          event: event,
                        ), // your ticket selection screen
                      );
                    },
                  );
                },

            // BOOK NOW BUTTON
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  if (_layoutLoading) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Loading layout..."),
                      ),
                    );
                    return;
                  }

                  if (_layout == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("No layout available for this event"),
                      ),
                    );
                    return;
                  }

                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.black,
                    shape: const RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(20)),
                    ),
                    builder: (context) {
                      return SizedBox(
                        height: MediaQuery.of(context).size.height * 0.8,
                        child: TicketSelectionScreen(
                          event: event,
                          // Add layout if needed
                          // layout: _layout!,
                        ),
                      );
                    },
                  );
                },
                child: const Text(
                  "Book Now",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
*/
/*
import 'dart:convert';
import 'package:events_feature/utils/date_time_format.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:events_feature/models/event_models.dart';
import 'tickets_selection_screen.dart';

class EventDetailsScreen extends StatefulWidget {
  final int eventId; // <-- accept eventId instead of full EventModel

  const EventDetailsScreen({super.key, required this.eventId});

  @override
  State<EventDetailsScreen> createState() => _EventDetailsScreenState();
}

class _EventDetailsScreenState extends State<EventDetailsScreen> {
  EventModel? _event;
  bool _isLoading = true;
  bool _bookNow = false;

  @override
  void initState() {
    super.initState();
    fetchEventDetails();
  }

  Future<void> fetchEventDetails() async {
    try {
      final url =
          "https://white-labels-app-server.vercel.app/api/events/getEventById?event_id=${widget.eventId}";
      final response = await http.get(
        Uri.parse(url),
        headers: {
          "x-auth-token":
              "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjoxMTAwNywidXNlcl9lbWFpbCI6InJpcHdpbmtsZTVAZ21haWwuY29tIiwidXNlcl9tb2JpbGUiOiI5MTkxNzcyNzIxMzMiLCJ1c2VyX2NsdWJfaWQiOjIyMiwiaWF0IjoxNzU5NDg3MzEzLCJleHAiOjE3NjAwOTIxMTN9.mdkoAHAk1fXGC0hYlRUBNfTbLflKWNbu1oUEbp5rNZs",
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body)["data"];
        setState(() {
          _event = EventModel.fromJson(data);
          _isLoading = false;
        });
      } else {
        throw Exception("Failed to load event details");
      }
    } catch (e) {
      debugPrint("Error fetching event: $e");
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_event == null) {
      return const Scaffold(body: Center(child: Text("Failed to load event")));
    }

    final event = _event!;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(event.title),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20), // curved border
                boxShadow: [
                  BoxShadow(
                    color: Colors.green.withOpacity(0.5), // green shadow
                    blurRadius: 10,
                    spreadRadius: 2,
                    offset: const Offset(0, 5), // shadow position
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(
                  20,
                ), // match same border radius
                child: Image.network(
                  event.imgPath,
                  width: double.infinity,
                  height: 350,
                  fit: BoxFit.cover,
                ),
              ),
            ),

            const SizedBox(height: 16),

            // From - To Date
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                " ${event.fromDate.toLocal().toString().split(' ')[0]} "
                " ${event.toDate.toLocal().toString().split(' ')[0]}",
                style: const TextStyle(
                  color: Colors.green,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Time
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                " ${event.startTime} - ${event.endTime}",
                style: const TextStyle(
                  color: Colors.green,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                "ARTISTS",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            //const SizedBox(height: 20),
            ListTile(
              title: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green, // transparent background
                      foregroundColor: Colors.white, // text color
                      shadowColor: Colors.transparent, // remove shadow
                      side: const BorderSide(
                        color: Colors.grey,
                      ), // optional border
                    ),
                    onPressed: () {
                      // TODO: handle button press
                    },
                    child: const Text("Artist 1"),
                  ),
                  const SizedBox(width: 30),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      shadowColor: Colors.transparent,
                      side: const BorderSide(color: Colors.grey),
                    ),
                    onPressed: () {
                      // TODO: handle button press
                    },
                    child: const Text("Artist 2"),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                "IMAGES",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // First image
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.asset(
                      'assets/priscilla-du-preez-W3SEyZODn8U-unsplash.jpg',
                      width:
                          (MediaQuery.of(context).size.width - 64) /
                          3, // divide space equally
                      height: 100,
                      fit: BoxFit.cover,
                    ),
                  ),
                  // Second image
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.asset(
                      'assets/pablo-heimplatz-ZODcBkEohk8-unsplash.jpg',
                      width: (MediaQuery.of(context).size.width - 64) / 3,
                      height: 100,
                      fit: BoxFit.cover,
                    ),
                  ),
                  // Third image
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.asset(
                      'assets/al-elmes-ULHxWq8reao-unsplash.jpg',
                      width: (MediaQuery.of(context).size.width - 64) / 3,
                      height: 100,
                      fit: BoxFit.cover,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green, // button background color
                  foregroundColor: Colors.white, // text color
                  minimumSize: const Size(
                    double.infinity,
                    50,
                  ), // full width button
                ),
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true, // full screen height if needed
                    backgroundColor:
                        Colors.black, // matches scaffold background
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(20),
                      ),
                    ),
                    builder: (context) {
                      return SizedBox(
                        height:
                            MediaQuery.of(context).size.height *
                            0.8, // 80% of screen
                        child: TicketSelectionScreen(
                          event: event,
                        ), // your ticket selection screen
                      );
                    },
                  );
                },
                child: const Text(
                  "Book Now",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
*/
