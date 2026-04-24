import 'package:flutter/material.dart';
import 'package:shuttlesync/database/database_helper.dart';

class PlayerSettingsPage extends StatefulWidget {
  final Map<String, dynamic>? currentUser;

  const PlayerSettingsPage({super.key, this.currentUser});

  @override
  State<PlayerSettingsPage> createState() => _PlayerSettingsPageState();
}

class _PlayerSettingsPageState extends State<PlayerSettingsPage> {
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    // Pre-fill the text fields with the user's current data!
    _nameController = TextEditingController(text: widget.currentUser?['full_name'] ?? '');
    _emailController = TextEditingController(text: widget.currentUser?['email'] ?? '');
    _passwordController = TextEditingController(text: widget.currentUser?['password'] ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _saveCredentials() async {
    if (widget.currentUser == null) return;

    setState(() => _isSaving = true);

    String newName = _nameController.text.trim();
    String newEmail = _emailController.text.trim().toLowerCase();
    String newPassword = _passwordController.text.trim();

    if (newName.isEmpty || newEmail.isEmpty || newPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('All fields are required.'), backgroundColor: Colors.red));
      setState(() => _isSaving = false);
      return;
    }

    // Update the SQLite Database
    await DatabaseHelper.instance.updateUser(
      widget.currentUser!['user_id'], 
      newName, 
      newEmail, 
      newPassword
    );

    if (!mounted) return;
    setState(() => _isSaving = false);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Credentials updated successfully!'), backgroundColor: Colors.green),
    );
    
    Navigator.pop(context); // Go back to dashboard
  }

  @override
  Widget build(BuildContext context) {
    const bgColor = Color(0xFF0F0E17);
    const primaryPurple = Color(0xFFBB6AFB);
    const inputFillColor = Color(0xFF1B1A24);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios, color: Colors.white70, size: 20), onPressed: () => Navigator.pop(context)),
        title: const Text("ACCOUNT SETTINGS", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1.5, color: primaryPurple)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Edit Credentials", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 8),
            const Text("Update your personal information below.", style: TextStyle(color: Color(0xFF8D8E98), fontSize: 14)),
            const SizedBox(height: 32),

            _buildFormLabel("FULL NAME"),
            const SizedBox(height: 8),
            _buildTextField(controller: _nameController, icon: Icons.person_outline, inputFillColor: inputFillColor),
            const SizedBox(height: 20),

            _buildFormLabel("EMAIL ADDRESS"),
            const SizedBox(height: 8),
            _buildTextField(controller: _emailController, icon: Icons.email_outlined, inputFillColor: inputFillColor),
            const SizedBox(height: 20),

            _buildFormLabel("PASSWORD"),
            const SizedBox(height: 8),
            _buildTextField(controller: _passwordController, icon: Icons.lock_outline, inputFillColor: inputFillColor, isObscure: true),
            const SizedBox(height: 40),

            SizedBox(
              width: double.infinity, height: 56,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _saveCredentials,
                style: ElevatedButton.styleFrom(backgroundColor: primaryPurple, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                child: _isSaving 
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text("SAVE CHANGES", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87, letterSpacing: 1.5)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormLabel(String text) {
    return Text(text, style: const TextStyle(color: Color(0xFF8D8E98), fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.2));
  }

  Widget _buildTextField({required TextEditingController controller, required IconData icon, required Color inputFillColor, bool isObscure = false}) {
    return TextField(
      controller: controller,
      obscureText: isObscure,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        filled: true, fillColor: inputFillColor,
        prefixIcon: Icon(icon, color: Colors.white54, size: 20),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        contentPadding: const EdgeInsets.symmetric(vertical: 18),
      ),
    );
  }
}