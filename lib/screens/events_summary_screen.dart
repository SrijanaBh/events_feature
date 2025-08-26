import 'package:flutter/material.dart';

class EventSummaryScreen extends StatefulWidget {
  final Map<String, String> event;
  final Map<String, int> ticketTypeCounts;

  const EventSummaryScreen({
    super.key,
    required this.event,
    required this.ticketTypeCounts,
  });

  @override
  State<EventSummaryScreen> createState() => _EventSummaryScreenState();
}

class _EventSummaryScreenState extends State<EventSummaryScreen> {
  // Pricing - you can adjust these as per your actual prices
  final Map<String, double> ticketPrices = {"Single": 50.0, "Couple": 90.0};

  String couponCode = '';
  double discountPercent = 0.0;

  // Simple coupon validation (you can expand this)
  void applyCoupon() {
    setState(() {
      if (couponCode.toUpperCase() == 'SAVE10') {
        discountPercent = 10.0;
      } else if (couponCode.toUpperCase() == 'SAVE20') {
        discountPercent = 20.0;
      } else {
        discountPercent = 0.0;
      }
    });
  }

  double get subtotal {
    double total = 0;
    widget.ticketTypeCounts.forEach((type, count) {
      final price = ticketPrices[type] ?? 0;
      total += price * count;
    });
    return total;
  }

  double get discountAmount => subtotal * discountPercent / 100;

  double get gst => (subtotal - discountAmount) * 0.18; // 18% GST

  double get total => subtotal - discountAmount + gst;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text(
          "Event Summary",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w100),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.event['title'] ?? 'No Title',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              Image.asset(
                widget.event['image'] ?? '',
                fit: BoxFit.cover,
                height: 200,
                width: double.infinity,
              ),
              const SizedBox(height: 16),
              Text(
                "Date: ${widget.event['date'] ?? 'N/A'}",
                style: const TextStyle(color: Colors.white),
              ),
              Text(
                "Time: ${widget.event['time'] ?? 'N/A'}",
                style: const TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 24),

              // Ticket Summary
              Text(
                "Ticket Summary:",
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              ...widget.ticketTypeCounts.entries
                  .where((entry) => entry.value > 0)
                  .map(
                    (entry) => Text(
                      "${entry.key}: ${entry.value} x \$${ticketPrices[entry.key]?.toStringAsFixed(2) ?? '0.00'}",
                      style: const TextStyle(
                        fontSize: 18,
                        color: Colors.white70,
                      ),
                    ),
                  )
                  .toList(),

              const SizedBox(height: 24),

              // Payment Breakdown
              Text(
                "Payment Details:",
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              _paymentRow("Subtotal", subtotal),
              _paymentRow(
                "Discount (${discountPercent.toStringAsFixed(0)}%)",
                -discountAmount,
              ),
              _paymentRow("GST (18%)", gst),
              const Divider(color: Colors.white54),

              _paymentRow("Total", total, isTotal: true),

              const SizedBox(height: 24),

              // Coupon Code Input
              TextField(
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Coupon Code',
                  labelStyle: const TextStyle(color: Colors.white70),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white54),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.redAccent),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  suffixIcon: TextButton(
                    onPressed: () {
                      applyCoupon();
                      FocusScope.of(context).unfocus(); // Hide keyboard
                    },
                    child: const Text('Apply'),
                  ),
                ),
                onChanged: (val) => couponCode = val,
              ),

              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: total > 0
                      ? () {
                          // Handle payment logic here
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Proceeding to payment...'),
                            ),
                          );
                        }
                      : null,
                  child: const Text(
                    "Continue to Pay",
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _paymentRow(String label, double amount, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isTotal ? 20 : 16,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: Colors.white,
            ),
          ),
          Text(
            "\$${amount.toStringAsFixed(2)}",
            style: TextStyle(
              fontSize: isTotal ? 20 : 16,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: isTotal ? Colors.redAccent : Colors.white70,
            ),
          ),
        ],
      ),
    );
  }
}



/*import 'package:flutter/material.dart';

class EventSummaryScreen extends StatelessWidget {
  final Map<String, String> event;
  final Map<String, int> ticketTypeCounts;

  const EventSummaryScreen({
    super.key,
    required this.event,
    required this.ticketTypeCounts,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text(
          "Event Summary",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w100),
        ),
      ),
      body: SingleChildScrollView(
        // <-- Wrap with this
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                event['title'] ?? 'No Title',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              Image.asset(event['image'] ?? '', fit: BoxFit.cover),
              const SizedBox(height: 16),
              Text(
                "Date: ${event['date'] ?? 'N/A'}",
                style: const TextStyle(color: Colors.white),
              ),
              Text(
                "Time: ${event['time'] ?? 'N/A'}",
                style: const TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 16),
              Text(
                "Ticket Summary:",
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              ...ticketTypeCounts.entries
                  .where((entry) => entry.value > 0)
                  .map(
                    (entry) => Text(
                      "${entry.key}: ${entry.value}",
                      style: const TextStyle(
                        fontSize: 18,
                        color: Colors.white70,
                      ),
                    ),
                  )
                  .toList(),
              if (ticketTypeCounts.values.every((count) => count == 0))
                const Text(
                  "No tickets selected",
                  style: TextStyle(fontSize: 18, color: Colors.white70),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
*/