import 'package:flutter/material.dart';
import 'package:events_feature/models/event_models.dart';
import 'events_summary_screen.dart';

class TicketSelectionScreen extends StatefulWidget {
  final EventModel event;

  const TicketSelectionScreen({super.key, required this.event});

  @override
  State<TicketSelectionScreen> createState() => _TicketSelectionScreenState();
}

class _TicketSelectionScreenState extends State<TicketSelectionScreen> {
  final Map<int, int> _selectedQuantities = {}; // ticketId -> qty

  @override
  Widget build(BuildContext context) {
    final event = widget.event;

    // Check if any tickets have been selected
    final hasSelection = _selectedQuantities.values.any((qty) => qty > 0);

    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        title: const Text("Select Tickets"),
        backgroundColor: Colors.grey[900],
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: event.ticketDetails.length,
              itemBuilder: (context, index) {
                final ticket = event.ticketDetails[index];
                final qty = _selectedQuantities[ticket.id] ?? 0;

                return ListTile(
                  leading: Image.network(
                    ticket.imgPath,
                    width: 40,
                    height: 40,
                    errorBuilder: (context, error, stackTrace) =>
                        const Icon(Icons.confirmation_num, size: 40),
                  ),
                  title: Text(
                    ticket.title,
                    style: const TextStyle(color: Colors.white),
                  ),
                  subtitle: Text(
                    "₹${ticket.price} • Available: ${ticket.availableQty}",
                    style: const TextStyle(color: Colors.greenAccent),
                  ),
                  trailing: (_selectedQuantities[ticket.id] ?? 0) == 0
                      ? GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedQuantities[ticket.id] = 1;
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 46,
                              vertical: 14,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.green,
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: const Text(
                              "Add",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        )
                      : AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 1,
                            vertical: 1,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green,
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Minus button
                              IconButton(
                                icon: const Icon(
                                  Icons.remove,
                                  color: Colors.white,
                                  size: 18,
                                ),
                                onPressed: (_selectedQuantities[ticket.id] ??
                                            0) >
                                        1
                                    ? () {
                                        setState(() {
                                          _selectedQuantities[ticket.id] =
                                              (_selectedQuantities[ticket.id] ??
                                                      0) -
                                                  1;
                                        });
                                      }
                                    : () {
                                        setState(() {
                                          _selectedQuantities[ticket.id] = 0;
                                        });
                                      },
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(
                                  minWidth: 32,
                                  minHeight: 32,
                                ),
                              ),

                              // Quantity text
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                ),
                                child: Text(
                                  (_selectedQuantities[ticket.id] ?? 0)
                                      .toString(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),

                              // Plus button
                              IconButton(
                                icon: const Icon(
                                  Icons.add,
                                  color: Colors.white,
                                  size: 18,
                                ),
                                onPressed: (_selectedQuantities[ticket.id] ??
                                            0) <
                                        ticket.availableQty
                                    ? () {
                                        setState(() {
                                          _selectedQuantities[ticket.id] =
                                              (_selectedQuantities[ticket.id] ??
                                                      0) +
                                                  1;
                                        });
                                      }
                                    : null,
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(
                                  minWidth: 32,
                                  minHeight: 32,
                                ),
                              ),
                            ],
                          ),
                        ),
                );
              },
            ),
          ),

          // Proceed Button
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
              ),
              onPressed: hasSelection
                  ? () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => EventsSummaryScreen(
                            event: event,
                            selectedTickets: _selectedQuantities,
                          ),
                        ),
                      );
                    }
                  : () {},
              child: const Text(
                "Proceed to Pay",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
