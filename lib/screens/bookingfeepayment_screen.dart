import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/bookingfee_model.dart';

class BookingFeePaymentScreen extends StatefulWidget {
  const BookingFeePaymentScreen({super.key});

  @override
  State<BookingFeePaymentScreen> createState() => _BookingFeePaymentScreenState();
}

class _BookingFeePaymentScreenState extends State<BookingFeePaymentScreen> {
  BookingFeeModel? bookingFeeModel;
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchBookingFee();
  }

  /// ✅ Fetch booking fee details from API
  Future<void> _fetchBookingFee() async {
    try {
      final response = await http.get(
        Uri.parse('https://white-labels-app-server.vercel.app/api/booking-fee'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          bookingFeeModel = BookingFeeModel.fromJson(data);
          isLoading = false;
        });
      } else {
        throw Exception('Failed to fetch booking fee details');
      }
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  /// ✅ Helper to display a key-value row
  Widget _buildInfoRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontSize: 16, color: Colors.white70)),
          Text(value, style: const TextStyle(fontSize: 16, color: Colors.white)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text(
          "Booking Fee Payment",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
        ),
        backgroundColor: Colors.grey[900],
        foregroundColor: Colors.white,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.green))
          : errorMessage != null
              ? Center(
                  child: Text(
                    errorMessage!,
                    style: const TextStyle(color: Colors.red),
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Booking Fee Details",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                      const SizedBox(height: 16),

                      _buildInfoRow("Booking Fee", "₹${bookingFeeModel!.data.bookingFee}"),
                      _buildInfoRow("Booking Fee Payer",
                          bookingFeeModel!.data.bookingFeePayer == 2 ? "User" : "Organizer"),
                      _buildInfoRow("Payment Gateway Fee Payer",
                          bookingFeeModel!.data.paymentGatewayFeePayer == 2 ? "User" : "Organizer"),
                      _buildInfoRow("GST", "${bookingFeeModel!.data.gst}%"),

                      const Divider(height: 32, color: Colors.white24),

                      _buildInfoRow(
                        "Estimated Total (with GST)",
                        "₹${_calculateTotal().toStringAsFixed(2)}",
                      ),

                      const Spacer(),

                      ElevatedButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                  "Proceeding to payment of ₹${_calculateTotal().toStringAsFixed(2)}"),
                            ),
                          );
                          // TODO: Integrate PayU or Razorpay next
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          minimumSize: const Size(double.infinity, 50),
                        ),
                        child: const Text(
                          "Proceed to Pay",
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }

  /// ✅ Calculate total (Booking Fee + GST)
  double _calculateTotal() {
    if (bookingFeeModel == null) return 0.0;
    final baseFee = bookingFeeModel!.data.bookingFee;
    final gstPercent = bookingFeeModel!.data.gst;
    final gstAmount = (baseFee * gstPercent) / 100;
    return baseFee + gstAmount;
  }
}
