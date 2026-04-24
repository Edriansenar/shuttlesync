import 'package:flutter/material.dart';
import 'package:shuttlesync/database/database_helper.dart'; // IMPORTANT: Adjust path if needed

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  bool _isPasswordVisible = false;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  void _registerUser() async {
    FocusManager.instance.primaryFocus?.unfocus();

    String name = _nameController.text.trim();
    String email = _emailController.text.trim().toLowerCase();
    String phone = _phoneController.text.trim();
    String password = _passwordController.text.trim();

    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in required fields (Name, Email, Password)'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    try {
      Map<String, dynamic> newUser = {
        'full_name': name,
        'email': email,
        'phone_number': phone,
        'password_hash': password, 
        'role': 'player',          
        'win_rate': 0.0,
        'matches_played': 0
      };

      await DatabaseHelper.instance.insertUser(newUser);

      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Registration Successful! A welcome email has been sent to your inbox.'), 
          backgroundColor: Colors.green,
          duration: Duration(seconds: 4),
        ),
      );
      
      Navigator.pop(context); 

    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Registration failed. Email might already be in use.'), 
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const cardBgColor = Color(0xFF1B1A24);
    const hintGray = Color(0xFFA5A5B1);
    const titlePink = Color(0xFFFA57A1);
    const linkPink = Color(0xFFFF9CCB);
    const inputFillColor = Color(0xFF232231);
    const buttonPurple = Color(0xFFBB6AFB);
    const buttonPinkAccent = Color(0xFFFF9CDE);

    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(color: Color(0xFF0F0E17)),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("SHUTTLESYNC", style: TextStyle(color: titlePink, fontSize: 28, fontWeight: FontWeight.bold, letterSpacing: 2.0)),
                  const SizedBox(height: 8),
                  const Text("Join the court. Elevate your game.", textAlign: TextAlign.center, style: TextStyle(color: hintGray, fontSize: 14, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 48),

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(color: cardBgColor, borderRadius: BorderRadius.circular(16)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildFieldHeader("FULL NAME"),
                        const SizedBox(height: 10),
                        _buildInputField(icon: Icons.person_outline, hintText: "Lee Chong Wei", fillColor: inputFillColor, hintGray: hintGray, controller: _nameController),
                        const SizedBox(height: 24),

                        _buildFieldHeader("EMAIL ADDRESS"),
                        const SizedBox(height: 10),
                        _buildInputField(icon: Icons.email_outlined, hintText: "athlete@shuttlesync.com", fillColor: inputFillColor, hintGray: hintGray, controller: _emailController, keyboardType: TextInputType.emailAddress), 
                        const SizedBox(height: 24),

                        _buildFieldHeader("PHONE NUMBER"),
                        const SizedBox(height: 10),
                        _buildInputField(icon: Icons.phone_outlined, hintText: "+1 (555) 000-0000", fillColor: inputFillColor, hintGray: hintGray, controller: _phoneController, keyboardType: TextInputType.phone), 
                        const SizedBox(height: 24),

                        _buildFieldHeader("PASSWORD"),
                        const SizedBox(height: 10),
                        _buildPasswordField(icon: Icons.lock_outline, hintText: "••••••••", fillColor: inputFillColor, hintGray: hintGray, controller: _passwordController), 
                        const SizedBox(height: 40),

                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: Container(
                            decoration: BoxDecoration(gradient: const LinearGradient(colors: [buttonPurple, buttonPinkAccent]), borderRadius: BorderRadius.circular(14)),
                            child: ElevatedButton(
                              onPressed: _registerUser, 
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent, foregroundColor: Colors.white, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                              child: const Text("Sign Up", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1.0)),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text("Already have an account? ", style: TextStyle(color: hintGray, fontSize: 13)),
                            GestureDetector(
                              onTap: () { Navigator.pop(context); },
                              child: const Text("Log In", style: TextStyle(color: linkPink, fontSize: 13, fontWeight: FontWeight.bold, letterSpacing: 1.0)),
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

  Widget _buildFieldHeader(String text) {
    return Text(text, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.2));
  }

  Widget _buildInputField({required IconData icon, required String hintText, required Color fillColor, required Color hintGray, required TextEditingController controller, TextInputType? keyboardType}) {
    return TextField(
      controller: controller, 
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(filled: true, fillColor: fillColor, prefixIcon: Icon(icon, color: hintGray, size: 20), hintText: hintText, hintStyle: TextStyle(color: hintGray.withOpacity(0.6)), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none), contentPadding: const EdgeInsets.symmetric(vertical: 18)),
    );
  }

  Widget _buildPasswordField({required IconData icon, required String hintText, required Color fillColor, required Color hintGray, required TextEditingController controller}) {
    return TextField(
      controller: controller,
      obscureText: !_isPasswordVisible,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(filled: true, fillColor: fillColor, prefixIcon: Icon(icon, color: hintGray, size: 20), hintText: hintText, hintStyle: TextStyle(color: hintGray.withOpacity(0.6)), suffixIcon: IconButton(icon: Icon(_isPasswordVisible ? Icons.visibility : Icons.visibility_off, color: hintGray, size: 20), onPressed: () { setState(() { _isPasswordVisible = !_isPasswordVisible; }); }), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none), contentPadding: const EdgeInsets.symmetric(vertical: 18)),
    );
  }
}