
/*
import 'dart:convert';
import 'package:events_feature/models/get_tickets_price_events.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'tickets_selection_screen.dart';

class GetTicketsScreenByEvent extends StatefulWidget {
  final int id;
  const GetTicketsScreenByEvent({super.key, required this.id});

  @override
  State<GetTicketsScreenByEvent> createState() =>
      _GetTicketsScreenByEventState();
}

class _GetTicketsScreenByEventState extends State<GetTicketsScreenByEvent> {
  Future<List<GetEventsTicketsPrice>> fetchTickets() async {
    try {
      final url =
          'https://white-labels-app-server.vercel.app/api/events/${widget.id}';
      final response = await http.get(
        Uri.parse(url),
        headers: {
          "x-auth-token": "YOUR_AUTH_TOKEN_HERE",
        },
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);

        final ticketsData = jsonResponse['data']['tickets'] as List;
        return ticketsData
            .map((t) => GetEventsTicketsPrice.fromJson(t))
            .toList();
      } else {
        throw Exception("Failed to load tickets");
      }
    } catch (e, s) {
      debugPrint("Error fetching tickets: $e\n$s");
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: FutureBuilder<List<GetEventsTicketsPrice>>(
        future: fetchTickets(),
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
                "No Tickets available",
                style: TextStyle(color: Colors.white),
              ),
            );
          }

          // Pass tickets + eventId to selection screen
          return TicketsSelectionScreen(
            eventId: widget.id,
            //tickets: snapshot.data!,
          );
        },
      ),
    );
  }
}


*/



/*class GetTicketsScreenByEvent extends StatefulWidget {
  final int id;
  const GetTicketsScreenByEvent({super.key, required this.id});

  @override
  State<GetTicketsScreenByEvent> createState() =>
      _GetTicketsScreenByEventState();
}

class _GetTicketsScreenByEventState extends State<GetTicketsScreenByEvent> {
  Future<List<dynamic>> fetchTicketsData() async {
    try {
      final url =
          'https://white-labels-app-server.vercel.app/api/events/${widget.id}';
      final response = await http.get(
        Uri.parse(url),
        headers: {
          "x-auth-token":
              "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjoxMTAwNywidXNlcl9lbWFpbCI6InNwYW55QGdtYWlsLmNvbSIsInVzZXJfbW9iaWxlIjoiOTE5MTc3MjcyMTMzIiwidXNlcl9jbHViX2lkIjoyMjIsImlhdCI6MTc1ODI1MzkxMywiZXhwIjoxNzU4ODU4NzEzfQ.hwreO_v0r8gmW50era7cu8EMpSxtumEkGbJHqY3w5Vc",
        },
      );
      final jsonResponse = jsonDecode(response.body);
      final List<GetEventsTicketsPrice> tickets =
          (jsonResponse['data']['tickets'] as List)
              .map((t) => GetEventsTicketsPrice.fromJson(t))
              .toList();

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        // Print for debugging (optional)
        debugPrint("API Response: $responseData");

        return responseData["data"] ?? [];
      } else {
        throw Exception("Failed to load events");
      }
    } catch (e, s) {
      debugPrint("Error fetching tickets: $e\n$s");
      rethrow;
    }
  }

  // Track selected quantities for tickets
  final Map<int, int> _quantities = {};

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<GetEventsTicketsPrice>>(
      future: fetchTickets(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

        return TicketSelectionScreen(tickets: snapshot.data!);
      },
    );
  }
}
*/
    /*return Scaffold(
      backgroundColor: Colors.black,
      body: FutureBuilder<List<dynamic>>(
        future: fetchTicketsData(),
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
                "No Tickets available",
                style: TextStyle(color: Colors.white),
              ),
            );
          }

          final events = snapshot.data!;
          return PageView.builder(
            itemCount: events.length,
            controller: PageController(viewportFraction: 0.95),
            itemBuilder: (context, index) {
              final rawTickets = events[index]['tickets'];

              // ✅ Safe handling of tickets (null, map, or list)
              final tickets = (rawTickets is List && rawTickets.isNotEmpty)
                  ? rawTickets
                  : (rawTickets == null ? [] : [rawTickets]);

              if (tickets.isEmpty) {
                return const Center(
                  child: Text(
                    "No tickets available for this event",
                    style: TextStyle(color: Colors.white),
                  ),
                );
              }

              return ListView.builder(
                shrinkWrap: true,
                physics: const BouncingScrollPhysics(),
                itemCount: tickets.length,
                itemBuilder: (context, tIndex) {
                  final ticket = tickets[tIndex];
                  final quantity = _quantities[tIndex] ?? 0;

                  if (ticket == null) {
                    return const SizedBox.shrink();
                  }

                  return Container(
                    margin: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 8,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Colors.grey[900],
                      boxShadow: [
                        BoxShadow(
                          color: Colors.green.withOpacity(0.5),
                          blurRadius: 10,
                          spreadRadius: 3,
                          offset: const Offset(5, 6),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Ticket image
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(20),
                          ),
                          child: Image.network(
                            ticket["img_path"] ?? '',
                            height: 200,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
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

                        // Ticket details
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                ticket["title"] ?? "No Title",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                ticket["description"] ?? "",
                                style: const TextStyle(color: Colors.white70),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                "Persons: ${ticket['persons']} | Available: ${ticket['available_qty']}",
                                style: const TextStyle(color: Colors.white),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                "Price: ₹${ticket['price']}",
                                style: const TextStyle(
                                  color: Colors.greenAccent,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 12),

                              // Quantity Selector
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    "Quantity:",
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  Row(
                                    children: [
                                      IconButton(
                                        icon: const Icon(
                                          Icons.remove_circle,
                                          color: Colors.red,
                                        ),
                                        onPressed: quantity > 0
                                            ? () {
                                                setState(() {
                                                  _quantities[tIndex] =
                                                      quantity - 1;
                                                });
                                              }
                                            : null,
                                      ),
                                      Text(
                                        "$quantity",
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 18,
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(
                                          Icons.add_circle,
                                          color: Colors.green,
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            _quantities[tIndex] = quantity + 1;
                                          });
                                        },
                                      ),
                                    ],
                                  ),
                                ],
                              ),

                              const SizedBox(height: 10),

                              // Book Now button
                              ElevatedButton(
                                onPressed: quantity > 0
                                    ? () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) =>
                                                TicketSelectionScreen(
                                                  eventTickets: [],
                                                  dealTickets: [],
                                                ),
                                          ),
                                        );
                                      }
                                    : null,
                                child: const Text("Book Now"),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
*/
