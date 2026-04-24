import 'package:flutter/material.dart';

import 'package:shuttlesync/screens/homepage.dart';        
import 'package:shuttlesync/screens/ecommercepage.dart';   
import 'package:shuttlesync/screens/courtbooking.dart';    
import 'package:shuttlesync/screens/admindashboard.dart';  
import 'package:shuttlesync/screens/playerdashboard.dart'; 

class MainNavigation extends StatefulWidget {
  final Map<String, dynamic>? currentUser;

  const MainNavigation({super.key, this.currentUser});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  late final List<Widget> _screens;
  late final List<BottomNavigationBarItem> _navItems;

  @override
  void initState() {
    super.initState();
    
    bool isAdmin = widget.currentUser?['role'] == 'admin';

    if (isAdmin) {
      _screens = [
        DashboardScreen(currentUser: widget.currentUser), 
        ShopPage(currentUser: widget.currentUser),        // FIXED: Passed user data
        CourtBookingPage(currentUser: widget.currentUser),                         
        const AdminDashboard(),                           
      ];

      _navItems = const [
        BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: 'HOME'),
        BottomNavigationBarItem(icon: Icon(Icons.shopping_bag), label: 'SHOP'),
        BottomNavigationBarItem(icon: Icon(Icons.sports_tennis), label: 'COURTS'),
        BottomNavigationBarItem(icon: Icon(Icons.admin_panel_settings), label: 'ADMIN'),
      ];

    } else {
      _screens = [
        DashboardScreen(currentUser: widget.currentUser), 
        ShopPage(currentUser: widget.currentUser),        // FIXED: Passed user data
        CourtBookingPage(currentUser: widget.currentUser),                         
        PlayerDashboard(currentUser: widget.currentUser), 
      ];

      _navItems = const [
        BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: 'HOME'),
        BottomNavigationBarItem(icon: Icon(Icons.shopping_bag), label: 'SHOP'),
        BottomNavigationBarItem(icon: Icon(Icons.sports_tennis), label: 'COURTS'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'PROFILE'), 
      ];
    }
  }

  @override
  Widget build(BuildContext context) {
    const primaryPurple = Color(0xFFBB6AFB);

    return Scaffold(
      backgroundColor: const Color(0xFF0F0E17),
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index; 
          });
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: const Color(0xFF11101A), 
        selectedItemColor: primaryPurple,
        unselectedItemColor: Colors.white30,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 10),
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 10),
        items: _navItems,
      ),
    );
  }
}