import 'package:events_feature/screens/tablebokking_screen.dart';
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
        actions: [
          IconButton(
            icon: const Icon(Icons.table_bar_rounded, color: Colors.green),
            onPressed: () {
              final eventId = event.id;
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => TableReservationPage(event: event),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              children: [
                ...event.ticketDetails.map((ticket) {
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
                    trailing: qty == 0
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
                                IconButton(
                                  icon: const Icon(Icons.remove,
                                      color: Colors.white, size: 18),
                                  onPressed: qty > 1
                                      ? () {
                                          setState(() {
                                            _selectedQuantities[ticket.id] =
                                                qty - 1;
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
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 8),
                                  child: Text(
                                    qty.toString(),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.add,
                                      color: Colors.white, size: 18),
                                  onPressed: qty < ticket.availableQty
                                      ? () {
                                          setState(() {
                                            _selectedQuantities[ticket.id] =
                                                qty + 1;
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
                }).toList(),

                // ⭐ NEW — Book Tables ListTile
                ListTile(
                  leading: const Icon(Icons.table_bar_rounded,
                      color: Colors.green, size: 36),
                  title: const Text(
                    " Reserve a Table",
                    style: TextStyle(color: Colors.white, fontSize: 22),
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios,
                      color: Colors.green, size: 18),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => TableReservationPage(event: event),
                      ),
                    );
                  },
                ),
              ],
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






/*
import 'package:events_feature/screens/tablebokking_screen.dart';
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
        actions: [
          IconButton(
            icon: const Icon(Icons.table_bar_rounded, color: Colors.green),
            onPressed: () {
              final eventId = event.id;
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => TableReservationPage(event: event),
                ),
              );
            },
          ),
        ],
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

*/



/*
import 'package:events_feature/models/event_models.dart';
import 'package:events_feature/models/get_tickets_price_events.dart';
import 'package:flutter/material.dart';
import 'events_summary_screen.dart';

class TicketSelectionScreen extends StatefulWidget {
  final EventModel event;
  final List<GetEventTicketDetails> tickets;

  const TicketSelectionScreen({
    super.key,
    required this.event,
    required this.tickets,
  });

  @override
  State<TicketSelectionScreen> createState() => _TicketSelectionScreenState();
}

class _TicketSelectionScreenState extends State<TicketSelectionScreen> {
  late List<int> quantities;

  @override
  void initState() {
    super.initState();
    quantities = List<int>.filled(widget.tickets.length, 0);
  }

  int get totalPrice {
    int sum = 0;
    for (int i = 0; i < widget.tickets.length; i++) {
      sum += widget.tickets[i].price * quantities[i];
    }
    return sum;
  }

  int get totalTickets => quantities.fold(0, (a, b) => a + b);

  /// Build a map of selected tickets:  { ticketId : quantity }
  Map<int, int> get selectedTickets {
    final Map<int, int> map = {};

    for (int i = 0; i < quantities.length; i++) {
      if (quantities[i] > 0) {
        final ticket = widget.tickets[i];
        map[ticket.id] = quantities[i]; // USE TICKET ID
      }
    }

    return map;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Select Tickets")),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: widget.tickets.length,
              itemBuilder: (context, index) {
                final ticket = widget.tickets[index];
                return Card(
                  margin: const EdgeInsets.all(8),
                  child: ListTile(
                    leading: Image.network(
                      ticket.imgPath,
                      width: 40,
                      errorBuilder: (context, error, stackTrace) =>
                          const Icon(Icons.local_activity),
                    ),
                    title: Text(ticket.title),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Price: ₹${ticket.price}"),
                        Text("Available: ${ticket.availableQty}"),
                        Text("Persons: ${ticket.persons}"),
                        Text("Valid Till: ${ticket.toDate}"),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove_circle_outline),
                          onPressed: () {
                            setState(() {
                              if (quantities[index] > 0) quantities[index]--;
                            });
                          },
                        ),
                        Text(
                          quantities[index].toString(),
                          style: const TextStyle(fontSize: 16),
                        ),
                        IconButton(
                          icon: const Icon(Icons.add_circle_outline),
                          onPressed: () {
                            setState(() {
                              if (quantities[index] <
                                  widget.tickets[index].availableQty) {
                                quantities[index]++;
                              }
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // Bottom Total Section
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[900],
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  offset: const Offset(0, -2),
                  blurRadius: 6,
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Total: ₹$totalPrice",
                        style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white)),
                    Text("Tickets: $totalTickets",
                        style: const TextStyle(color: Colors.white70)),
                  ],
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                  ),
                  onPressed: totalTickets == 0
                      ? null
                      : () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => EventsSummaryScreen(
                                event: widget.event,
                                selectedTickets: selectedTickets,
                              ),
                            ),
                          );
                        },
                  child: const Text(
                    "Book Now",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
*/

/*
import 'package:flutter/material.dart';
import 'package:events_feature/models/event_models.dart';
import '../models/layout_model.dart';
import 'events_summary_screen.dart';
import 'tablebokking_screen.dart'; // Make sure this file contains TableReservationPage

class TicketSelectionScreen extends StatefulWidget {
  final EventModel event;
  final Layout layoutID;


  const TicketSelectionScreen({
    super.key,
    required this.event,required this.layoutID,
  });

  @override
  State<TicketSelectionScreen> createState() => _TicketSelectionScreenState();
}

class _TicketSelectionScreenState extends State<TicketSelectionScreen> {
  final Map<int, int> _selectedQuantities = {}; // ticketId -> qty

  @override
  Widget build(BuildContext context) {
    final event = widget.event;

    /// A ticket is selected only if qty > 0
    final bool hasSelection = _selectedQuantities.values.any((qty) => qty > 0);

    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        title: const Text("Select Tickets"),
        backgroundColor: Colors.grey[900],
        foregroundColor: Colors.white,
        actions: [
          /// TABLE BOOKING BUTTON
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => TableReservationPage(event: event),
                ),
              );
            },
            icon: const Icon(Icons.table_bar_rounded, color: Colors.green),
            tooltip: 'Book a Table',
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: event.ticketDetails.length + 1,
              itemBuilder: (context, index) {
                /// ---- TABLE BOOKING TILE ----
                if (index == event.ticketDetails.length) {
                  return Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    child: Card(
                      color: Colors.grey[850],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        leading: const Icon(
                          Icons.table_bar_rounded,
                          color: Colors.green,
                          size: 40,
                        ),
                        title: const Text(
                          "Book a Table",
                          style: TextStyle(color: Colors.white, fontSize: 18),
                        ),
                        subtitle: const Text(
                          "Reserve your table in advance",
                          style: TextStyle(
                            color: Colors.greenAccent,
                            fontSize: 14,
                          ),
                        ),
                        trailing: const Icon(
                          Icons.arrow_forward_ios,
                          color: Colors.white70,
                          size: 18,
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => TableReservationPage(event: event),
                            ),
                          );
                        },
                      ),
                    ),
                  );
                }

                /// ---- TICKET TILE ----
                final ticket = event.ticketDetails[index];
                final qty = _selectedQuantities[ticket.id] ?? 0;

                return Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: Card(
                    color: Colors.grey[850],
                    child: ListTile(
                      leading: Image.network(
                        ticket.imgPath,
                        width: 40,
                        height: 40,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Icon(
                          Icons.confirmation_num,
                          size: 40,
                          color: Colors.white,
                        ),
                      ),
                      title: Text(
                        ticket.title,
                        style: const TextStyle(color: Colors.white),
                      ),
                      subtitle: Text(
                        "₹${ticket.price} • Available: ${ticket.availableQty}",
                        style: const TextStyle(color: Colors.greenAccent),
                      ),
                      trailing: qty == 0
                          ? _buildAddButton(ticket)
                          : _buildQtySelector(ticket, qty),
                    ),
                  ),
                );
              },
            ),
          ),

          /// ---- PROCEED BUTTON ----
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: hasSelection ? Colors.green : Colors.grey,
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
                  : null,
              child: const Text(
                "Proceed to Pay",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// ---------------- BUTTON WIDGETS ----------------

  Widget _buildAddButton(ticket) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedQuantities[ticket.id] = 1;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 35, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.green,
          borderRadius: BorderRadius.circular(30),
        ),
        child: const Text(
          "Add",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
        ),
      ),
    );
  }

  Widget _buildQtySelector(ticket, int qty) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: Colors.green,
        borderRadius: BorderRadius.circular(30),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.remove, color: Colors.white, size: 18),
            onPressed: qty > 1
                ? () {
                    setState(() {
                      _selectedQuantities[ticket.id] = qty - 1;
                    });
                  }
                : () {
                    setState(() {
                      _selectedQuantities[ticket.id] = 0;
                    });
                  },
          ),
          Text(
            qty.toString(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.add, color: Colors.white, size: 18),
            onPressed: qty < ticket.availableQty
                ? () {
                    setState(() {
                      _selectedQuantities[ticket.id] = qty + 1;
                    });
                  }
                : null,
          ),
        ],
      ),
    );
  }
}

*/
















/*
import 'package:events_feature/screens/tablebokking_screen.dart';
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
    final hasSelection = _selectedQuantities.values.any((qty) => qty >= 0);

    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        title: const Text("Select Tickets"),
        backgroundColor: Colors.grey[900],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => TableReservationPage(
                    event: event,
                    //layoutID: layoutID["id"], // 🔹 static for now; can be dynamic later
                  ),
                ),
              );
            },
            icon:
                const Icon(Icons.table_bar_rounded, color: Colors.greenAccent),
            tooltip: 'Book a Table',
          ),
        ],
      ),

      // ---------- BODY ----------
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount:
                  event.ticketDetails.length + 1, // +1 for table booking tile
              itemBuilder: (context, index) {
                // ✅ Last tile — show "Book a Table"
                if (index == event.ticketDetails.length) {
                  return Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: Card(
                      color: Colors.grey[900],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        leading: const Icon(Icons.table_bar_rounded,
                            color: Colors.greenAccent, size: 40),
                        title: const Text(
                          "Book a Table",
                          style: TextStyle(color: Colors.white, fontSize: 18),
                        ),
                        subtitle: const Text(
                          "Reserve your table in advance",
                          style: TextStyle(
                              color: Colors.greenAccent, fontSize: 14),
                        ),
                        trailing: const Icon(Icons.arrow_forward_ios,
                            color: Colors.white70, size: 18),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => TableReservationPage(
                                event: event,
                                //layoutID: layoutID,
                                //layoutId: 245,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  );
                }

                // ✅ Otherwise, render ticket list
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
                  trailing: qty == 0
                      ? GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedQuantities[ticket.id] = 1;
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 46, vertical: 14),
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
                              horizontal: 1, vertical: 1),
                          decoration: BoxDecoration(
                            color: Colors.green,
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.remove,
                                    color: Colors.white, size: 18),
                                onPressed: qty > 1
                                    ? () {
                                        setState(() {
                                          _selectedQuantities[ticket.id] =
                                              qty - 1;
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
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8),
                                child: Text(
                                  qty.toString(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.add,
                                    color: Colors.white, size: 18),
                                onPressed: qty < ticket.availableQty
                                    ? () {
                                        setState(() {
                                          _selectedQuantities[ticket.id] =
                                              qty + 1;
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

          // ---------- Proceed Button ----------
          Padding(
            padding: const EdgeInsets.all(10.0),
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
                  : null,
              child: const Text(
                "Proceed to Pay",
                style: TextStyle(
                  fontSize: 20,
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
*/
/*
import 'package:flutter/material.dart';
import 'package:events_feature/models/event_models.dart';
import 'events_summary_screen.dart';
import 'tablebokking_screen.dart';

class TicketSelectionScreen extends StatefulWidget {
  final EventModel event;

  const TicketSelectionScreen({
    super.key,
    required this.event,
  });

  @override
  State<TicketSelectionScreen> createState() => _TicketSelectionScreenState();
}

class _TicketSelectionScreenState extends State<TicketSelectionScreen> {
  final Map<int, int> _selectedQuantities = {}; // ticketId -> qty

  @override
  Widget build(BuildContext context) {
    final event = widget.event;

    /// A ticket is selected only if qty > 0
    final bool hasSelection = _selectedQuantities.values.any((qty) => qty > 0);

    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        title: const Text("Select Tickets"),
        backgroundColor: Colors.grey[900],
        foregroundColor: Colors.white,
        actions: [
          /// TABLE BOOKING BUTTON
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => TableReservationPage(event: event),
                ),
              );
            },
            icon: const Icon(Icons.table_bar_rounded, color: Colors.green),
            tooltip: 'Book a Table',
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: event.ticketDetails.length + 1,
              itemBuilder: (context, index) {
                /// ---- TABLE BOOKING TILE ----
                if (index == event.ticketDetails.length) {
                  return Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    child: Card(
                      color: Colors.grey[850],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        leading: const Icon(Icons.table_bar_rounded,
                            color: Colors.green, size: 40),
                        title: const Text(
                          "Book a Table",
                          style: TextStyle(color: Colors.white, fontSize: 18),
                        ),
                        subtitle: const Text(
                          "Reserve your table in advance",
                          style: TextStyle(
                            color: Colors.greenAccent,
                            fontSize: 14,
                          ),
                        ),
                        trailing: const Icon(Icons.arrow_forward_ios,
                            color: Colors.white70, size: 18),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  TableReservationPage(event: event),
                            ),
                          );
                        },
                      ),
                    ),
                  );
                }

                /// ---- TICKET TILE ----
                final ticket = event.ticketDetails[index];
                final qty = _selectedQuantities[ticket.id] ?? 0;

                return Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: Card(
                    color: Colors.grey[850],
                    child: ListTile(
                      leading: Image.network(
                        ticket.imgPath,
                        width: 40,
                        height: 40,
                        errorBuilder: (_, __, ___) => const Icon(
                          Icons.confirmation_num,
                          size: 40,
                          color: Colors.white,
                        ),
                      ),
                      title: Text(
                        ticket.title,
                        style: const TextStyle(color: Colors.white),
                      ),
                      subtitle: Text(
                        "₹${ticket.price} • Available: ${ticket.availableQty}",
                        style: const TextStyle(color: Colors.greenAccent),
                      ),
                      trailing: qty == 0
                          ? _buildAddButton(ticket)
                          : _buildQtySelector(ticket, qty),
                    ),
                  ),
                );
              },
            ),
          ),

          /// ---- PROCEED BUTTON ----
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
                  : null,
              child: const Text(
                "Proceed to Pay",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// ---------------- BUTTON WIDGETS ----------------

  Widget _buildAddButton(ticket) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedQuantities[ticket.id] = 1;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.green,
          borderRadius: BorderRadius.circular(30),
        ),
        child: const Text(
          "Add",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
        ),
      ),
    );
  }

  Widget _buildQtySelector(ticket, int qty) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      decoration: BoxDecoration(
        color: Colors.green,
        borderRadius: BorderRadius.circular(30),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.remove, color: Colors.white, size: 18),
            onPressed: qty > 1
                ? () {
                    setState(() {
                      _selectedQuantities[ticket.id] = qty - 1;
                    });
                  }
                : () {
                    setState(() {
                      _selectedQuantities[ticket.id] = 0;
                    });
                  },
          ),
          Text(
            qty.toString(),
            style: const TextStyle(
                color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          IconButton(
            icon: const Icon(Icons.add, color: Colors.white, size: 18),
            onPressed: qty < ticket.availableQty
                ? () {
                    setState(() {
                      _selectedQuantities[ticket.id] = qty + 1;
                    });
                  }
                : null,
          ),
        ],
      ),
    );
  }
}




/*
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:events_feature/models/event_models.dart';
import 'events_summary_screen.dart';
import 'tablebokking_screen.dart';

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
    final hasSelection = _selectedQuantities.values.any((qty) => qty >= 0);

    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        title: const Text("Select Tickets"),
        backgroundColor: Colors.grey[900],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const TableReservationPage(event: event,layoutID:245)),
              );
            },
            icon: const Icon(Icons.table_bar_rounded, color: Colors.green),
            tooltip: 'Book a table',
          ),
        ],
      ),

      // ---------- BODY ----------
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: event.ticketDetails.length +
                  1, // +1 for the table booking tile
              itemBuilder: (context, index) {
                // ✅ If it's the last tile — show Table Booking option
                if (index == event.ticketDetails.length) {
                  return Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: Card(
                      color: Colors.grey[900],
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      child: ListTile(
                        leading: const Icon(Icons.table_bar_rounded,
                            color: Colors.green, size: 50),
                        title: const Text(
                          "Book a Table",
                          style: TextStyle(color: Colors.white, fontSize: 18),
                        ),
                        subtitle: const Text(
                          "Reserve your table in advance",
                          style: TextStyle(
                              color: Colors.greenAccent, fontSize: 14),
                        ),
                        trailing: const Icon(Icons.arrow_forward_ios,
                            color: Colors.white70, size: 18),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const TableReservationPage(),
                            ),
                          );
                        },
                      ),
                    ),
                  );
                }

                // ✅ Otherwise show normal ticket tiles
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
                  trailing: qty == 0
                      ? GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedQuantities[ticket.id] = 1;
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 46, vertical: 14),
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
                              horizontal: 1, vertical: 1),
                          decoration: BoxDecoration(
                            color: Colors.green,
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.remove,
                                    color: Colors.white, size: 18),
                                onPressed: qty > 1
                                    ? () {
                                        setState(() {
                                          _selectedQuantities[ticket.id] =
                                              qty - 1;
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
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8),
                                child: Text(
                                  qty.toString(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.add,
                                    color: Colors.white, size: 18),
                                onPressed: qty < ticket.availableQty
                                    ? () {
                                        setState(() {
                                          _selectedQuantities[ticket.id] =
                                              qty + 1;
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

          /* Expanded(
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
                  trailing: qty == 0
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
                                onPressed: qty > 1
                                    ? () {
                                        setState(() {
                                          _selectedQuantities[ticket.id] =
                                              qty - 1;
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
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8),
                                child: Text(
                                  qty.toString(),
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
                                onPressed: qty < ticket.availableQty
                                    ? () {
                                        setState(() {
                                          _selectedQuantities[ticket.id] =
                                              qty + 1;
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
          ),*/

          // ---------- Proceed Button ----------
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
                  : null,
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

      // ---------- Floating Table Button ----------
      /* floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.greenAccent,
        child: const Icon(Icons.table_bar_rounded, color: Colors.black),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const TableReservationPage(),
            ),
          );
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,*/
    );
  }
}
*/
*/