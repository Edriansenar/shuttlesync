import 'package:flutter/material.dart';
import 'package:etherealapp/widgets/nav_bar.dart';

class AboutUsPage extends StatelessWidget {
  const AboutUsPage({super.key});

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
            onPressed: () {},
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 24),
            
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  'https://images.unsplash.com/photo-1499951360447-b19be8fe80f5?q=80&w=1000&auto=format&fit=crop', 
                  width: double.infinity,
                  height: 200,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: double.infinity,
                      height: 200,
                      color: const Color(0xFFE5E7EB),
                      child: const Icon(Icons.image, color: Colors.grey, size: 50),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 32),
            
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                'The Essence of\nSimplicity.',
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: Color(0xFF1F2937), height: 1.15),
              ),
            ),
            const SizedBox(height: 16),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                'We believe that the most powerful tools are the ones that disappear into your workflow. Ethereal was designed to eliminate the noise of modern software.',
                style: TextStyle(fontSize: 16, color: Color(0xFF4B5563), height: 1.6),
              ),
            ),
            const SizedBox(height: 40),
            
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.auto_awesome, color: Color(0xFF0D5CEB), size: 28),
                    SizedBox(height: 16),
                    Text('Intentional Design', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1F2937))),
                    SizedBox(height: 8),
                    Text('Every pixel serves a purpose. We reject clutter in favor of clarity and focus.', style: TextStyle(fontSize: 14, color: Color(0xFF6B7280), height: 1.5)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(color: const Color(0xFFF3F6FA), borderRadius: BorderRadius.circular(12)),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.speed, color: Color(0xFF0D5CEB), size: 28),
                    SizedBox(height: 16),
                    Text('Effortless Speed', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1F2937))),
                    SizedBox(height: 8),
                    Text('Optimized for humans. Built with the fastest modern technologies to ensure zero friction.', style: TextStyle(fontSize: 14, color: Color(0xFF6B7280), height: 1.5)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 48),
            
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Container(
                decoration: const BoxDecoration(border: Border(left: BorderSide(color: Color(0xFFB1C8FA), width: 4))),
                padding: const EdgeInsets.only(left: 20),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('THE MISSION', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.2, color: Color(0xFF0D5CEB))),
                    SizedBox(height: 12),
                    Text('Ethereal began as a weekend project to solve a personal frustration: apps that demand too much of our attention. Our mission is to return that time to you by creating an interface that is as calm as it is capable.', style: TextStyle(fontSize: 16, color: Color(0xFF4B5563), height: 1.6)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 40),
            
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RichText(
                      text: const TextSpan(
                        style: TextStyle(fontSize: 16, color: Color(0xFF4B5563), height: 1.6, fontFamily: 'Roboto'),
                        children: [
                          TextSpan(text: "Whether you're organizing your day or managing a complex project, our philosophy remains the same: "),
                          TextSpan(text: "Focus on the output, not the tool.", style: TextStyle(color: Color(0xFF0D5CEB), fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Divider(color: Color(0xFFF3F4F6), thickness: 1),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Container(
                          width: 48, height: 48,
                          decoration: BoxDecoration(color: const Color(0xFFDFE6FF), borderRadius: BorderRadius.circular(12)),
                          alignment: Alignment.center,
                          child: const Text('EA', style: TextStyle(color: Color(0xFF0D5CEB), fontWeight: FontWeight.bold, fontSize: 16)),
                        ),
                        const SizedBox(width: 16),
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Ethereal Architects', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1F2937))),
                            SizedBox(height: 2),
                            Text('Est. 2024', style: TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 80),
            
            Container(
              width: double.infinity,
              color: const Color(0xFFF3F4F6),
              padding: const EdgeInsets.symmetric(vertical: 40),
              child: Column(
                children: [
                  const Text('Ethereal Essentialist', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF1F2937))),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _footerLink('Login'),
                      const SizedBox(width: 24),
                      _footerLink('Register'),
                      const SizedBox(width: 24),
                      _footerLink('Privacy'),
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
      
      bottomNavigationBar: const CustomNavBar(selectedIndex: 1),
    );
  }

  Widget _footerLink(String text) {
    return InkWell(
      onTap: () {},
      child: Text(text, style: const TextStyle(fontSize: 14, color: Color(0xFF6B7280))),
    );
  }
}