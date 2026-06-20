import 'dart:convert';
import 'package:events_feature/models/event_models.dart';
import 'package:events_feature/models/layout_model.dart';
import 'package:events_feature/models/tables_occupied.dart';
import 'package:events_feature/screens/table_summary_screen.dart';
import 'package:events_feature/utils/date_time_format.dart';
import 'package:events_feature/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:events_feature/utils/session_manager.dart';
import 'package:events_feature/models/seats_model.dart';
import 'package:html/parser.dart' as html_parser;
import 'package:events_feature/screens/table_summary_screen.dart';

class TableReservationPage extends StatefulWidget {
  final EventModel event;

  const TableReservationPage({
    super.key,
    required this.event,
  });

  @override
  State<TableReservationPage> createState() => _TableReservationPageState();
}

class _TableReservationPageState extends State<TableReservationPage> {
  EventSeatMapData? seatMap;
  List<String> selectedTables = [];
  String? authToken;
  bool isLoading = true;

  // Price popup
  String? _showingPriceLabel;
  String? _showingPriceValue;

  int? layoutId;

  List<Layout> layouts = [];

  @override
  void initState() {
    super.initState();
    _loadTokenAndFetch();
  }

  Future<void> _loadTokenAndFetch() async {
    final session = SessionManager();
    await session.loadSession();
    authToken = session.authToken;

    if (authToken == null || authToken!.isEmpty) {
      debugPrint("❌ No auth token found.");
      setState(() => isLoading = false);
      return;
    }
    fetchLayouts();
  }

  // fetch layouts
  Future<void> fetchLayouts() async {
    final String url =
        'https://white-labels-app-server.vercel.app/api/seatmaps/getLayouts?event_id=${widget.event.id}';

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'x-auth-token': authToken ?? "",
        },
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        final List<dynamic> data = jsonResponse['data'];

        layouts = data
            .map((layoutJson) =>
                Layout.fromJson(layoutJson as Map<String, dynamic>))
            .toList();

        if (data.isNotEmpty) {
          // Assuming the first layout is the one we want to use
          final layout = Layout.fromJson(data.first);
          setState(() {
            layoutId = layout.id;
          });
          await fetchSeatMap(layout.id);
        } else {
          debugPrint("❌ No layouts found for this event.");
          setState(() => isLoading = false);
        }
      } else {
        debugPrint("❌ Failed to fetch layouts: ${response.statusCode}");
        setState(() => isLoading = false);
      }
    } catch (e, s) {
      debugPrint("❌ Error fetching layouts: $e");
      debugPrint(s.toString());
      setState(() => isLoading = false);
    }
  }

  Future<void> fetchSeatMap(int layoutId) async {
    setState(() => isLoading = true);

    final url = Uri.parse(
      "https://white-labels-app-server.vercel.app/api/seatmaps/getEventMappedSeatmaps/?layout_id=$layoutId&event_id=${widget.event.id}",
    );

    try {
      final response = await http.get(
        url,
        headers: {"x-auth-token": authToken!},
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        final result = EventSeatMapResponse.fromJson(jsonResponse);

        setState(() {
          seatMap = result.data.isNotEmpty ? result.data.first : null;
          isLoading = false;
        });
      } else {
        debugPrint("❌ Failed to fetch seat map: ${response.statusCode}");
        setState(() => isLoading = false);
      }
    } catch (e, s) {
      debugPrint("❌ Error fetching seat map: $e");
      debugPrint(s.toString());
      setState(() => isLoading = false);
    }
  }

  void toggleSelection(SeatPoint table) {
    if (table.isBlocked == 1 || table.isBooked == 1) return;

    setState(() {
      if (selectedTables.contains(table.label)) {
        selectedTables.remove(table.label);
      } else {
        selectedTables.add(table.label);

        _showingPriceLabel = table.label;
        _showingPriceValue =
            table.minBilling.isNotEmpty ? "₹${table.minBilling}" : "No Price";

        Future.delayed(const Duration(seconds: 2), () {
          if (mounted && _showingPriceLabel == table.label) {
            setState(() {
              _showingPriceLabel = null;
              _showingPriceValue = null;
            });
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: CircularProgressIndicator(color: Colors.green),
        ),
      );
    }

    if (seatMap == null) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Text("No seat map available",
              style: TextStyle(color: Colors.white)),
        ),
      );
    }

    final allTables = seatMap!.seatMapJsonData;

    // Remove duplicates safely
    final Map<String, SeatPoint> uniqueMap = {
      for (var t in allTables) t.label: t,
    };

    final tables = uniqueMap.values.toList();

    if (tables.isEmpty) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Text("No tables found", style: TextStyle(color: Colors.white)),
        ),
      );
    }

    final minX = tables.map((t) => t.x).reduce((a, b) => a < b ? a : b);
    final minY = tables.map((t) => t.y).reduce((a, b) => a < b ? a : b);
    final maxX = tables.map((t) => t.x).reduce((a, b) => a > b ? a : b);
    final maxY = tables.map((t) => t.y).reduce((a, b) => a > b ? a : b);

    final double availableWidth = MediaQuery.of(context).size.width - 80;
    final double availableHeight = MediaQuery.of(context).size.height - 250;

    final double scaleX = availableWidth / (maxX - minX);
    final double scaleY = availableHeight / (maxY - minY);
    final double scale = scaleX < scaleY ? scaleX : scaleY;

    const double spacing = 20;
    double totalAmount = selectedTables.fold(
      0.0,
      (sum, label) {
        final t = tables.firstWhere((x) => x.label == label);
        return sum + (double.tryParse(t.minBilling) ?? 0.0);
      },
    );

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.event.title,
              style: const TextStyle(
                color: Color.fromARGB(255, 247, 216, 216),
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              widget.event.venue,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              "${formatDateTime((widget.event.fromDate).toString())} | ${formatDateTime((widget.event.startTime).toString())} Onwards",
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 12,
                decoration: TextDecoration.underline,
                decorationColor: Color.fromARGB(255, 230, 213, 213), // optional
                decorationThickness: 0.5,
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Wrap(
              spacing: 12.0,
              children: layouts.map((layout) {
                final isSelected = layoutId == layout.id;
                return ChoiceChip(
                  showCheckmark: false,
                  label: Text(" ${layout.title} "),
                  selected: isSelected,
                  // labelStyle: GoogleFonts.poppins(
                  //   color: isSelected ? Colors.black : Colors.white,
                  //   fontWeight: FontWeight.bold,
                  // ),
                  selectedColor: Colors.green,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() {
                        layoutId = layout.id;
                        fetchSeatMap(layout.id);
                      });
                      // Call the controller's method to handle the logic
                    }
                  },
                );
              }).toList(),
            ),
          ),
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.white24, // subtle white border
                  width: 1,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: ClipRRect(
                borderRadius:
                    BorderRadius.circular(12), // ensures content is clipped
                child: InteractiveViewer(
                  boundaryMargin: const EdgeInsets.all(100),
                  minScale: 0.5,
                  maxScale: 3,
                  child: Stack(
                    children: [
                      for (final table in tables)
                        Positioned(
                          left: (table.x - (minX)) * scale * 1.0598 +
                              (spacing * (scale)),
                          top: (table.y - (minY)) * scale * 1.98 +
                              (spacing * (scale)),
                          /*child: GestureDetector(
                            onTap: () {
                              toggleSelection(table);
                              showTableDetailsPopup(table);
                            },
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                AnimatedContainer(
                                  duration: const Duration(milliseconds: 250),
                                  width: (table.width * scale * 0.98)
                                      .clamp(30, 120),
                                  height: (table.height * scale * 0.9)
                                      .clamp(30, 120),
                                  decoration: BoxDecoration(
                                    gradient: _getTableGradient(table),
                                    borderRadius: BorderRadius.circular(
                                        table.cornerRadius),
                                    border: Border.all(
                                      color:
                                          selectedTables.contains(table.label)
                                              ? const Color.fromARGB(
                                                  255, 1, 119, 37)
                                              : Colors.grey,
                                      width:
                                          selectedTables.contains(table.label)
                                              ? 3
                                              : 1,
                                    ),
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    table.label,
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 10),
                                  ),
                                ),
                                if (_showingPriceLabel == table.label &&
                                    _showingPriceValue != null)
                                  Positioned(
                                    bottom: -25,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: Colors.black.withOpacity(0.8),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        _showingPriceValue!,
                                        style: const TextStyle(
                                            color: Colors.greenAccent,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ),
                              ],
                            ),*/
                          child: GestureDetector(
                            onTap: () {
                              toggleSelection(table);
                              showTableDetailsPopup(table);
                            },
                            child: Transform.rotate(
                              angle: table.rotationAngle *
                                  3.1415926535 /
                                  180, // degrees → radians
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  AnimatedContainer(
                                    duration: const Duration(milliseconds: 250),
                                    width: (table.width * scale * 1.5)
                                        .clamp(30, 120),
                                    height: (table.height * scale * 1.1)
                                        .clamp(30, 120),
                                    decoration: BoxDecoration(
                                      gradient: _getTableGradient(table),
                                      borderRadius: BorderRadius.circular(
                                          table.cornerRadius),
                                      border: Border.all(
                                        color:
                                            selectedTables.contains(table.label)
                                                ? const Color.fromARGB(
                                                    255, 1, 119, 37)
                                                : Colors.grey,
                                        width:
                                            selectedTables.contains(table.label)
                                                ? 2
                                                : 1,
                                      ),
                                    ),
                                    alignment: Alignment.center,
                                    child: Text(
                                      table.label,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 10,
                                      ),
                                    ),
                                  ),
                                  if (_showingPriceLabel == table.label &&
                                      _showingPriceValue != null)
                                    Positioned(
                                      bottom: -25,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: Colors.black.withOpacity(0.8),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          _showingPriceValue!,
                                          style: const TextStyle(
                                            color: Colors.greenAccent,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
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
          ),
          _buildLegendBar(),
          Container(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      selectedTables.isNotEmpty ? Colors.green : Colors.grey,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: selectedTables.isEmpty
                    ? null
                    : /*() {
                        debugPrint("Selected Tables: $selectedTables");
                      },*/
                    () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => TableSummaryScreen(
                                event: widget.event,
                                selectedTableObjects: selectedTables
                                    .map((tableLabel) => tables.firstWhere(
                                        (table) => table.label == tableLabel))
                                    .toList(),
                                totalAmount: totalAmount),
                          ),
                        );
                      },
                child: Text(
                  selectedTables.isEmpty
                      ? "Select a Table"
                      : "Reserve (${selectedTables.length}) Table(s)",
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  LinearGradient _getTableGradient(SeatPoint table) {
    if (table.isBlocked == 1) {
      return const LinearGradient(
        colors: [Color(0xFF6C757D), Color(0xFF343A40)],
      );
    } else if (table.isBooked == 1) {
      return const LinearGradient(
        colors: [Color(0xFFFF4B2B), Color(0xFF8B0000)],
      );
    } else if (selectedTables.contains(table.label)) {
      return const LinearGradient(
        colors: [Colors.greenAccent, Colors.green],
      );
    } else {
      return const LinearGradient(
        colors: [Colors.orange, Colors.blue],
      );
    }
  }

  Widget _buildLegendBar() {
    return Container(
      color: Colors.black,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _legendItem("Available", [Colors.orange, Colors.blue]),
          _legendItem(
              "Booked", [const Color(0xFFFF4B2B), const Color(0xFF8B0000)]),
          _legendItem(
              "Blocked", [const Color(0xFF6C757D), const Color(0xFF343A40)]),
          _legendItem("Selected", [Colors.green, Colors.lightGreenAccent]),
        ],
      ),
    );
  }

  Widget _legendItem(String label, List<Color> colors) {
    return Row(
      children: [
        Container(
          width: 22,
          height: 22,
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: colors),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: Colors.white, width: 0.8),
          ),
        ),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(color: Colors.white)),
      ],
    );
  }

  void showTableDetailsPopup(SeatPoint table) {
    print(table.inclusions);
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color.fromARGB(221, 37, 36, 36),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 50,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white30,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 10),

              /// Title
              Text(
                "Table ${table.label}",
                style: const TextStyle(
                  color: Colors.greenAccent,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 16),

              /// Chips Section
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  _chipItem("Table ID", table.id.toString()),
                  _chipItem("Price", "₹${table.minBilling}"),
                  //if (table.inclusions.isNotEmpty)
                  // _chipItem("Inclusions", (table.inclusions)),
                  _chipItem("Seats", "${table.seats} Seats"),
                ],
              ),

              Text(
                "Inclusions",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 6),

              ...showInclusions(table.inclusions),

              const SizedBox(height: 18),

              /// View Details Button
              /*  SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.greenAccent,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    "View Details",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),*/
            ],
          ),
        );
      },
    );
  }

  Widget _chipItem(String label, String value) {
    return Chip(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      backgroundColor: Colors.white10,
      side: const BorderSide(color: Colors.greenAccent),
      label: Text(
        "$label: $value",
        style: const TextStyle(color: Colors.white, fontSize: 13),
      ),
    );
  }

  Iterable<Widget> showInclusions(String inclusions) {
    final value = parseHtmlList(inclusions);

    return value.map((element) => Padding(
          padding: const EdgeInsets.only(left: 8),
          child: Text(
            element,
            style: const TextStyle(color: Colors.white),
          ),
        ));
  }
}



/*
import 'dart:convert';
import 'package:events_feature/models/event_models.dart';
import 'package:events_feature/models/layout_model.dart';
import 'package:events_feature/models/tables_occupied.dart';
import 'package:events_feature/utils/date_time_format.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:events_feature/utils/session_manager.dart';
import 'package:events_feature/models/seats_model.dart';

class TableReservationPage extends StatefulWidget {
  final EventModel event;

  const TableReservationPage({
    super.key,
    required this.event,
  });

  @override
  State<TableReservationPage> createState() => _TableReservationPageState();
}

class _TableReservationPageState extends State<TableReservationPage> {
  EventSeatMapData? seatMap;
  List<String> selectedTables = [];
  String? authToken;
  bool isLoading = true;

  // Price popup
  String? _showingPriceLabel;
  String? _showingPriceValue;

  int? layoutId;

  @override
  void initState() {
    super.initState();
    _loadTokenAndFetch();
  }

  Future<void> _loadTokenAndFetch() async {
    final session = SessionManager();
    await session.loadSession();
    authToken = session.authToken;

    if (authToken == null || authToken!.isEmpty) {
      debugPrint("❌ No auth token found.");
      setState(() => isLoading = false);
      return;
    }
    fetchLayouts();
  }

  // fetch layouts
  Future<void> fetchLayouts() async {
    final String url =
        'https://white-labels-app-server.vercel.app/api/seatmaps/getLayouts?event_id=${widget.event.id}';

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'x-auth-token': authToken ?? "",
        },
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        final List<dynamic> data = jsonResponse['data'];

        if (data.isNotEmpty) {
          // Assuming the first layout is the one we want to use
          final layout = Layout.fromJson(data.first);
          setState(() {
            layoutId = layout.id;
          });
          await fetchSeatMap(layout.id);
        } else {
          debugPrint("❌ No layouts found for this event.");
          setState(() => isLoading = false);
        }
      } else {
        debugPrint("❌ Failed to fetch layouts: ${response.statusCode}");
        setState(() => isLoading = false);
      }
    } catch (e, s) {
      debugPrint("❌ Error fetching layouts: $e");
      debugPrint(s.toString());
      setState(() => isLoading = false);
    }
  }

  Future<void> fetchSeatMap(int layoutId) async {
    setState(() => isLoading = true);

    final url = Uri.parse(
      "https://white-labels-app-server.vercel.app/api/seatmaps/getEventMappedSeatmaps/?layout_id=$layoutId&event_id=${widget.event.id}}",
    );

    try {
      final response = await http.get(
        url,
        headers: {"x-auth-token": authToken!},
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        final result = EventSeatMapResponse.fromJson(jsonResponse);

        setState(() {
          seatMap = result.data.isNotEmpty ? result.data.first : null;
          isLoading = false;
        });
      } else {
        debugPrint("❌ Failed to fetch seat map: ${response.statusCode}");
        setState(() => isLoading = false);
      }
    } catch (e, s) {
      debugPrint("❌ Error fetching seat map: $e");
      debugPrint(s.toString());
      setState(() => isLoading = false);
    }
  }

  void toggleSelection(SeatPoint table) {
    if (table.isBlocked == 1 || table.isBooked == 1) return;

    setState(() {
      if (selectedTables.contains(table.label)) {
        selectedTables.remove(table.label);
      } else {
        selectedTables.add(table.label);

        _showingPriceLabel = table.label;
        _showingPriceValue =
            table.minBilling.isNotEmpty ? "₹${table.minBilling}" : "No Price";

        Future.delayed(const Duration(seconds: 2), () {
          if (mounted && _showingPriceLabel == table.label) {
            setState(() {
              _showingPriceLabel = null;
              _showingPriceValue = null;
            });
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: CircularProgressIndicator(color: Colors.green),
        ),
      );
    }

    if (seatMap == null) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Text("No seat map available",
              style: TextStyle(color: Colors.white)),
        ),
      );
    }

    final allTables = seatMap!.seatMapJsonData;

    // Remove duplicates safely
    final Map<String, SeatPoint> uniqueMap = {
      for (var t in allTables) t.label: t,
    };

    final tables = uniqueMap.values.toList();

    if (tables.isEmpty) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Text("No tables found", style: TextStyle(color: Colors.white)),
        ),
      );
    }

    final minX = tables.map((t) => t.x).reduce((a, b) => a < b ? a : b);
    final minY = tables.map((t) => t.y).reduce((a, b) => a < b ? a : b);
    final maxX = tables.map((t) => t.x).reduce((a, b) => a > b ? a : b);
    final maxY = tables.map((t) => t.y).reduce((a, b) => a > b ? a : b);

    final double availableWidth = MediaQuery.of(context).size.width - 80;
    final double availableHeight = MediaQuery.of(context).size.height - 250;

    final double scaleX = availableWidth / (maxX - minX + 1);
    final double scaleY = availableHeight / (maxY - minY + 1);
    final double scale = scaleX < scaleY ? scaleX : scaleY;

    const double spacing = 12;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.event.title,
              style: const TextStyle(
                color: Color.fromARGB(255, 247, 216, 216),
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              widget.event.venue,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              "${formatDateTime((widget.event.fromDate).toString())} | ${formatDateTime((widget.event.startTime).toString())} Onwards",
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 12,
                decoration: TextDecoration.underline,
                decorationColor: Color.fromARGB(255, 230, 213, 213), // optional
                decorationThickness: 0.5,
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: InteractiveViewer(
              boundaryMargin: const EdgeInsets.all(100),
              minScale: 0.5,
              maxScale: 3,
              child: Stack(
                children: [
                  for (final table in tables)
                    Positioned(
                      left: (table.x - minX) * scale + spacing,
                      top: (table.y - minY) * scale + spacing,
                      child: GestureDetector(
                        onTap: () => toggleSelection(table),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 250),
                              width:
                                  (table.width * scale * 0.98).clamp(30, 120),
                              height:
                                  (table.height * scale * 0.9).clamp(30, 120),
                              decoration: BoxDecoration(
                                gradient: _getTableGradient(table),
                                borderRadius:
                                    BorderRadius.circular(table.cornerRadius),
                                border: Border.all(
                                  color: selectedTables.contains(table.label)
                                      ? const Color.fromARGB(255, 1, 119, 37)
                                      : Colors.grey,
                                  width: selectedTables.contains(table.label)
                                      ? 3
                                      : 1,
                                ),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                table.label,
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 10),
                              ),
                            ),
                            if (_showingPriceLabel == table.label &&
                                _showingPriceValue != null)
                              Positioned(
                                bottom: -25,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.8),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    _showingPriceValue!,
                                    style: const TextStyle(
                                        color: Colors.greenAccent,
                                        fontWeight: FontWeight.bold),
                                  ),
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
          _buildLegendBar(),
          Container(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      selectedTables.isNotEmpty ? Colors.green : Colors.grey,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: selectedTables.isEmpty
                    ? null
                    : () {
                        debugPrint("Selected Tables: $selectedTables");
                      },
                child: Text(
                  selectedTables.isEmpty
                      ? "Select a Table"
                      : "Reserve (${selectedTables.length}) Table(s)",
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  LinearGradient _getTableGradient(SeatPoint table) {
    if (table.isBlocked == 1) {
      return const LinearGradient(
        colors: [Color(0xFF6C757D), Color(0xFF343A40)],
      );
    } else if (table.isBooked == 1) {
      return const LinearGradient(
        colors: [Color(0xFFFF4B2B), Color(0xFF8B0000)],
      );
    } else if (selectedTables.contains(table.label)) {
      return const LinearGradient(
        colors: [Colors.greenAccent, Colors.green],
      );
    } else {
      return const LinearGradient(
        colors: [Colors.orange, Colors.blue],
      );
    }
  }

  Widget _buildLegendBar() {
    return Container(
      color: Colors.black,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _legendItem("Available", [Colors.orange, Colors.blue]),
          _legendItem(
              "Booked", [const Color(0xFFFF4B2B), const Color(0xFF8B0000)]),
          _legendItem(
              "Blocked", [const Color(0xFF6C757D), const Color(0xFF343A40)]),
          _legendItem("Selected", [Colors.green, Colors.lightGreenAccent]),
        ],
      ),
    );
  }

  Widget _legendItem(String label, List<Color> colors) {
    return Row(
      children: [
        Container(
          width: 22,
          height: 22,
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: colors),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: Colors.white, width: 0.8),
          ),
        ),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(color: Colors.white)),
      ],
    );
  }
}
*/

/*
import 'dart:convert';
import 'package:events_feature/models/event_models.dart';
import 'package:events_feature/models/layout_model.dart';
import 'package:events_feature/models/tables_occupied.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:events_feature/utils/session_manager.dart';
import 'package:events_feature/models/seats_model.dart';

class TableReservationPage extends StatefulWidget {
  final EventModel event;

  const TableReservationPage({
    super.key,
    required this.event,
  });

  @override
  State<TableReservationPage> createState() => _TableReservationPageState();
}

class _TableReservationPageState extends State<TableReservationPage> {
  EventSeatMapData? seatMap;
  List<String> selectedTables = [];
  String? authToken;
  bool isLoading = true;

  // Price popup
  String? _showingPriceLabel;
  String? _showingPriceValue;

  int? layoutId;

  @override
  void initState() {
    super.initState();
    _loadTokenAndFetch();
  }

  Future<void> _loadTokenAndFetch() async {
    final session = SessionManager();
    await session.loadSession();
    authToken = session.authToken;

    if (authToken == null || authToken!.isEmpty) {
      debugPrint("❌ No auth token found.");
      setState(() => isLoading = false);
      return;
    }
    fetchLayouts();
  }

  // fetch layouts
  Future<void> fetchLayouts() async {
    final String url =
        'https://white-labels-app-server.vercel.app/api/seatmaps/getLayouts?event_id=${widget.event.id}';

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'x-auth-token': authToken ?? "",
        },
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        final List<dynamic> data = jsonResponse['data'];

        if (data.isNotEmpty) {
          // Assuming the first layout is the one we want to use
          final layout = Layout.fromJson(data.first);
          setState(() {
            layoutId = layout.id;
          });
          await fetchSeatMap(layout.id);
        } else {
          debugPrint("❌ No layouts found for this event.");
          setState(() => isLoading = false);
        }
      } else {
        debugPrint("❌ Failed to fetch layouts: ${response.statusCode}");
        setState(() => isLoading = false);
      }
    } catch (e, s) {
      debugPrint("❌ Error fetching layouts: $e");
      debugPrint(s.toString());
      setState(() => isLoading = false);
    }
  }

  Future<void> fetchSeatMap(int layoutId) async {
    setState(() => isLoading = true);

    final url = Uri.parse(
      "https://white-labels-app-server.vercel.app/api/seatmaps/getEventMappedSeatmaps/?layout_id=$layoutId&event_id=${widget.event.id}}",
    );

    try {
      final response = await http.get(
        url,
        headers: {"x-auth-token": authToken!},
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        final result = EventSeatMapResponse.fromJson(jsonResponse);

        setState(() {
          seatMap = result.data.isNotEmpty ? result.data.first : null;
          isLoading = false;
        });
      } else {
        debugPrint("❌ Failed to fetch seat map: ${response.statusCode}");
        setState(() => isLoading = false);
      }
    } catch (e, s) {
      debugPrint("❌ Error fetching seat map: $e");
      debugPrint(s.toString());
      setState(() => isLoading = false);
    }
  }

  void toggleSelection(SeatPoint table) {
    if (table.isBlocked == 1 || table.isBooked == 1) return;

    setState(() {
      if (selectedTables.contains(table.label)) {
        selectedTables.remove(table.label);
      } else {
        selectedTables.add(table.label);

        _showingPriceLabel = table.label;
        _showingPriceValue =
            table.minBilling.isNotEmpty ? "₹${table.minBilling}" : "No Price";

        Future.delayed(const Duration(seconds: 2), () {
          if (mounted && _showingPriceLabel == table.label) {
            setState(() {
              _showingPriceLabel = null;
              _showingPriceValue = null;
            });
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: CircularProgressIndicator(color: Colors.green),
        ),
      );
    }

    if (seatMap == null) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Text("No seat map available",
              style: TextStyle(color: Colors.white)),
        ),
      );
    }

    final allTables = seatMap!.seatMapJsonData;

    // Remove duplicates safely
    final Map<String, SeatPoint> uniqueMap = {
      for (var t in allTables) t.label: t,
    };

    final tables = uniqueMap.values.toList();

    if (tables.isEmpty) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Text("No tables found", style: TextStyle(color: Colors.white)),
        ),
      );
    }

    final minX = tables.map((t) => t.x).reduce((a, b) => a < b ? a : b);
    final minY = tables.map((t) => t.y).reduce((a, b) => a < b ? a : b);
    final maxX = tables.map((t) => t.x).reduce((a, b) => a > b ? a : b);
    final maxY = tables.map((t) => t.y).reduce((a, b) => a > b ? a : b);

    final double availableWidth = MediaQuery.of(context).size.width - 80;
    final double availableHeight = MediaQuery.of(context).size.height - 250;

    final double scaleX = availableWidth / (maxX - minX + 1);
    final double scaleY = availableHeight / (maxY - minY + 1);
    final double scale = scaleX < scaleY ? scaleX : scaleY;

    const double spacing = 12;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("Table Bookings",
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.grey[900],
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Expanded(
            child: InteractiveViewer(
              boundaryMargin: const EdgeInsets.all(100),
              minScale: 0.5,
              maxScale: 3,
              child: Stack(
                children: [
                  for (final table in tables)
                    Positioned(
                      left: (table.x - minX) * scale + spacing,
                      top: (table.y - minY) * scale + spacing,
                      child: GestureDetector(
                        onTap: () => toggleSelection(table),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 250),
                              width:
                                  (table.width * scale * 0.98).clamp(30, 120),
                              height:
                                  (table.height * scale * 0.9).clamp(30, 120),
                              decoration: BoxDecoration(
                                gradient: _getTableGradient(table),
                                borderRadius:
                                    BorderRadius.circular(table.cornerRadius),
                                border: Border.all(
                                  color: selectedTables.contains(table.label)
                                      ? const Color.fromARGB(255, 2, 233, 71)
                                      : Colors.grey,
                                  width: selectedTables.contains(table.label)
                                      ? 3
                                      : 1,
                                ),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                table.label,
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 10),
                              ),
                            ),
                            if (_showingPriceLabel == table.label &&
                                _showingPriceValue != null)
                              Positioned(
                                bottom: -25,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.8),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    _showingPriceValue!,
                                    style: const TextStyle(
                                        color: Colors.greenAccent,
                                        fontWeight: FontWeight.bold),
                                  ),
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
          _buildLegendBar(),
          Container(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      selectedTables.isNotEmpty ? Colors.green : Colors.grey,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: selectedTables.isEmpty
                    ? null
                    : () {
                        debugPrint("Selected Tables: $selectedTables");
                      },
                child: Text(
                  selectedTables.isEmpty
                      ? "Select a Table"
                      : "Reserve (${selectedTables.length}) Table(s)",
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  LinearGradient _getTableGradient(SeatPoint table) {
    if (table.isBlocked == 1) {
      return const LinearGradient(
        colors: [Color(0xFF6C757D), Color(0xFF343A40)],
      );
    } else if (table.isBooked == 1) {
      return const LinearGradient(
        colors: [Color(0xFFFF4B2B), Color(0xFF8B0000)],
      );
    } else if (selectedTables.contains(table.label)) {
      return const LinearGradient(
        colors: [Colors.greenAccent, Colors.green],
      );
    } else {
      return const LinearGradient(
        colors: [Colors.orange, Colors.blue],
      );
    }
  }

  Widget _buildLegendBar() {
    return Container(
      color: Colors.black,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _legendItem("Available", [Colors.orange, Colors.blue]),
          _legendItem(
              "Booked", [const Color(0xFFFF4B2B), const Color(0xFF8B0000)]),
          _legendItem(
              "Blocked", [const Color(0xFF6C757D), const Color(0xFF343A40)]),
          _legendItem("Selected", [Colors.green, Colors.lightGreenAccent]),
        ],
      ),
    );
  }

  Widget _legendItem(String label, List<Color> colors) {
    return Row(
      children: [
        Container(
          width: 22,
          height: 22,
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: colors),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: Colors.white, width: 0.8),
          ),
        ),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(color: Colors.white)),
      ],
    );
  }
}



/*
import 'dart:convert';
import 'package:events_feature/models/event_models.dart';
import 'package:events_feature/models/layout_model.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:events_feature/utils/session_manager.dart';
import 'package:events_feature/models/seats_model.dart';
import 'package:events_feature/models/tables_occupied.dart';

class TableReservationPage extends StatefulWidget {
  final EventModel event;
  final Layout layoutID;


  const TableReservationPage({super.key,required this.event,required this.layoutID});

  @override
  State<TableReservationPage> createState() => _TableReservationPageState();
}

class _TableReservationPageState extends State<TableReservationPage> {
  EventSeatMapData? seatMap;
  List<String> selectedTables = [];
  String? authToken;
  bool isLoading = true;

  // 🔹 To show temporary price
  String? _showingPriceLabel;
  String? _showingPriceValue;

  @override
  void initState() {
    super.initState();
    _loadTokenAndFetch();
  }

  Future<void> _loadTokenAndFetch() async {
    final session = SessionManager();
    await session.loadSession();
    authToken = session.authToken;
    if (authToken == null || authToken!.isEmpty) {
      debugPrint("❌ No token found");
      return;
    }
    await fetchSeatMap();
  }

  Future<List<Layout>> fetchLayouts({
    required int clubId,
    required int eventId,
    required int layoutId,
  }) async {
    // Using your provided localhost URL
    final String url =
        'https://white-labels-app-server.vercel.app/api/seatmaps/getLayouts?event_id=$eventId';

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'x-auth-token': authToken ?? "",
        },
      );

      final data = jsonDecode(response.body)["data"];

      // Map the JSON list to a list of Layout objects
      return data
          .map(
            (layoutJson) => Layout.fromJson(layoutJson as Map<String, dynamic>),
          )
          .toList();
    } catch (e, s) {
      print(e);
      print(s);
      throw Exception('An unexpected error occurred: $e');
    }
  }

  Future<void> fetchSeatMap() async {
    setState(() => isLoading = true);
    final url = Uri.parse(
      "https://white-labels-app-server.vercel.app/api/seatmaps/getEventMappedSeatmaps/?layout_id=${widget.layoutID.id}&event_id=${widget.event.id}",
    );
    try {
      final response =
          await http.get(url, headers: {"x-auth-token": authToken!});
      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        final result = EventSeatMapResponse.fromJson(jsonResponse);
        if (result.data.isNotEmpty) {
          setState(() {
            seatMap = result.data.first;
            isLoading = false;
          });
        } else {
          debugPrint("⚠️ No seat map data found");
          setState(() => isLoading = false);
        }
      } else {
        debugPrint("❌ Failed to fetch seat map: ${response.statusCode}");
        setState(() => isLoading = false);
      }
    } catch (e, s) {
      debugPrint("❌ Error fetching seat map: $e");
      debugPrint(s.toString());
      setState(() => isLoading = false);
    }
  }

  /// Toggle table selection + show price temporarily
  void toggleSelection(SeatPoint table) {
    if (table.isBlocked == 1 || table.isBooked == 1) return;

    setState(() {
      if (selectedTables.contains(table.label)) {
        selectedTables.remove(table.label);
      } else {
        selectedTables.add(table.label);

        // ✅ Show price when selected
        _showingPriceLabel = table.label;
        _showingPriceValue = table.minBilling.isNotEmpty
            ? "₹${table.minBilling}"
            : "Price not available";

        // Hide after 2 seconds
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted && _showingPriceLabel == table.label) {
            setState(() {
              _showingPriceLabel = null;
              _showingPriceValue = null;
            });
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: CircularProgressIndicator(color: Colors.greenAccent),
        ),
      );
    }

    if (seatMap == null) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Text("No seat map available",
              style: TextStyle(color: Colors.white)),
        ),
      );
    }

    final allTables = seatMap!.seatMapJsonData;
    final Map<String, SeatPoint> uniqueMap = {};

    for (final t in allTables) {
      uniqueMap[t.label] = t;
    }
    final tables = uniqueMap.values.toList();

    final minX = tables.map((t) => t.x).reduce((a, b) => a < b ? a : b);
    final minY = tables.map((t) => t.y).reduce((a, b) => a < b ? a : b);
    final maxX = tables.map((t) => t.x).reduce((a, b) => a > b ? a : b);
    final maxY = tables.map((t) => t.y).reduce((a, b) => a > b ? a : b);

    final double availableWidth = MediaQuery.of(context).size.width - 80;
    final double availableHeight = MediaQuery.of(context).size.height - 250;
    final double scaleX = availableWidth / (maxX - minX);
    final double scaleY = availableHeight / (maxY - minY);
    final double scale = scaleX < scaleY ? scaleX : scaleY;
    const double spacing = 12;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text(
          "Table Bookings",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.grey[900],
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Expanded(
            child: InteractiveViewer(
              boundaryMargin: const EdgeInsets.all(200),
              minScale: 0.5,
              maxScale: 3,
              child: Stack(
                children: [
                  for (final table in tables)
                    Positioned(
                      left: (table.x - minX) * scale + spacing,
                      top: (table.y - minY) * scale + spacing,
                      child: GestureDetector(
                        onTap: () => toggleSelection(table),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // 🪑 Table widget
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 250),
                              width:
                                  (table.width * scale * 0.94).clamp(30, 120),
                              height:
                                  (table.height * scale * 0.9).clamp(30, 120),
                              decoration: BoxDecoration(
                                gradient: _getTableGradient(table),
                                borderRadius:
                                    BorderRadius.circular(table.cornerRadius),
                                border: Border.all(
                                  color: selectedTables.contains(table.label)
                                      ? const Color.fromARGB(255, 71, 133, 0)
                                      : Colors.grey,
                                  width: selectedTables.contains(table.label)
                                      ? 3
                                      : 1,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.4),
                                    blurRadius: 6,
                                    offset: const Offset(3, 3),
                                  ),
                                ],
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                table.label,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 10,
                                ),
                              ),
                            ),

                            // 💰 Temporary Price Text
                            if (_showingPriceLabel == table.label &&
                                _showingPriceValue != null)
                              Positioned(
                                bottom: -24,
                                child: AnimatedOpacity(
                                  opacity: 1,
                                  duration: const Duration(milliseconds: 300),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withOpacity(0.8),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      _showingPriceValue!,
                                      style: const TextStyle(
                                          color: Colors.greenAccent,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12),
                                    ),
                                  ),
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
          _buildLegendBar(),
          Container(
            color: Colors.black,
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      selectedTables.isNotEmpty ? Colors.green : Colors.grey,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: selectedTables.isEmpty
                    ? null
                    : () {
                        debugPrint("✅ Selected tables: $selectedTables");
                      },
                child: Text(
                  selectedTables.isEmpty
                      ? "Select a Table"
                      : "Reserve (${selectedTables.length}) Table/s",
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  LinearGradient _getTableGradient(SeatPoint table) {
    if (table.isBlocked == 1) {
      return const LinearGradient(
        colors: [Color(0xFF6C757D), Color(0xFF343A40)],
      );
    } else if (table.isBooked == 1) {
      return const LinearGradient(
        colors: [Color(0xFFFF4B2B), Color(0xFF8B0000)],
      );
    } else if (selectedTables.contains(table.label)) {
      return const LinearGradient(
        colors: [Colors.greenAccent, Colors.green],
      );
    } else {
      return const LinearGradient(
        colors: [Colors.orange, Colors.blue],
      );
    }
  }

  Widget _buildLegendBar() {
    return Container(
      color: Colors.black,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _legendItem("Available", [Colors.orange, Colors.blue]),
          _legendItem(
              "Booked", [const Color(0xFFFF4B2B), const Color(0xFF8B0000)]),
          _legendItem(
              "Blocked", [const Color(0xFF6C757D), const Color(0xFF343A40)]),
          _legendItem("Selected", [Colors.green, Colors.lightGreenAccent]),
        ],
      ),
    );
  }

  Widget _legendItem(String label, List<Color> colors) {
    return Row(
      children: [
        Container(
          width: 22,
          height: 22,
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: colors),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: Colors.white, width: 0.8),
          ),
        ),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(color: Colors.white, fontSize: 12)),
      ],
    );
  }
}
*/

*/

/*
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:events_feature/utils/session_manager.dart';
import 'package:events_feature/models/seats_model.dart'; // your new model file
import 'package:events_feature/models/tables_occupied.dart'; // your new model file

class TableReservationPage extends StatefulWidget {
  const TableReservationPage({super.key});

  @override
  State<TableReservationPage> createState() => _TableReservationPageState();
}

class _TableReservationPageState extends State<TableReservationPage> {
  EventSeatMapData? seatMap;
  List<String> selectedTables = [];
  String? authToken;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTokenAndFetch();
  }

  /// Load session and fetch seat map
  Future<void> _loadTokenAndFetch() async {
    final session = SessionManager();
    await session.loadSession();
    authToken = session.authToken;
    if (authToken == null || authToken!.isEmpty) {
      debugPrint("❌ No token found");
      return;
    }
    await fetchSeatMap();
  }

  /// Fetch seat map from API
  Future<void> fetchSeatMap() async {
    setState(() => isLoading = true);
    final url = Uri.parse(
      "https://white-labels-app-server.vercel.app/api/seatmaps/getEventMappedSeatmaps?layout_id=245&event_id=28635",
      //"https://white-labels-app-server.vercel.app/api/seatmaps/getLayouts?layout_id=${widget.EventSeatMapData.layoutId}&event_id=${widget.EventSeatMapData.eventId}",
    );
    try {
      final response =
          await http.get(url, headers: {"x-auth-token": authToken!});
      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        final result = EventSeatMapResponse.fromJson(jsonResponse);
        if (result.data.isNotEmpty) {
          setState(() {
            seatMap = result.data.first;
            isLoading = false;
          });
        } else {
          debugPrint("⚠️ No seat map data found");
          setState(() => isLoading = false);
        }
      } else {
        debugPrint("❌ Failed to fetch seat map: ${response.statusCode}");
        setState(() => isLoading = false);
      }
    } catch (e, s) {
      debugPrint("❌ Error fetching seat map: $e");
      debugPrint(s.toString());
      setState(() => isLoading = false);
    }
  }

  /// Toggle table selection
  void toggleSelection(SeatPoint table) {
    if (table.isBlocked == 1 || table.isBooked == 1)
      return; // cannot select blocked/booked
    setState(() {
      if (selectedTables.contains(table.label)) {
        selectedTables.remove(table.label);
      } else {
        selectedTables.add(table.label);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: CircularProgressIndicator(color: Colors.greenAccent),
        ),
      );
    }

    if (seatMap == null) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Text("No seat map available",
              style: TextStyle(color: Colors.white)),
        ),
      );
    }

    // final tables = seatMap!.seatMapJsonData;

    final allTables = seatMap!.seatMapJsonData;
    final Map<String, SeatPoint> uniqueMap = {};

// keep only one instance per label
    for (final t in allTables) {
      uniqueMap[t.label] = t;
    }
    final tables = uniqueMap.values.toList();

    // Normalize coordinates
    final minX = tables.map((t) => t.x).reduce((a, b) => a < b ? a : b);
    final minY = tables.map((t) => t.y).reduce((a, b) => a < b ? a : b);
    final maxX = tables.map((t) => t.x).reduce((a, b) => a > b ? a : b);
    final maxY = tables.map((t) => t.y).reduce((a, b) => a > b ? a : b);

    final double availableWidth = MediaQuery.of(context).size.width - 80;
    final double availableHeight = MediaQuery.of(context).size.height - 250;

    final double scaleX = availableWidth / (maxX - minX);
    final double scaleY = availableHeight / (maxY - minY);
    final double scale = scaleX < scaleY ? scaleX : scaleY;
    const double spacing = 12;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text(
          "Table Bookings",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Expanded(
            child: InteractiveViewer(
              boundaryMargin: const EdgeInsets.all(200),
              minScale: 0.5,
              maxScale: 3,
              child: Stack(
                children: [
                  for (final table in tables)
                    Positioned(
                      left: (table.x - minX) * scale + spacing,
                      top: (table.y - minY) * scale + spacing,
                      child: GestureDetector(
                        onTap: () => toggleSelection(table),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          width: (table.width * scale * 0.94).clamp(30, 120),
                          height: (table.height * scale * 0.9).clamp(30, 120),
                          decoration: BoxDecoration(
                            gradient: _getTableGradient(table),
                            borderRadius:
                                BorderRadius.circular(table.cornerRadius),
                            border: Border.all(
                              color: selectedTables.contains(table.label)
                                  ? Colors.greenAccent
                                  : Colors.grey,
                              width:
                                  selectedTables.contains(table.label) ? 3 : 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.4),
                                blurRadius: 6,
                                offset: const Offset(3, 3),
                              ),
                            ],
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            table.label,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),

          /// 🔹 Color Legend Bar
          _buildLegendBar(),

          /// 🔹 Bottom Reserve Button
          Container(
            color: Colors.black,
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      selectedTables.isNotEmpty ? Colors.green : Colors.grey,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: selectedTables.isEmpty
                    ? null
                    : () {
                        debugPrint("✅ Selected tables: $selectedTables");
                      },
                child: Text(
                  selectedTables.isEmpty
                      ? "Select a Table"
                      : "Reserve (${selectedTables.length}) Tables",
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 🔹 Table gradient based on status
  LinearGradient _getTableGradient(SeatPoint table) {
    if (table.isBlocked == 1) {
      // 🔴 Blocked
      return const LinearGradient(
        colors: [Color(0xFFFF4B2B), Color(0xFF8B0000)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    } else if (table.isBooked == 1) {
      // ⚫ Booked
      return const LinearGradient(
        colors: [Color(0xFF6C757D), Color(0xFF343A40)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    } else if (selectedTables.contains(table.label)) {
      // 🟢 Selected
      return const LinearGradient(
        colors: [Colors.greenAccent, Colors.green],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    } else {
      // 🟠 Available
      return const LinearGradient(
        colors: [Colors.orange, Colors.blue],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    }
  }

  /// 🔹 Legend bar widget
  Widget _buildLegendBar() {
    return Container(
      color: Colors.black,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _legendItem("Available", [Colors.orange, Colors.blue]),
          _legendItem(
              "Booked", [const Color(0xFF6C757D), const Color(0xFF343A40)]),
          _legendItem(
              "Blocked", [const Color(0xFFFF4B2B), const Color(0xFF8B0000)]),
          _legendItem("Selected", [Colors.greenAccent, Colors.green]),
        ],
      ),
    );
  }

  Widget _legendItem(String label, List<Color> colors) {
    return Row(
      children: [
        Container(
          width: 22,
          height: 22,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: colors,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: Colors.white, width: 0.8),
          ),
        ),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(color: Colors.white, fontSize: 12)),
      ],
    );
  }
}

*/

/*
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:events_feature/utils/session_manager.dart';
import 'package:events_feature/models/seats_model.dart'; // your new model file
import 'package:events_feature/models/tables_occupied.dart'; // your new model file

class TableReservationPage extends StatefulWidget {
  const TableReservationPage({super.key});

  @override
  State<TableReservationPage> createState() => _TableReservationPageState();
}

class _TableReservationPageState extends State<TableReservationPage> {
  EventSeatMapData? seatMap;
  List<String> selectedTables = [];
  String? authToken;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTokenAndFetch();
  }

  /// Load session and fetch seat map
  Future<void> _loadTokenAndFetch() async {
    final session = SessionManager();
    await session.loadSession();
    authToken = session.authToken;
    if (authToken == null || authToken!.isEmpty) {
      debugPrint("❌ No token found");
      return;
    }
    await fetchSeatMap();
  }

  /// Fetch seat map from API
  Future<void> fetchSeatMap() async {
    setState(() => isLoading = true);
    final url = Uri.parse(
      "https://white-labels-app-server.vercel.app/api/seatmaps/getEventMappedSeatmaps?layout_id=245&event_id=28635",
    );

    try {
      final response =
          await http.get(url, headers: {"x-auth-token": authToken!});
      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        final result = EventSeatMapResponse.fromJson(jsonResponse);
        if (result.data.isNotEmpty) {
          setState(() {
            seatMap = result.data.first;
            isLoading = false;
          });
        } else {
          debugPrint("⚠️ No seat map data found");
          setState(() => isLoading = false);
        }
      } else {
        debugPrint("❌ Failed to fetch seat map: ${response.statusCode}");
        setState(() => isLoading = false);
      }
    } catch (e, s) {
      debugPrint("❌ Error fetching seat map: $e");
      debugPrint(s.toString());
      setState(() => isLoading = false);
    }
  }

  /// Toggle table selection
  void toggleSelection(SeatPoint table) {
    if (table.isBlocked == 1 || table.isBooked == 1)
      return; // cannot select blocked/booked
    setState(() {
      if (selectedTables.contains(table.label)) {
        selectedTables.remove(table.label);
      } else {
        selectedTables.add(table.label);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: CircularProgressIndicator(color: Colors.greenAccent),
        ),
      );
    }

    if (seatMap == null) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Text("No seat map available",
              style: TextStyle(color: Colors.white)),
        ),
      );
    }

    final tables = seatMap!.seatMapJsonData;

    // Normalize coordinates
    final minX = tables.map((t) => t.x).reduce((a, b) => a < b ? a : b);
    final minY = tables.map((t) => t.y).reduce((a, b) => a < b ? a : b);
    final maxX = tables.map((t) => t.x).reduce((a, b) => a > b ? a : b);
    final maxY = tables.map((t) => t.y).reduce((a, b) => a > b ? a : b);

    final double availableWidth = MediaQuery.of(context).size.width - 80;
    final double availableHeight = MediaQuery.of(context).size.height - 200;

    final double scaleX = availableWidth / (maxX - minX);
    final double scaleY = availableHeight / (maxY - minY);
    final double scale = scaleX < scaleY ? scaleX : scaleY;
    const double spacing = 12;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text(
          "Table Bookings",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: InteractiveViewer(
        boundaryMargin: const EdgeInsets.all(200),
        minScale: 0.5,
        maxScale: 3,
        child: Stack(
          children: [
            for (final table in tables)
              Positioned(
                left: (table.x - minX) * scale + spacing,
                top: (table.y - minY) * scale + spacing,
                child: GestureDetector(
                  onTap: () => toggleSelection(table),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: (table.width * scale * 0.94).clamp(30, 120),
                    height: (table.height * scale * 0.9).clamp(30, 120),
                    decoration: BoxDecoration(
                      color: _getTableColor(table),
                      borderRadius: BorderRadius.circular(table.cornerRadius),
                      border: Border.all(
                        color: selectedTables.contains(table.label)
                            ? Colors.greenAccent
                            : Colors.grey,
                        width: selectedTables.contains(table.label) ? 3 : 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.4),
                          blurRadius: 6,
                          offset: const Offset(3, 3),
                        ),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      table.label,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        color: Colors.black,
        padding: const EdgeInsets.all(16),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor:
                selectedTables.isNotEmpty ? Colors.green : Colors.grey,
            foregroundColor: Colors.black,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onPressed: selectedTables.isEmpty
              ? null
              : () {
                  debugPrint("✅ Selected tables: $selectedTables");
                },
          child: Text(
            selectedTables.isEmpty
                ? "Select a Table"
                : "Reserve (${selectedTables.length}) Tables",
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  /// Color based on table status
  Color _getTableColor(SeatPoint table) {
    if (table.isBlocked == 1) {
      return Colors.blueGrey; // 🔴 Blocked
    } else if (table.isBooked == 1) {
      return Colors.red; // ⚫ Booked
    } else if (selectedTables.contains(table.label)) {
      return Colors.green; // 🟢 Selected
    } else {
      return Colors.purple.shade200; // 🟠 Available
    }
  }
}

*/




/*
import 'dart:convert';
import 'package:events_feature/models/seats_model.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:events_feature/utils/session_manager.dart';
import 'package:events_feature/models/floor_available.dart';

class TableReservationPage extends StatefulWidget {
  const TableReservationPage({super.key});

  @override
  State<TableReservationPage> createState() => _TableReservationPageState();
}

class _TableReservationPageState extends State<TableReservationPage> {
  SeatMapDetails? seatMapResponse;
  List<String> selectedTables = [];
  String? authToken;

  @override
  void initState() {
    super.initState();
    _loadTokenAndFetch();
  }

  /// 🔹 Step 1: Load token and fetch
  Future<void> _loadTokenAndFetch() async {
    final session = SessionManager();
    await session.loadSession();

    setState(() {
      authToken = session.authToken;
    });

    debugPrint("✅ Loaded Token: $authToken");

    if (authToken == null || authToken!.isEmpty) {
      debugPrint("❌ No token found.");
      return;
    }

    await fetchSeatMap();
  }

  /// 🔹 Step 2: Fetch Seat Map API
  Future<void> fetchSeatMap() async {
    final url = Uri.parse(
      "https://white-labels-app-server.vercel.app/api/seatmaps/getEventMappedSeatmaps?layout_id=245&event_id=28635",
    );

    try {
      final response = await http.get(
        url,
        headers: {
          "x-auth-token": authToken!,
        },
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        final List<dynamic> result = jsonResponse['data'];

        if (result.isNotEmpty) {
          setState(() {
            seatMapResponse =
                SeatMapDetails.fromJson(Map<String, dynamic>.from(result[0]));
          });
        }
      } else {
        debugPrint("❌ Failed to fetch seat map: ${response.statusCode}");
      }
    } catch (e, s) {
      debugPrint("❌ Error fetching seat map: $e");
      debugPrint(s.toString());
    }
  }

  /// 🔹 Step 3: Toggle table selection
  void toggleSelection(String label) {
    setState(() {
      if (selectedTables.contains(label)) {
        selectedTables.remove(label);
      } else {
        selectedTables.add(label);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = seatMapResponse == null;

    if (isLoading) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: CircularProgressIndicator(color: Colors.greenAccent),
        ),
      );
    }

    // ✅ Step 4: Get seats and remove duplicates
    List<Seat> tables = seatMapResponse?.seats ?? [];

    // Remove duplicates by label (if two tables share the same label)
    final seenLabels = <String>{};
    tables = tables.where((t) {
      final label = t.label ?? '';
      if (label.isEmpty) return true;
      if (seenLabels.contains(label)) return false;
      seenLabels.add(label);
      return true;
    }).toList();

    // Optionally: remove duplicates by coordinate positions
    final seenCoords = <String>{};
    tables = tables.where((t) {
      final key = "${t.x}_${t.y}";
      if (seenCoords.contains(key)) return false;
      seenCoords.add(key);
      return true;
    }).toList();

    // ✅ Layout normalization
    final minX = tables.map((t) => t.x).reduce((a, b) => a < b ? a : b);
    final minY = tables.map((t) => t.y).reduce((a, b) => a < b ? a : b);
    final maxX = tables.map((t) => t.x).reduce((a, b) => a > b ? a : b);
    final maxY = tables.map((t) => t.y).reduce((a, b) => a > b ? a : b);

    final double availableWidth = MediaQuery.of(context).size.width - 80;
    final double availableHeight = MediaQuery.of(context).size.height - 200;

    final double scaleX = availableWidth / (maxX - minX);
    final double scaleY = availableHeight / (maxY - minY);
    final double scale = scaleX < scaleY ? scaleX : scaleY;
    const double spacing = 12;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text(
          "Table Bookings",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: InteractiveViewer(
        boundaryMargin: const EdgeInsets.all(200),
        minScale: 0.5,
        maxScale: 3,
        child: Stack(
          children: [
            for (final table in tables)
              Positioned(
                left: (table.x - minX) * scale + spacing,
                top: (table.y - minY) * scale + spacing,
                child: GestureDetector(
                  onTap: () => toggleSelection(table.label ?? "no label"),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: (table.width * scale * 0.94).clamp(30, 120),
                    height: (table.height * scale * 0.9).clamp(30, 120),
                    decoration: BoxDecoration(
                      gradient: selectedTables.contains(table.label)
                          ? const LinearGradient(
                              colors: [Colors.greenAccent, Colors.green],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            )
                          : const LinearGradient(
                              colors: [Colors.orange, Colors.blue],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                      borderRadius:
                          BorderRadius.circular(table.cornerRadius ?? 8),
                      border: Border.all(
                        color: selectedTables.contains(table.label)
                            ? Colors.green
                            : Colors.grey,
                        width: selectedTables.contains(table.label) ? 3 : 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.4),
                          blurRadius: 6,
                          offset: const Offset(3, 3),
                        ),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      table.label ?? "No Label",
                      style: TextStyle(
                        color: selectedTables.contains(table.label)
                            ? Colors.black
                            : Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        color: Colors.black,
        padding: const EdgeInsets.all(16),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor:
                selectedTables.isNotEmpty ? Colors.green : Colors.blue,
            foregroundColor: Colors.black,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onPressed: selectedTables.isEmpty
              ? null
              : () {
                  debugPrint("✅ Selected tables: $selectedTables");
                  // TODO: Navigate to reservation summary
                },
          child: Text(
            selectedTables.isEmpty
                ? "Select a Table"
                : "Reserve (${selectedTables.length}) Tables",
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}
*/