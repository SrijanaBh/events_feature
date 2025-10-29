import 'package:events_feature/screens/upi_payment_screen.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:events_feature/models/deal_models.dart';

class DealSelectionScreen extends StatelessWidget {
  final DealModel deal;
  final DateTime selectedDate;
  final int ticketCount;

  const DealSelectionScreen({
    super.key,
    required this.deal,
    required this.selectedDate,
    required this.ticketCount,
  });

  @override
  Widget build(BuildContext context) {
    final totalPrice = deal.actualPrice * ticketCount;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("Confirm Deal"),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.network(
                deal.imgPath,
                height: 220,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              deal.title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              deal.description,
              style: const TextStyle(color: Colors.white70, fontSize: 16),
            ),
            const SizedBox(height: 20),
            Text(
              "Date: ${DateFormat('EEE, MMM d, yyyy').format(selectedDate)}",
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
            Text(
              "Tickets: $ticketCount",
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              "Price per Ticket: ₹${deal.actualPrice}",
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
            const Divider(color: Colors.white24, height: 30),
            Text(
              "Total: ₹${totalPrice.toStringAsFixed(2)}",
              style: const TextStyle(
                color: Colors.green,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () {
                  /*Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const PayUPaymentScreen()),
                  );*/
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        "Deal confirmed for ${DateFormat('MMM d, yyyy').format(selectedDate)}!",
                      ),
                    ),
                  );
                },
                child: const Text(
                  "Confirm Booking",
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
