
/*
import 'package:encrypt/encrypt.dart' as encrypt;
import 'dart:convert';
import 'package:events_feature/models/selected_events_deals_model.dart';
import 'package:events_feature/utils/date_time_format.dart';
import 'package:events_feature/utils/session_manager.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_html/flutter_html.dart';

String decryptAES(String encryptedBase64, String keyBase64, String ivBase64) {
  final key = encrypt.Key.fromBase64(keyBase64);
  final iv = encrypt.IV.fromBase64(ivBase64);
  final encrypter = encrypt.Encrypter(
    encrypt.AES(key, mode: encrypt.AESMode.cbc),
  );

  final decrypted = encrypter.decrypt64(encryptedBase64, iv: iv);
  return decrypted;
}

class EventOrdersScreen extends StatefulWidget {
  const EventOrdersScreen({super.key});

  @override
  State<EventOrdersScreen> createState() => _EventOrdersScreenState();
}

class _EventOrdersScreenState extends State<EventOrdersScreen> {
  late Future<EventOrdersResponse> _futureOrders;

  @override
  void initState() {
    super.initState();
    _futureOrders = fetchOrders();
  }

  // ✅ Fetch event orders from API
  Future<EventOrdersResponse> fetchOrders() async {
    final session = SessionManager();
    await session.loadSession();

    final response = await http.get(
      Uri.parse('https://white-labels-app-server.vercel.app/api/orders/list'),
      headers: {
        'Content-Type': 'application/json',
        'x-auth-token': session.authToken ?? "",
      },
    );

    if (response.statusCode == 200) {
      return EventOrdersResponse.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load orders');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text(
          'My Event Orders',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<EventOrdersResponse>(
        future: _futureOrders,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.green),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text(
                "Error: ${snapshot.error}",
                style: const TextStyle(color: Colors.redAccent),
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.data.isEmpty) {
            return const Center(
              child: Text(
                "No event orders found.",
                style: TextStyle(color: Colors.white70),
              ),
            );
          }

          final orders = snapshot.data!.data;

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index];
              return Card(
                color: Colors.grey[900],
                margin: const EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(12),
                  title: /*Text(
                    order.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),*/ Text(
                    order.title.isNotEmpty && order.title.startsWith("U2FsdGVk")
                        ? "Encrypted Title"
                        : order.title,
                  ),

                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 6),
                      Text(
                        order.description,
                        style: const TextStyle(color: Colors.white70),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Qty: ${order.qty}",
                            style: const TextStyle(color: Colors.white),
                          ),
                          Text(
                            "₹${order.totalPriceWithTaxes.toStringAsFixed(2)}",
                            style: const TextStyle(
                              color: Colors.greenAccent,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(
                            Icons.access_time,
                            color: Colors.white54,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              "${formatDateTime(order.startTime)} - ${formatDateTime(order.endTime)}",
                              style: const TextStyle(
                                color: Colors.white54,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(
                            Icons.calendar_today,
                            color: Colors.white54,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            "${formatDateTime(order.fromDate)} → ${formatDateTime(order.toDate)}",
                            style: const TextStyle(
                              color: Colors.white54,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: order.status == 1
                              ? Colors.green
                              : Colors.orangeAccent,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          order.status == 1 ? "Confirmed" : "Pending",
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => EventOrderDetailsScreen(order: order),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class EventOrderDetailsScreen extends StatelessWidget {
  final EventOrder order;
  const EventOrderDetailsScreen({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(order.title, style: const TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            // ✅ Render HTML Description
            if (order.description.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Html(
                  data: order.description,
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
            _infoRow("Order ID", order.orderId.toString()),
            _infoRow("Table Number", order.tableNumber),
            _infoRow("Quantity", order.qty.toString()),
            _infoRow("Price", "₹${order.totalPrice.toStringAsFixed(2)}"),
            _infoRow(
              "Total (with taxes)",
              "₹${order.totalPriceWithTaxes.toStringAsFixed(2)}",
            ),
            _infoRow("Start Time", formatDateTime(order.startTime)),
            _infoRow("End Time", formatDateTime(order.endTime)),
            _infoRow("From Date", formatDateTime(order.fromDate)),
            _infoRow("To Date", formatDateTime(order.toDate)),
            const SizedBox(height: 20),

            ElevatedButton.icon(
              onPressed: () {
                // TODO: Add invoice download logic
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
              icon: const Icon(Icons.download, color: Colors.white),
              label: const Text(
                "Download Invoice",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.white60, fontSize: 14),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
*/