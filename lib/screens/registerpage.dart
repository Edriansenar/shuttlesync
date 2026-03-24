import 'package:flutter/material.dart';
// Import your reusable widgets!
import 'package:etherealapp/widgets/input_fields.dart';
import 'package:etherealapp/widgets/submit_button.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  // Added this so users can toggle seeing their password while typing
  bool _obscurePassword = true; 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 80), 
            
            // Header Section
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: const Color(0xFFE0E7FF), 
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.design_services, 
                color: Color(0xFF0D5CEB),
                size: 32,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Ethereal',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w900,
                color: Color(0xFF1F2937),
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Begin your essential journey',
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFF4B5563),
              ),
            ),
            const SizedBox(height: 40),
            
            // Registration Card
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    
                    // 1. Full Name Field (Using our widget!)
                    const CustomInputField(
                      label: 'FULL NAME',
                      hintText: 'John Doe',
                    ),
                    const SizedBox(height: 24),
                    
                    // 2. Email Field (Using our widget!)
                    const CustomInputField(
                      label: 'EMAIL ADDRESS',
                      hintText: 'name@example.com',
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 24),
                    
                    // 3. Password Field (Using our widget + visibility toggle!)
                    CustomInputField(
                      label: 'PASSWORD',
                      hintText: '••••••••',
                      obscureText: _obscurePassword,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                          color: const Color(0xFF9CA3AF),
                          size: 20,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                    ),
                    const SizedBox(height: 32),
                    
                    // 4. Submit Button (Using our widget!)
                    CustomSubmitButton(
                      text: 'Register',
                      onPressed: () {
                        // Navigate to home or trigger registration logic
                        Navigator.pushReplacementNamed(context, '/homepage');
                      },
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Login Link
                    Center(
                      child: GestureDetector(
                        onTap: () {
                          // Go back to login page
                          Navigator.pushReplacementNamed(context, '/login');
                        },
                        child: RichText(
                          text: const TextSpan(
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0xFF4B5563),
                              fontFamily: 'Roboto',
                            ),
                            children: [
                              TextSpan(text: 'Already have an account? '),
                              TextSpan(
                                text: 'Login',
                                style: TextStyle(
                                  color: Color(0xFF0D5CEB),
                                  fontWeight: FontWeight.bold,
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
            const SizedBox(height: 40),
            
            // Pagination Dots
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 24,
                  height: 6,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD1E0FF), 
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE5E7EB), 
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE5E7EB), 
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 64),
            
            // Footer Area
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 40),
              color: const Color(0xFFF8F9FA), 
              child: Column(
                children: [
                  const Text(
                    'Ethereal Essentialist',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _footerLink('Login'),
                      const SizedBox(width: 24),
                      _footerLink('Register', isActive: true), 
                      const SizedBox(width: 24),
                      _footerLink('Privacy'),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    '© 2024 Ethereal Essentialist',
                    style: TextStyle(
                      fontSize: 13,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper widget for footer text links
  Widget _footerLink(String text, {bool isActive = false}) {
    return InkWell(
      onTap: () {},
      child: Container(
        decoration: isActive 
          ? const BoxDecoration(
              border: Border(bottom: BorderSide(color: Color(0xFF6B7280), width: 1))
            )
          : null,
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 14,
            color: Color(0xFF6B7280),
          ),
        ),
      ),
    );
  }
}