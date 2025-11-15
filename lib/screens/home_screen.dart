/*
import 'package:flutter/material.dart';
import 'package:events_feature/utils/session_manager.dart';
import 'package:events_feature/screens/login_page.dart';
import 'package:events_feature/screens/logout_page.dart';
import 'package:events_feature/screens/deals_home_page.dart';
import 'package:events_feature/screens/events_home_screen.dart';
import 'package:events_feature/screens/feedback_bome_page.dart';
import 'package:events_feature/screens/home_page.dart';
import 'package:events_feature/screens/settings_screen.dart';
import 'package:shimmer/shimmer.dart';

class MainHomeScreen extends StatefulWidget {
  final String? userName;

  const MainHomeScreen({super.key, this.userName});

  @override
  State<MainHomeScreen> createState() => _MainHomeScreenState();
}

class _MainHomeScreenState extends State<MainHomeScreen> {
  int _selectedIndex = 0;
  bool isLoggedIn = false;
  String? authToken;

  final List<Widget> _pages = const [
    HomePage(),
    EventsHomeScreen(),
    DealsPage(),
    FeedbackPage(),
  ];

  @override
  void initState() {
    super.initState();
    loadUserSession();
  }

  Future<void> loadUserSession() async {
    final session = SessionManager();
    await session.loadSession();

    setState(() {
      authToken = session.authToken;
      isLoggedIn = session.authToken != null;
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final session = SessionManager();

    // Screen size helpers for adaptive layout
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final textScale = MediaQuery.of(context).textScaleFactor;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        automaticallyImplyLeading: false,
        titleSpacing: screenWidth * 0.04,
        title: LayoutBuilder(
          builder: (context, constraints) {
            return FittedBox(
              alignment: Alignment.centerLeft,
              fit: BoxFit.scaleDown,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Shimmer.fromColors(
                    baseColor: Colors.green,
                    highlightColor: Colors.green.shade200,
                    child: Text(
                      isLoggedIn
                          ? "${session.userName ?? 'User'},"
                          : "Welcome to Clubr!",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: screenWidth * 0.055, // adaptive text
                      ),
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.004),
                  Shimmer.fromColors(
                    baseColor: Colors.green,
                    highlightColor: Colors.green.shade200,
                    child: Text(
                      isLoggedIn ? "Welcome to Clubr!" : "",
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: screenWidth * 0.04,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: screenWidth * 0.03),
            child: IconButton(
              icon: Icon(
                Icons.account_circle,
                color: Colors.white70,
                size: screenWidth * 0.10, // scales icon with screen width
              ),
              tooltip: 'Profile',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ProfileScreen()),
                );
              },
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: _pages[_selectedIndex],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.grey[900],
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.white70,
        currentIndex: _selectedIndex,
        iconSize: screenWidth * 0.06, // ✅ responsive icons
        selectedFontSize: screenWidth * 0.035,
        unselectedFontSize: screenWidth * 0.03,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.event), label: "Events"),
          BottomNavigationBarItem(
              icon: Icon(Icons.local_offer), label: "Deals"),
          BottomNavigationBarItem(
              icon: Icon(Icons.feedback), label: "Feedback"),
        ],
      ),
    );
  }
}
*/

import 'package:flutter/material.dart';
import 'package:events_feature/utils/session_manager.dart'; // ✅ Import this
import 'package:events_feature/utils/auth_manager.dart';
import 'package:events_feature/screens/login_page.dart';
import 'package:events_feature/screens/logout_page.dart';
import 'package:events_feature/screens/deals_home_page.dart';
import 'package:events_feature/screens/events_home_screen.dart';
import 'package:events_feature/screens/feedback_bome_page.dart';
import 'package:events_feature/screens/home_page.dart';
import 'package:events_feature/screens/settings_screen.dart';
import 'package:shimmer/shimmer.dart';

class MainHomeScreen extends StatefulWidget {
  final String? userName;

  const MainHomeScreen({super.key, this.userName});

  @override
  State<MainHomeScreen> createState() => _MainHomeScreenState();
}

class _MainHomeScreenState extends State<MainHomeScreen> {
  int _selectedIndex = 0;
  bool isLoggedIn = false;
  String? authToken; // 🔹 Store token locally

  final List<Widget> _pages = const [
    HomePage(),
    EventsHomeScreen(),
    DealsPage(),
    FeedbackPage(),
  ];

  @override
  void initState() {
    super.initState();
    loadUserSession();
  }

  /// 🔹 Load user session (token + login state)
  Future<void> loadUserSession() async {
    final session = SessionManager();
    await session.loadSession(); // ensures it's up-to-date

    setState(() {
      authToken = session.authToken;
      isLoggedIn = session.authToken != null;
    });

    debugPrint("✅ Auth Token: $authToken");
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final session = SessionManager(); // Access current session

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        automaticallyImplyLeading: false,
        titleSpacing: 14,
        title: Align(
          alignment: Alignment.topLeft,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /*Text(
                isLoggedIn
                    ? "${session.userName ?? 'User'},"
                    : "Welcome to Clubr!",
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                isLoggedIn ? "Welcome to Clubr !" : "",
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),*/
              Shimmer.fromColors(
                baseColor: Colors.green,
                highlightColor: Colors.green.shade200,
                child: Text(
                  isLoggedIn
                      ? "${session.userName ?? 'User'} ,"
                      : "Welcome to Clubr!",
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Shimmer.fromColors(
                baseColor: Colors.green,
                highlightColor: Colors.green.shade200,
                child: Text(
                  isLoggedIn ? "Welcome to Clubr !" : "",
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.account_circle,
              color: Colors.white70,
              size: 50,
            ),
            tooltip: 'Profile',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfileScreen()),
              );
            },
          ),
        ],
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.grey[900],
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.white70,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.event), label: "Events"),
          BottomNavigationBarItem(
            icon: Icon(Icons.local_offer),
            label: "Deals",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.feedback),
            label: "Feedback",
          ),
        ],
      ),
    );
  }
}

/*
import 'package:events_feature/screens/logout_page.dart';
import 'package:flutter/material.dart';
import 'package:events_feature/screens/deals_home_page.dart';
import 'package:events_feature/screens/events_home_screen.dart';
import 'package:events_feature/screens/feedback_bome_page.dart';
import 'package:events_feature/screens/home_page.dart';
import 'package:events_feature/screens/settings_screen.dart';
import 'package:events_feature/screens/login_page.dart';
import 'package:events_feature/utils/auth_manager.dart';

class MainHomeScreen extends StatefulWidget {
  final String? userName;
  const MainHomeScreen({super.key, this.userName});

  @override
  State<MainHomeScreen> createState() => _MainHomeScreenState();
}

class _MainHomeScreenState extends State<MainHomeScreen> {
  int _selectedIndex = 0;
  bool isLoggedIn = false;
  String _userName = '';

  final List<Widget> _pages = const [
    HomePage(),
    EventsHomeScreen(),
    DealsPage(),
    FeedbackPage(),
  ];

  @override
  void initState() {
    super.initState();
    loginCheck();
  }

  // 🔹 Check login status from SharedPreferences
  Future<void> loginCheck() async {
    final loggedIn = await AuthManager.isLoggedIn();
    final userInfo = await AuthManager.getUserInfo();

    setState(() {
      isLoggedIn = loggedIn;
      _userName = userInfo['name'] ?? '';
    });

    if (!loggedIn) {
      showLoginSheet();
    }
  }

  // 🔹 Show bottom sheet login form
  Future<void> showLoginSheet() async {
    final result = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.grey[900],
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: const LoginScreen(),
      ),
    );

    // 🔹 Update state with data returned from login
    if (result != null && result['isLoggedIn'] == true) {
      setState(() {
        isLoggedIn = true;
        _userName = result['userName'] ?? '';
      });
    }
  }

  // 🔹 Logout Function
  Future<void> _logoutUser() async {
    await AuthManager.logout();
    if (mounted) {
      setState(() {
        isLoggedIn = false;
        _userName = '';
      });
      showLoginSheet();
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        automaticallyImplyLeading: false,
        titleSpacing: 14,
        title: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            (isLoggedIn && _userName.isNotEmpty)
                ? "$_userName, Welcome to Clubr!"
                : "Welcome to Clubr!",
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.redAccent),
            tooltip: 'Logout',
            onPressed: _logoutUser,
          ),
          IconButton(
            icon: const Icon(Icons.account_circle_outlined, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfileScreen()),
              );
            },
          ),
        ],
      ),

      // 🔹 Page body
      body: _pages[_selectedIndex],

      // 🔹 Bottom navigation
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.grey[900],
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.white70,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_max_rounded),
            label: "Home",
          ),
          BottomNavigationBarItem(icon: Icon(Icons.event), label: "Events"),
          BottomNavigationBarItem(icon: Icon(Icons.local_offer), label: "Deals"),
          BottomNavigationBarItem(icon: Icon(Icons.feedback), label: "Feedback"),
        ],
      ),
    );
  }
}
*/
/*
import 'package:events_feature/screens/logout_page.dart';
import 'package:flutter/material.dart';
import 'package:events_feature/screens/deals_home_page.dart';
import 'package:events_feature/screens/events_home_screen.dart';
import 'package:events_feature/screens/feedback_bome_page.dart';
import 'package:events_feature/screens/home_page.dart';
import 'package:events_feature/screens/settings_screen.dart';
import 'package:events_feature/screens/login_page.dart';
import 'package:events_feature/utils/auth_manager.dart';

class MainHomeScreen extends StatefulWidget {
  final String? userName;

  const MainHomeScreen({super.key, this.userName});

  @override
  State<MainHomeScreen> createState() => _MainHomeScreenState();
}

class _MainHomeScreenState extends State<MainHomeScreen> {
  int _selectedIndex = 0;

  bool isLoggedIn = false;

  @override
  final List<Widget> _pages = const [
    HomePage(),
    EventsHomeScreen(),
    DealsPage(),
    FeedbackPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // 🔹 Logout Function
  Future<void> _logoutUser() async {
    await AuthManager.logout();
    if (mounted) {
      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (_) => const LoginScreen()));
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // 🔹 Check saved login session
    loginCheck();
  }

  loginCheck() async {
    setState(() {});

    if (!isLoggedIn) showLoginSheet();

    // final userInfo = await AuthManager.getUserInfo();
  }

  showLoginSheet() {
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
        child: const LoginScreen(), // Your existing login dialog/screen
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        automaticallyImplyLeading: false,
        centerTitle: false,
        titleSpacing: 14,
        title: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            (isLoggedIn) ? " Srijana, Welcome to Clubr !" : "Welcome to Clubr!",
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        actions: [
          // 🔹 Logout Button in AppBar
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.redAccent),
            tooltip: 'Logout',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const LogoutPage()),
              );
            },
          ),
          IconButton(
            icon: const Icon(
              Icons.account_circle_outlined,
              color: Colors.white,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfileScreen()),
              );
            },
          ),
        ],
      ),

      // 🔹 Body
      body: _pages[_selectedIndex],

      // 🔹 Bottom Navigation
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.grey[900],
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.white70,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_max_rounded),
            label: "Home",
          ),
          BottomNavigationBarItem(icon: Icon(Icons.event), label: "Events"),
          BottomNavigationBarItem(
            icon: Icon(Icons.local_offer),
            label: "Deals",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.feedback),
            label: "Feedback",
          ),
        ],
      ),

      // 🔹 Floating Logout Button (optional)
      /*floatingActionButton: FloatingActionButton.extended(
        onPressed: _logoutUser,
        label: const Text("Logout"),
        icon: const Icon(Icons.logout),
        backgroundColor: Colors.redAccent,
      ),*/
    );
  }
}
*/
/*
import 'package:events_feature/screens/login_page.dart';
import 'package:flutter/material.dart';
import 'package:events_feature/screens/deals_home_page.dart';
import 'package:events_feature/screens/events_home_screen.dart';
import 'package:events_feature/screens/feedback_bome_page.dart';
import 'package:events_feature/screens/home_page.dart';
import 'package:events_feature/screens/settings_screen.dart';
import 'package:events_feature/screens/login_page.dart';
import 'package:events_feature/utils/auth_manager.dart';

class MainHomeScreen extends StatefulWidget {
  final String? userName;

  const MainHomeScreen({super.key, this.userName});

  @override
  State<MainHomeScreen> createState() => _MainHomeScreenState();
}

class _MainHomeScreenState extends State<MainHomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = const [
    HomePage(),
    EventsHomeScreen(),
    DealsPage(),
    FeedbackPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // 🔹 Logout Function
  Future<void> _logoutUser() async {
    await AuthManager.logout();
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        automaticallyImplyLeading: false,
        centerTitle: false,
        titleSpacing: 14,
        title: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            (widget.userName != null && widget.userName!.isNotEmpty)
                ? "${widget.userName}, Welcome to Clubr!"
                : "Welcome to Clubr!",
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        actions: [
          // 🔹 Logout Button in AppBar
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.redAccent),
            tooltip: 'Logout',
            onPressed: _logoutUser,
          ),
          IconButton(
            icon: const Icon(Icons.account_circle_outlined, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfileScreen()),
              );
            },
          ),
        ],
      ),

      // 🔹 Body
      body: _pages[_selectedIndex],

      // 🔹 Bottom Navigation
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.grey[900],
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.white70,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_max_rounded),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.event),
            label: "Events",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.local_offer),
            label: "Deals",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.feedback),
            label: "Feedback",
          ),
        ],
      ),

      // 🔹 Floating Logout Button (optional alternative)
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _logoutUser,
        label: const Text("Logout"),
        icon: const Icon(Icons.logout),
        backgroundColor: Colors.redAccent,
      ),
    );
  }
}

*/
