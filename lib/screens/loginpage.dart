import 'package:flutter/material.dart';
import 'package:shuttlesync/screens/registerpage.dart';
import 'package:shuttlesync/screens/main_navigation.dart';
import 'package:shuttlesync/database/database_helper.dart'; 

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  void _loginUser() async {
    String email = _emailController.text.trim().toLowerCase();
    
    String password = _passwordController.text.trim(); 

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter both email and password.')),
      );
      return;
    }

    try {
      Map<String, dynamic>? user = await DatabaseHelper.instance.loginUser(email, password);

      if (!mounted) return;

      if (user != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Welcome back, ${user['full_name']}!'), backgroundColor: Colors.green),
        );
        
        Navigator.pushAndRemoveUntil(
          context, 
          MaterialPageRoute(
            builder: (context) => MainNavigation(currentUser: user) 
          ),
          (Route<dynamic> route) => false, 
        );
      } else {
        // FAILED!
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid email or password.'), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Database Error: $e'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFF221F33), Color(0xFF110F18)]),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: const BoxDecoration(color: Color(0xFF2E2A44), shape: BoxShape.circle),
                    child: const Icon(Icons.sports_tennis, size: 40, color: Color(0xFFD49CFF)),
                  ),
                  const SizedBox(height: 32),
                  const Text("THE NEON VELOCITY", style: TextStyle(color: Colors.white70, fontSize: 14, letterSpacing: 2.5, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 48),

                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(color: const Color(0xFF201E30), borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10))]),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("EMAIL", style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                        const SizedBox(height: 10),
                        
                        TextField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress, // Added to show email keyboard
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(filled: true, fillColor: const Color(0xFF2A283C), prefixIcon: const Icon(Icons.email_outlined, color: Colors.white54, size: 20), hintText: "admin@shuttlesync.com", hintStyle: const TextStyle(color: Colors.white38), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none), contentPadding: const EdgeInsets.symmetric(vertical: 18)),
                        ),
                        const SizedBox(height: 24),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text("PASSWORD", style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                            TextButton(
                              onPressed: () {},
                              style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: Size.zero, tapTargetSize: MaterialTapTargetSize.shrinkWrap),
                              child: const Text("Forgot Password?", style: TextStyle(color: Color(0xFFB578FF), fontSize: 12, decoration: TextDecoration.underline, decorationColor: Color(0xFFB578FF))),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        
                        TextField(
                          controller: _passwordController,
                          obscureText: true,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(filled: true, fillColor: const Color(0xFF2A283C), prefixIcon: const Icon(Icons.lock_outline, color: Colors.white54, size: 20), hintText: "password", hintStyle: const TextStyle(color: Colors.white38), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none), contentPadding: const EdgeInsets.symmetric(vertical: 18)),
                        ),
                        const SizedBox(height: 32),

                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: _loginUser, 
                            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFB161FF), foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)), elevation: 0),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text("ENTER COURT", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                                SizedBox(width: 8),
                                Icon(Icons.arrow_forward, size: 20),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text("New player? ", style: TextStyle(color: Colors.white54, fontSize: 13)),
                            GestureDetector(
                              onTap: () {
                                Navigator.push(context, MaterialPageRoute(builder: (context) => const RegisterPage()));
                              },
                              child: const Text("REGISTER", style: TextStyle(color: Color(0xFFFF6A9A), fontSize: 13, fontWeight: FontWeight.bold, letterSpacing: 1.0)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}