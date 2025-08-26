import 'package:flutter/material.dart';
import 'package:events_feature/screens/events_summary_screen.dart';

class TicketSelectionScreen extends StatefulWidget {
  final Map<String, String> event;

  const TicketSelectionScreen({super.key, required this.event});

  @override
  State<TicketSelectionScreen> createState() => _TicketSelectionScreenState();
}

class _TicketSelectionScreenState extends State<TicketSelectionScreen> {
  int singleCount = 0;
  int coupleCount = 0;

  void incrementSingle() => setState(() => singleCount++);
  void decrementSingle() {
    if (singleCount > 0) setState(() => singleCount--);
  }

  void incrementCouple() => setState(() => coupleCount++);
  void decrementCouple() {
    if (coupleCount > 0) setState(() => coupleCount--);
  }

  void removeSingle() => setState(() => singleCount = 0);
  void removeCouple() => setState(() => coupleCount = 0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Select Tickets")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _ticketRow(
              title: "Single",
              count: singleCount,
              onIncrement: incrementSingle,
              onDecrement: decrementSingle,
              onRemove: removeSingle,
            ),
            const SizedBox(height: 16),
            _ticketRow(
              title: "Couple",
              count: coupleCount,
              onIncrement: incrementCouple,
              onDecrement: decrementCouple,
              onRemove: removeCouple,
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: (singleCount == 0 && coupleCount == 0)
                  ? null
                  : () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => EventSummaryScreen(
                            event: widget.event,
                            ticketTypeCounts: {
                              "Single": singleCount,
                              "Couple": coupleCount,
                            },
                          ),
                        ),
                      );
                    },
              child: const Text("Continue"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _ticketRow({
    required String title,
    required int count,
    required VoidCallback onIncrement,
    required VoidCallback onDecrement,
    required VoidCallback onRemove,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: const TextStyle(fontSize: 18)),
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.remove_circle_outline),
              onPressed: count > 0 ? onDecrement : null,
            ),
            Text(count.toString(), style: const TextStyle(fontSize: 16)),
            IconButton(
              icon: const Icon(Icons.add_circle_outline),
              onPressed: onIncrement,
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              onPressed: count > 0 ? onRemove : null,
            ),
          ],
        ),
      ],
    );
  }
}


