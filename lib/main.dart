import 'package:flutter/material.dart';

// 1. Import all of your screen files here
import 'package:etherealapp/screens/homepage.dart';
import 'package:etherealapp/screens/aboutuspage.dart';
import 'package:etherealapp/screens/loginpage.dart';
import 'package:etherealapp/screens/registerpage.dart';
import 'package:etherealapp/screens/contactus.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ethereal',
      debugShowCheckedModeBanner: false, // Added this to remove the debug banner
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 47, 16, 100),
        ),
        useMaterial3: true,
      ),
      
      // 2. Map your routes to the correct screen classes
      routes: {
        '/homepage': (context) => const HomePage(),
        '/aboutus': (context) => const AboutUsPage(),
        '/login': (context) => const LoginPage(),
        '/register': (context) => const RegisterPage(),
        '/contactus': (context) => const ContactUsPage(),
      },
      
      // 3. Set the initial screen when the app launches
      home: const AboutUsPage(), 
    );
  }
}