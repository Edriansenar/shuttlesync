import 'package:flutter/material.dart';
import 'package:etherealapp/widgets/submit_button.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Navigation index (0 = Home, 1 = About, 2 = Contact)
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Color(0xFF0D5CEB)),
          onPressed: () {},
        ),
        title: const Text(
          'Ethereal',
          style: TextStyle(
            color: Color(0xFF1F2937),
            fontWeight: FontWeight.w900,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle_outlined, color: Color(0xFF0D5CEB), size: 28),
            onPressed: () {
              // Navigate to login/profile when user icon is tapped
              Navigator.pushNamed(context, '/login');
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 48),
            
            // Hero Section
            const Text(
              'Welcome to',
              style: TextStyle(fontSize: 36, fontWeight: FontWeight.w900, color: Color(0xFF1F2937), height: 1.1),
            ),
            const Text(
              'Ethereal',
              style: TextStyle(fontSize: 36, fontWeight: FontWeight.w900, color: Color(0xFF0D5CEB), height: 1.2),
            ),
            const SizedBox(height: 16),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                'Experience clarity through\nessential design.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, color: Color(0xFF4B5563), height: 1.5),
              ),
            ),
            const SizedBox(height: 40),
            
            // Action Buttons
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: CustomSubmitButton(
                text: 'Get Started',
                onPressed: () {
                  Navigator.pushNamed(context, '/register');
                },
              ),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () {
                Navigator.pushNamed(context, '/aboutus');
              },
              child: const Text(
                'Learn More',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Color(0xFF0D5CEB)),
              ),
            ),
            const SizedBox(height: 48),
            
            // Feature Card
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4)),
                  ],
                ),
                padding: const EdgeInsets.all(20),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFDFE6FF),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.auto_awesome, color: Color(0xFF0D5CEB), size: 24),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Pure Focus', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF1F2937))),
                          SizedBox(height: 6),
                          Text(
                            'Reducing noise to amplify what matters most in your daily journey.',
                            style: TextStyle(fontSize: 14, color: Color(0xFF6B7280), height: 1.4),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 80),
            
            // Minimal Footer
            Container(
              width: double.infinity,
              color: const Color(0xFFF3F4F6), 
              padding: const EdgeInsets.symmetric(vertical: 40),
              child: Column(
                children: [
                  const Text('Ethereal', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF1F2937))),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _footerLink('Login', () => Navigator.pushNamed(context, '/login')),
                      const SizedBox(width: 24),
                      _footerLink('Register', () => Navigator.pushNamed(context, '/register')),
                      const SizedBox(width: 24),
                      _footerLink('Privacy', () {}),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Text('© 2024 Ethereal Essentialist', style: TextStyle(fontSize: 13, color: Color(0xFF6B7280))),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
      
      // Bottom Navigation Bar
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24)),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, -4))],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        child: SafeArea(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildNavItem(0, Icons.home_filled, 'Home', () {}),
              _buildNavItem(1, Icons.info_outline, 'About', () => Navigator.pushReplacementNamed(context, '/aboutus')),
              _buildNavItem(2, Icons.email_outlined, 'Contact', () => Navigator.pushReplacementNamed(context, '/contactus')),
            ],
          ),
        ),
      ),
    );
  }

  Widget _footerLink(String text, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Text(text, style: const TextStyle(fontSize: 14, color: Color(0xFF6B7280))),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label, VoidCallback onTap) {
    final isSelected = _selectedIndex == index;
    
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFEFF4FF) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: isSelected ? const Color(0xFF0D5CEB) : const Color(0xFF9CA3AF), size: 24),
            const SizedBox(height: 4),
            Text(label, style: TextStyle(fontSize: 12, fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500, color: isSelected ? const Color(0xFF0D5CEB) : const Color(0xFF9CA3AF))),
          ],
        ),
      ),
    );
  }
}