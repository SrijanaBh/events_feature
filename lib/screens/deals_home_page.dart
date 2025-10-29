import 'dart:convert';
import 'package:events_feature/controllers/looping_appbar_title.dart';
import 'package:events_feature/models/deal_models.dart';
import 'package:events_feature/screens/deals_details_screen.dart';
import 'package:events_feature/utils/date_time_format.dart';
import 'package:events_feature/utils/session_manager.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class DealsPage extends StatefulWidget {
  const DealsPage({super.key});

  @override
  State<DealsPage> createState() => _DealsPageState();
}

class _DealsPageState extends State<DealsPage> {
  late Future<List<DealModel>> _dealsFuture;
  final SessionManager _sessionManager = SessionManager();

  @override
  void initState() {
    super.initState();
    _dealsFuture = fetchDealsData();
  }

  Future<List<DealModel>> fetchDealsData() async {
    await _sessionManager.loadSession();
    final token = _sessionManager.authToken;

    if (token == null || token.isEmpty) {
      throw Exception("User not authenticated. Please log in again.");
    }

    const url =
        'https://white-labels-app-server.vercel.app/api/deals/list?club_id=222';

    final response = await http.get(
      Uri.parse(url),
      headers: {'x-auth-token': token},
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> body = jsonDecode(response.body);
      final List<dynamic> data = body["data"] ?? [];
      return data.map((e) => DealModel.fromJson(e)).toList();
    } else {
      throw Exception("Failed to load deals (${response.statusCode})");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const LoopingTypingAppBarTitle(
          messages: [
            "Grab Your Deals Now !",
            "Explore Exclusive Offers !",
            "Don't Miss Out !",
          ],
          typingSpeed: Duration(milliseconds: 80),
        ),
      ),
      body: FutureBuilder<List<DealModel>>(
        future: _dealsFuture,
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
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                "No Deals Available",
                style: TextStyle(color: Colors.white),
              ),
            );
          }

          final deals = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: deals.length,
            itemBuilder: (context, index) {
              final deal = deals[index];

              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => DealsDetailsScreen(dealId: deal.id),
                    ),
                  );
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.grey[900],
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.green.withOpacity(0.4),
                        blurRadius: 6,
                        spreadRadius: 1,
                        offset: const Offset(2, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // --- Deal Image (Top) ---
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(16),
                        ),
                        child: Stack(
                          children: [
                            Image.network(
                              deal.imgPath,
                              height: 450,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  Container(
                                height: 450,
                                color: Colors.grey[800],
                                child: const Icon(
                                  Icons.broken_image,
                                  color: Colors.white,
                                  size: 40,
                                ),
                              ),
                            ),

                            // 🟢 Discount Badge
                            if (deal.discount.isNotEmpty)
                              Positioned(
                                top: 16,
                                right: 16,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.green.withOpacity(0.9),
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.green.withOpacity(0.6),
                                        blurRadius: 8,
                                        spreadRadius: 2,
                                        offset: const Offset(0, 3),
                                      ),
                                    ],
                                  ),
                                  child: Text(
                                    deal.discountType == 'percent'
                                        ? '${deal.discount}% OFF'
                                        : '₹${deal.discount} OFF',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),

                      // --- Deal Details ---
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Title
                            Text(
                              deal.title,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),

                            // Slug
                            if (deal.slug.isNotEmpty)
                              Text(
                                deal.slug,
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14,
                                ),
                              ),
                            const SizedBox(height: 10),

                            // Dates Row
                            Row(
                              children: [
                                const Icon(
                                  Icons.calendar_today,
                                  color: Colors.green,
                                  size: 18,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  "${formatDateTime(deal.offerStartDate)} → ${formatDateTime(deal.offerEndDate)}",
                                  style: const TextStyle(
                                    color: Colors.green,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}



/*
import 'dart:convert';
import 'package:events_feature/controllers/looping_appbar_title.dart';
import 'package:events_feature/screens/deals_details_screen.dart';
import 'package:events_feature/models/deal_models.dart';
import 'package:events_feature/utils/date_time_format.dart';
import 'package:events_feature/utils/session_manager.dart'; // ✅ Import SessionManager
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class DealsPage extends StatefulWidget {
  const DealsPage({super.key});

  @override
  State<DealsPage> createState() => _DealsPageState();
}

class _DealsPageState extends State<DealsPage> {
  late Future<List<DealModel>> _dealsFuture;
  final SessionManager _sessionManager = SessionManager();

  @override
  void initState() {
    super.initState();
    _dealsFuture = fetchDealsData();
  }

  Future<List<DealModel>> fetchDealsData() async {
    // ✅ Ensure session is loaded
    await _sessionManager.loadSession();
    final token = _sessionManager.authToken;

    if (token == null || token.isEmpty) {
      throw Exception("User not authenticated. Please log in again.");
    }

    const url =
        'https://white-labels-app-server.vercel.app/api/deals/list?club_id=222';

    final response = await http.get(
      Uri.parse(url),
      headers: {'x-auth-token': token},
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> body = jsonDecode(response.body);
      final List<dynamic> data = body["data"] ?? [];
      return data.map((e) => DealModel.fromJson(e)).toList();
    } else {
      throw Exception("Failed to load deals (${response.statusCode})");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const LoopingTypingAppBarTitle(
          messages: [
            "Grab Your Deals Now !",
            "Explore More !",
            "Don't Miss Out !",
          ],
          typingSpeed: Duration(milliseconds: 80),
        ),
      ),
      body: FutureBuilder<List<DealModel>>(
        future: _dealsFuture,
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
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                "No Deals available",
                style: TextStyle(color: Colors.white),
              ),
            );
          }

          final deals = snapshot.data!;
          return PageView.builder(
            itemCount: deals.length,
            controller: PageController(viewportFraction: 0.95),
            itemBuilder: (context, index) {
              final deal = deals[index];
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => DealsDetailsScreen(dealId: deal.id),
                    ),
                  );
                },
                child: Container(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.shade900,
                        blurRadius: 10,
                        spreadRadius: 3,
                        offset: const Offset(5, 6),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Stack(
                      children: [
                        // Background image
                        Image.network(
                          deal.imgPath,
                          height: 450,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Container(
                                color: Colors.grey[700],
                                alignment: Alignment.center,
                                child: const Icon(
                                  Icons.broken_image,
                                  color: Colors.white,
                                  size: 40,
                                ),
                              ),
                        ),

                        // 🟢 Discount badge at top-right
                        Positioned(
                          top: 16,
                          right: 16,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.green.withOpacity(0.85),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.green.withOpacity(0.6),
                                  blurRadius: 8,
                                  spreadRadius: 2,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Text(
                              deal.discount.isNotEmpty
                                  ? (deal.discountType == 'percent'
                                        ? '${deal.discount}% OFF'
                                        : '₹${deal.discount} OFF')
                                  : 'Deal',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),

                        // Gradient Overlay + Text
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.transparent,
                                  Colors.grey.shade900.withOpacity(0.8),
                                ],
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  deal.title,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  deal.slug,
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                // 🗓️ Start and End Dates
                                Row(
                                  children: [
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.calendar_today,
                                          color: Colors.green,
                                          size: 18,
                                        ),
                                        const SizedBox(width: 5),
                                        Text(
                                          formatDateTime(
                                                deal.offerStartDate,
                                              ).isNotEmpty
                                              ? formatDateTime(
                                                  deal.offerStartDate,
                                                )
                                              : 'N/A',
                                          style: const TextStyle(
                                            color: Colors.green,
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(width: 5),
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.arrow_right_alt,
                                          color: Colors.green,
                                          size: 18,
                                        ),
                                        const SizedBox(width: 5),
                                        Text(
                                          formatDateTime(
                                                deal.offerEndDate,
                                              ).isNotEmpty
                                              ? formatDateTime(
                                                  deal.offerEndDate,
                                                )
                                              : 'N/A',
                                          style: const TextStyle(
                                            color: Colors.green,
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
*/




/*
import 'dart:convert';
import 'package:events_feature/controllers/looping_appbar_title.dart';
import 'package:events_feature/screens/deals_details_screen.dart';
import 'package:events_feature/models/deal_models.dart';
import 'package:events_feature/utils/date_time_format.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class DealsPage extends StatefulWidget {
  const DealsPage({super.key});

  @override
  State<DealsPage> createState() => _DealsPageState();
}

class _DealsPageState extends State<DealsPage> {
  late Future<List<DealModel>> _dealsFuture;

  @override
  void initState() {
    super.initState();
    _dealsFuture = fetchDealsData();
  }

  Future<List<DealModel>> fetchDealsData() async {
    const url =
        'https://white-labels-app-server.vercel.app/api/deals/list?club_id=222';
    const token =
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjoxMTAwNywidXNlcl9lbWFpbCI6InJpcHdpbmtsZTVAZ21haWwuY29tIiwidXNlcl9tb2JpbGUiOiI5MTkxNzcyNzIxMzMiLCJ1c2VyX2NsdWJfaWQiOjIyMiwiaWF0IjoxNzYwMzMzMzEzLCJleHAiOjE3NjA5MzgxMTN9.a_bN5P_xKkNYtitRRfnRhBiz5o94CkQfX7OFyYiB9pE';

    final response = await http.get(
      Uri.parse(url),
      headers: {'x-auth-token': token},
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> body = jsonDecode(response.body);
      final List<dynamic> data = body["data"] ?? [];
      return data.map((e) => DealModel.fromJson(e)).toList();
    } else {
      throw Exception("Failed to load deals (${response.statusCode})");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const LoopingTypingAppBarTitle(
          messages: [
            "Grab Your Deals Now !",
            "Explore More !",
            "Don't Miss Out !",
          ],
          typingSpeed: Duration(milliseconds: 80),
        ),
      ),
      body: FutureBuilder<List<DealModel>>(
        future: _dealsFuture,
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
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                "No Deals available",
                style: TextStyle(color: Colors.white),
              ),
            );
          }

          final deals = snapshot.data!;
          return PageView.builder(
            itemCount: deals.length,
            controller: PageController(viewportFraction: 0.95),
            itemBuilder: (context, index) {
              final deal = deals[index];
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => DealsDetailsScreen(dealId: deal.id),
                    ),
                  );
                },
                child: Container(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.green.withOpacity(0.5),
                        blurRadius: 10,
                        spreadRadius: 3,
                        offset: const Offset(5, 6),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Stack(
                      children: [
                        // Background image
                        Image.network(
                          deal.imgPath,
                          height: double.infinity,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Container(
                                color: Colors.grey[700],
                                alignment: Alignment.center,
                                child: const Icon(
                                  Icons.broken_image,
                                  color: Colors.white,
                                  size: 40,
                                ),
                              ),
                        ),

                        // 🟢 Discount badge at top-right
                        Positioned(
                          top: 16,
                          right: 16,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.green.withOpacity(0.85),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.green.withOpacity(0.6),
                                  blurRadius: 6,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Text(
                              deal.discount.isNotEmpty
                                  ? (deal.discountType == 'percent'
                                        ? '${deal.discount}% OFF'
                                        : '₹${deal.discount} OFF')
                                  : 'Deal',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),

                        // Gradient Overlay + Text
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.transparent,
                                  Colors.black.withOpacity(0.8),
                                ],
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  deal.title,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  deal.slug,
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                // 🗓️ Start and End Dates
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.calendar_today,
                                          color: Colors.green,
                                          size: 18,
                                        ),
                                        const SizedBox(width: 5),
                                        Text(
                                          "${formatDateTime(deal.offerStartDate).isNotEmpty ? formatDateTime(deal.offerStartDate) : 'N/A'}",
                                          style: const TextStyle(
                                            color: Colors.green,
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(width: 5),
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.arrow_right_alt,
                                          color: Colors.green,
                                          size: 18,
                                        ),
                                        const SizedBox(width: 5),
                                        Text(
                                          "${formatDateTime(deal.offerEndDate).isNotEmpty ? formatDateTime(deal.offerEndDate) : 'N/A'}",
                                          style: const TextStyle(
                                            color: Colors.green,
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

*/


/*
import 'dart:convert';
import 'package:events_feature/controllers/looping_appbar_title.dart';
import 'package:events_feature/screens/deals_details_screen.dart';
import 'package:events_feature/models/deal_models.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class DealsPage extends StatefulWidget {
  const DealsPage({super.key});

  @override
  State<DealsPage> createState() => _DealsPageState();
}

class _DealsPageState extends State<DealsPage> {
  late Future<List<DealModel>> _dealsFuture;

  @override
  void initState() {
    super.initState();
    _dealsFuture = fetchDealsData();
  }

  Future<List<DealModel>> fetchDealsData() async {
    const url =
        'https://white-labels-app-server.vercel.app/api/deals/list?club_id=222';
    const token =
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjoxMTAwNywidXNlcl9lbWFpbCI6InJpcHdpbmtsZTVAZ21haWwuY29tIiwidXNlcl9tb2JpbGUiOiI5MTkxNzcyNzIxMzMiLCJ1c2VyX2NsdWJfaWQiOjIyMiwiaWF0IjoxNzU5NDg3MzEzLCJleHAiOjE3NjAwOTIxMTN9.mdkoAHAk1fXGC0hYlRUBNfTbLflKWNbu1oUEbp5rNZs';

    final response = await http.get(
      Uri.parse(url),
      headers: {'x-auth-token': token},
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> body = jsonDecode(response.body);
      final List<dynamic> data = body["data"] ?? [];
      return data.map((e) => DealModel.fromJson(e)).toList();
    } else {
      throw Exception("Failed to load deals (${response.statusCode})");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const LoopingTypingAppBarTitle(
          messages: [
            "Grab Your Deals Now !",
            "Explore More !",
            "Don't Miss Out !",
          ],
          typingSpeed: Duration(milliseconds: 80),
        ),
      ),
      body: FutureBuilder<List<DealModel>>(
        future: _dealsFuture,
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
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                "No Deals available",
                style: TextStyle(color: Colors.white),
              ),
            );
          }

          final deals = snapshot.data!;
          return PageView.builder(
            itemCount: deals.length,
            controller: PageController(viewportFraction: 0.95),
            itemBuilder: (context, index) {
              final deal = deals[index];
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => DealsDetailsScreen(dealId: deal.id),
                    ),
                  );
                },
                child: Container(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.green.withOpacity(0.5),
                        blurRadius: 10,
                        spreadRadius: 3,
                        offset: const Offset(5, 6),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Stack(
                      children: [
                        Image.network(
                          deal.imgPath ?? '',
                          height: double.infinity,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Container(
                                color: Colors.grey[700],
                                alignment: Alignment.center,
                                child: const Icon(
                                  Icons.broken_image,
                                  color: Colors.white,
                                  size: 40,
                                ),
                              ),
                        ),
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.transparent,
                                  Colors.black.withOpacity(0.8),
                                ],
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  deal.title ?? "No Title",
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  deal.slug ?? "",
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
*/