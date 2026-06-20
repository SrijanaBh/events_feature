import 'package:flutter/material.dart';
import 'package:events_feature/models/event_models.dart';
import 'package:events_feature/models/seats_model.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:events_feature/utils/session_manager.dart';
import 'package:events_feature/models/tables_occupied.dart';
import 'package:events_feature/utils/date_time_format.dart';

class TableSummaryScreen extends StatelessWidget {
  final EventModel event;
  final List<SeatPoint> selectedTableObjects;
  final double totalAmount;

  const TableSummaryScreen({
    super.key,
    required this.event,
    required this.selectedTableObjects,
    required this.totalAmount,
  });
  Future<void> postTableBooking(BuildContext context) async {
    final session = SessionManager();
    await session.loadSession();
    final token = session.authToken;

    if (token == null || token.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Authentication token missing")),
      );
      return;
    }

    final url = Uri.parse(
        "https://white-labels-app-server.vercel.app/api/tables/createBooking");

    // Prepare the request payload
    final List<Map<String, dynamic>> tablesPayload =
        selectedTableObjects.map((t) {
      return {
        "table_id": t.id,
        "table_label": t.label,
        "price": t.minBilling,
        "seats": t.seats,
        "inclusions": t.inclusions,
      };
    }).toList();

    final body = {
      "event_id": event.id,
      "event_title": event.title,
      "total_amount": totalAmount,
      "tables": tablesPayload,
    };

    try {
      final res = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "x-auth-token": token,
        },
        body: jsonEncode(body),
      );

      if (res.statusCode == 200) {
        final responseJson = jsonDecode(res.body);
        print("Booking Success: $responseJson");

        // After successful booking → Navigate to PayU
        Navigator.pushNamed(
          context,
          "/payuScreen",
          arguments: {
            "amount": totalAmount,
            "event": event,
            "tables": selectedTableObjects,
            "booking_id": responseJson["booking_id"], // server response
          },
        );
      } else {
        print("Booking Failed: ${res.statusCode}");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Booking failed: ${res.statusCode}")),
        );
      }
    } catch (e) {
      print("Error posting booking: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          "Table Summary",
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Event Information
            Text(
              event.title,
              style: const TextStyle(
                color: Colors.greenAccent,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            Text(
              event.venue,
              style: const TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 20),

            /// List of Selected Tables
            const Text(
              "Selected Tables",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),

            Expanded(
              child: ListView.builder(
                itemCount: selectedTableObjects.length,
                itemBuilder: (ctx, i) {
                  final table = selectedTableObjects[i];
                  return Container(
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: Colors.white12,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.greenAccent),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Table: ${table.label}",
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold)),
                        Text("Seats: ${table.seats}",
                            style: const TextStyle(color: Colors.white70)),
                        Text("Price: ₹${table.minBilling}",
                            style: const TextStyle(color: Colors.greenAccent)),

                        /* if (table.inclusions.isNotEmpty) ...[
                          const SizedBox(height: 6),
                          const Text("Inclusions:",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold)),
                          Text(
                            table.inclusions,
                            style: const TextStyle(color: Colors.white70),
                          )
                        ]*/
                      ],
                    ),
                  );
                },
              ),
            ),

            /// Total Amount
            Text(
              "Total Price: ₹$totalAmount",
              style: const TextStyle(
                color: Colors.greenAccent,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),

            const SizedBox(height: 16),

            /// Proceed to PayU Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 14)),
                onPressed:
                    () /*{
                  // TODO: Navigate to PayU screen
                  Navigator.pushNamed(context, "/payuScreen", arguments: {
                    "amount": totalAmount,
                    "event": event,
                    "tables": selectedTableObjects,
                  });
                },*/
                    {
                  postTableBooking(context);
                },
                child: const Text(
                  "Proceed to PayU",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
