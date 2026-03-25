import 'package:flutter/material.dart';
import 'package:etherealapp/widgets/input_fields.dart';
import 'package:etherealapp/widgets/submit_button.dart';
import 'package:etherealapp/widgets/nav_bar.dart'; 

class ContactUsPage extends StatelessWidget {
  const ContactUsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        title: const Text(
          'Ethereal Contact Us',
          style: TextStyle(color: Color(0xFF1F2937), fontWeight: FontWeight.w900, fontSize: 20),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 32),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                'Get in touch.',
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: Color(0xFF1F2937), height: 1.15),
              ),
            ),
            const SizedBox(height: 16),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                'Have a question or just want to say hello? Our team is here to help you find your essence.',
                style: TextStyle(fontSize: 16, color: Color(0xFF6B7280), height: 1.5),
              ),
            ),
            const SizedBox(height: 32),
            
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 15, offset: const Offset(0, 8))],
                ),
                child: Column(
                  children: [
                    const CustomInputField(label: 'NAME', hintText: 'Evelyn Vane'),
                    const SizedBox(height: 20),
                    const CustomInputField(label: 'EMAIL', hintText: 'hello@ethereal.com'),
                    const SizedBox(height: 20),
                    const CustomInputField(label: 'MESSAGE', hintText: 'How can we help?', maxLines: 4),
                    const SizedBox(height: 24),
                    CustomSubmitButton(
                      text: 'Send Message',
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Message Sent!')),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 48),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  _buildInfoRow(Icons.email, 'SUPPORT', 'support@ethereal.com'),
                  const SizedBox(height: 24),
                  _buildInfoRow(Icons.location_on, 'STUDIO', '124 Blue Sky Blvd, London'),
                ],
              ),
            ),
            const SizedBox(height: 64),
          ],
        ),
      ),
      
      bottomNavigationBar: const CustomNavBar(selectedIndex: 2),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Container(
          width: 52, height: 52,
          decoration: BoxDecoration(color: const Color(0xFFE5E7EB), borderRadius: BorderRadius.circular(12)),
          child: Icon(icon, color: const Color(0xFF0D5CEB), size: 24),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.2, color: Color(0xFF4B5563))),
            const SizedBox(height: 4),
            Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Color(0xFF1F2937))),
          ],
        ),
      ],
    );
  }
}