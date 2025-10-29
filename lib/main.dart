import 'package:events_feature/screens/home_screen.dart';
import 'package:events_feature/screens/login_page.dart';
import 'package:events_feature/utils/session_manager.dart';
import 'package:flutter/material.dart';
import 'package:events_feature/utils/auth_manager.dart';

//import 'package:firebase_core/firebase_core.dart';
//import 'package:shared_preferences/shared_preferences.dart';
//import 'package:flutter/material.dart';
//import 'package:events_feature/screens/home_screen.dart';
//import 'package:events_feature/screens/login_page.dart';
//import 'package:events_feature/utils/auth_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final session = SessionManager();
  await session.loadSession();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Events Demo Project',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(useMaterial3: true),
      home: MainHomeScreen(),
    );
  }
}

/*void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 🔹 Check saved login session
  final loggedIn = await AuthManager.isLoggedIn();
  final userInfo = await AuthManager.getUserInfo();

  runApp(MyApp(loggedIn: loggedIn, userName: userInfo['name']));
}

class MyApp extends StatelessWidget {
  final bool loggedIn;
  final String? userName;

  const MyApp({super.key, required this.loggedIn, this.userName});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Events Demo Project',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(useMaterial3: true),
      home: loggedIn
          ? MainHomeScreen(userName: userName ?? "Guest")
          : const LoginScreen(),
    );
  }
}*/
/*
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final loggedIn = await AuthManager.isLoggedIn();

  runApp(MyApp(isLoggedIn: loggedIn));

  //runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;
  const MyApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Events demo project',
      debugShowCheckedModeBanner: false,
      /* theme: ThemeData(),
      darkTheme: ThemeData.dark(
        useMaterial3: true,

      ).copyWith(
        scaffoldBackgroundColor: AppColors.background,

      ),
    themeMode: ThemeMode.dark,*/
      // home: isLoggedIn ? const MainHomeScreen() : const LoginScreen(),
      home: const MainHomeScreen(userName: ),
    );
  }
}*/

/*class LoginTest extends StatefulWidget {
  const LoginTest({super.key});

  @override
  State<LoginTest> createState() => _LoginTestState();
}

class _LoginTestState extends State<LoginTest> {
  bool isLoggedIn = false;

  login() async {
    final prefs = await SharedPreferences.getInstance();

    prefs.setBool('isLoggedIn', true);

    setState(() {
      isLoggedIn = true;
    });
  }

  logout() async {
    final prefs = await SharedPreferences.getInstance();

    prefs.setBool('isLoggedIn', false);
    setState(() {
      isLoggedIn = false;
    });
  }

  @override
  void initState() {
    super.initState();
    checkLoginStatus();
  }

  // login status check
  Future<void> checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            isLoggedIn
                ? Text(
                    "Hello Srijana!",
                    style: TextTheme.of(context).displayLarge,
                  )
                : Text(
                    "Hello World!",
                    style: TextTheme.of(context).displayLarge,
                  ),

            FilledButton(
              onPressed: () {
                isLoggedIn ? logout() : login();
              },
              child: Text(isLoggedIn ? "Logout" : "Login"),
            ),
          ],
        ),
      ),
    );
  }
}*/
