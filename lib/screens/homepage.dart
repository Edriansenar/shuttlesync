import 'package:flutter/material.dart';
import 'dart:io'; 
import 'package:shuttlesync/screens/loginpage.dart';
import 'package:shuttlesync/screens/registerpage.dart';
import 'package:shuttlesync/screens/shoppingcart.dart';
import 'package:shuttlesync/screens/playerdashboard.dart';
import 'package:shuttlesync/screens/courtbooking.dart'; 
import 'package:shuttlesync/screens/ecommercepage.dart'; 
import 'package:shuttlesync/database/database_helper.dart'; 

class HomePage extends StatelessWidget {
  final Map<String, dynamic>? currentUser;
  
  const HomePage({super.key, this.currentUser});

  @override
  Widget build(BuildContext context) {
    return DashboardScreen(currentUser: currentUser);
  }
}

class DashboardScreen extends StatefulWidget {
  final Map<String, dynamic>? currentUser;

  const DashboardScreen({super.key, this.currentUser});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool get isLoggedIn => widget.currentUser != null;

  @override
  Widget build(BuildContext context) {
    if (!isLoggedIn) {
      return Scaffold(
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: const BoxDecoration(color: Color(0xFF2E2A44), shape: BoxShape.circle),
                    child: const Icon(Icons.sports_tennis, size: 60, color: Color(0xFFD49CFF)),
                  ),
                  const SizedBox(height: 32),
                  Text("SHUTTLESYNC", style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, letterSpacing: 2.0, color: Theme.of(context).colorScheme.secondary)),
                  const SizedBox(height: 16),
                  const Text("You must be a registered player to access the court dashboard and pro shop.", textAlign: TextAlign.center, style: TextStyle(color: Color(0xFF8D8E98), fontSize: 16, height: 1.5)),
                  const SizedBox(height: 48),
                  
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const LoginPage()));
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).primaryColor, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                      child: const Text("Log In", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const RegisterPage()));
                      },
                      style: OutlinedButton.styleFrom(side: BorderSide(color: Theme.of(context).primaryColor, width: 2), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                      child: Text("Register New Player", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Theme.of(context).primaryColor)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    String fullName = widget.currentUser!['full_name'] ?? 'Athlete';
    String firstName = fullName.split(' ')[0];

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ShuttleSyncHeader(currentUser: widget.currentUser),
              const SizedBox(height: 24),
              const Text("Welcome back,", style: TextStyle(color: Color(0xFF8D8E98), fontSize: 16)),
              
              Text("$firstName.", style: Theme.of(context).textTheme.displayLarge),
              
              const SizedBox(height: 24),
              
              StatsSection(
                winRate: widget.currentUser!['win_rate']?.toString() ?? "0",
                matches: widget.currentUser!['matches_played']?.toString() ?? "0",
              ),
              
              const SizedBox(height: 32),
              QuickBookCard(currentUser: widget.currentUser),
              const SizedBox(height: 32),

              // DYNAMIC UPCOMING SESSIONS
              UpcomingSessionsSection(currentUser: widget.currentUser!),
              const SizedBox(height: 32),
              
              // DYNAMIC PRO SHOP DROPS
              ProShopDropsSection(currentUser: widget.currentUser),
              const SizedBox(height: 24), 
            ],
          ),
        ),
      ),
    );
  }
}

class SectionTitle extends StatelessWidget {
  final String title;
  final String actionText;
  final VoidCallback onPressed;

  const SectionTitle({
    super.key,
    required this.title,
    required this.actionText,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleMedium),
        TextButton(
          onPressed: onPressed,
          child: Text(actionText, style: TextStyle(color: Theme.of(context).colorScheme.secondary, fontWeight: FontWeight.w600)),
        ),
      ],
    );
  }
}

class ShuttleSyncHeader extends StatelessWidget {
  final Map<String, dynamic>? currentUser;

  const ShuttleSyncHeader({super.key, this.currentUser});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        GestureDetector(
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => PlayerDashboard(currentUser: currentUser)));
          },
          child: CircleAvatar(
            radius: 20,
            backgroundColor: const Color(0xFF2E3047),
            child: ClipOval(
              child: Image.asset(
                'assets/img/profile.png', 
                width: 40, height: 40, fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => const Icon(Icons.person_outline, color: Colors.white70),
              ),
            ),
          ),
        ),
        Text(
          "SHUTTLESYNC",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, letterSpacing: 1.2, color: Theme.of(context).colorScheme.secondary),
        ),
        IconButton(
          icon: const Icon(Icons.shopping_bag_outlined, color: Colors.white70),
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => ShoppingCartScreen(currentUser: currentUser)));
          },
        ),
      ],
    );
  }
}

class StatsSection extends StatelessWidget {
  final String winRate;
  final String matches;

  const StatsSection({super.key, required this.winRate, required this.matches});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: StatCard(
            label: "WIN RATE",
            value: "$winRate%",
            color: Theme.of(context).colorScheme.secondary,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: StatCard(
            label: "MATCHES",
            value: matches,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}

class StatCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const StatCard({super.key, required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(color: const Color(0xFF1D1E33), borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 1.1)),
          const SizedBox(height: 8),
          Text(value, style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: Colors.white)),
        ],
      ),
    );
  }
}

class QuickBookCard extends StatelessWidget {
  final Map<String, dynamic>? currentUser;

  const QuickBookCard({super.key, this.currentUser});

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;
    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: const Color(0xFF1D1E33),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: primaryColor.withOpacity(0.3), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Secure Your Court", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 8),
          const Text("Reserve your slot ahead of time at ShuttleSync Arena.", style: TextStyle(color: Color(0xFF8D8E98), fontSize: 15, height: 1.4)),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => CourtBookingPage(currentUser: currentUser)));
              },
              style: ElevatedButton.styleFrom(backgroundColor: primaryColor, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)), elevation: 0),
              child: const Text("Go to Reservations", style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}

// --- NEW: DYNAMIC UPCOMING SESSIONS ---
class UpcomingSessionsSection extends StatefulWidget {
  final Map<String, dynamic> currentUser;
  const UpcomingSessionsSection({super.key, required this.currentUser});

  @override
  State<UpcomingSessionsSection> createState() => _UpcomingSessionsSectionState();
}

class _UpcomingSessionsSectionState extends State<UpcomingSessionsSection> {
  List<Map<String, dynamic>> _mySessions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUpcomingSessions();
  }

  void _fetchUpcomingSessions() async {
    int userId = widget.currentUser['user_id'];
    try {
      final db = await DatabaseHelper.instance.database;
      final List<Map<String, dynamic>> localBookings = await db.query(
        'Bookings',
        where: 'user_id = ? AND status != ?',
        whereArgs: [userId, 'CANCELLED'],
        orderBy: 'booking_date ASC, start_time ASC', 
      );
      if (!mounted) return;
      setState(() {
        _mySessions = List<Map<String, dynamic>>.from(localBookings);
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionTitle(
          title: "Upcoming Sessions", 
          actionText: "VIEW ALL", 
          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => PlayerDashboard(currentUser: widget.currentUser)))
        ),
        const SizedBox(height: 16),
        _isLoading 
          ? const Center(child: CircularProgressIndicator())
          : _mySessions.isEmpty
            ? Container(
                width: double.infinity, padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: const Color(0xFF1D1E33), borderRadius: BorderRadius.circular(18)),
                child: const Center(child: Text("You have no upcoming bookings.", style: TextStyle(color: Colors.white54)))
              )
            : SizedBox(
                height: 180,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _mySessions.length,
                  separatorBuilder: (context, index) => const SizedBox(width: 16),
                  itemBuilder: (context, index) => UpcomingSessionCard(booking: _mySessions[index]),
                ),
              ),
      ],
    );
  }
}

class UpcomingSessionCard extends StatelessWidget {
  final Map<String, dynamic> booking;
  const UpcomingSessionCard({super.key, required this.booking});

  @override
  Widget build(BuildContext context) {
    String courtTitle;
    switch(booking['court_id']) {
      case 1: courtTitle = "Championship Court 1"; break;
      case 2: courtTitle = "Championship Court 2"; break;
      case 3: courtTitle = "Standard Court 3"; break;
      case 4: courtTitle = "Standard Court 4"; break;
      case 5: courtTitle = "Practice Court 5"; break;
      case 6: courtTitle = "Practice Court 6"; break;
      default: courtTitle = "Court ${booking['court_id']}";
    }

    return Container(
      width: 300,
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(color: const Color(0xFF1D1E33), borderRadius: BorderRadius.circular(18)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(color: Theme.of(context).primaryColor.withOpacity(0.15), borderRadius: BorderRadius.circular(20)),
                child: Row(
                  children: [
                    CircleAvatar(radius: 3, backgroundColor: Theme.of(context).primaryColor),
                    const SizedBox(width: 6),
                    Text(booking['status'], style: TextStyle(color: Theme.of(context).primaryColor, fontSize: 12, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              const Icon(Icons.sports_tennis_outlined, color: Colors.white30, size: 20),
            ],
          ),
          const SizedBox(height: 16),
          Text(courtTitle, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 4),
          Text("Duration: ${booking['duration_minutes']} min", style: const TextStyle(color: Color(0xFF8D8E98), fontSize: 14)),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: const [
                  CircleAvatar(radius: 12, backgroundColor: Color(0xFF2E3047), child: Icon(Icons.person, size: 16, color: Colors.white70)),
                  SizedBox(width: -8),
                  CircleAvatar(radius: 12, backgroundColor: Color(0xFF3E4057), child: Icon(Icons.person, size: 16, color: Colors.white70)),
                ],
              ),
              Text("${booking['booking_date']} @ ${booking['start_time']}", style: TextStyle(color: Theme.of(context).colorScheme.secondary, fontWeight: FontWeight.bold, fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }
}

// --- DYNAMIC PRO SHOP DROPS ---
class ProShopDropsSection extends StatefulWidget {
  final Map<String, dynamic>? currentUser;
  const ProShopDropsSection({super.key, this.currentUser});

  @override
  State<ProShopDropsSection> createState() => _ProShopDropsSectionState();
}

class _ProShopDropsSectionState extends State<ProShopDropsSection> {
  List<Map<String, dynamic>> _latestProducts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchLatestProducts();
  }

  void _fetchLatestProducts() async {
    final products = await DatabaseHelper.instance.getAllProducts();
    if (!mounted) return;
    setState(() {
      _latestProducts = products.reversed.take(3).toList();
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionTitle(
          title: "Pro Shop Drops", 
          actionText: "EXPLORE STORE", 
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => ShopPage(currentUser: widget.currentUser)));
          }
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 300, 
          child: _isLoading 
            ? const Center(child: CircularProgressIndicator())
            : _latestProducts.isEmpty 
              ? const Center(child: Text("No items available in the shop.", style: TextStyle(color: Colors.white54)))
              : ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    if (_latestProducts.isNotEmpty) 
                      ProShopProductCard(product: _latestProducts[0]),
                    const SizedBox(width: 16),
                    if (_latestProducts.length > 1) 
                      CompactProductList(products: _latestProducts.sublist(1)),
                  ],
                ),
        ),
      ],
    );
  }
}

class ProShopProductCard extends StatelessWidget {
  final Map<String, dynamic> product;

  const ProShopProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    String? imgPath = product['image_path'];

    return Container(
      width: 200,
      decoration: BoxDecoration(color: const Color(0xFF1D1E33), borderRadius: BorderRadius.circular(18)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 150, width: double.infinity,
            decoration: const BoxDecoration(
              color: Color(0xFF111226), 
              borderRadius: BorderRadius.only(topLeft: Radius.circular(18), topRight: Radius.circular(18))
            ),
            child: ClipRRect(
              borderRadius: const BorderRadius.only(topLeft: Radius.circular(18), topRight: Radius.circular(18)),
              child: imgPath != null && imgPath.isNotEmpty
                  ? Image.file(File(imgPath), fit: BoxFit.cover, errorBuilder: (c,e,s) => const Icon(Icons.broken_image, color: Colors.white30, size: 40))
                  : const Center(child: Icon(Icons.sports_tennis, size: 80, color: Colors.white10)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(color: const Color(0xFF2E3047), borderRadius: BorderRadius.circular(5)),
                  child: const Text("NEW ARRIVAL", style: TextStyle(color: Colors.white60, fontSize: 10, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(height: 10),
                Text(product['name'], maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                const SizedBox(height: 4),
                Text(product['description'], maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Color(0xFF8D8E98), fontSize: 12)),
                const SizedBox(height: 10),
                Text("₱${product['price'].toStringAsFixed(2)}", style: TextStyle(color: Theme.of(context).colorScheme.secondary, fontWeight: FontWeight.bold, fontSize: 16)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class CompactProductList extends StatelessWidget {
  final List<Map<String, dynamic>> products;

  const CompactProductList({super.key, required this.products});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (products.isNotEmpty)
          CompactProductItem(product: products[0]),
        const SizedBox(height: 16),
        if (products.length > 1)
          CompactProductItem(product: products[1]),
      ],
    );
  }
}

class CompactProductItem extends StatelessWidget {
  final Map<String, dynamic> product;

  const CompactProductItem({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    String? imgPath = product['image_path'];
    
    return Container(
      width: 250,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: const Color(0xFF1D1E33), borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          Container(
            width: 50, height: 50,
            decoration: BoxDecoration(color: const Color(0xFF111226), borderRadius: BorderRadius.circular(8)),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: imgPath != null && imgPath.isNotEmpty
                  ? Image.file(File(imgPath), fit: BoxFit.cover, errorBuilder: (c,e,s) => const Icon(Icons.broken_image, color: Colors.white30))
                  : const Icon(Icons.shopping_bag, color: Colors.white30),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(product['name'], maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 14)),
                const SizedBox(height: 2),
                Text(product['category'] ?? 'Gear', style: const TextStyle(color: Color(0xFF8D8E98), fontSize: 12)),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text("₱${product['price'].toStringAsFixed(0)}", style: TextStyle(color: Theme.of(context).colorScheme.secondary, fontWeight: FontWeight.bold, fontSize: 14)),
        ],
      ),
    );
  }
}