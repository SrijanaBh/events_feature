import 'dart:convert';
import 'package:events_feature/screens/deals_selection_screen.dart';
import 'package:events_feature/utils/date_time_format.dart';
import 'package:events_feature/utils/session_manager.dart'; // ✅ SessionManager import
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:events_feature/models/deal_models.dart';
import 'package:intl/intl.dart';

class DealsDetailsScreen extends StatefulWidget {
  final int dealId;

  const DealsDetailsScreen({super.key, required this.dealId});

  @override
  State<DealsDetailsScreen> createState() => _DealsDetailsScreenState();
}

class _DealsDetailsScreenState extends State<DealsDetailsScreen> {
  DealModel? _deal;
  bool _isLoading = true;
  String? _error;

  DateTime? _selectedDate;
  int _ticketCount = 0;

  final SessionManager _sessionManager = SessionManager();

  @override
  void initState() {
    super.initState();
    fetchDealsDetails();
  }

  /// Fetch deal details from API dynamically using SessionManager
  Future<void> fetchDealsDetails() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      await _sessionManager.loadSession();
      final token = _sessionManager.authToken;

      if (token == null || token.isEmpty) {
        throw Exception("User not authenticated. Please log in again.");
      }

      final url =
          "https://white-labels-app-server.vercel.app/api/deals/getDealById?deal_id=${widget.dealId}";
      final response = await http.get(
        Uri.parse(url),
        headers: {"x-auth-token": token},
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        final data = decoded['data'];
        final dealData = (data is List && data.isNotEmpty) ? data.first : data;

        setState(() {
          _deal = DealModel.fromJson(dealData);
          _isLoading = false;
        });
      } else {
        throw Exception(
          "Failed to load deal details (Code: ${response.statusCode})",
        );
      }
    } catch (e) {
      debugPrint("Error fetching deal details: $e");
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  List<DateTime> getAvailableDates() {
    if (_deal == null) return [];

    if (_deal!.onlyToday.isNotEmpty && _deal!.onlyToday != "0000-00-00") {
      final today = DateTime.tryParse(_deal!.onlyToday);
      return today != null ? [today] : [];
    }

    try {
      final start = DateTime.parse(_deal!.offerStartDate);
      final end = DateTime.parse(_deal!.offerEndDate);

      final dates = <DateTime>[];
      for (var d = start; !d.isAfter(end); d = d.add(const Duration(days: 1))) {
        dates.add(d);
      }
      return dates;
    } catch (_) {
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    final availableDates = getAvailableDates();

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("Deal Details"),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.green))
          : _error != null
              ? Center(
                  child: Text(
                    _error!,
                    style: const TextStyle(color: Colors.redAccent),
                  ),
                )
              : _deal == null
                  ? const Center(
                      child: Text(
                        "No deal data found",
                        style: TextStyle(color: Colors.white),
                      ),
                    )
                  : _buildDealContent(_deal!, availableDates),
      bottomNavigationBar: _deal != null
          ? Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: _selectedDate == null || _ticketCount == 0
                    ? null
                    : _proceedToPay,
                child: Text(
                  _selectedDate == null || _ticketCount == 0
                      ? "Select a Date & Tickets"
                      : "Proceed to Pay ₹${(_deal!.actualPrice * _ticketCount).toStringAsFixed(2)}",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            )
          : null,
    );
  }

  Widget _buildDealContent(DealModel deal, List<DateTime> availableDates) {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        if (deal.imgPath.isNotEmpty)
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(26),
                
                child: Image.network(
                  deal.imgPath,
                  height: 450,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                top: 16,
                right: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.green.withOpacity(0.5),
                        blurRadius: 10,
                        spreadRadius: 2,
                        offset: const Offset(2, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    deal.discountType == 'r'
                        ? "${deal.discount}% OFF"
                        : "₹${deal.discount} OFF",
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ],
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
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Base Price: ₹${deal.price}",
              style: const TextStyle(
                color: Colors.green,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              "Final Price: ₹${deal.actualPrice}",
              style: const TextStyle(
                color: Colors.green,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const Divider(color: Colors.black, thickness: 0.5, height: 25),
        if (availableDates.isNotEmpty) _buildDateSelector(availableDates),
        const SizedBox(height: 20),
        _buildTicketSelector(),
        const SizedBox(height: 20),
        const Divider(color: Colors.grey, thickness: 0.5, height: 25),
        _buildPriceDetails(deal),
        const SizedBox(height: 30),
        const Divider(color: Colors.grey, thickness: 0.5, height: 25),
        _buildTermsAndConditions(deal.tc),
      ],
    );
  }

  Widget _buildDateSelector(List<DateTime> dates) {
    final dateFormat = DateFormat('EEE, MMM d, yyyy');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "SELECT DATE",
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 50,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: dates.length,
            itemBuilder: (context, index) {
              final date = dates[index];
              final isSelected = _selectedDate == date;
              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: GestureDetector(
                  onTap: () => setState(() => _selectedDate = date),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.green : Colors.grey[800],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        dateFormat.format(date),
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.grey[300],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTicketSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "SELECT NUMBER OF TICKETS",
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            color: Colors.green,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              InkWell(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  bottomLeft: Radius.circular(12),
                ),
                onTap: _ticketCount > 0
                    ? () => setState(() => _ticketCount--)
                    : null,
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Icon(Icons.remove, color: Colors.white, size: 24),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 8,
                ),
                decoration: const BoxDecoration(
                  border: Border.symmetric(
                    vertical: BorderSide(color: Colors.green, width: 1),
                  ),
                ),
                child: Text(
                  '$_ticketCount',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              InkWell(
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(12),
                  bottomRight: Radius.circular(12),
                ),
                onTap: () => setState(() => _ticketCount++),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Icon(Icons.add, color: Colors.white, size: 24),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPriceDetails(DealModel deal) {
    final totalPrice = deal.actualPrice * _ticketCount;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Base Price: ₹${deal.price}",
          style: const TextStyle(color: Colors.white, fontSize: 16),
        ),
        Text(
          "Discount: ${deal.discount}${deal.discountType == 'r' ? '%' : ''}",
          style: const TextStyle(color: Colors.white, fontSize: 16),
        ),
        Text(
          "Final Price per Ticket: ₹${deal.actualPrice.toStringAsFixed(2)}",
          style: const TextStyle(color: Colors.white, fontSize: 16),
        ),
        const SizedBox(height: 8),
        Text(
          "Total for $_ticketCount Ticket(s): ₹${totalPrice.toStringAsFixed(2)}",
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildTermsAndConditions(String tc) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "TERMS & CONDITIONS",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          tc.isNotEmpty ? tc : "No terms provided.",
          style: const TextStyle(color: Colors.white70),
        ),
      ],
    );
  }

  void _proceedToPay() {
    if (_deal == null || _selectedDate == null || _ticketCount == 0) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DealSelectionScreen(
          deal: _deal!,
          selectedDate: _selectedDate!,
          ticketCount: _ticketCount,
        ),
      ),
    );
  }
}





/*
import 'dart:convert';
import 'package:events_feature/screens/deals_selection_screen.dart';
import 'package:events_feature/utils/date_time_format.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:events_feature/models/deal_models.dart';
import 'package:intl/intl.dart';

class DealsDetailsScreen extends StatefulWidget {
  final int dealId;

  const DealsDetailsScreen({super.key, required this.dealId});

  @override
  State<DealsDetailsScreen> createState() => _DealsDetailsScreenState();
}

class _DealsDetailsScreenState extends State<DealsDetailsScreen> {
  DealModel? _deal;
  bool _isLoading = true;
  String? _error;

  DateTime? _selectedDate;
  int _ticketCount = 0;

  @override
  void initState() {
    super.initState();
    fetchDealsDetails();
  }

  /// Fetch deal details from API
  Future<void> fetchDealsDetails() async {
    try {
      final url =
          "https://white-labels-app-server.vercel.app/api/deals/getDealById?deal_id=${widget.dealId}";

      final response = await http.get(
        Uri.parse(url),
        headers: {
          "x-auth-token":
              "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjoxMTAwNywidXNlcl9lbWFpbCI6InJpcHdpbmtsZTVAZ21haWwuY29tIiwidXNlcl9tb2JpbGUiOiI5MTkxNzcyNzIxMzMiLCJ1c2VyX2NsdWJfaWQiOjIyMiwiaWF0IjoxNzYwMzMzMzEzLCJleHAiOjE3NjA5MzgxMTN9.a_bN5P_xKkNYtitRRfnRhBiz5o94CkQfX7OFyYiB9pE",
        },
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        final data = decoded['data'];
        final dealData = (data is List && data.isNotEmpty) ? data.first : data;

        setState(() {
          _deal = DealModel.fromJson(dealData);
          _isLoading = false;
        });
      } else {
        throw Exception(
          "Failed to load deal details (Code: ${response.statusCode})",
        );
      }
    } catch (e) {
      debugPrint("Error fetching deal details: $e");
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  /// Generate list of valid dates between offer_start_date and offer_end_date
  List<DateTime> getAvailableDates() {
    if (_deal == null) return [];

    // Handle "only_today" deal
    if (_deal!.onlyToday != "0000-00-00" && _deal!.onlyToday.isNotEmpty) {
      final todayDate = DateTime.tryParse(_deal!.onlyToday);
      return todayDate != null ? [todayDate] : [];
    }

    // Handle date range deals
    try {
      final start = DateTime.parse(_deal!.offerStartDate);
      final end = DateTime.parse(_deal!.offerEndDate);

      final dates = <DateTime>[];
      for (
        DateTime d = start;
        d.isBefore(end.add(const Duration(days: 1)));
        d = d.add(const Duration(days: 1))
      ) {
        dates.add(d);
      }
      return dates;
    } catch (e) {
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    final availableDates = getAvailableDates();

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("Deal Details"),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.green))
          : _error != null
          ? Center(
              child: Text(
                _error!,
                style: const TextStyle(color: Colors.redAccent),
              ),
            )
          : _deal == null
          ? const Center(
              child: Text(
                "No deal data found",
                style: TextStyle(color: Colors.white),
              ),
            )
          : _buildDealContent(_deal!, availableDates),
      bottomNavigationBar: _deal != null
          ? Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: _selectedDate == null ? null : _proceedToPay,
                child: Text(
                  _selectedDate == null
                      ? "Select a Date to Proceed"
                      : "Proceed to Pay ₹${(_deal!.actualPrice * _ticketCount).toStringAsFixed(2)}",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            )
          : null,
    );
  }

  Widget _buildDealContent(DealModel deal, List<DateTime> availableDates) {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        if (deal.imgPath.isNotEmpty)
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(26),
                child: Image.network(
                  deal.imgPath,
                  height: 450,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                top: 16,
                right: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.4),
                        blurRadius: 4,
                        offset: const Offset(2, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    deal.discountType == 'r'
                        ? "${deal.discount}% OFF"
                        : "₹${deal.discount} OFF",
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),

        // const SizedBox(height: 16),
        Text(
          deal.title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        //const SizedBox(height: 8),
        Text(
          deal.description,
          style: const TextStyle(color: Colors.white70, fontSize: 16),
        ),
        //const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Base Price: ₹${deal.price}",
              style: const TextStyle(
                color: Colors.green,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              "Final Price: ₹${deal.actualPrice}",
              style: const TextStyle(
                color: Colors.green,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const Divider(color: Colors.black, thickness: 0.5, height: 25),

        /// --- Date Selector ---
        if (availableDates.isNotEmpty) _buildDateSelector(availableDates),
        const SizedBox(height: 20),

        /// --- Ticket Selector ---
        _buildTicketSelector(),
        const SizedBox(height: 20),
        const Divider(color: Colors.grey, thickness: 0.5, height: 25),

        _buildPriceDetails(deal),
        const SizedBox(height: 30),
        const Divider(color: Colors.grey, thickness: 0.5, height: 25),

        _buildTermsAndConditions(deal.tc),
      ],
    );
  }

  Widget _buildDateSelector(List<DateTime> dates) {
    final dateFormat = DateFormat('EEE, MMM d, yyyy');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "SELECT DATE",
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 50,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: dates.length,
            itemBuilder: (context, index) {
              final date = dates[index];
              final isSelected = _selectedDate == date;
              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: GestureDetector(
                  onTap: () {
                    setState(() => _selectedDate = date);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.green : Colors.grey[800],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        dateFormat.format(date),
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.grey[300],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTicketSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "SELECT NUMBER OF TICKETS",
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            color: Colors.green,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Minus button
              InkWell(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  bottomLeft: Radius.circular(12),
                ),
                onTap: _ticketCount > 0
                    ? () => setState(() => _ticketCount--)
                    : null,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Icon(
                    Icons.remove,
                    color: _ticketCount > 0 ? Colors.white : Colors.white,
                    size: 24,
                  ),
                ),
              ),

              // Selected count
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 8,
                ),
                decoration: const BoxDecoration(
                  border: Border.symmetric(
                    vertical: BorderSide(color: Colors.green, width: 1),
                  ),
                ),
                child: Text(
                  '$_ticketCount',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              // Plus button
              InkWell(
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(12),
                  bottomRight: Radius.circular(12),
                ),
                onTap: () => setState(() => _ticketCount++),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Icon(Icons.add, color: Colors.white, size: 24),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPriceDetails(DealModel deal) {
    final totalPrice = deal.actualPrice * _ticketCount;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Base Price: ₹${deal.price}",
          style: const TextStyle(color: Colors.white, fontSize: 16),
        ),
        Text(
          "Discount: ${deal.discount}${deal.discountType == 'r' ? '%' : ''}",
          style: const TextStyle(color: Colors.white, fontSize: 16),
        ),
        Text(
          "Final Price per Ticket: ₹${deal.actualPrice.toStringAsFixed(2)}",
          style: const TextStyle(color: Colors.white, fontSize: 16),
        ),
        const SizedBox(height: 8),
        Text(
          "Total for $_ticketCount Ticket(s): ₹${totalPrice.toStringAsFixed(2)}",
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildTermsAndConditions(String tc) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "TERMS & CONDITIONS",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          tc.isNotEmpty ? tc : "No terms provided.",
          style: const TextStyle(color: Colors.white70),
        ),
      ],
    );
  }

  void _proceedToPay() {
    if (_deal == null || _selectedDate == null) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DealSelectionScreen(
          deal: _deal!,
          selectedDate: _selectedDate!,
          ticketCount: _ticketCount,
        ),
      ),
    );
  }
}
*/