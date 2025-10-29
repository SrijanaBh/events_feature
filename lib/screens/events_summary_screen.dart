import 'dart:convert';
import 'package:events_feature/screens/payuweb_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:http/http.dart' as http;
import 'package:events_feature/models/event_models.dart';
import 'package:events_feature/models/bookingfee_model.dart';
import 'package:events_feature/utils/session_manager.dart';

class EventsSummaryScreen extends StatefulWidget {
  final EventModel event;
  final Map<int, int> selectedTickets;

  const EventsSummaryScreen({
    super.key,
    required this.event,
    required this.selectedTickets,
  });

  @override
  State<EventsSummaryScreen> createState() => _EventsSummaryScreenState();
}

class _EventsSummaryScreenState extends State<EventsSummaryScreen> {
  double baseTotal = 0.0;
  double bookingFee = 0.0;
  double gstAmount = 0.0;
  double finalTotal = 0.0;

  bool isLoading = true;
  String errorMessage = '';

  BookingFeeModel? bookingFeeModel;
  String? authToken;

  @override
  void initState() {
    super.initState();
    _loadAuthTokenAndCalculateTotals();
  }

  /// Load auth token then calculate totals
  Future<void> _loadAuthTokenAndCalculateTotals() async {
    try {
      await SessionManager().loadSession();
      authToken = SessionManager().authToken;

      if (authToken == null || authToken!.isEmpty) {
        throw Exception("You are not logged in.");
      }

      await _calculateTotals();
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  /// Step 1: Calculate base ticket total and fetch booking fee
  Future<void> _calculateTotals() async {
    try {
      final selectedTicketsList = widget.event.ticketDetails
          .where(
            (t) =>
                widget.selectedTickets[t.id] != null &&
                widget.selectedTickets[t.id]! > 0,
          )
          .toList();

      baseTotal = selectedTicketsList.fold<double>(
        0,
        (sum, t) => sum + t.price * (widget.selectedTickets[t.id] ?? 0),
      );

      bookingFeeModel = await fetchBookingFee();
      _calculateFinalTotal();

      setState(() {
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  Future<void> _initiatePayment() async {
    try {
      setState(() => isLoading = true);

      final response = await http.post(
        Uri.parse(
            'https://white-labels-app-server.vercel.app/api/payu/payment'),
        headers: {
          'Content-Type': 'application/json',
          'x-auth-token': authToken!,
        },
        body: jsonEncode({
          "event_id": widget.event.id,
          "amount": finalTotal.toStringAsFixed(2),
          "tickets": widget.selectedTickets,
        }),
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200 && responseData['success'] == true) {
        final paymentUrl = responseData['data'];

        if (paymentUrl != null && paymentUrl.toString().isNotEmpty) {
          // Navigate to WebView for payment
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => PayUPaymentWebView(paymentUrl: paymentUrl),
            ),
          );
        } else {
          throw Exception("Invalid payment URL received.");
        }
      } else {
        throw Exception(responseData['message'] ?? "Payment initiation failed");
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Payment Error: ${e.toString()}")),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  /// Fetch booking fee from API
  Future<BookingFeeModel> fetchBookingFee() async {
    final response = await http.get(
      Uri.parse(
        'https://white-labels-app-server.vercel.app/api/tables/getBookingFee',
      ),
      headers: {'x-auth-token': authToken!},
    );

    if (response.statusCode == 200) {
      return BookingFeeModel.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to fetch booking fee');
    }
  }

  /// Step 2: Calculate all totals
  void _calculateFinalTotal() {
    if (bookingFeeModel == null) return;

    final data = bookingFeeModel!.data;
    bookingFee = data.bookingFeePayer == 2 ? data.bookingFee : 0.0;

    double subtotal = baseTotal + bookingFee;
    gstAmount = subtotal * data.gst / 100;

    finalTotal = subtotal + gstAmount;
  }

  /// Reusable info tile
  Widget _buildListTile(String label, String value, {Color? valueColor}) {
    return Card(
      color: Colors.black,
      margin: const EdgeInsets.symmetric(vertical: 1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        title: Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
        ),
        trailing: Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: valueColor ?? Colors.white,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final selectedTicketsList = widget.event.ticketDetails
        .where(
          (t) =>
              widget.selectedTickets[t.id] != null &&
              widget.selectedTickets[t.id]! > 0,
        )
        .toList();

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text(
          "Booking Summary",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 26),
        ),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.green))
          : errorMessage.isNotEmpty
              ? Center(
                  child: Text(
                    errorMessage,
                    style: const TextStyle(color: Colors.red),
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Event Info
                      Text(
                        widget.event.title,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Venue: ${widget.event.slug}",
                        style:
                            const TextStyle(fontSize: 16, color: Colors.white),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        "SELECTED TICKETS:",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Ticket list
                      Expanded(
                        child: ListView(
                          children: [
                            ...selectedTicketsList.map((ticket) {
                              final qty =
                                  widget.selectedTickets[ticket.id] ?? 0;
                              final total = ticket.price * qty;
                              return _buildListTile(
                                "${ticket.title} (x$qty)",
                                "₹${total.toStringAsFixed(2)}",
                                valueColor: Colors.white,
                              );
                            }),

                            const SizedBox(height: 12),
                            const Text(
                              "PAYMENT BREAKDOWN",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 8),

                            // Fees breakdown
                            _buildListTile(
                              "Base Total",
                              "₹${baseTotal.toStringAsFixed(2)}",
                              valueColor: Colors.green,
                            ),
                            _buildListTile(
                              "Booking Fee",
                              "₹${bookingFee.toStringAsFixed(2)}",
                            ),
                            _buildListTile(
                              "GST (${bookingFeeModel?.data.gst.toStringAsFixed(0)}%)",
                              "₹${gstAmount.toStringAsFixed(2)}",
                            ),

                            const Divider(
                              height: 24,
                              thickness: 1,
                              color: Colors.white12,
                            ),

                            // Grand Total
                            Card(
                              color: Colors.grey[800],
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: ListTile(
                                title: const Text(
                                  "Grand Total",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                                trailing: Text(
                                  "₹${finalTotal.toStringAsFixed(2)}",
                                  style: const TextStyle(
                                    color: Colors.green,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 80),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
      bottomNavigationBar: !isLoading
          ? Container(
              padding: const EdgeInsets.all(16),
              color: Colors.black,
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
                  _initiatePayment();

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        "Proceeding to payment for ₹${finalTotal.toStringAsFixed(2)}",
                      ),
                    ),
                  );
                  // TODO: Integrate PayU next
                },
                child: const Text(
                  "Proceed to Pay",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
            )
          : null,
    );
  }
}





/*
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:events_feature/models/event_models.dart';
import 'package:events_feature/models/bookingfee_model.dart';
import 'package:events_feature/utils/session_manager.dart';

class EventsSummaryScreen extends StatefulWidget {
  final EventModel event;
  final Map<int, int> selectedTickets;

  const EventsSummaryScreen({
    super.key,
    required this.event,
    required this.selectedTickets,
  });

  @override
  State<EventsSummaryScreen> createState() => _EventsSummaryScreenState();
}

class _EventsSummaryScreenState extends State<EventsSummaryScreen> {
  double baseTotal = 0.0;
  double bookingFee = 0.0;
  double gstAmount = 0.0;
  double finalTotal = 0.0;

  bool isLoading = true;
  String errorMessage = '';

  BookingFeeModel? bookingFeeModel;
  String? authToken;

  @override
  void initState() {
    super.initState();
    _loadAuthTokenAndCalculateTotals();
  }

  /// Load auth token from SessionManager, then calculate totals
  Future<void> _loadAuthTokenAndCalculateTotals() async {
    try {
      await SessionManager().loadSession();
      authToken = SessionManager().authToken;

      if (authToken == null || authToken!.isEmpty) {
        throw Exception("You are not logged in.");
      }

      await _calculateTotals();
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  /// Step 1: Calculate base ticket total and fetch booking fee from API
  Future<void> _calculateTotals() async {
    try {
      final selectedTicketsList = widget.event.ticketDetails
          .where(
            (t) =>
                widget.selectedTickets[t.id] != null &&
                widget.selectedTickets[t.id]! > 0,
          )
          .toList();

      baseTotal = selectedTicketsList.fold<double>(
        0,
        (sum, t) => sum + t.price * (widget.selectedTickets[t.id] ?? 0),
      );

      bookingFeeModel = await fetchBookingFee();

      _calculateFinalTotal();

      setState(() {
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  /// Fetch booking fee from API using auth token
  Future<BookingFeeModel> fetchBookingFee() async {
    final response = await http.get(
      Uri.parse(
        'https://white-labels-app-server.vercel.app/api/tables/getBookingFee',
      ),
      headers: {'x-auth-token': authToken!},
    );

    if (response.statusCode == 200) {
      return BookingFeeModel.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to fetch booking fee');
    }
  }

  /// Calculate final totals including booking fee and GST
  void _calculateFinalTotal() {
    if (bookingFeeModel == null) return;

    final data = bookingFeeModel!.data;
    bookingFee = data.bookingFeePayer == 2 ? data.bookingFee : 0.0;

    double subtotal = baseTotal + bookingFee;
    gstAmount = subtotal * data.gst / 100;

    finalTotal = subtotal + gstAmount;
  }

  /// Reusable widget for amount rows
  Widget _buildAmountRow(String label, double value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.white70,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            "₹${value.toStringAsFixed(2)}",
            style: const TextStyle(fontSize: 16, color: Colors.white),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final selectedTicketsList = widget.event.ticketDetails
        .where(
          (t) =>
              widget.selectedTickets[t.id] != null &&
              widget.selectedTickets[t.id]! > 0,
        )
        .toList();

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text(
          "Booking Summary",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 26),
        ),
        backgroundColor: Colors.grey[900],
        foregroundColor: Colors.white,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.green))
          : errorMessage.isNotEmpty
          ? Center(
              child: Text(
                errorMessage,
                style: const TextStyle(color: Colors.red),
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.event.title,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Venue: ${widget.event.slug}",
                    style: const TextStyle(fontSize: 16, color: Colors.white),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "SELECTED TICKETS:",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Ticket list
                  Expanded(
                    child: ListView.builder(
                      itemCount: selectedTicketsList.length,
                      itemBuilder: (context, index) {
                        final ticket = selectedTicketsList[index];
                        final qty = widget.selectedTickets[ticket.id] ?? 0;
                        return Card(
                          color: Colors.grey[850],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          child: ListTile(
                            title: Text(
                              ticket.title,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            subtitle: Text(
                              "₹${ticket.price} x $qty",
                              style: const TextStyle(color: Colors.white70),
                            ),
                            trailing: Text(
                              "₹${(ticket.price * qty).toStringAsFixed(2)}",
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  const Divider(
                    thickness: 1,
                    height: 24,
                    color: Colors.white12,
                  ),

                  // Amount breakdown
                  _buildAmountRow("Base Total", baseTotal),
                  _buildAmountRow("Booking Fee", bookingFee),
                  _buildAmountRow("GST", gstAmount),

                  const Divider(
                    thickness: 1,
                    height: 24,
                    color: Colors.white12,
                  ),

                  // Final total
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Final Total:",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        "₹${finalTotal.toStringAsFixed(2)}",
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 80),
                ],
              ),
            ),
      bottomNavigationBar: isLoading
          ? null
          : Container(
              padding: const EdgeInsets.all(16),
              color: Colors.black,
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
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        "Proceeding to payment for ₹${finalTotal.toStringAsFixed(2)}",
                      ),
                    ),
                  );
                  // TODO: integrate PayU payment here
                },
                child: const Text(
                  "Proceed to Pay",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
    );
  }
}
*/