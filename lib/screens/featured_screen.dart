import 'dart:convert';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:events_feature/screens/deals_details_screen.dart';
import 'package:events_feature/screens/events_details_screen.dart';
import 'package:events_feature/utils/session_manager.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class FeaturedEvents extends StatefulWidget {
  const FeaturedEvents({super.key});

  @override
  State<FeaturedEvents> createState() => _FeaturedEventsState();
}

class _FeaturedEventsState extends State<FeaturedEvents> {
  final SessionManager _sessionManager = SessionManager();
  String? _authToken;
  int _currentIndex = 0;

  static const String _baseUrl =
      'https://white-labels-app-server.vercel.app/api/features/list?club_id=222';

  Future<Map<String, dynamic>>? featuredList;
  @override
  void initState() {
    super.initState();
    loadData();
  }

  loadData() async {
    await _loadAuthToken();
    featuredList = fetchFeaturedList();
  }

  Future<void> _loadAuthToken() async {
    await _sessionManager.loadSession();
    setState(() {
      _authToken = _sessionManager.authToken;
    });
  }

  Future<Map<String, dynamic>> fetchFeaturedList() async {
    if (_authToken == null) {
      throw Exception("Auth token not available. Please log in again.");
    }

    final response = await http.get(
      Uri.parse(_baseUrl),
      headers: {"x-auth-token": _authToken!},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data["data"] ?? {};
    } else {
      throw Exception("Failed to load featured list");
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_authToken == null) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator(color: Colors.green)),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: FutureBuilder<Map<String, dynamic>>(
        future: featuredList,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.green),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text(
                "Error: ${snapshot.error}",
                style: const TextStyle(color: Colors.red),
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                "No featured items available",
                style: TextStyle(color: Colors.white),
              ),
            );
          }

          final deals = List<Map<String, dynamic>>.from(
            snapshot.data!["deals"] ?? [],
          );
          final events = List<Map<String, dynamic>>.from(
            snapshot.data!["events"] ?? [],
          );

          final uniqueDeals = {for (var d in deals) d["id"]: d}.values.toList();

          final featuredList = [
            ...uniqueDeals.map((d) => {...d, "type": "deal"}),
            ...events.map((e) => {...e, "type": "event"}),
          ];

          return Column(
            children: [
              const SizedBox(height: 12),
              /*CarouselSlider.builder(
                itemCount: featuredList.length,
                itemBuilder: (context, index, realIdx) {
                  final item = featuredList[index];
                  final bool isActive = index == _currentIndex;
                  final double scale = isActive ? 1.0 : 1.0;
                  final double tilt = isActive
                      ? 0
                      : (index < _currentIndex ? -0.05 : 0.05);

                  return //AnimatedContainer(
                  //duration: const Duration(milliseconds: 400),
                  //curve: Curves.easeOut,
                  // transform: Matrix4.identity()
                  //  ..scale(scale)
                  // ..setEntry(3, 2, 0.001)
                  // ..rotateY(tilt),
                  //child:
                  _buildImageCard(context, item);
                  //);
                },
                options: CarouselOptions(
                  height: MediaQuery.of(context).size.height * 0.65,
                  enlargeCenterPage: true,
                  enlargeStrategy: CenterPageEnlargeStrategy.height,
                  viewportFraction: 0.95,
                  autoPlay: false, // <-- disabled for manual sliding
                  enableInfiniteScroll: true,
                  onPageChanged: (index, reason) {
                    setState(() => _currentIndex = index);
                  },
                ),
              ),*/
              /* CarouselSlider.builder(
                itemCount: featuredList.length,
                itemBuilder: (context, index, realIdx) {
                  final item = featuredList[index];
                  return _buildImageCard(context, item);
                },
                options: CarouselOptions(
                  height: MediaQuery.of(context).size.height *
                      0.48, // adaptive height
                  enlargeCenterPage: true,
                  enlargeFactor: 0.25,
                  viewportFraction: 0.85,
                  autoPlay: false,
                  enableInfiniteScroll: true,
                  onPageChanged: (index, reason) {
                    setState(() => _currentIndex = index);
                  },
                ),
              ),*/
              CarouselSlider.builder(
                itemCount: featuredList.length,
                itemBuilder: (context, index, realIdx) {
                  final item = featuredList[index];
                  return _buildImageCard(context, item);
                },
                options: CarouselOptions(
                  height: MediaQuery.of(context).size.height * 0.65,
                  enlargeCenterPage: true,
                  enlargeFactor: 0.35, // scales center card 25% larger
                  viewportFraction:
                      0.85, // enough space on sides for swipe gestures
                  autoPlay: false, // manual sliding
                  enableInfiniteScroll: true,
                  onPageChanged: (index, reason) {
                    setState(() => _currentIndex = index);
                  },
                ),
              ),

              //  const SizedBox(height: 10),
              // Page indicator
              /*   Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: featuredList.asMap().entries.map((entry) {
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: _currentIndex == entry.key ? 14.0 : 8.0,
                    height: 8.0,
                    margin: const EdgeInsets.symmetric(horizontal: 3.0),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _currentIndex == entry.key
                          ? Colors.greenAccent
                          : Colors.white30,
                    ),
                  );
                }).toList(),
              ),
              */
            ],
          );
        },
      ),
    );
  }

  Widget _buildImageCard(BuildContext context, Map<String, dynamic> item) {
    final type = item["type"];

    String formatDate(String? dateStr) {
      if (dateStr == null || dateStr.isEmpty || dateStr == "0000-00-00") {
        return "";
      }
      try {
        final date = DateTime.parse(dateStr);
        return "${date.day}/${date.month}/${date.year}";
      } catch (_) {
        return "";
      }
    }

    String fromDate = "";
    String toDate = "";
    if (type == "event") {
      fromDate = formatDate(item["from_date"]);
      toDate = formatDate(item["to_date"]);
    } else if (type == "deal") {
      fromDate = formatDate(item["offer_start_date"]);
      toDate = formatDate(item["offer_end_date"]);
    }

    return GestureDetector(
      onTap: () {
        if (type == "event") {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => EventDetailsScreen(eventId: item['id']),
            ),
          );
        } else if (type == "deal") {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => DealsDetailsScreen(dealId: item['id']),
            ),
          );
        }
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.greenAccent.withOpacity(0.4),
              blurRadius: 10,
              spreadRadius: 2,
              offset: const Offset(3, 3),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            children: [
              // --- Background Image ---
              Image.network(
                item["img_path"] ?? '',
                height: double.infinity,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: Colors.grey[900],
                  child: const Center(
                    child: Icon(Icons.broken_image,
                        color: Colors.white54, size: 48),
                  ),
                ),
              ),

              // --- Gradient Overlay for Bottom Info ---
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
                        Colors.black.withOpacity(0.7),
                      ],
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item["title"] ?? "No Title",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item["slug"] ?? "",
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // --- Date Chip ---
              if (fromDate.isNotEmpty && toDate.isNotEmpty)
                Positioned(
                  bottom: 70,
                  left: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.calendar_today,
                          color: Colors.white,
                          size: 16,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          "$fromDate → $toDate",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              // --- ✅ Discount Badge on Top-Right ---
              if (item["discount"] != null && item["discount"] != 0)
                Positioned(
                  top: 16,
                  right: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.95),
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.green.withOpacity(0.6),
                          blurRadius: 10,
                          spreadRadius: 1,
                          offset: const Offset(2, 3),
                        ),
                      ],
                    ),
                    child: Text(
                      item["discount_type"] == "r"
                          ? "${item["discount"]}% OFF"
                          : "₹${item["discount"]} OFF",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        shadows: [
                          Shadow(
                            color: Colors.black45,
                            blurRadius: 4,
                            offset: Offset(1, 1),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  /*Widget _buildImageCard(BuildContext context, Map<String, dynamic> item) {
    final type = item["type"];

    // --- Responsive scaling helpers ---
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    String formatDate(String? dateStr) {
      if (dateStr == null || dateStr.isEmpty || dateStr == "0000-00-00")
        return "";
      try {
        final date = DateTime.parse(dateStr);
        return "${date.day}/${date.month}/${date.year}";
      } catch (_) {
        return "";
      }
    }

    String fromDate = "";
    String toDate = "";
    if (type == "event") {
      fromDate = formatDate(item["from_date"]);
      toDate = formatDate(item["to_date"]);
    } else if (type == "deal") {
      fromDate = formatDate(item["offer_start_date"]);
      toDate = formatDate(item["offer_end_date"]);
    }

    return GestureDetector(
      onTap: () {
        if (type == "event") {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => EventDetailsScreen(eventId: item['id']),
            ),
          );
        } else if (type == "deal") {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => DealsDetailsScreen(dealId: item['id']),
            ),
          );
        }
      },
      child: Container(
        margin: EdgeInsets.symmetric(
          horizontal: screenWidth * 0.025,
          vertical: screenHeight * 0.012,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.greenAccent.withOpacity(0.4),
              blurRadius: 10,
              spreadRadius: 2,
              offset: const Offset(3, 3),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: AspectRatio(
            aspectRatio: 16 / 9, // Ensures consistent image proportions
            child: Stack(
              fit: StackFit.expand,
              children: [
                // --- Background Image ---
                Image.network(
                  item["img_path"] ?? '',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: Colors.grey[900],
                    child: const Center(
                      child: Icon(Icons.broken_image,
                          color: Colors.white54, size: 48),
                    ),
                  ),
                ),

                // --- Gradient Overlay ---
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: screenWidth * 0.04,
                      vertical: screenHeight * 0.015,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.75),
                        ],
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          item["title"] ?? "No Title",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: screenWidth * 0.05,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.004),
                        Text(
                          item["slug"] ?? "",
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: screenWidth * 0.035,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // --- Date Badge ---
                if (fromDate.isNotEmpty && toDate.isNotEmpty)
                  Positioned(
                    bottom: screenHeight * 0.10,
                    left: screenWidth * 0.04,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: screenWidth * 0.03,
                        vertical: screenHeight * 0.006,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.calendar_today,
                              color: Colors.white, size: 14),
                          SizedBox(width: screenWidth * 0.015),
                          Text(
                            "$fromDate → $toDate",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: screenWidth * 0.035,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                // --- Discount Badge ---
                if (item["discount"] != null && item["discount"] != 0)
                  Positioned(
                    top: screenHeight * 0.015,
                    right: screenWidth * 0.04,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: screenWidth * 0.03,
                        vertical: screenHeight * 0.006,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.95),
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.green.withOpacity(0.5),
                            blurRadius: 8,
                            spreadRadius: 1,
                            offset: const Offset(2, 3),
                          ),
                        ],
                      ),
                      child: Text(
                        item["discount_type"] == "r"
                            ? "${item["discount"]}% OFF"
                            : "₹${item["discount"]} OFF",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: screenWidth * 0.035,
                          fontWeight: FontWeight.bold,
                          shadows: const [
                            Shadow(
                              color: Colors.black45,
                              blurRadius: 4,
                              offset: Offset(1, 1),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }*/
}

/*
import 'dart:convert';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:events_feature/screens/deals_details_screen.dart';
import 'package:events_feature/screens/events_details_screen.dart';
import 'package:events_feature/utils/session_manager.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class FeaturedEvents extends StatefulWidget {
  const FeaturedEvents({super.key});

  @override
  State<FeaturedEvents> createState() => _FeaturedEventsState();
}

class _FeaturedEventsState extends State<FeaturedEvents> {
  final SessionManager _sessionManager = SessionManager();
  String? _authToken;
  int _currentIndex = 0;

  static const String _baseUrl =
      'https://white-labels-app-server.vercel.app/api/features/list?club_id=222';

  Future<Map<String, dynamic>>? featuredList;
  @override
  void initState() {
    super.initState();
    loadData();
  }

  loadData() async {
    await _loadAuthToken();
    featuredList = fetchFeaturedList();
  }

  Future<void> _loadAuthToken() async {
    await _sessionManager.loadSession();
    setState(() {
      _authToken = _sessionManager.authToken;
    });
  }

  Future<Map<String, dynamic>> fetchFeaturedList() async {
    if (_authToken == null) {
      throw Exception("Auth token not available. Please log in again.");
    }

    final response = await http.get(
      Uri.parse(_baseUrl),
      headers: {"x-auth-token": _authToken!},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data["data"] ?? {};
    } else {
      throw Exception("Failed to load featured list");
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_authToken == null) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator(color: Colors.green)),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: FutureBuilder<Map<String, dynamic>>(
        future: featuredList,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.green),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text(
                "Error: ${snapshot.error}",
                style: const TextStyle(color: Colors.red),
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                "No featured items available",
                style: TextStyle(color: Colors.white),
              ),
            );
          }

          final deals = List<Map<String, dynamic>>.from(
            snapshot.data!["deals"] ?? [],
          );
          final events = List<Map<String, dynamic>>.from(
            snapshot.data!["events"] ?? [],
          );

          final uniqueDeals = {for (var d in deals) d["id"]: d}.values.toList();

          final featuredList = [
            ...uniqueDeals.map((d) => {...d, "type": "deal"}),
            ...events.map((e) => {...e, "type": "event"}),
          ];

          return Column(
            children: [
              const SizedBox(height: 12),
              /*CarouselSlider.builder(
                itemCount: featuredList.length,
                itemBuilder: (context, index, realIdx) {
                  final item = featuredList[index];
                  final bool isActive = index == _currentIndex;
                  final double scale = isActive ? 1.0 : 1.0;
                  final double tilt = isActive
                      ? 0
                      : (index < _currentIndex ? -0.05 : 0.05);

                  return //AnimatedContainer(
                  //duration: const Duration(milliseconds: 400),
                  //curve: Curves.easeOut,
                  // transform: Matrix4.identity()
                  //  ..scale(scale)
                  // ..setEntry(3, 2, 0.001)
                  // ..rotateY(tilt),
                  //child:
                  _buildImageCard(context, item);
                  //);
                },
                options: CarouselOptions(
                  height: MediaQuery.of(context).size.height * 0.65,
                  enlargeCenterPage: true,
                  enlargeStrategy: CenterPageEnlargeStrategy.height,
                  viewportFraction: 0.95,
                  autoPlay: false, // <-- disabled for manual sliding
                  enableInfiniteScroll: true,
                  onPageChanged: (index, reason) {
                    setState(() => _currentIndex = index);
                  },
                ),
              ),*/
              CarouselSlider.builder(
                itemCount: featuredList.length,
                itemBuilder: (context, index, realIdx) {
                  final item = featuredList[index];
                  return _buildImageCard(context, item);
                },
                options: CarouselOptions(
                  height: MediaQuery.of(context).size.height * 0.65,
                  enlargeCenterPage: true,
                  enlargeFactor: 0.25, // scales center card 25% larger
                  viewportFraction:
                      0.85, // enough space on sides for swipe gestures
                  autoPlay: false, // manual sliding
                  enableInfiniteScroll: true,
                  onPageChanged: (index, reason) {
                    setState(() => _currentIndex = index);
                  },
                ),
              ),

              //  const SizedBox(height: 10),
              // Page indicator
              /*   Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: featuredList.asMap().entries.map((entry) {
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: _currentIndex == entry.key ? 14.0 : 8.0,
                    height: 8.0,
                    margin: const EdgeInsets.symmetric(horizontal: 3.0),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _currentIndex == entry.key
                          ? Colors.greenAccent
                          : Colors.white30,
                    ),
                  );
                }).toList(),
              ),
              */
            ],
          );
        },
      ),
    );
  }

  Widget _buildImageCard(BuildContext context, Map<String, dynamic> item) {
    final type = item["type"];

    String formatDate(String? dateStr) {
      if (dateStr == null || dateStr.isEmpty || dateStr == "0000-00-00") {
        return "";
      }
      try {
        final date = DateTime.parse(dateStr);
        return "${date.day}/${date.month}/${date.year}";
      } catch (_) {
        return "";
      }
    }

    String fromDate = "";
    String toDate = "";
    if (type == "event") {
      fromDate = formatDate(item["from_date"]);
      toDate = formatDate(item["to_date"]);
    } else if (type == "deal") {
      fromDate = formatDate(item["offer_start_date"]);
      toDate = formatDate(item["offer_end_date"]);
    }

    return GestureDetector(
      onTap: () {
        if (type == "event") {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => EventDetailsScreen(eventId: item['id']),
            ),
          );
        } else if (type == "deal") {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => DealsDetailsScreen(dealId: item['id']),
            ),
          );
        }
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.greenAccent.withOpacity(0.5),
              blurRadius: 12,
              spreadRadius: 2,
              offset: const Offset(5, 5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            children: [
              Image.network(
                item["img_path"] ?? '',
                height: double.infinity,
                width: double.infinity,
                fit: BoxFit.cover,
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
                        Colors.black.withOpacity(0.7),
                      ],
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item["title"] ?? "No Title",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item["slug"] ?? "",
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (fromDate.isNotEmpty && toDate.isNotEmpty)
                Positioned(
                  bottom: 70,
                  left: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.calendar_today,
                          color: Colors.white,
                          size: 16,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          "$fromDate → $toDate",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
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
  }
}
*/
/*
import 'dart:convert';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:events_feature/screens/deals_details_screen.dart';
import 'package:events_feature/screens/events_details_screen.dart';
import 'package:events_feature/utils/session_manager.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class FeaturedEvents extends StatefulWidget {
  const FeaturedEvents({super.key});

  @override
  State<FeaturedEvents> createState() => _FeaturedEventsState();
}

class _FeaturedEventsState extends State<FeaturedEvents> {
  final SessionManager _sessionManager = SessionManager();
  String? _authToken;
  int _currentIndex = 0;

  static const String _baseUrl =
      'https://white-labels-app-server.vercel.app/api/features/list?club_id=222';

  @override
  void initState() {
    super.initState();
    _loadAuthToken();
  }

  Future<void> _loadAuthToken() async {
    await _sessionManager.loadSession();
    setState(() {
      _authToken = _sessionManager.authToken;
    });
  }

  Future<Map<String, dynamic>> fetchFeaturedList() async {
    if (_authToken == null) {
      throw Exception("Auth token not available. Please log in again.");
    }

    final headers = {"x-auth-token": _authToken!};

    final response = await http.get(Uri.parse(_baseUrl), headers: headers);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data["data"] ?? {};
    } else {
      throw Exception("Failed to fetch featured list");
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_authToken == null) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator(color: Colors.green)),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: FutureBuilder<Map<String, dynamic>>(
        future: fetchFeaturedList(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.green),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text(
                "Error: ${snapshot.error}",
                style: const TextStyle(color: Colors.red),
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                "No featured items available",
                style: TextStyle(color: Colors.white),
              ),
            );
          }

          final deals = List<Map<String, dynamic>>.from(
            snapshot.data!["deals"] ?? [],
          );
          final events = List<Map<String, dynamic>>.from(
            snapshot.data!["events"] ?? [],
          );

          final uniqueDeals = {for (var d in deals) d["id"]: d}.values.toList();

          final featuredList = [
            ...uniqueDeals.map((d) => {...d, "type": "deal"}),
            ...events.map((e) => {...e, "type": "event"}),
          ];

          return Column(
            children: [
              const SizedBox(height: 12),
              CarouselSlider.builder(
                itemCount: featuredList.length,
                itemBuilder: (context, index, realIdx) {
                  final item = featuredList[index];
                  final bool isActive = index == _currentIndex;

                  // 🎯 Scale & tilt effect
                  final double scale = isActive ? 1.0 : 0.85;
                  final double tilt = isActive
                      ? 0
                      : (index < _currentIndex ? -0.05 : 0.05);

                  return Transform.scale(
                    scale: scale,
                    child: Transform.rotate(
                      angle: tilt,
                      child: _buildImageCard(context, item, isActive),
                    ),
                  );
                },
                options: CarouselOptions(
                  height: 400,
                  enlargeCenterPage: true,
                  viewportFraction: 0.75,
                  autoPlay: true,
                  autoPlayInterval: const Duration(seconds: 4),
                  autoPlayAnimationDuration: const Duration(milliseconds: 900),
                  onPageChanged: (index, reason) {
                    setState(() => _currentIndex = index);
                  },
                ),
              ),
              const SizedBox(height: 10),
              // 🔹 Page indicator
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: featuredList.asMap().entries.map((entry) {
                  return Container(
                    width: _currentIndex == entry.key ? 12 : 8,
                    height: 8,
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _currentIndex == entry.key
                          ? Colors.greenAccent
                          : Colors.white38,
                    ),
                  );
                }).toList(),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildImageCard(
    BuildContext context,
    Map<String, dynamic> item,
    bool isActive,
  ) {
    final type = item["type"];

    String formatDate(String? dateStr) {
      if (dateStr == null || dateStr.isEmpty || dateStr == "0000-00-00") {
        return "";
      }
      try {
        final date = DateTime.parse(dateStr);
        return "${date.day}/${date.month}/${date.year}";
      } catch (_) {
        return "";
      }
    }

    String fromDate = "";
    String toDate = "";
    if (type == "event") {
      fromDate = formatDate(item["from_date"]);
      toDate = formatDate(item["to_date"]);
    } else if (type == "deal") {
      fromDate = formatDate(item["offer_start_date"]);
      toDate = formatDate(item["offer_end_date"]);
    }

    return GestureDetector(
      onTap: () {
        if (type == "event") {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => EventDetailsScreen(eventId: item['id']),
            ),
          );
        } else if (type == "deal") {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => DealsDetailsScreen(dealId: item['id']),
            ),
          );
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 400),
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: isActive
                  ? Colors.greenAccent.withOpacity(0.6)
                  : Colors.green.withOpacity(0.2),
              blurRadius: isActive ? 12 : 5,
              spreadRadius: isActive ? 2 : 1,
              offset: const Offset(3, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            children: [
              Image.network(
                item["img_path"] ?? '',
                height: double.infinity,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: Colors.grey[700],
                  child: const Icon(
                    Icons.broken_image,
                    color: Colors.white,
                    size: 40,
                  ),
                ),
              ),
              // Gradient overlay
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
                    children: [
                      Text(
                        item["title"] ?? "No Title",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item["slug"] ?? "",
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // 📅 Date tag
              if (fromDate.isNotEmpty && toDate.isNotEmpty)
                Positioned(
                  bottom: 70,
                  left: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.calendar_today,
                          color: Colors.white,
                          size: 16,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          "$fromDate → $toDate",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
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
  }
}
*/
/*
import 'dart:convert';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:events_feature/screens/deals_details_screen.dart';
import 'package:events_feature/screens/events_details_screen.dart';
import 'package:events_feature/utils/session_manager.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class FeaturedEvents extends StatefulWidget {
  const FeaturedEvents({super.key});

  @override
  State<FeaturedEvents> createState() => _FeaturedEventsState();
}

class _FeaturedEventsState extends State<FeaturedEvents> {
  final SessionManager _sessionManager = SessionManager();
  String? _authToken;
  int _currentIndex = 0;

  static const String _baseUrl =
      'https://white-labels-app-server.vercel.app/api/features/list?club_id=222';

  @override
  void initState() {
    super.initState();
    _loadAuthToken();
  }

  Future<void> _loadAuthToken() async {
    await _sessionManager.loadSession();
    setState(() {
      _authToken = _sessionManager.authToken;
    });
  }

  Future<Map<String, dynamic>> fetchFeaturedList() async {
    if (_authToken == null) {
      throw Exception("Auth token not available. Please log in again.");
    }

    final headers = {"x-auth-token": _authToken!};

    try {
      final response = await http.get(Uri.parse(_baseUrl), headers: headers);

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return responseData["data"] ?? {};
      } else {
        throw Exception(
          "Failed to load featured list (Status ${response.statusCode})",
        );
      }
    } catch (e, s) {
      debugPrint("❌ Error fetching featured list: $e\n$s");
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_authToken == null) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator(color: Colors.green)),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: FutureBuilder<Map<String, dynamic>>(
        future: fetchFeaturedList(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.green),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text(
                "Error: ${snapshot.error}",
                style: const TextStyle(color: Colors.red),
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                "No featured items available",
                style: TextStyle(color: Colors.white),
              ),
            );
          }

          final deals = List<Map<String, dynamic>>.from(
            snapshot.data!["deals"] ?? [],
          );
          final events = List<Map<String, dynamic>>.from(
            snapshot.data!["events"] ?? [],
          );

          final uniqueDeals = {for (var d in deals) d["id"]: d}.values.toList();

          final featuredList = [
            ...uniqueDeals.map((d) => {...d, "type": "deal"}),
            ...events.map((e) => {...e, "type": "event"}),
          ];

          return Column(
            children: [
              const SizedBox(height: 10),
              CarouselSlider.builder(
                itemCount: featuredList.length,
                itemBuilder: (context, index, realIdx) {
                  final item = featuredList[index];
                  return _buildImageCard(context, item);
                },
                options: CarouselOptions(
                  autoPlay: true,
                  enlargeCenterPage: true,
                  aspectRatio: 16 / 9,
                  viewportFraction: 0.9,
                  autoPlayInterval: const Duration(seconds: 4),
                  autoPlayAnimationDuration: const Duration(milliseconds: 1000),
                  onPageChanged: (index, reason) {
                    setState(() => _currentIndex = index);
                  },
                ),
              ),
              const SizedBox(height: 8),
              // 🔹 Page Indicator Dots
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: featuredList.asMap().entries.map((entry) {
                  return GestureDetector(
                    onTap: () => setState(() => _currentIndex = entry.key),
                    child: Container(
                      width: _currentIndex == entry.key ? 12.0 : 8.0,
                      height: 8.0,
                      margin: const EdgeInsets.symmetric(horizontal: 4.0),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _currentIndex == entry.key
                            ? Colors.greenAccent
                            : Colors.white38,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildImageCard(BuildContext context, Map<String, dynamic> item) {
    final type = item["type"];

    String formatDate(String? dateStr) {
      if (dateStr == null || dateStr.isEmpty || dateStr == "0000-00-00") {
        return "";
      }
      try {
        final date = DateTime.parse(dateStr);
        return "${date.day}/${date.month}/${date.year}";
      } catch (_) {
        return "";
      }
    }

    String fromDate = "";
    String toDate = "";
    if (type == "event") {
      fromDate = formatDate(item["from_date"]);
      toDate = formatDate(item["to_date"]);
    } else if (type == "deal") {
      fromDate = formatDate(item["offer_start_date"]);
      toDate = formatDate(item["offer_end_date"]);
    }

    return GestureDetector(
      onTap: () {
        if (type == "event") {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => EventDetailsScreen(eventId: item['id']),
            ),
          );
        } else if (type == "deal") {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => DealsDetailsScreen(dealId: item['id']),
            ),
          );
        }
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.green.withOpacity(0.4),
              blurRadius: 12,
              spreadRadius: 2,
              offset: const Offset(3, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            children: [
              Image.network(
                item["img_path"] ?? '',
                height: double.infinity,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: Colors.grey[700],
                  child: const Icon(
                    Icons.broken_image,
                    color: Colors.white,
                    size: 40,
                  ),
                ),
              ),
              // Gradient overlay
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
                        Colors.black.withOpacity(0.7),
                      ],
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item["title"] ?? "No Title",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item["slug"] ?? "",
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (fromDate.isNotEmpty && toDate.isNotEmpty)
                Positioned(
                  bottom: 70,
                  left: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.calendar_today,
                          color: Colors.white,
                          size: 16,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          "$fromDate → $toDate",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
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
  }
}
*/
/*
import 'dart:convert';
import 'package:events_feature/screens/deals_details_screen.dart';
import 'package:events_feature/screens/events_details_screen.dart';
import 'package:events_feature/utils/session_manager.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class FeaturedEvents extends StatefulWidget {
  const FeaturedEvents({super.key});

  @override
  State<FeaturedEvents> createState() => _FeaturedEventsState();
}

class _FeaturedEventsState extends State<FeaturedEvents> {
  final SessionManager _sessionManager = SessionManager();
  String? _authToken;

  static const String _baseUrl =
      'https://white-labels-app-server.vercel.app/api/features/list?club_id=222';

  @override
  void initState() {
    super.initState();
    _loadAuthToken();
  }

  Future<void> _loadAuthToken() async {
    await _sessionManager.loadSession();
    setState(() {
      _authToken = _sessionManager.authToken;
    });
  }

  Future<Map<String, dynamic>> fetchFeaturedList() async {
    if (_authToken == null) {
      throw Exception("Auth token not available. Please log in again.");
    }

    final headers = {"x-auth-token": _authToken!};

    try {
      final response = await http.get(Uri.parse(_baseUrl), headers: headers);

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return responseData["data"] ?? {};
      } else {
        throw Exception(
          "Failed to load featured list (Status ${response.statusCode})",
        );
      }
    } catch (e, s) {
      debugPrint("❌ Error fetching featured list: $e\n$s");
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_authToken == null) {
      // Wait for token to load
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator(color: Colors.green)),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: FutureBuilder<Map<String, dynamic>>(
        future: fetchFeaturedList(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.green),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text(
                "Error: ${snapshot.error}",
                style: const TextStyle(color: Colors.red),
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                "No featured items available",
                style: TextStyle(color: Colors.white),
              ),
            );
          }

          final deals = List<Map<String, dynamic>>.from(
            snapshot.data!["deals"] ?? [],
          );
          final events = List<Map<String, dynamic>>.from(
            snapshot.data!["events"] ?? [],
          );

          // Remove duplicate deals
          final uniqueDeals = {for (var d in deals) d["id"]: d}.values.toList();

          // Merge both
          final featuredList = [
            ...uniqueDeals.map((d) => {...d, "type": "deal"}),
            ...events.map((e) => {...e, "type": "event"}),
          ];

          return PageView.builder(
            itemCount: featuredList.length,
            controller: PageController(viewportFraction: 0.95),
            itemBuilder: (context, index) {
              final item = featuredList[index];
              return _buildImageCard(context, item);
            },
          );
        },
      ),
    );
  }

  Widget _buildImageCard(BuildContext context, Map<String, dynamic> item) {
    final type = item["type"];

    String formatDate(String? dateStr) {
      if (dateStr == null || dateStr.isEmpty || dateStr == "0000-00-00") {
        return "";
      }
      try {
        final date = DateTime.parse(dateStr);
        return "${date.day}/${date.month}/${date.year}";
      } catch (_) {
        return "";
      }
    }

    String fromDate = "";
    String toDate = "";
    if (type == "event") {
      fromDate = formatDate(item["from_date"]);
      toDate = formatDate(item["to_date"]);
    } else if (type == "deal") {
      fromDate = formatDate(item["offer_start_date"]);
      toDate = formatDate(item["offer_end_date"]);
    }

    return GestureDetector(
      onTap: () {
        if (type == "event") {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => EventDetailsScreen(eventId: item['id']),
            ),
          );
        } else if (type == "deal") {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => DealsDetailsScreen(dealId: item['id']),
            ),
          );
        }
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
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
                item["img_path"] ?? '',
                height: double.infinity,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: Colors.grey[700],
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
                        Colors.black.withOpacity(0.7),
                      ],
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item["title"] ?? "No Title",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item["slug"] ?? "",
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (fromDate.isNotEmpty && toDate.isNotEmpty)
                Positioned(
                  bottom: 70,
                  left: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.calendar_today,
                          color: Colors.white,
                          size: 16,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          "$fromDate → $toDate",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
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
  }
}
*/
/*
import 'dart:convert';
import 'package:events_feature/screens/deals_details_screen.dart';
import 'package:flutter/material.dart';
import 'package:events_feature/screens/events_details_screen.dart';
import 'package:http/http.dart' as http;

class FeaturedEvents extends StatelessWidget {
  const FeaturedEvents({super.key});

  static const String _baseUrl =
      'https://white-labels-app-server.vercel.app/api/features/list?club_id=222';

  static const Map<String, String> _headers = {
    "x-auth-token":
      authToken!,
  };

  Future<Map<String, dynamic>> fetchFeaturedList() async {
    try {
      final response = await http.get(Uri.parse(_baseUrl), headers: _headers);

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return responseData["data"] ?? {};
      } else {
        throw Exception("Failed to load featured list");
      }
    } catch (e, s) {
      debugPrint("Error fetching featured list: $e\n$s");
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: FutureBuilder<Map<String, dynamic>>(
        future: fetchFeaturedList(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Text(
                "Error: ${snapshot.error}",
                style: const TextStyle(color: Colors.red),
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                "No featured items available",
                style: TextStyle(color: Colors.white),
              ),
            );
          }

          // Extract lists
          final deals = List<Map<String, dynamic>>.from(
            snapshot.data!["deals"] ?? [],
          );
          final events = List<Map<String, dynamic>>.from(
            snapshot.data!["events"] ?? [],
          );

          // Remove duplicate deals based on id
          final uniqueDeals = {for (var d in deals) d["id"]: d}.values.toList();

          // Merge into one list
          final featuredList = [
            ...uniqueDeals.map((d) => {...d, "type": "deal"}),
            ...events.map((e) => {...e, "type": "event"}),
          ];

          return PageView.builder(
            itemCount: featuredList.length,
            controller: PageController(viewportFraction: 0.95),
            itemBuilder: (context, index) {
              final item = featuredList[index];
              return _buildImageCard(context, item);
            },
          );
        },
      ),
    );
  }

  Widget _buildImageCard(BuildContext context, Map<String, dynamic> item) {
    final type = item["type"]; // "deal" or "event"

    String formatDate(String? dateStr) {
      if (dateStr == null || dateStr.isEmpty || dateStr == "0000-00-00") {
        return "";
      }
      try {
        final date = DateTime.parse(dateStr);
        return "${date.day}/${date.month}/${date.year}";
      } catch (_) {
        return "";
      }
    }

    // 🗓️ Determine date range based on type
    String fromDate = "";
    String toDate = "";
    if (type == "event") {
      fromDate = formatDate(item["from_date"]);
      toDate = formatDate(item["to_date"]);
    } else if (type == "deal") {
      fromDate = formatDate(item["offer_start_date"]);
      toDate = formatDate(item["offer_end_date"]);
    }

    return GestureDetector(
      onTap: () {
        if (type == "event") {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => EventDetailsScreen(eventId: item['id']),
            ),
          );
        } else if (type == "deal") {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => DealsDetailsScreen(dealId: item['id']),
            ),
          );
        }
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
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
              // --- Background Image ---
              Image.network(
                item["img_path"] ?? '',
                height: double.infinity,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: Colors.grey[700],
                  child: const Icon(
                    Icons.broken_image,
                    color: Colors.white,
                    size: 40,
                  ),
                ),
              ),

              // --- Title & Slug ---
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
                        Colors.black.withOpacity(0.7),
                      ],
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item["title"] ?? "No Title",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item["slug"] ?? "",
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // --- 📅 Date Badge (Bottom-Left Corner) ---
              if (fromDate.isNotEmpty && toDate.isNotEmpty)
                Positioned(
                  bottom: 70, // slightly above the gradient
                  left: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.calendar_today,
                          color: Colors.white,
                          size: 16,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          "$fromDate → $toDate",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
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
  }
}
*/
