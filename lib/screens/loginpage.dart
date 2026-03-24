import 'package:flutter/material.dart';
import 'package:etherealapp/widgets/input_fields.dart'; 

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        automaticallyImplyLeading: false, 
        title: const Text(
          'Ethereal',
          style: TextStyle(
            color: Color(0xFF1F2937),
            fontWeight: FontWeight.w900,
            fontSize: 20,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_rounded, color: Color(0xFF6B7280), size: 24),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 48),
            
            // Header Section
            const Text(
              'Welcome Back.',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w900,
                color: Color(0xFF1F2937),
                height: 1.2,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Log in to your ethereal workspace.',
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFF4B5563),
              ),
            ),
            const SizedBox(height: 40),
            
            // Login Card
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    
                    // 1. THIS IS YOUR NEW CUSTOM WIDGET IN ACTION (Email)
                    const CustomInputField(
                      label: 'EMAIL ADDRESS',
                      hintText: 'name@example.com',
                      prefixIcon: Icons.email_outlined,
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // 2. YOUR CUSTOM WIDGET (Password)
                    CustomInputField(
                      label: 'PASSWORD',
                      hintText: '••••••••',
                      obscureText: _obscurePassword,
                      prefixIcon: Icons.lock_outline,
                      // We can pass the visibility toggle right into our widget!
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                          color: const Color(0xFF6B7280),
                          size: 20,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                    ),
                    
                    // Forgot Password Link
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {},
                        child: const Text(
                          'FORGOT?',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0D5CEB),
                          ),
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 12),
                    
                    // Login Button (We will modularize this next!)
                    ElevatedButton(
                      onPressed: () {
                        // Example of how you'd navigate to the home page after login
                        Navigator.pushReplacementNamed(context, '/homepage');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0D5CEB),
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 56),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 2,
                        shadowColor: const Color(0xFF0D5CEB).withOpacity(0.4),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Log In', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                          SizedBox(width: 8),
                          Icon(Icons.arrow_forward, size: 20),
                        ],
                      ),
                    ),
                    
                    // ... (I kept the rest of the social buttons out to keep this snippet clean, 
                    // but you can leave your social login buttons here from the original code!)
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Register Link
            Center(
              child: GestureDetector(
                onTap: () {
                  Navigator.pushNamed(context, '/register');
                },
                child: RichText(
                  text: const TextSpan(
                    style: TextStyle(fontSize: 15, color: Color(0xFF4B5563), fontFamily: 'Roboto'),
                    children: [
                      TextSpan(text: 'New to Ethereal? '),
                      TextSpan(
                        text: 'Register',
                        style: TextStyle(color: Color(0xFF0D5CEB), fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}