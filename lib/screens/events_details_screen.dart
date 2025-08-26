

import 'package:flutter/material.dart';
import 'package:events_feature/screens/tickets_selection_screen.dart';

class EventDetailsScreen extends StatefulWidget {
  final Map<String, String> event;

  const EventDetailsScreen({super.key, required this.event});

  @override
  State<EventDetailsScreen> createState() => _EventDetailsScreenState();
}

class _EventDetailsScreenState extends State<EventDetailsScreen> {
  bool? _isBooked = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.event['title']!)),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Fixed height image to avoid overflow
            Container(
              height: 250,
              width: double.infinity,
              child: Image.asset(widget.event['image']!, fit: BoxFit.cover),
            ),
            const SizedBox(height: 16),
            Center(
              child: Text(
                '${widget.event['date']} | ${widget.event['time']}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: RadioListTile<bool>(
                title: const Text("Book Now"),
                value: true,
                groupValue: _isBooked,
                onChanged: (val) {
                  setState(() {
                    _isBooked = val;
                  });

                  if (val == true) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            TicketSelectionScreen(event: widget.event),
                      ),
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
