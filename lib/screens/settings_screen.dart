import 'dart:convert';
import 'package:events_feature/models/selected_orders.dart';
import 'package:events_feature/screens/customer_support_screen.dart';
import 'package:events_feature/screens/edit_profile_page.dart';
import 'package:events_feature/screens/login_page.dart';
import 'package:events_feature/screens/logout_page.dart';
import 'package:events_feature/utils/date_time_format.dart';
import 'package:events_feature/utils/session_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:http/http.dart' as http;

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String selected = "Events";
  final SessionManager _sessionManager = SessionManager();

  String? _name;
  String? _email;
  String? _phone;
  bool _isLoading = true;
  bool _isLoggedIn = false;
  late Future<EventsResponse> _futureOrders;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    await _loadUserData();
    _futureOrders = fetchOrders();
  }

  Future<void> _loadUserData() async {
    await _sessionManager.loadSession();
    setState(() {
      _name = _sessionManager.userName ?? "";
      _email = _sessionManager.userEmail ?? "";
      _phone = _sessionManager.userPhone ?? "";
      _isLoggedIn = _sessionManager.authToken != null;
      _isLoading = false;
    });
  }

  Future<EventsResponse> fetchOrders() async {
    await _sessionManager.loadSession();
    const url = "https://white-labels-app-server.vercel.app/api/orders/list";

    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'x-auth-token': _sessionManager.authToken ?? "",
      },
    );

    if (response.statusCode == 200) {
      return EventsResponse.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load orders');
    }
  }

  void _changeTab(String label) {
    setState(() {
      selected = label;
    });
  }

  // ⚙️ Show Settings Bottom Sheet
  void _showSettingsSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey[900],
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.grey[700],
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            if (!_isLoggedIn)
              ListTile(
                leading: const Icon(Icons.login, color: Colors.greenAccent),
                title: const Text(
                  "Login",
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () {
                  Navigator.pop(context);
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.grey[900],
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(20),
                      ),
                    ),
                    builder: (context) => const LoginScreen(),
                  ).whenComplete(() => _loadUserData());
                },
              ),
            if (_isLoggedIn)
              ListTile(
                leading: const Icon(Icons.edit, color: Colors.greenAccent),
                title: const Text(
                  "Edit Profile",
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () {
                  Navigator.pop(context);
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.grey[850],
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(20),
                      ),
                    ),
                    builder: (context) => const EditProfilePage(),
                  ).whenComplete(() => _loadUserData());
                },
              ),
            if (_isLoggedIn)
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.redAccent),
                title: const Text(
                  "Logout",
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () {
                  Navigator.pop(context);
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.grey[850],
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(20),
                      ),
                    ),
                    builder: (context) => const LogoutPage(),
                  ).whenComplete(() => _loadUserData());
                },
              ),
            if (_isLoggedIn || !_isLoggedIn)
              ListTile(
                leading: const Icon(Icons.support_agent, color: Colors.white70),
                title: const Text(
                  "Customer Support",
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () {
                  Navigator.pop(context);
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.grey[850],
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(20),
                      ),
                    ),
                    builder: (context) => const CustomerSupportPage(),
                  ).whenComplete(() => _loadUserData());
                },
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator(color: Colors.green)),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text(
          "Profile",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.grey[900],
        automaticallyImplyLeading: true,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white),
            onPressed: () => _showSettingsSheet(context),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProfileHeader(),
            //    const SizedBox(height: 20),
            _buildTabs(),
            const SizedBox(height: 10),
            Expanded(child: _buildOrdersList()),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          CircleAvatar(
            radius: 35,
            backgroundColor: Colors.green,
            child: Text(
              _name!.isNotEmpty ? _name![0].toUpperCase() : "?",
              style: const TextStyle(fontSize: 22, color: Colors.white),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _name ?? "",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _email ?? "",
                  style: const TextStyle(color: Colors.white70),
                ),
                Text(
                  _phone ?? "",
                  style: const TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabs() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(child: _buildTabButton("Events")),
          const SizedBox(width: 10),
          Expanded(child: _buildTabButton("Deals")),
          const SizedBox(width: 10),
          Expanded(child: _buildTabButton("Table Bookings")),
        ],
      ),
    );
  }

  Widget _buildTabButton(String label) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: selected == label ? Colors.green : Colors.transparent,
        foregroundColor: selected == label ? Colors.black : Colors.white,
        side: const BorderSide(color: Colors.white54),
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      onPressed: () => _changeTab(label),
      child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildOrdersList() {
    return FutureBuilder<EventsResponse>(
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
          return Center(
            child: Text(
              "No ${selected.toLowerCase()} found.",
              style: const TextStyle(color: Colors.white70),
            ),
          );
        }

        final List<EventData> allOrders = snapshot.data!.data;
        List<EventData> filteredOrders = [];

        if (selected == "Events") {
          filteredOrders = allOrders
              .where(
                (o) =>
                    o.name?.toLowerCase().contains("tickets") == true ||
                    o.identityType?.toLowerCase().contains("event") == true,
              )
              .toList();
        } else if (selected == "Deals") {
          filteredOrders = allOrders
              .where(
                (o) =>
                    o.name?.toLowerCase().contains("deals") == true ||
                    o.identityType?.toLowerCase().contains("deal") == true,
              )
              .toList();
        } else if (selected == "Table Bookings") {
          filteredOrders = allOrders
              .where(
                (o) =>
                    o.name?.toLowerCase().contains("tickets") == true ||
                    o.identityType?.toLowerCase().contains("table") == true,
              )
              .toList();
        }

        if (filteredOrders.isEmpty) {
          return Center(
            child: Text(
              "No ${selected.toLowerCase()} found.",
              style: const TextStyle(color: Colors.white70),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          itemCount: filteredOrders.length,
          itemBuilder: (context, index) {
            final order = filteredOrders[index];

            if (selected == "Events") {
              return _eventCard(order);
            } else if (selected == "Deals") {
              return _dealCard(order);
            } else {
              return _tableCard(order);
            }
          },
        );
      },
    );
  }

  // 🎟️ EVENT CARD
  Widget _eventCard(EventData order) => Card(
        color: Colors.grey[900],
        margin: const EdgeInsets.symmetric(vertical: 10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: Colors.greenAccent.withOpacity(0.3)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 🖼️ Event Image
              if (order.imgPath != null && order.imgPath!.isNotEmpty)
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(
                    order.imgPath!,
                    height: 180,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      height: 180,
                      color: Colors.grey[800],
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.broken_image,
                        color: Colors.white54,
                        size: 50,
                      ),
                    ),
                  ),
                ),

              const SizedBox(height: 12),

              // 🏷️ Title
              Text(
                order.title ?? "",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),

              // const SizedBox(height: 6),

              // 📜 Description
              Html(
                data: order.description ?? "",
                style: {
                  "body": Style(
                    color: Colors.white70,
                    fontSize: FontSize(15),
                    lineHeight: LineHeight(1.4),
                    textAlign: TextAlign.justify,
                    maxLines: 2,
                    textOverflow: TextOverflow.ellipsis,
                  ),
                },
              ),

              //const SizedBox(height: 8),

              // 🧾 Quantity & Price Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Qty: ${order.qty ?? 0}",
                    style: const TextStyle(color: Colors.white),
                  ),
                  Text(
                    "₹${order.totalPriceWithTaxes?.toStringAsFixed(2) ?? '0.00'}",
                    style: const TextStyle(
                      color: Colors.greenAccent,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),

              //const SizedBox(height: 8),

              // ⏰ Date Range
              Text(
                "${formatDateTime(order.fromDate.toString())} → ${formatDateTime(order.toDate.toString())}",
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      );

  // 💰 DEAL CARD
  Widget _dealCard(EventData order) => Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: Colors.grey[850],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.greenAccent.withOpacity(0.3)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ✅ Image
              if (order.imgPath != null && order.imgPath!.isNotEmpty)
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    order.imgPath!,
                    width: double.infinity,
                    height: 180,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      height: 180,
                      color: Colors.grey[700],
                      child: const Center(
                        child: Icon(
                          Icons.broken_image,
                          color: Colors.white70,
                          size: 50,
                        ),
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: 8),
              // ✅ Title
              Text(
                order.title ?? "",
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),

              const SizedBox(height: 4),
              // ✅ Date (fromDate → toDate)
              Text(
                "${formatDateTime(order.fromDate.toString())} → ${formatDateTime(order.toDate.toString())}",
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              // ✅ Price
              const SizedBox(height: 8),
              // ✅ Qty and Price on same line
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Qty: ${order.qty ?? 0}",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    "₹${order.totalPriceWithTaxes?.toStringAsFixed(2) ?? '0.00'}",
                    style: const TextStyle(
                      color: Colors.greenAccent,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );

  // 🍽️ TABLE BOOKING CARD
  /* Widget _tableCard(EventData order) => Container(
    margin: const EdgeInsets.symmetric(vertical: 8),
    decoration: BoxDecoration(
      color: Colors.grey[850],
      borderRadius: BorderRadius.circular(12),
      //border: Border.all(color: Colors.white24),
      border: Border.all(color: Colors.greenAccent.withOpacity(0.3)),
    ),
    child: 
    if (order.imgPath != null && order.imgPath!.isNotEmpty)
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                order.imgPath!,
                height: 180,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 180,
                  color: Colors.grey[800],
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.broken_image,
                    color: Colors.white54,
                    size: 50,
                  ),
                ),
              ),
            ),
    
    const SizedBox(height: 12),
    
    
    
    ListTile(
      leading: const Icon(Icons.table_bar, color: Colors.orangeAccent),
      title: Text(
        "Table ${order.tableNumber?.isNotEmpty == true ? order.tableNumber : 'N/A'}",
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
      subtitle: Html(
        data:
            "${formatDateTime((order.fromDate).toString())} ->${formatDateTime((order.toDate).toString())}",
        style: {
          "body": Style(
            color: Colors.white70,
            fontSize: FontSize(15),
            lineHeight: LineHeight(1.4),
          ),
        },
      ),
      trailing: Text(
        "₹${order.totalPriceWithTaxes?.toStringAsFixed(2) ?? '0.00'}",
        style: const TextStyle(
          color: Colors.orangeAccent,
          fontWeight: FontWeight.bold,
        ),
      ),
    ),
  );*/
  Widget _tableCard(EventData order) => Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: Colors.grey[850],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.greenAccent.withOpacity(0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ✅ Image if available
            if (order.imgPath != null && order.imgPath!.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  order.imgPath!,
                  height: 180,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    height: 180,
                    color: Colors.grey[800],
                    alignment: Alignment.center,
                    child: const Icon(
                      Icons.broken_image,
                      color: Colors.white54,
                      size: 50,
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 12),
            // ✅ Table info
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Table ${order.tableNumber?.isNotEmpty == true ? order.tableNumber : 'N/A'}",
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "${formatDateTime(order.fromDate.toString())} → ${formatDateTime(order.toDate.toString())}",
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    "₹${order.totalPriceWithTaxes?.toStringAsFixed(2) ?? '0.00'}",
                    style: const TextStyle(
                      color: Colors.greenAccent,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      );
}


/*
import 'dart:convert';
import 'package:events_feature/models/selected_events_deals_model.dart';
import 'package:events_feature/models/selected_orders.dart';
import 'package:events_feature/screens/edit_profile_page.dart';
import 'package:events_feature/screens/login_page.dart';
import 'package:events_feature/screens/logout_page.dart';
import 'package:events_feature/utils/date_time_format.dart';
import 'package:events_feature/utils/session_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:http/http.dart' as http;

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String selected = "Events";
  final SessionManager _sessionManager = SessionManager();

  String? _name;
  String? _email;
  String? _phone;
  bool _isLoading = true;
  bool _isLoggedIn = false;
  late Future<EventsResponse> _futureOrders;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    await _loadUserData();
    _futureOrders = fetchOrders();
  }

  Future<void> _loadUserData() async {
    await _sessionManager.loadSession();
    setState(() {
      _name = _sessionManager.userName ?? "";
      _email = _sessionManager.userEmail ?? "";
      _phone = _sessionManager.userPhone ?? "";
      _isLoggedIn = _sessionManager.authToken != null;
      _isLoading = false;
    });
  }

  Future<EventsResponse> fetchOrders() async {
    await _sessionManager.loadSession();
    const url = "https://white-labels-app-server.vercel.app/api/orders/list";

    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'x-auth-token': _sessionManager.authToken ?? "",
      },
    );

    if (response.statusCode == 200) {
      return EventsResponse.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load orders');
    }
  }

  void _changeTab(String label) {
    setState(() {
      selected = label;
    });
  }

  // ✅ Show Settings Bottom Sheet
  void _showSettingsSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey[900],
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.grey[700],
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            if (!_isLoggedIn)
              ListTile(
                leading: const Icon(Icons.login, color: Colors.greenAccent),
                title: const Text("Login",
                    style: TextStyle(color: Colors.white)),
                trailing:
                    const Icon(Icons.arrow_forward_ios, color: Colors.white70),
                onTap: () {
                  Navigator.pop(context);
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.grey[900],
                    shape: const RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(20)),
                    ),
                    builder: (context) => const LoginScreen(),
                  ).whenComplete(() => _loadUserData());
                },
              ),
            if (_isLoggedIn)
              ListTile(
                leading: const Icon(Icons.edit, color: Colors.greenAccent),
                title: const Text("Edit Profile",
                    style: TextStyle(color: Colors.white)),
                trailing:
                    const Icon(Icons.arrow_forward_ios, color: Colors.white70),
                onTap: () {
                  Navigator.pop(context);
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.grey[850],
                    shape: const RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(20)),
                    ),
                    builder: (context) => const EditProfilePage(),
                  ).whenComplete(() => _loadUserData());
                },
              ),
            if (_isLoggedIn)
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.redAccent),
                title: const Text("Logout",
                    style: TextStyle(color: Colors.white)),
                trailing:
                    const Icon(Icons.arrow_forward_ios, color: Colors.white70),
                onTap: () {
                  Navigator.pop(context);
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.grey[850],
                    shape: const RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(20)),
                    ),
                    builder: (context) => const LogoutPage(),
                  ).whenComplete(() => _loadUserData());
                },
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: CircularProgressIndicator(color: Colors.green),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text(
          "Profile",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.grey[900],
        automaticallyImplyLeading: false,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white),
            onPressed: () => _showSettingsSheet(context),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProfileHeader(),
            const SizedBox(height: 20),
            _buildTabs(),
            const SizedBox(height: 16),
            Expanded(child: _buildOrdersList()),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          CircleAvatar(
            radius: 35,
            backgroundColor: Colors.green,
            child: Text(
              _name!.isNotEmpty ? _name![0].toUpperCase() : "?",
              style: const TextStyle(fontSize: 22, color: Colors.white),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _name ?? "",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _email ?? "",
                  style: const TextStyle(color: Colors.white70),
                ),
                Text(
                  _phone ?? "",
                  style: const TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabs() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(child: _buildTabButton("Events")),
          const SizedBox(width: 10),
          Expanded(child: _buildTabButton("Deals")),
          const SizedBox(width: 10),
          Expanded(child: _buildTabButton("Table Bookings")),
        ],
      ),
    );
  }

  Widget _buildTabButton(String label) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: selected == label ? Colors.green : Colors.transparent,
        foregroundColor: selected == label ? Colors.black : Colors.white,
        side: const BorderSide(color: Colors.white54),
        padding: const EdgeInsets.symmetric(vertical: 14),
      ),
      onPressed: () => _changeTab(label),
      child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildOrdersList() {
    return FutureBuilder<EventsResponse>(
      future: _futureOrders,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
              child: CircularProgressIndicator(color: Colors.green));
        } else if (snapshot.hasError) {
          return Center(
              child: Text("Error: ${snapshot.error}",
                  style: const TextStyle(color: Colors.redAccent)));
        } else if (!snapshot.hasData || snapshot.data!.data.isEmpty) {
          return Center(
            child: Text("No ${selected.toLowerCase()} found.",
                style: const TextStyle(color: Colors.white70)),
          );
        }

        final allOrders = snapshot.data!.data;
        List<EventsResponse> filteredOrders = [];

        // ✅ Filter logic
        if (selected == "Events") {
          filteredOrders = allOrders
              .where((order) =>
                  order.name?.toLowerCase() == "tickets" ||
                  order.name?.toLowerCase() == "event")
              .toList();
        } else if (selected == "Deals") {
          filteredOrders = allOrders
              .where(
                  (order) => order.name?.toLowerCase() == "deals")
              .toList();
        } else if (selected == "Table Bookings") {
          filteredOrders = allOrders
              .where((order) =>
                  order.name?.toLowerCase() == "table" ||
                  order.name?.toLowerCase() == "table_booking")
              .toList();
        }

        if (filteredOrders.isEmpty) {
          return Center(
            child: Text("No ${selected.toLowerCase()} found.",
                style: const TextStyle(color: Colors.white70)),
          );
        }

        // ✅ Cards by category
        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          itemCount: filteredOrders.length,
          itemBuilder: (context, index) {
            final order = filteredOrders[index];

            if (selected == "Events") {
              return _eventCard(order);
            } else if (selected == "Deals") {
              return _dealCard(order);
            } else {
              return _tableCard(order);
            }
          },
        );
      },
    );
  }

  // 🎟️ EVENT CARD
  Widget _eventCard(EventsResponse order) => Card(
        color: Colors.grey[900],
        margin: const EdgeInsets.symmetric(vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: ListTile(
          contentPadding: const EdgeInsets.all(12),
          title: Text(order.title ?? "",
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold)),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 6),
              Html(
                data: order.description ?? "",
                style: {
                  "body": Style(
                    color: Colors.white70,
                    fontSize: FontSize(15),
                    lineHeight: LineHeight(1.4),
                    textAlign: TextAlign.justify,
                  ),
                },
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Qty: ${order.qty ?? 0}",
                      style: const TextStyle(color: Colors.white)),
                  Text("₹${order.totalPriceWithTaxes?.toStringAsFixed(2) ?? '0.00'}",
                      style: const TextStyle(
                          color: Colors.greenAccent,
                          fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                "${formatDateTime(order.fromDate)} → ${formatDateTime(order.toDate)}",
                style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      );

  // 💰 DEAL CARD
  Widget _dealCard(EventsResponse order) => Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: Colors.grey[850],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.greenAccent.withOpacity(0.3)),
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.all(12),
          leading: const Icon(Icons.local_offer, color: Colors.greenAccent),
          title: Text(order.title ?? "",
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold)),
          subtitle: Html(
            data: order.description ?? "",
            style: {
              "body": Style(
                color: Colors.white70,
                fontSize: FontSize(15),
                lineHeight: LineHeight(1.4),
                textAlign: TextAlign.justify,
              ),
            },
          ),
          trailing: Text(
            "₹${order.totalPriceWithTaxes?.toStringAsFixed(2) ?? '0.00'}",
            style: const TextStyle(
                color: Colors.greenAccent, fontWeight: FontWeight.bold),
          ),
        ),
      );

  // 🍽️ TABLE BOOKING CARD
  Widget _tableCard(EventsResponse order) => Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: Colors.grey[850],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white24),
        ),
        child: ListTile(
          leading: const Icon(Icons.table_bar, color: Colors.orangeAccent),
          title: Text(
            "Table ${order.tableNumber?.isNotEmpty == true ? order.tableNumber : 'N/A'}",
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold),
          ),
          subtitle: Html(
            data:
                "From <strong>${formatDateTime(order.fromDate)}</strong> to <strong>${formatDateTime(order.toDate)}</strong>",
            style: {
              "body": Style(
                color: Colors.white70,
                fontSize: FontSize(15),
                lineHeight: LineHeight(1.4),
              ),
            },
          ),
          trailing: Text(
            "₹${order.totalPriceWithTaxes?.toStringAsFixed(2) ?? '0.00'}",
            style: const TextStyle(
                color: Colors.orangeAccent, fontWeight: FontWeight.bold),
          ),
        ),
      );
}

*/



/*
import 'dart:convert';
import 'package:events_feature/models/selected_orders.dart';
import 'package:events_feature/screens/edit_profile_page.dart';
import 'package:events_feature/screens/login_page.dart';
import 'package:events_feature/screens/logout_page.dart';
import 'package:events_feature/utils/date_time_format.dart';
import 'package:events_feature/utils/session_manager.dart';
import 'package:events_feature/models/selected_events_deals_model.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_html/flutter_html.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String selected = "Events";
  final SessionManager _sessionManager = SessionManager();

  String? _name;
  String? _email;
  String? _phone;
  bool _isLoading = true;
  bool _isLoggedIn = false;
  late Future<EventOrdersResponse> _futureOrders;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _futureOrders = fetchOrders();
  }

  Future<void> _loadUserData() async {
    await _sessionManager.loadSession();
    setState(() {
      _name = _sessionManager.userName ?? "";
      _email = _sessionManager.userEmail ?? "";
      _phone = _sessionManager.userPhone ?? "";
      _isLoggedIn = _sessionManager.authToken != null;
      _isLoading = false;
    });
  }

  Future<EventsResponse> fetchOrders() async {
    await _sessionManager.loadSession();

    String url = "https://white-labels-app-server.vercel.app/api/orders/list";

    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'x-auth-token': _sessionManager.authToken ?? "",
      },
    );

    if (response.statusCode == 200) {
      return EventsResponse.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load  orders');
    }
  }

  void _changeTab(String label) {
    setState(() {
      selected = label;
      // if (label == "Events") {
      //   _futureOrders = fetchOrders("events");
      // } else if (label == "Deals") {
      //   _futureOrders = fetchOrders("deals");
      // } else {
      //   _futureOrders = fetchOrders("table");
      // }
    });
  }

  // ✅ Show Settings Bottom Sheet
  void _showSettingsSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey[900],
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.grey[700],
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            if (!_isLoggedIn)
              ListTile(
                leading: const Icon(Icons.login, color: Colors.greenAccent),
                title: const Text(
                  "Login",
                  style: TextStyle(color: Colors.white),
                ),
                trailing: const Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.white70,
                ),
                onTap: () {
                  Navigator.pop(context);
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.grey[900],
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(20),
                      ),
                    ),
                    builder: (context) => const LoginScreen(),
                  ).whenComplete(() => _loadUserData());
                },
              ),
            if (_isLoggedIn)
              ListTile(
                leading: const Icon(Icons.edit, color: Colors.greenAccent),
                title: const Text(
                  "Edit Profile",
                  style: TextStyle(color: Colors.white),
                ),
                trailing: const Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.white70,
                ),
                onTap: () {
                  Navigator.pop(context);
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.grey[850],
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(20),
                      ),
                    ),
                    builder: (context) => EditProfilePage(
                      //userName: _name ?? "",
                      // userEmail: _email ?? "",
                      // userNumber: _phone ?? "",
                    ),
                  ).whenComplete(() => _loadUserData());
                },
              ),
            if (_isLoggedIn)
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.redAccent),
                title: const Text(
                  "Logout",
                  style: TextStyle(color: Colors.white),
                ),
                trailing: const Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.white70,
                ),
                onTap: () {
                  Navigator.pop(context);
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.grey[850],
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(20),
                      ),
                    ),
                    builder: (context) => const LogoutPage(),
                  ).whenComplete(() => _loadUserData());
                },
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator(color: Colors.green)),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text(
          "Profile",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.grey[900],
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white),
            onPressed: () => _showSettingsSheet(context),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProfileHeader(),
            const SizedBox(height: 20),
            _buildTabs(),
            const SizedBox(height: 16),
            Expanded(child: _buildOrdersList()),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          CircleAvatar(
            radius: 35,
            backgroundColor: Colors.green,
            child: Text(
              _name!.isNotEmpty ? _name![0].toUpperCase() : "?",
              style: const TextStyle(fontSize: 22, color: Colors.white),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _name ?? "",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _email ?? "",
                  style: const TextStyle(color: Colors.white70),
                ),
                Text(
                  _phone ?? "",
                  style: const TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabs() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(child: _buildTabButton("Events")),
          const SizedBox(width: 10),
          Expanded(child: _buildTabButton("Deals")),
          const SizedBox(width: 10),
          Expanded(child: _buildTabButton("Table Bookings")),
        ],
      ),
    );
  }

  Widget _buildTabButton(String label) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: selected == label ? Colors.green : Colors.transparent,
        foregroundColor: selected == label ? Colors.black : Colors.white,
        side: const BorderSide(color: Colors.white54),
        padding: const EdgeInsets.symmetric(vertical: 14),
      ),
      onPressed: () => _changeTab(label),
      child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
    );
  }

  /* Widget _buildOrdersList() {
    return FutureBuilder<EventOrdersResponse>(
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
          return Center(
            child: Text(
              "No ${selected.toLowerCase()} found.",
              style: const TextStyle(color: Colors.white70),
            ),
          );
        }

        final allOrders = snapshot.data!.data;

        // ✅ Filter based on selected tab
        List<EventOrder> filteredOrders = [];

        if (selected == "Events") {
          filteredOrders = allOrders
              .where(
                (order) =>
                    order.name.toLowerCase() == "tickets" ||
                    order.name.toLowerCase() == "event",
              )
              .toList();
        } else if (selected == "Deals") {
          filteredOrders = allOrders
              .where((order) => order.name.toLowerCase() == "deals")
              .toList();
        } else if (selected == "Table Bookings") {
          filteredOrders = allOrders
              .where(
                (order) =>
                    order.name.toLowerCase() == "table" ||
                    order.name.toLowerCase() == "table_booking",
              )
              .toList();
        }

        if (filteredOrders.isEmpty) {
          return Center(
            child: Text(
              "No ${selected.toLowerCase()} found.",
              style: const TextStyle(color: Colors.white70),
            ),
          );
        }

        // ✅ Different layouts based on category
        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          itemCount: filteredOrders.length,
          itemBuilder: (context, index) {
            final order = filteredOrders[index];

            // 🎟️ EVENT CARD
            if (selected == "Events") {
              return Card(
                color: Colors.grey[900],
                margin: const EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(12),
                  title: Text(
                    order.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 6),
                      Text(
                        order.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: Colors.white70),
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
                      Text(
                        "${formatDateTime(order.fromDate)} → ${formatDateTime(order.toDate)}",
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }
            // 💰 DEAL CARD
            else if (selected == "Deals") {
              return Container(
                margin: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.grey[850],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.greenAccent.withOpacity(0.3),
                  ),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(12),
                  leading: const Icon(
                    Icons.local_offer,
                    color: Colors.greenAccent,
                  ),
                  title: Text(
                    order.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: /* Text(
                    order.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.white70),
                  ),*/ Html(
                    data: order.description,
                    style: {
                      "body": Style(
                        color: Colors.white70,
                        maxLines: 2,
                        textOverflow: TextOverflow.ellipsis,
                        fontSize: FontSize.medium,
                        margin: Margins.zero,
                        padding: HtmlPaddings.zero,
                      ),
                    },
                  ),

                  trailing: Text(
                    "₹${order.totalPriceWithTaxes.toStringAsFixed(2)}",
                    style: const TextStyle(
                      color: Colors.greenAccent,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              );
            }
            // 🍽️ TABLE BOOKING CARD
            else {
              return Container(
                margin: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.grey[850],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white24),
                ),
                child: ListTile(
                  leading: const Icon(
                    Icons.table_bar,
                    color: Colors.orangeAccent,
                  ),
                  title: Text(
                    "Table ${order.tableNumber.isNotEmpty ? order.tableNumber : 'N/A'}",
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(
                    "From ${formatDateTime(order.fromDate)} to ${formatDateTime(order.toDate)}",
                    style: const TextStyle(color: Colors.white70),
                  ),
                  trailing: Text(
                    "₹${order.totalPriceWithTaxes.toStringAsFixed(2)}",
                    style: const TextStyle(
                      color: Colors.orangeAccent,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              );
            }
          },
        );
      },*/
  Widget _buildOrdersList() {
    return FutureBuilder<EventsResponse>(
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
          return Center(
            child: Text(
              "No ${selected.toLowerCase()} found.",
              style: const TextStyle(color: Colors.white70),
            ),
          );
        }

        final allOrders = snapshot.data!.data;

        // ✅ Filter based on selected tab
        List<EventOrder> filteredOrders = [];
        if (selected == "Events") {
          filteredOrders = allOrders
              .where(
                (order) =>
                    order.name.toLowerCase() == "tickets" ||
                    order.name.toLowerCase() == "event",
              )
              .toList();
        } else if (selected == "Deals") {
          filteredOrders = allOrders
              .where((order) => order.name.toLowerCase() == "deals")
              .toList();
        } else if (selected == "Table Bookings") {
          filteredOrders = allOrders
              .where(
                (order) =>
                    order.name.toLowerCase() == "table" ||
                    order.name.toLowerCase() == "table_booking",
              )
              .toList();
        }

        if (filteredOrders.isEmpty) {
          return Center(
            child: Text(
              "No ${selected.toLowerCase()} found.",
              style: const TextStyle(color: Colors.white70),
            ),
          );
        }

        // ✅ Different layouts based on category
        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          itemCount: filteredOrders.length,
          itemBuilder: (context, index) {
            final order = filteredOrders[index];

            // 🎟️ EVENT CARD
            if (selected == "Events") {
              return Card(
                color: Colors.grey[900],
                margin: const EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(12),
                  title: Text(
                    order.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 6),
                      Html(
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
                      Text(
                        "${formatDateTime(order.fromDate)} → ${formatDateTime(order.toDate)}",
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }
            // 💰 DEAL CARD
            else if (selected == "Deals") {
              return Container(
                margin: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.grey[850],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.greenAccent.withOpacity(0.3),
                  ),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(12),
                  leading: const Icon(
                    Icons.local_offer,
                    color: Colors.greenAccent,
                  ),
                  title: Text(
                    order.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Html(
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
                  trailing: Text(
                    "₹${order.totalPriceWithTaxes.toStringAsFixed(2)}",
                    style: const TextStyle(
                      color: Colors.greenAccent,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              );
            }
            // 🍽️ TABLE BOOKING CARD
            else {
              return Container(
                margin: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.grey[850],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white24),
                ),
                child: ListTile(
                  leading: const Icon(
                    Icons.table_bar,
                    color: Colors.orangeAccent,
                  ),
                  title: Text(
                    "Table ${order.tableNumber.isNotEmpty ? order.tableNumber : 'N/A'}",
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Html(
                    data:
                        "From <strong>${formatDateTime(order.fromDate)}</strong> to <strong>${formatDateTime(order.toDate)}</strong>",
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
                  trailing: Text(
                    "₹${order.totalPriceWithTaxes.toStringAsFixed(2)}",
                    style: const TextStyle(
                      color: Colors.orangeAccent,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              );
            }
          },
        );
      },
    );
  }
}
*/
/*
import 'dart:convert';
import 'package:events_feature/utils/session_manager.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

// ✅ Import your models
import 'package:events_feature/models/selected_events_deals_model.dart'; // Contains EventOrdersResponse, EventOrder

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String selected = "Events";
  final SessionManager _sessionManager = SessionManager();

  String? _name;
  String? _email;
  String? _phone;
  bool _isLoading = true;
  late Future<EventOrdersResponse> _futureOrders;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _futureOrders = fetchOrders("events");
  }

  Future<void> _loadUserData() async {
    await _sessionManager.loadSession();
    setState(() {
      _name = _sessionManager.userName ?? "";
      _email = _sessionManager.userEmail ?? "";
      _phone = _sessionManager.userPhone ?? "";
      _isLoading = false;
    });
  }

  // ✅ Generic fetcher for different order categories
  Future<EventOrdersResponse> fetchOrders(String type) async {
    final session = SessionManager();
    await session.loadSession();

    // Adjust URLs for each category
    String url;
    if (type == "events") {
      url = 'https://white-labels-app-server.vercel.app/api/orders/list';
    } else if (type == "deals") {
      url = 'https://white-labels-app-server.vercel.app/api/orders/deals';
    } else {
      url = 'https://white-labels-app-server.vercel.app/api/orders/table';
    }

    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'x-auth-token': session.authToken ?? "",
      },
    );

    if (response.statusCode == 200) {
      return EventOrdersResponse.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load $type orders');
    }
  }

  // ✅ Change category and reload
  void _changeTab(String label) {
    setState(() {
      selected = label;
      if (label == "Events") {
        _futureOrders = fetchOrders("events");
      } else if (label == "Deals") {
        _futureOrders = fetchOrders("deals");
      } else {
        _futureOrders = fetchOrders("table");
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator(color: Colors.green)),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text(
          "Profile",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: Colors.grey[900],
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProfileHeader(),
            const SizedBox(height: 20),
            _buildTabs(),
            const SizedBox(height: 16),
            Expanded(child: _buildOrdersList()),
          ],
        ),
      ),
    );
  }

  // ✅ Profile header
  Widget _buildProfileHeader() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          CircleAvatar(
            radius: 35,
            backgroundColor: Colors.green,
            child: Text(
              _name!.isNotEmpty ? _name![0].toUpperCase() : "?",
              style: const TextStyle(fontSize: 22, color: Colors.white),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _name ?? "",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _email ?? "",
                  style: const TextStyle(color: Colors.white70),
                ),
                Text(
                  _phone ?? "",
                  style: const TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ✅ Tabs (Events / Deals / Table Booking)
  Widget _buildTabs() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(child: _buildTabButton("Events")),
          const SizedBox(width: 10),
          Expanded(child: _buildTabButton("Deals")),
          const SizedBox(width: 10),
          Expanded(child: _buildTabButton("Table Bookings")),
        ],
      ),
    );
  }

  Widget _buildTabButton(String label) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: selected == label ? Colors.green : Colors.transparent,
        foregroundColor: selected == label ? Colors.black : Colors.white,
        side: const BorderSide(color: Colors.white54),
        padding: const EdgeInsets.symmetric(vertical: 14),
      ),
      onPressed: () => _changeTab(label),
      child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
    );
  }

  // ✅ Orders list (FutureBuilder)
  Widget _buildOrdersList() {
    return FutureBuilder<EventOrdersResponse>(
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
          return Center(
            child: Text(
              "No ${selected.toLowerCase()} found.",
              style: const TextStyle(color: Colors.white70),
            ),
          );
        }

        final orders = snapshot.data!.data;

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 12),
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
                title: Text(
                  order.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 6),
                    Text(
                      order.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: Colors.white70),
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
                    Text(
                      "${order.fromDate}  →  ${order.toDate}",
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
*/
/*
import 'package:events_feature/screens/edit_profile_page.dart';
import 'package:events_feature/screens/login_page.dart';
import 'package:events_feature/screens/logout_page.dart';
import 'package:events_feature/utils/session_manager.dart';
import 'package:flutter/material.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String selected = "";
  final SessionManager _sessionManager = SessionManager();

  String? _name;
  String? _email;
  String? _phone;

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    await _sessionManager.loadSession();
    setState(() {
      _name = _sessionManager.userName ?? "";
      _email = _sessionManager.userEmail ?? "";
      _phone = _sessionManager.userPhone ?? "";
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator(color: Colors.green)),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text(
          "Profile",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: Colors.grey[900],
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsPage()),
              );
              _loadUserData(); // refresh on return
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- Profile Info ---
              if (_name != null && _name!.isNotEmpty)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Avatar
                    CircleAvatar(
                      radius: 35,
                      backgroundColor: Colors.green,
                      child: Text(
                        _name!.isNotEmpty ? _name![0].toUpperCase() : "?",
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    // User details
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _name ?? "",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            _email ?? "",
                            style: const TextStyle(color: Colors.white70),
                          ),
                          Text(
                            _phone ?? "",
                            style: const TextStyle(color: Colors.white70),
                          ),
                        ],
                      ),
                    ),
                  ],
                )
              else
                const Text(
                  "Not logged in",
                  style: TextStyle(color: Colors.white70, fontSize: 18),
                ),

              const SizedBox(height: 30),

              // --- Tab Buttons ---
              Row(
                children: [
                  Expanded(child: _buildTabButton("Events")),
                  const SizedBox(width: 12),
                  Expanded(child: _buildTabButton("Deals")),
                  const SizedBox(width: 12),
                  Expanded(child: _buildTabButton("Table Booking")),
                ],
              ),

              const SizedBox(height: 24),

              // --- Content Area ---
              if (selected == "Events")
                const Text(
                  "Showing your Events...",
                  style: TextStyle(color: Colors.white),
                ),
              if (selected == "Deals")
                const Text(
                  "Showing your Deals...",
                  style: TextStyle(color: Colors.white),
                ),
              if (selected == "Table Booking")
                const Text(
                  "Showing your Table Booking...",
                  style: TextStyle(color: Colors.white),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabButton(String label) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: selected == label ? Colors.green : Colors.transparent,
        foregroundColor: selected == label ? Colors.black : Colors.white,
        side: const BorderSide(color: Colors.white70),
        padding: const EdgeInsets.symmetric(vertical: 16),
      ),
      onPressed: () {
        setState(() => selected = label);
      },
      child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
    );
  }
}

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final SessionManager _sessionManager = SessionManager();
  bool _isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _loadSession();
  }

  Future<void> _loadSession() async {
    await _sessionManager.loadSession();
    setState(() {
      _isLoggedIn = _sessionManager.authToken != null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Settings",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.grey[900],
      ),
      body: ListView(
        children: [
          if (!_isLoggedIn)
            ListTile(
              leading: const Icon(Icons.login, color: Colors.green),
              title: const Text(
                "Login",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              trailing: const Icon(
                Icons.arrow_forward_ios,
                color: Colors.white70,
                size: 16,
              ),
              onTap: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.grey[900],
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                  ),
                  builder: (context) => const LoginScreen(),
                ).whenComplete(() => _loadSession());
              },
            ),
          if (!_isLoggedIn) const Divider(color: Colors.white24),

          if (_isLoggedIn)
            ListTile(
              leading: const Icon(Icons.edit, color: Colors.green),
              title: const Text(
                "Edit Profile",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              trailing: const Icon(
                Icons.arrow_forward_ios,
                color: Colors.white70,
                size: 16,
              ),
              onTap: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.grey[800],
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                  ),
                  builder: (context) => const EditProfilePage(),
                ).whenComplete(() => _loadSession());
              },
            ),
          if (_isLoggedIn) const Divider(color: Colors.white24),

          if (_isLoggedIn)
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.green),
              title: const Text(
                "Logout",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              trailing: const Icon(
                Icons.arrow_forward_ios,
                color: Colors.white70,
                size: 16,
              ),
              onTap: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.grey[800],
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                  ),
                  builder: (context) => const LogoutPage(),
                ).whenComplete(() => _loadSession());
              },
            ),
        ],
      ),
    );
  }
}
*/
/*
import 'package:events_feature/screens/edit_profile_page.dart';
import 'package:events_feature/screens/login_page.dart';
import 'package:events_feature/screens/logout_page.dart';
import 'package:flutter/material.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String selected = ""; // Track selection

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text(
          "Profile",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: Colors.grey[900],
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsPage()),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // --- Events and Deals buttons side by side ---
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: selected == "Events"
                          ? Colors.green
                          : Colors.transparent,
                      foregroundColor: selected == "Events"
                          ? Colors.black
                          : Colors.white,
                      side: const BorderSide(color: Colors.white70),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    onPressed: () {
                      setState(() {
                        selected = "Events";
                      });
                    },
                    child: const Text(
                      "Events",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: selected == "Deals"
                          ? Colors.green
                          : Colors.transparent,
                      foregroundColor: selected == "Deals"
                          ? Colors.black
                          : Colors.white,
                      side: const BorderSide(color: Colors.white70),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    onPressed: () {
                      setState(() {
                        selected = "Deals";
                      });
                    },
                    child: const Text(
                      "Deals",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: selected == "Table Booking"
                          ? Colors.green
                          : Colors.transparent,
                      foregroundColor: selected == "Table Booking"
                          ? Colors.black
                          : Colors.white,
                      side: const BorderSide(color: Colors.white70),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    onPressed: () {
                      setState(() {
                        selected = "Table Booking";
                      });
                    },
                    child: const Text(
                      "Table Booking",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Optional: Display some content depending on selection
            if (selected == "Events")
              const Text(
                "Showing your Events...",
                style: TextStyle(color: Colors.white),
              ),
            if (selected == "Deals")
              const Text(
                "Showing your Deals...",
                style: TextStyle(color: Colors.white),
              ),
            if (selected == "Table Booking")
              const Text(
                "Showing your Table Booking...",
                style: TextStyle(color: Colors.white),
              ),
          ],
        ),
      ),
    );
  }
}

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Settings",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.grey[900],
      ),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.login, color: Colors.green),
            title: const Text(
              "Login",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            trailing: const Icon(
              Icons.arrow_forward_ios,
              color: Colors.white70,
              size: 16,
            ),
            onTap: () {
              /*Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
              );*/
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.grey[900],
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                builder: (context) => Padding(
                  padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewInsets.bottom,
                  ),
                  child:
                      const LoginScreen(), // Your existing login dialog/screen
                ),
              );
            },
          ),
          const Divider(color: Colors.white24),

          ListTile(
            leading: const Icon(Icons.logout, color: Colors.green),
            title: const Text(
              "Logout",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            trailing: const Icon(
              Icons.arrow_forward_ios,
              color: Colors.white70,
              size: 16,
            ),
            onTap: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.grey[700],
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                builder: (context) => const LogoutPage(),
              );
            },
          ),
          const Divider(color: Colors.white24),

          ListTile(
            leading: const Icon(Icons.edit, color: Colors.green),
            title: const Text(
              "Edit Profile",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            trailing: const Icon(
              Icons.arrow_forward_ios,
              color: Colors.white70,
              size: 16,
            ),
            onTap: () {
              /* Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const EditProfilePage()),
              );*/
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.grey[700],
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                builder: (context) => const EditProfilePage(
                  userName: "", // Replace with actual login data
                  userEmail: "",
                  userNumber: "",
                ),
              );
            },
          ),
          const Divider(color: Colors.white24),
        ],
      ),
    );
  }
}
*/
