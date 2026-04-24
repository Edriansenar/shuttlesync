import 'package:flutter/material.dart';

class AnalyticsPage extends StatefulWidget {
  const AnalyticsPage({super.key});

  @override
  State<AnalyticsPage> createState() => _AnalyticsPageState();
}

class _AnalyticsPageState extends State<AnalyticsPage> {
  int _selectedTimeframeIndex = 1; 
  final List<String> _timeframes = ['7 Days', '30 Days', 'YTD'];

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
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white70, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "SHUTTLESYNC",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.5,
            color: primaryPurple,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_bag, color: primaryPurple),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(left: 24.0, right: 24.0, bottom: 40.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Header Section ---
            const SizedBox(height: 10),
            const Text(
              "Analytics",
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 4),
            const Text(
              "REAL-TIME COURT & REVENUE METRICS",
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.2, color: textGray),
            ),
            const SizedBox(height: 24),

            Row(
              children: List.generate(_timeframes.length, (index) {
                bool isSelected = _selectedTimeframeIndex == index;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedTimeframeIndex = index;
                    });
                  },
                  child: Container(
                    margin: const EdgeInsets.only(right: 12),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFF332A4C) : darkCardColor,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isSelected ? primaryPurple.withOpacity(0.5) : Colors.transparent,
                        width: 1,
                      ),
                    ),
                    child: Text(
                      _timeframes[index],
                      style: TextStyle(
                        color: isSelected ? primaryPurple : Colors.white70,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 24),

            _buildMetricCard(
              title: "TOTAL REVENUE",
              value: "\$24,590",
              trend: "+12.5%",
              trendUp: true,
              icon: Icons.payments_outlined,
              cardColor: darkCardColor,
              accentColor: primaryPurple,
            ),
            const SizedBox(height: 16),
            _buildMetricCard(
              title: "COURT UTILIZATION",
              value: "87%",
              trend: "+4.2%",
              trendUp: true,
              icon: Icons.sports_tennis,
              cardColor: darkCardColor,
              accentColor: accentPink,
            ),
            const SizedBox(height: 16),
            _buildMetricCard(
              title: "ACTIVE PLAYERS",
              value: "1,432",
              trend: "0.0%",
              trendUp: null, // Neutral
              icon: Icons.people_outline,
              cardColor: darkCardColor,
              accentColor: primaryPurple,
            ),
            const SizedBox(height: 16),
            _buildMetricCard(
              title: "SHOP ORDERS",
              value: "342",
              trend: "-2.1%",
              trendUp: false,
              icon: Icons.shopping_cart_outlined,
              cardColor: darkCardColor,
              accentColor: accentPink,
            ),
            const SizedBox(height: 32),

            const Text("Revenue Trends", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 4),
            const Text("Daily gross income for current month", style: TextStyle(color: textGray, fontSize: 13)),
            const SizedBox(height: 20),
            _buildCustomBarChart(),
            const SizedBox(height: 32),

            const Text("Top Selling Gear", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 16),
            _buildTopSellingList(darkCardColor, primaryPurple, accentPink, textGray),
            const SizedBox(height: 24),

            Center(
              child: TextButton(
                onPressed: () {},
                child: const Text(
                  "View All Inventory",
                  style: TextStyle(color: primaryPurple, fontSize: 14, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required String trend,
    required bool? trendUp,
    required IconData icon,
    required Color cardColor,
    required Color accentColor,
  }) {
    Color trendColor;
    IconData trendIcon;
    if (trendUp == true) {
      trendColor = const Color(0xFFFF6A9A); 
      trendIcon = Icons.trending_up;
    } else if (trendUp == false) {
      trendColor = const Color(0xFFFF6A9A); 
      trendIcon = Icons.trending_down;
    } else {
      trendColor = const Color(0xFF8D8E98);
      trendIcon = Icons.trending_flat;
    }

    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -20,
            top: -20,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: accentColor.withOpacity(0.05),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(color: Color(0xFF8D8E98), fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                    const SizedBox(height: 12),
                    Text(value, style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(trendIcon, color: trendColor, size: 16),
                        const SizedBox(width: 4),
                        Text(trend, style: TextStyle(color: trendColor, fontSize: 13, fontWeight: FontWeight.bold)),
                        const SizedBox(width: 6),
                        const Text("vs last month", style: TextStyle(color: Color(0xFF8D8E98), fontSize: 13)),
                      ],
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2A283C),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: accentColor, size: 20),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomBarChart() {
    final List<Map<String, dynamic>> chartData = [
      {'day': 'Mon', 'val': 0.35, 'color': const Color(0xFF9166FF)},
      {'day': 'Tue', 'val': 0.55, 'color': const Color(0xFF9166FF)},
      {'day': 'Wed', 'val': 0.80, 'color': const Color(0xFFFF6A9A)}, 
      {'day': 'Thu', 'val': 0.45, 'color': const Color(0xFF9166FF)},
      {'day': 'Fri', 'val': 0.95, 'color': const Color(0xFFFF6A9A)}, 
      {'day': 'Sat', 'val': 0.90, 'color': const Color(0xFFFF6A9A)}, 
      {'day': 'Sun', 'val': 0.65, 'color': const Color(0xFF9166FF)},
    ];

    return Container(
      height: 200,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1B1A24),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: chartData.map((data) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Expanded(
                child: Container(
                  width: 32,
                  alignment: Alignment.bottomCenter,
                  decoration: BoxDecoration(
                    color: const Color(0xFF110F18), 
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: FractionallySizedBox(
                    heightFactor: data['val'], 
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            data['color'].withOpacity(0.5),
                            data['color'],
                          ],
                        ),
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(data['day'], style: const TextStyle(color: Color(0xFF8D8E98), fontSize: 11, fontWeight: FontWeight.bold)),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTopSellingList(Color cardColor, Color primaryPurple, Color accentPink, Color textGray) {
    final List<Map<String, dynamic>> items = [
      {'name': 'AeroPro Strike', 'cat': 'Racket', 'units': '124', 'icon': Icons.sports_tennis, 'color': accentPink},
      {'name': 'Feather Elite Tubes', 'cat': 'Shuttles', 'units': '482', 'icon': Icons.kitchen, 'color': accentPink},
      {'name': 'Grip Master Pro', 'cat': 'Accessories', 'units': '215', 'icon': Icons.dry_cleaning, 'color': primaryPurple},
    ];

    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: items.map((item) {
          return ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            leading: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFF2A283C),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(item['icon'], color: item['color'], size: 18),
            ),
            title: Text(item['name'], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
            subtitle: Text(item['cat'], style: TextStyle(color: textGray, fontSize: 12)),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(item['units'], style: TextStyle(color: item['color'], fontWeight: FontWeight.bold, fontSize: 16)),
                Text("units", style: TextStyle(color: textGray, fontSize: 10)),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}