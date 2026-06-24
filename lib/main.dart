import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shuttlesync/database/database_helper.dart';

import 'package:shuttlesync/screens/homepage.dart';
import 'package:shuttlesync/screens/aboutuspage.dart';
import 'package:shuttlesync/screens/loginpage.dart';
import 'package:shuttlesync/screens/registerpage.dart';
import 'package:shuttlesync/screens/contactus.dart';
import 'package:shuttlesync/screens/courtbooking.dart';
import 'package:shuttlesync/screens/ecommercepage.dart';
import 'package:shuttlesync/screens/admindashboard.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); 
  
  SharedPreferences prefs = await SharedPreferences.getInstance();
  int? savedUserId = prefs.getInt('saved_user_id');

  Widget initialScreen = const HomePage(currentUser: null);

  if (savedUserId != null) {
    final db = await DatabaseHelper.instance.database;
    final userResult = await db.query('Users', where: 'user_id = ?', whereArgs: [savedUserId]);
    
    if (userResult.isNotEmpty) {
      if (userResult.first['role'] == 'admin') {
        initialScreen = AdminDashboard(currentUser: userResult.first);
      } else {
        initialScreen = HomePage(currentUser: userResult.first);
      }
    }
  }

  runApp(MyApp(initialScreen: initialScreen));
}

class MyApp extends StatelessWidget {
  final Widget initialScreen;
  const MyApp({super.key, required this.initialScreen});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'ShuttleSync',
      debugShowCheckedModeBanner: false, 
      
      theme: ThemeData.dark().copyWith(
        primaryColor: const Color(0xFF9166FF), 
        scaffoldBackgroundColor: const Color(0xFF0F1021), 
        cardColor: const Color(0xFF1D1E33), 
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF0F1021),
          elevation: 0,
        ),
        textTheme: const TextTheme(
          displayLarge: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
          titleMedium: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white),
          bodyMedium: TextStyle(fontSize: 14, color: Color(0xFF8D8E98)), 
          labelLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white), 
        ),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF9166FF),
          secondary: Color(0xFFFF80AB), 
        ),
      ),
       
      routes: {
        '/homepage': (context) => const HomePage(currentUser: null),
        '/aboutus': (context) => const AboutUsPage(),
        '/login': (context) => const LoginPage(),
        '/register': (context) => const RegisterPage(),
        '/contactus': (context) => const ContactUsPage(),
        '/courtbooking': (context) => const CourtBookingPage(),
        '/shop': (context) => const ShopPage(),
      },
      
      home: initialScreen, 
    );
  }
}