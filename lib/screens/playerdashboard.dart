import 'package:flutter/material.dart';
import 'package:shuttlesync/database/database_helper.dart'; 
import 'package:shuttlesync/screens/shoppingcart.dart'; 
import 'package:shuttlesync/screens/playersettings.dart';
import 'package:shuttlesync/screens/contactus.dart';
import 'package:shuttlesync/screens/loginpage.dart';

class PlayerDashboard extends StatefulWidget {
  final Map<String, dynamic>? currentUser;

  const PlayerDashboard({super.key, this.currentUser});

  @override
  State<PlayerDashboard> createState() => _PlayerDashboardState();
}

class _PlayerDashboardState extends State<PlayerDashboard> {
  int _selectedTab = 0; 
  
  List<Map<String, dynamic>> _myBookings = [];
  bool _isLoadingBookings = true;

  @override
  void initState() {
    super.initState();
    _fetchMyBookings();
  }

  // --- FETCH BOOKINGS & RETURN A FUTURE FOR THE PULL-TO-REFRESH ---
  Future<void> _fetchMyBookings() async {
    if (widget.currentUser == null) {
      setState(() => _isLoadingBookings = false);
      return;
    }

    int userId = widget.currentUser!['user_id'];
    final db = await DatabaseHelper.instance.database;
    
    List<Map<String, dynamic>> bookings = await db.query(
      'Bookings',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'booking_date DESC, start_time DESC', 
    );

    if (!mounted) return;
    
    setState(() {
      _myBookings = bookings;
      _isLoadingBookings = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    const bgColor = Color(0xFF0F0E17);
    const darkCardColor = Color(0xFF1B1A24);
    const primaryPurple = Color(0xFFBB6AFB);
    const accentPink = Color(0xFFFF6A9A);
    const textGray = Color(0xFF8D8E98);

    String fullName = widget.currentUser?['full_name'] ?? 'Guest Player';
    String matches = widget.currentUser?['matches_played']?.toString() ?? '0';
    String winRate = widget.currentUser?['win_rate']?.toString() ?? '0';

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: GestureDetector(
            onTap: () {
              if (Navigator.canPop(context)) {
                Navigator.pop(context);
              }
            },
            child: const CircleAvatar(
              backgroundColor: Color(0xFF1B1A28),
              child: Icon(Icons.arrow_back_ios_new, color: Colors.white70, size: 16),
            ),
          ),
        ),
        title: const Text(
          "SHUTTLESYNC",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: 1.5, color: primaryPurple),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_bag_outlined, color: textGray),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => ShoppingCartScreen(currentUser: widget.currentUser)));
            },
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.white70),
            color: const Color(0xFF1B1A24), 
            onSelected: (value) async { 
              if (value == 'settings') {
                Navigator.push(context, MaterialPageRoute(builder: (context) => PlayerSettingsPage(currentUser: widget.currentUser)));
              } else if (value == 'contact') {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const ContactUsPage()));
              } else if (value == 'logout') {
                await Future.delayed(const Duration(milliseconds: 150));
                if (context.mounted) {
                  Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => const LoginPage()), 
                    (route) => false
                  );
                }
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(value: 'settings', child: Text('Account Settings', style: TextStyle(color: Colors.white))),
              const PopupMenuItem<String>(value: 'contact', child: Text('Contact Support', style: TextStyle(color: Colors.white))),
              const PopupMenuDivider(),
              const PopupMenuItem<String>(value: 'logout', child: Text('Log Out', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold))),
            ],
          ),
          const SizedBox(width: 8), 
        ],
      ),
      
      floatingActionButton: FloatingActionButton(
        onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("New action initiated!"))),
        backgroundColor: primaryPurple,
        child: const Icon(Icons.add, color: Colors.white),
      ),

      // ==========================================
      // NEW: REFRESH INDICATOR WRAPPER
      // Pull down to instantly load new bookings!
      // ==========================================
      body: RefreshIndicator(
        onRefresh: _fetchMyBookings, // Calls the database when pulled
        color: primaryPurple,
        backgroundColor: darkCardColor,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(), // Important: Allows pull-to-refresh even if the screen isn't full
          padding: const EdgeInsets.only(bottom: 80.0), 
          child: Column(
            children: [
              const SizedBox(height: 20),
              Center(
                child: Stack(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: primaryPurple, width: 3),
                      ),
                      child: CircleAvatar(
                        radius: 50,
                        backgroundColor: const Color(0xFF2E2A44),
                        child: ClipOval(
                          child: Image.asset(
                            'assets/img/profile.png', 
                            width: 100, height: 100, fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => const Icon(Icons.person, size: 50, color: Colors.white30),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(color: accentPink, borderRadius: BorderRadius.circular(12)),
                        child: const Text("ELITE", style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.0)),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const Text("PRO PLAYER", style: TextStyle(color: accentPink, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 2.0)),
              const SizedBox(height: 8),
              Text(fullName, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
              const SizedBox(height: 24),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildStatColumn(matches, "MATCHES"),
                  Container(height: 30, width: 1, color: Colors.white24, margin: const EdgeInsets.symmetric(horizontal: 24)),
                  _buildStatColumn("$_myBookings", "BOOKINGS", overrideText: _myBookings.length.toString()), 
                ],
              ),
              const SizedBox(height: 16),
              _buildStatColumn("$winRate%", "WIN RATE"),
              const SizedBox(height: 24),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => PlayerSettingsPage(currentUser: widget.currentUser)));
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryPurple,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                    child: const Text("Edit Profile", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    decoration: const BoxDecoration(color: Color(0xFF2A283C), shape: BoxShape.circle),
                    child: IconButton(
                      icon: const Icon(Icons.settings, color: Colors.white70),
                      onPressed: () {
                         Navigator.push(context, MaterialPageRoute(builder: (context) => PlayerSettingsPage(currentUser: widget.currentUser)));
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Row(
                  children: [
                    _buildTab("MY BOOKINGS", 0, accentPink),
                    const SizedBox(width: 24),
                    _buildTab("ORDER HISTORY", 1, accentPink),
                  ],
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.0),
                child: Divider(color: Color(0xFF2A283C), height: 1),
              ),
              const SizedBox(height: 24),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: _selectedTab == 0 
                    ? _buildBookingsView(darkCardColor, primaryPurple, accentPink, textGray) 
                    : _buildOrdersView(darkCardColor, primaryPurple, accentPink, textGray),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- Helper Widgets ---

  Widget _buildStatColumn(String rawValue, String label, {String? overrideText}) {
    return Column(
      children: [
        Text(overrideText ?? rawValue, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.2, color: Color(0xFF8D8E98))),
      ],
    );
  }

  Widget _buildTab(String title, int index, Color accentPink) {
    bool isSelected = _selectedTab == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedTab = index),
      child: Column(
        children: [
          Text(title, style: TextStyle(color: isSelected ? Colors.white : const Color(0xFF8D8E98), fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 8),
          Container(
            height: 3, width: 40,
            decoration: BoxDecoration(color: isSelected ? accentPink : Colors.transparent, borderRadius: BorderRadius.circular(2)),
          )
        ],
      ),
    );
  }

  // --- Views ---

  Widget _buildBookingsView(Color darkCardColor, Color primaryPurple, Color accentPink, Color textGray) {
    if (_isLoadingBookings) {
      return const Center(child: Padding(padding: EdgeInsets.all(40), child: CircularProgressIndicator()));
    }

    if (_myBookings.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(40),
        decoration: BoxDecoration(color: darkCardColor, borderRadius: BorderRadius.circular(16)),
        child: const Column(
          children: [
            Icon(Icons.sports_tennis, size: 40, color: Colors.white24),
            SizedBox(height: 16),
            Text("No active bookings.", style: TextStyle(color: Colors.white70, fontSize: 16, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text("Hit the courts and schedule your first match!", textAlign: TextAlign.center, style: TextStyle(color: Colors.white54, fontSize: 14)),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ..._myBookings.map((booking) {
          Color iconColor = booking['status'] == 'CONFIRMED' ? primaryPurple : textGray;
          
          return Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: _buildBookingCard(
              courtName: "Court ${booking['court_id']} - Neon Arena", 
              location: "Duration: ${booking['duration_minutes']} min",
              date: booking['booking_date'], 
              time: booking['start_time'], 
              status: booking['status'], 
              iconColor: iconColor,
              darkCardColor: darkCardColor,
            ),
          );
        }), // FIXED: Added .toList() to prevent spread errors

        const SizedBox(height: 24),
        
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: darkCardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border(left: BorderSide(color: accentPink, width: 4)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Ready to level up?", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text("You've played ${_myBookings.length} sessions. Keep booking to reach 'Legendary' status!", style: TextStyle(color: textGray, fontSize: 13, height: 1.4)),
              const SizedBox(height: 20),
              Container(
                height: 8, width: double.infinity,
                decoration: BoxDecoration(color: const Color(0xFF110F18), borderRadius: BorderRadius.circular(4)),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: 0.4,
                  child: Container(decoration: BoxDecoration(gradient: LinearGradient(colors: [primaryPurple, accentPink]), borderRadius: BorderRadius.circular(4))),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBookingCard({
    required String courtName,
    required String location,
    required String date,
    required String time,
    required String status,
    required Color iconColor,
    Color titleColor = Colors.white,
    required Color darkCardColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: darkCardColor, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 10, offset: const Offset(0, 5))]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(Icons.sports_tennis, color: iconColor, size: 24),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: const Color(0xFF332A4C), borderRadius: BorderRadius.circular(6)),
                child: Text(status, style: TextStyle(color: iconColor, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.0)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(courtName, style: TextStyle(color: titleColor, fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(location, style: const TextStyle(color: Color(0xFF8D8E98), fontSize: 13)),
          const SizedBox(height: 20),
          Row(children: [const Icon(Icons.calendar_today, color: Colors.white54, size: 16), const SizedBox(width: 8), Text(date, style: const TextStyle(color: Colors.white, fontSize: 13))]),
          const SizedBox(height: 12),
          Row(children: [const Icon(Icons.access_time, color: Colors.white54, size: 16), const SizedBox(width: 8), Text(time, style: const TextStyle(color: Colors.white, fontSize: 13))]),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("MANAGE", style: TextStyle(color: iconColor, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
              Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: const Color(0xFF2A283C), borderRadius: BorderRadius.circular(8)), child: const Icon(Icons.qr_code, color: Colors.white70, size: 20)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOrdersView(Color darkCardColor, Color primaryPurple, Color accentPink, Color textGray) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Recent Orders", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
        const SizedBox(height: 16),
        _buildOrderCard(orderNum: "SYNC-8892", item: "Volt-Striker Carbon Racket (x1)", date: "Oct 20, 2023", price: "\$189.00", payment: "PAID VIA APPLE PAY", status: "IN TRANSIT", action: "TRACK PACKAGE", icon: Icons.shopping_cart_outlined, statusColor: accentPink, darkCardColor: darkCardColor),
        const SizedBox(height: 16),
        _buildOrderCard(orderNum: "SYNC-8410", item: "Pro Grip Tape (x3), Shuttlecocks (x12)", date: "Oct 12, 2023", price: "\$54.50", payment: "PAID VIA VISA", status: "DELIVERED", action: "VIEW RECEIPT", icon: Icons.inventory_2_outlined, statusColor: textGray, darkCardColor: darkCardColor),
      ],
    );
  }

  Widget _buildOrderCard({required String orderNum, required String item, required String date, required String price, required String payment, required String status, required String action, required IconData icon, required Color statusColor, required Color darkCardColor}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: darkCardColor, borderRadius: BorderRadius.circular(16)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: const Color(0xFF0F0E17), borderRadius: BorderRadius.circular(12)), child: Icon(icon, color: const Color(0xFFBB6AFB), size: 24)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("ORDER #$orderNum", style: const TextStyle(color: Color(0xFF8D8E98), fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.0)),
                const SizedBox(height: 6),
                Text(item, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold, height: 1.4)),
                const SizedBox(height: 4),
                Text("Ordered on $date", style: const TextStyle(color: Color(0xFF8D8E98), fontSize: 11)),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [Text(price, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)), const SizedBox(height: 2), Text(payment, style: const TextStyle(color: Color(0xFF8D8E98), fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 0.5))],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Row(children: [CircleAvatar(radius: 3, backgroundColor: statusColor), const SizedBox(width: 4), Text(status, style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.0))]),
                        const SizedBox(height: 8),
                        Text(action, style: const TextStyle(color: Color(0xFFBB6AFB), fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.0)),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}