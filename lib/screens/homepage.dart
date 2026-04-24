import 'package:flutter/material.dart';
import 'package:shuttlesync/screens/loginpage.dart';
import 'package:shuttlesync/screens/registerpage.dart';
import 'package:shuttlesync/screens/shoppingcart.dart';
import 'package:shuttlesync/screens/playerdashboard.dart';

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
              const QuickBookCard(),
              const SizedBox(height: 32),
              const UpcomingSessionsSection(),
              const SizedBox(height: 32),
              const ProShopDropsSection(),
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
            Navigator.push(context, MaterialPageRoute(builder: (context) => const ShoppingCartScreen()));
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
  const QuickBookCard({super.key});

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
          const Text("Prime time slots at Neon Arena are filling up fast for this evening.", style: TextStyle(color: Color(0xFF8D8E98), fontSize: 15, height: 1.4)),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(color: const Color(0xFF111226), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFF2E3047), width: 1)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text("Tonight", style: TextStyle(color: Color(0xFF8D8E98), fontSize: 13)),
                    SizedBox(height: 4),
                    Text("19:00 - 21:00", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                  ],
                ),
                Icon(Icons.access_time, color: primaryColor),
              ],
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Quick booking initiated!"))),
              style: ElevatedButton.styleFrom(backgroundColor: primaryColor, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)), elevation: 0),
              child: const Text("Quick Book", style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}

class UpcomingSessionsSection extends StatelessWidget {
  const UpcomingSessionsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SectionTitle(title: "Upcoming Sessions", actionText: "VIEW ALL", onPressed: () {}),
        const SizedBox(height: 16),
        SizedBox(
          height: 180,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: 2,
            separatorBuilder: (context, index) => const SizedBox(width: 16),
            itemBuilder: (context, index) => const UpcomingSessionCard(),
          ),
        ),
      ],
    );
  }
}

class UpcomingSessionCard extends StatelessWidget {
  const UpcomingSessionCard({super.key});

  @override
  Widget build(BuildContext context) {
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
                    Text("Confirmed", style: TextStyle(color: Theme.of(context).primaryColor, fontSize: 12, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              const Icon(Icons.sports_tennis_outlined, color: Colors.white30, size: 20),
            ],
          ),
          const SizedBox(height: 16),
          const Text("Neon Arena - Court 4", style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 4),
          const Text("Doubles Match • Competitive", style: TextStyle(color: Color(0xFF8D8E98), fontSize: 14)),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: const [
                  CircleAvatar(radius: 12, backgroundColor: Color(0xFF2E3047), child: Icon(Icons.person, size: 16, color: Colors.white70)),
                  SizedBox(width: -8),
                  CircleAvatar(radius: 12, backgroundColor: Color(0xFF3E4057), child: Icon(Icons.person, size: 16, color: Colors.white70)),
                  SizedBox(width: 8),
                  Text("+1", style: TextStyle(color: Color(0xFF8D8E98), fontSize: 14)),
                ],
              ),
              Text("Tomorrow, 18:00", style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold, fontSize: 14)),
            ],
          ),
        ],
      ),
    );
  }
}

class ProShopDropsSection extends StatelessWidget {
  const ProShopDropsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SectionTitle(title: "Pro Shop Drops", actionText: "EXPLORE STORE", onPressed: () {}),
        const SizedBox(height: 16),
        SizedBox(
          height: 300, 
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: const [
              ProShopProductCard(),
              SizedBox(width: 16),
              CompactProductList(),
            ],
          ),
        ),
      ],
    );
  }
}

class ProShopProductCard extends StatelessWidget {
  const ProShopProductCard({super.key});

  @override
  Widget build(BuildContext context) {
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
              child: Image.asset(
                'assets/img/RKT-001.png', 
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => const Center(child: Icon(Icons.sports_tennis, size: 80, color: Colors.white10)),
              ),
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
                const Text("AeroStrike Pro X", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                const SizedBox(height: 4),
                const Text("Engineered for extreme...", style: TextStyle(color: Color(0xFF8D8E98), fontSize: 12)),
                const SizedBox(height: 10),
                Text("\$249.00", style: TextStyle(color: Theme.of(context).colorScheme.secondary, fontWeight: FontWeight.bold, fontSize: 16)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class CompactProductList extends StatelessWidget {
  const CompactProductList({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: const [
        CompactProductItem(
          name: "AeroFlight Feathers", 
          desc: "Tournament Grade", 
          price: "\$35.00", 
          fallbackIcon: Icons.sports_kabaddi_outlined,
          imagePath: 'assets/img/SHT-001.png', 
        ),
        SizedBox(height: 16),
        CompactProductItem(
          name: "Sync Dry-Fit Tee", 
          desc: "Midnight Navy", 
          price: "\$45.00", 
          fallbackIcon: Icons.checkroom_outlined,
          imagePath: 'assets/img/APP-001.png', 
        ),
      ],
    );
  }
}

class CompactProductItem extends StatelessWidget {
  final String name, desc, price, imagePath;
  final IconData fallbackIcon;

  const CompactProductItem({
    super.key, 
    required this.name, 
    required this.desc, 
    required this.price, 
    required this.fallbackIcon,
    required this.imagePath
  });

  @override
  Widget build(BuildContext context) {
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
              child: Image.asset(
                imagePath,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Icon(fallbackIcon, color: Colors.white30),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 14)),
                const SizedBox(height: 2),
                Text(desc, style: const TextStyle(color: Color(0xFF8D8E98), fontSize: 12)),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(price, style: TextStyle(color: Theme.of(context).colorScheme.secondary, fontWeight: FontWeight.bold, fontSize: 14)),
        ],
      ),
    );
  }
}