import 'package:flutter/material.dart';
import 'package:shuttlesync/database/database_helper.dart'; // IMPORTANT: Added database import

class ContactUsPage extends StatefulWidget {
  const ContactUsPage({super.key});

  @override
  State<ContactUsPage> createState() => _ContactUsPageState();
}

class _ContactUsPageState extends State<ContactUsPage> {
  // Form Controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();
  bool _isSending = false; 

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  void _sendMessage() async {
    String name = _nameController.text.trim();
    String email = _emailController.text.trim();
    String message = _messageController.text.trim();

    // 1. Validation
    if (name.isEmpty || email.isEmpty || message.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill in all fields before sending."), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _isSending = true);
    FocusManager.instance.primaryFocus?.unfocus(); 

    await DatabaseHelper.instance.insertContactMessage({
      'name': name,
      'email': email,
      'message': message,
      'date_sent': DateTime.now().toIso8601String(), 
    });

    if (!mounted) return;

    setState(() => _isSending = false);
    _nameController.clear();
    _emailController.clear();
    _messageController.clear();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Message Sent! Our support team will review it shortly."), backgroundColor: Colors.green),
    );
  }

  @override
  Widget build(BuildContext context) {
    const bgColor = Color(0xFF0F0E17);
    const darkCardColor = Color(0xFF1B1A24);
    const primaryPurple = Color(0xFFBB6AFB);
    const accentPink = Color(0xFFFF6A9A);
    const textGray = Color(0xFF8D8E98);
    const inputFillColor = Color(0xFF232231);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white70, size: 20),
          onPressed: () => Navigator.pop(context), 
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Text(
              "Nocturne Court",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 1.0,
              ),
            ),
          ],
        ),
        centerTitle: true,
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16.0),
            child: CircleAvatar(
              radius: 14,
              backgroundColor: Color(0xFF2E2A44),
              child: Icon(Icons.person, color: Colors.white70, size: 16),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "CONNECT WITH SHUTTLESYNC",
              style: TextStyle(color: accentPink, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.5),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Text("Get in ", style: TextStyle(fontSize: 40, fontWeight: FontWeight.w900, color: Colors.white)),
                ShaderMask(
                  shaderCallback: (bounds) => const LinearGradient(
                    colors: [accentPink, primaryPurple],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ).createShader(bounds),
                  child: const Text(
                    "Touch",
                    style: TextStyle(fontSize: 40, fontWeight: FontWeight.w900, color: Colors.white),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              "Whether you're looking to book a championship-grade court or inquiring about pro-shop gear, our team is ready to assist your journey.",
              style: TextStyle(color: textGray, fontSize: 14, height: 1.5),
            ),
            const SizedBox(height: 32),

            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(color: darkCardColor, borderRadius: BorderRadius.circular(20)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildFormLabel("FULL NAME", primaryPurple),
                  const SizedBox(height: 8),
                  _buildTextField(controller: _nameController, hint: "Alex Chen", fillColor: inputFillColor),
                  const SizedBox(height: 20),

                  _buildFormLabel("EMAIL ADDRESS", primaryPurple),
                  const SizedBox(height: 8),
                  _buildTextField(controller: _emailController, hint: "alex@shuttlesync.com", fillColor: inputFillColor, isEmail: true),
                  const SizedBox(height: 20),

                  _buildFormLabel("YOUR MESSAGE", primaryPurple),
                  const SizedBox(height: 8),
                  _buildTextField(controller: _messageController, hint: "Tell us how we can help you today...", fillColor: inputFillColor, maxLines: 4),
                  const SizedBox(height: 24),

                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(colors: [primaryPurple, Color(0xFFD49CFF)]),
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [BoxShadow(color: primaryPurple.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4))],
                      ),
                      child: ElevatedButton(
                        onPressed: _isSending ? null : _sendMessage, // Wired to DB function
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        child: _isSending 
                          ? const CircularProgressIndicator(color: Color(0xFF332A4C))
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Text("Send Message", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF332A4C))),
                                SizedBox(width: 8),
                                Icon(Icons.send, color: Color(0xFF332A4C), size: 18),
                              ],
                            ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            _buildContactCard(
              icon: Icons.location_on,
              title: "Location",
              content: "88 Kinetic Blvd,\nSports District, NY 10012",
              iconColor: primaryPurple,
              cardColor: darkCardColor,
            ),
            const SizedBox(height: 16),
            _buildContactCard(
              icon: Icons.email,
              title: "Email",
              content: "support@shuttlesync.com\ninfo@nocturnecourt.com",
              iconColor: accentPink,
              cardColor: darkCardColor,
            ),
            const SizedBox(height: 16),
            _buildContactCard(
              icon: Icons.phone,
              title: "Phone",
              content: "+1 (555) 234-SYNC\nMon-Sun: 6am - Midnight",
              iconColor: const Color(0xFFFF9CDE),
              cardColor: darkCardColor,
            ),
            const SizedBox(height: 16),
            
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: darkCardColor, borderRadius: BorderRadius.circular(16)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: const BoxDecoration(color: Color(0xFF2A283C), shape: BoxShape.circle),
                    child: const Icon(Icons.share, color: primaryPurple, size: 20),
                  ),
                  const SizedBox(height: 16),
                  const Text("Social", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  Row(
                    children: const [
                      Icon(Icons.language, color: textGray, size: 20),
                      SizedBox(width: 16),
                      Icon(Icons.chat_bubble_outline, color: textGray, size: 20),
                      SizedBox(width: 16),
                      Icon(Icons.camera_alt_outlined, color: textGray, size: 20),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            Container(
              height: 180,
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFF110F18),
                borderRadius: BorderRadius.circular(16),
                image: const DecorationImage(
                  image: AssetImage('assets/img/map_placeholder.png'), // Add your map image here
                  fit: BoxFit.cover,
                  opacity: 0.5,
                ),
              ),
              child: Stack(
                children: [
                  // Fake map pins for aesthetic
                  const Center(child: Icon(Icons.map, color: Colors.white10, size: 60)), 
                  
                  Positioned(
                    bottom: 16,
                    left: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(color: const Color(0xFF1B1A24).withOpacity(0.9), borderRadius: BorderRadius.circular(20)),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          CircleAvatar(radius: 4, backgroundColor: accentPink),
                          SizedBox(width: 8),
                          Text("LIVE OPERATIONS HUB", style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 48),
            const Divider(color: Color(0xFF2A283C), height: 1),
            const SizedBox(height: 32),


            _buildFAQSection("Booking Issues?", "Check our instant court availability matrix for real-time status.", textGray),
            const SizedBox(height: 24),
            _buildFAQSection("Membership", "Join the Pro Tier for priority booking and equipment discounts.", textGray),
            const SizedBox(height: 24),
            _buildFAQSection("Venue Rental", "Hosting a tournament? Contact our events coordinator directly.", textGray),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }


  Widget _buildFormLabel(String text, Color highlightColor) {
    return Text(
      text,
      style: TextStyle(color: highlightColor, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.5),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required Color fillColor,
    int maxLines = 1,
    bool isEmail = false,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: isEmail ? TextInputType.emailAddress : TextInputType.text,
      style: const TextStyle(color: Colors.white, fontSize: 14),
      decoration: InputDecoration(
        filled: true,
        fillColor: fillColor,
        hintText: hint,
        hintStyle: const TextStyle(color: Color(0xFF4B495C)),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        contentPadding: const EdgeInsets.all(16),
      ),
    );
  }

  Widget _buildContactCard({required IconData icon, required String title, required String content, required Color iconColor, required Color cardColor}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: const BoxDecoration(color: Color(0xFF2A283C), shape: BoxShape.circle),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(height: 16),
          Text(title, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(content, style: const TextStyle(color: Color(0xFF8D8E98), fontSize: 13, height: 1.5)),
        ],
      ),
    );
  }

  Widget _buildFAQSection(String title, String desc, Color textGray) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Text(desc, style: TextStyle(color: textGray, fontSize: 13, height: 1.4)),
      ],
    );
  }
}