import 'package:events_feature/screens/events_summary_screen.dart';
import 'package:flutter/material.dart';

class TicketSelectionScreen extends StatefulWidget {
  final Map<String, dynamic> event;

  const TicketSelectionScreen({super.key, required this.event});

  @override
  State<TicketSelectionScreen> createState() => _TicketSelectionScreenState();
}

class _TicketSelectionScreenState extends State<TicketSelectionScreen> {
  int _ticketCount = 1;

  @override
  Widget build(BuildContext context) {
    final double pricePerTicket =
        double.tryParse(widget.event["price"].toString()) ?? 0;
    final double totalPrice = _ticketCount * pricePerTicket;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.grey[900],
        title: Text(
          "Book Tickets",
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Event title
            Text(
              widget.event["title"] ?? "Event",
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 10),

            // Ticket selector
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Number of Tickets",
                  style: TextStyle(color: Colors.white70, fontSize: 16),
                ),
                Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        if (_ticketCount > 1) {
                          setState(() => _ticketCount--);
                        }
                      },
                      icon: const Icon(
                        Icons.remove_circle,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      '$_ticketCount',
                      style: const TextStyle(fontSize: 18, color: Colors.white),
                    ),
                    IconButton(
                      onPressed: () {
                        setState(() => _ticketCount++);
                      },
                      icon: const Icon(Icons.add_circle, color: Colors.white),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 30),

            // Price summary
            Text(
              "Price per Ticket: ₹$pricePerTicket",
              style: const TextStyle(color: Colors.white54),
            ),
            const SizedBox(height: 5),
            Text(
              "Total: ₹$totalPrice",
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.greenAccent,
              ),
            ),

            const Spacer(),

            // Proceed Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () {
                  // Placeholder: Add payment logic here
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => EventsSummaryScreen(
                        event: widget.event,
                        ticketCount: _ticketCount,
                        totalPrice: totalPrice,
                      ),
                    ),
                  );
                  /*showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                      backgroundColor: Colors.grey[900],
                      title: const Text("Booking Confirmed", style: TextStyle(color: Colors.white)),
                      content: Text(
                        "You've booked $_ticketCount ticket(s) for ₹$totalPrice.",
                        style: const TextStyle(color: Colors.white70),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text("OK", style: TextStyle(color: Colors.redAccent)),
                        ),
                      ],
                    ),
                  );*/
                },
                child: const Text(
                  "Proceed to Payment",
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
