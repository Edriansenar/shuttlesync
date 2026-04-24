import 'package:flutter/material.dart';

import 'package:shuttlesync/screens/homepage.dart';
import 'package:shuttlesync/screens/aboutuspage.dart';
import 'package:shuttlesync/screens/loginpage.dart';
import 'package:shuttlesync/screens/registerpage.dart';
import 'package:shuttlesync/screens/contactus.dart';
import 'package:shuttlesync/screens/courtbooking.dart';
import 'package:shuttlesync/screens/ecommercepage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); 
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
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
        '/homepage': (context) => const HomePage(),
        '/aboutus': (context) => const AboutUsPage(),
        '/login': (context) => const LoginPage(),
        '/register': (context) => const RegisterPage(),
        '/contactus': (context) => const ContactUsPage(),
        '/courtbooking': (context) => const CourtBookingPage(),
        '/shop': (context) => const ShopPage(),
      },
      
      home: const HomePage(currentUser: null), 
    );
  }
}