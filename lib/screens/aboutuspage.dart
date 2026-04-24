import 'package:flutter/material.dart';

class AboutUsPage extends StatelessWidget {
  const AboutUsPage({super.key});

  @override
  Widget build(BuildContext context) {
    const bgColor = Color(0xFF0F0E17);
    const darkCardColor = Color(0xFF1B1A24);
    const primaryPurple = Color(0xFFBB6AFB);
    const accentPink = Color(0xFFFF6A9A);
    const textGray = Color(0xFF8D8E98);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.white70),
          onPressed: () {}, // Opens drawer if connected
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.sports_tennis, color: primaryPurple, size: 20),
            SizedBox(width: 8),
            Text(
              "Nocturne Court", // Using the title from your mockup's app bar
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ==========================================
            // 1. HERO & HERITAGE SECTION
            // ==========================================
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2A283C),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      "OUR HERITAGE",
                      style: TextStyle(color: textGray, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.5),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text("Redefining the", style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: Colors.white, height: 1.1)),
                  // Gradient Text for "Kinetic Court"
                  ShaderMask(
                    shaderCallback: (bounds) => const LinearGradient(
                      colors: [primaryPurple, accentPink],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ).createShader(bounds),
                    child: const Text(
                      "Kinetic Court",
                      style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: Colors.white, height: 1.1),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "ShuttleSync was born from the sweat and speed of the midnight match. We believe badminton isn't just a sport—it's a high-velocity dialogue between precision and instinct.",
                    style: TextStyle(color: textGray, fontSize: 14, height: 1.5),
                  ),
                ],
              ),
            ),

            // ==========================================
            // 2. MISSION CARD
            // ==========================================
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(color: darkCardColor, borderRadius: BorderRadius.circular(20)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: const BoxDecoration(color: primaryPurple, shape: BoxShape.circle),
                      child: const Icon(Icons.rocket_launch, color: Colors.white, size: 20),
                    ),
                    const SizedBox(height: 16),
                    const Text("Our Mission", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    const Text(
                      "To empower every athlete with seamless access to elite environments, precision equipment, and a community that moves at the speed of light. We synchronize the court experience so you can focus on the smash.",
                      style: TextStyle(color: textGray, fontSize: 13, height: 1.5),
                    ),
                    const SizedBox(height: 20),
                    const Align(
                      alignment: Alignment.bottomRight,
                      child: Text("SINCE 2024", style: TextStyle(color: primaryPurple, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 48),

            // ==========================================
            // 3. CORE PRINCIPLES
            // ==========================================
            Center(
              child: Column(
                children: [
                  const Text("Core Principles", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
                  const SizedBox(height: 8),
                  Container(height: 3, width: 40, color: accentPink),
                ],
              ),
            ),
            const SizedBox(height: 32),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                children: [
                  _buildPrincipleCard("01", Icons.lightbulb, "Innovation", "Pushing the boundaries of digital court management with predictive booking algorithms and immersive gear analytics.", darkCardColor, primaryPurple, textGray),
                  const SizedBox(height: 16),
                  _buildPrincipleCard("02", Icons.people, "Community", "Fostering a sanctuary where enthusiasts and professionals collide, creating a global network of competitive spirit.", darkCardColor, accentPink, textGray),
                  const SizedBox(height: 16),
                  _buildPrincipleCard("03", Icons.settings, "Excellence", "Uncompromising quality in every aspect—from the tension of our strings to the latency of our platform.", darkCardColor, accentPink, textGray), // Used accentPink again based on your mockup icon color
                ],
              ),
            ),
            const SizedBox(height: 48),

            // ==========================================
            // 4. LEADERSHIP TEAM
            // ==========================================
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("ARCHITECTS OF SPEED", style: TextStyle(color: accentPink, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                  const SizedBox(height: 4),
                  const Text("The Leadership Team", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
                  const SizedBox(height: 8),
                  const Text("Meet the visionaries behind the most advanced badminton ecosystem in the digital age.", style: TextStyle(color: textGray, fontSize: 13, height: 1.4)),
                  const SizedBox(height: 32),

                  _buildLeaderCard("Marcus Vane", "FOUNDER & CEO", darkCardColor, textGray),
                  const SizedBox(height: 24),
                  _buildLeaderCard("Elena Chen", "HEAD OF OPERATIONS", darkCardColor, textGray, roleColor: accentPink),
                  const SizedBox(height: 24),
                  _buildLeaderCard("David Park", "DESIGN DIRECTOR", darkCardColor, textGray, roleColor: accentPink),
                  const SizedBox(height: 24),
                  _buildLeaderCard("Sonia Rodriguez", "CTO", darkCardColor, textGray),
                ],
              ),
            ),
            const SizedBox(height: 48),

            // ==========================================
            // 5. STATS & METRICS
            // ==========================================
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                children: [
                  // Global Reach Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(color: darkCardColor, borderRadius: BorderRadius.circular(20)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("GLOBAL REACH", style: TextStyle(color: textGray, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                        const SizedBox(height: 8),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            const Text("12k+", style: TextStyle(fontSize: 48, fontWeight: FontWeight.w900, color: Colors.white)),
                            const SizedBox(width: 12),
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: const [
                                  Text("Active\nAthletes", style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold, height: 1.2)),
                                  SizedBox(height: 4),
                                  Text("Monthly\nBookings", style: TextStyle(color: textGray, fontSize: 10, height: 1.2)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Precision Focus Gradient Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [primaryPurple, Color(0xFFD49CFF)]),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text("PRECISION FOCUS", style: TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                        SizedBox(height: 8),
                        Text("99%", style: TextStyle(fontSize: 48, fontWeight: FontWeight.w900, color: Colors.white)),
                        SizedBox(height: 4),
                        Text("Uptime & Reliability", style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 48),

            // ==========================================
            // 6. FOOTER
            // ==========================================
            Container(
              width: double.infinity,
              color: const Color(0xFF0A090F), // Slightly darker black for footer
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("ShuttleSync", style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: primaryPurple, letterSpacing: 1.0)),
                  const SizedBox(height: 12),
                  const Text(
                    "Elevating the badminton experience through relentless innovation and a deep respect for the sport.",
                    style: TextStyle(color: textGray, fontSize: 12, height: 1.5),
                  ),
                  const SizedBox(height: 24),
                  
                  // Social Icons Placeholder
                  Row(
                    children: [
                      Container(padding: const EdgeInsets.all(8), decoration: const BoxDecoration(color: Color(0xFF1B1A24), shape: BoxShape.circle), child: const Icon(Icons.language, color: Colors.white70, size: 16)),
                      const SizedBox(width: 12),
                      Container(padding: const EdgeInsets.all(8), decoration: const BoxDecoration(color: Color(0xFF1B1A24), shape: BoxShape.circle), child: const Icon(Icons.camera_alt_outlined, color: Colors.white70, size: 16)),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // Links Columns
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("Platform", style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 12),
                            _buildFooterLink("Booking"),
                            _buildFooterLink("Gear"),
                            _buildFooterLink("Events"),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("Support", style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 12),
                            _buildFooterLink("Terms"),
                            _buildFooterLink("Privacy"),
                            _buildFooterLink("Contact"),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 48),
                  const Center(
                    child: Text("© 2024 SHUTTLESYNC STUDIO. ALL RIGHTS RESERVED.", style: TextStyle(color: Color(0xFF4B495C), fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 1.0)),
                  ),
                  const SizedBox(height: 20), // Bottom padding
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- Helper Widgets ---

  Widget _buildPrincipleCard(String number, IconData icon, String title, String desc, Color darkCardColor, Color iconColor, Color textGray) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: darkCardColor, borderRadius: BorderRadius.circular(20)),
      child: Stack(
        children: [
          // Background Number
          Positioned(
            right: 0,
            top: -10,
            child: Text(
              number,
              style: const TextStyle(fontSize: 64, fontWeight: FontWeight.w900, color: Color(0xFF22202E)), // Faded text color
            ),
          ),
          // Content
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: iconColor, size: 28),
              const SizedBox(height: 16),
              Text(title, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(desc, style: TextStyle(color: textGray, fontSize: 12, height: 1.5)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLeaderCard(String name, String role, Color darkCardColor, Color textGray, {Color roleColor = const Color(0xFFBB6AFB)}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Placeholder for the AI Portrait Images
        Container(
          height: 350,
          width: double.infinity,
          decoration: BoxDecoration(
            color: darkCardColor,
            borderRadius: BorderRadius.circular(20),
            // TODO: When you have the images, replace the color above with this DecorationImage:
            // image: DecorationImage(image: AssetImage('assets/your_image.png'), fit: BoxFit.cover),
          ),
          child: Stack(
            children: [
              const Center(child: Icon(Icons.person, size: 80, color: Colors.white10)), // Placeholder icon
              Positioned(
                bottom: 16,
                left: 16,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: const Color(0xFF0F0E17).withOpacity(0.6), shape: BoxShape.circle),
                  child: const Icon(Icons.share, color: Colors.white, size: 16),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Text(name, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(role, style: TextStyle(color: roleColor, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
      ],
    );
  }

  Widget _buildFooterLink(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(title, style: const TextStyle(color: Color(0xFF8D8E98), fontSize: 13)),
    );
  }
}