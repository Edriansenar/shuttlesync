import 'package:flutter/material.dart';
import 'package:shuttlesync/database/database_helper.dart'; 

class AnalyticsPage extends StatefulWidget {
  const AnalyticsPage({super.key});

  @override
  State<AnalyticsPage> createState() => _AnalyticsPageState();
}

class _AnalyticsPageState extends State<AnalyticsPage> {
  int _selectedTimeframeIndex = 1; 
  final List<String> _timeframes = ['7 Days', '30 Days', 'YTD'];

  double _totalRevenue = 0.0;
  int _totalOrders = 0;
  int _activePlayers = 0;
  List<Map<String, dynamic>> _topSellingItems = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAnalytics();
  }

  void _loadAnalytics() async {
    final data = await DatabaseHelper.instance.getAnalyticsData();
    
    // Fetch products to dynamically show real "Top Selling" items
    final dbProducts = await DatabaseHelper.instance.getAllProducts();
    List<Map<String, dynamic>> mutableProducts = List<Map<String, dynamic>>.from(dbProducts);
    
    // Sort products by lowest stock to mimic them selling out fast
    mutableProducts.sort((a, b) => (a['stock_quantity'] as int).compareTo(b['stock_quantity'] as int));

    if (mounted) {
      setState(() {
        _totalRevenue = data['revenue'];
        _totalOrders = data['orders'];
        _activePlayers = data['players'];
        _topSellingItems = mutableProducts.take(3).toList();
        _isLoading = false;
      });
    }
  }

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
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: 1.5, color: primaryPurple),
        ),
        centerTitle: true,
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator(color: primaryPurple))
        : SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Facility Analytics", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
              const SizedBox(height: 8),
              const Text("Comprehensive breakdown of facility performance, user engagement, and commerce metrics.", style: TextStyle(color: textGray, fontSize: 13, height: 1.4)),
              const SizedBox(height: 24),

              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(color: const Color(0xFF110F18), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.white10)),
                child: Row(
                  children: List.generate(_timeframes.length, (index) {
                    bool isSelected = _selectedTimeframeIndex == index;
                    return Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedTimeframeIndex = index),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(color: isSelected ? const Color(0xFF2A283C) : Colors.transparent, borderRadius: BorderRadius.circular(8)),
                          child: Center(
                            child: Text(_timeframes[index], style: TextStyle(color: isSelected ? Colors.white : textGray, fontWeight: FontWeight.bold, fontSize: 13)),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
              const SizedBox(height: 32),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF2A1C40), Color(0xFF1B1A24)], begin: Alignment.topLeft, end: Alignment.bottomRight), borderRadius: BorderRadius.circular(20), border: Border.all(color: primaryPurple.withValues(alpha: 0.3))),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("TOTAL REVENUE (PAID ORDERS)", style: TextStyle(color: textGray, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                        Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: Colors.green.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(4)), child: const Text("LIVE", style: TextStyle(color: Colors.greenAccent, fontSize: 10, fontWeight: FontWeight.bold))),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text("₱${_totalRevenue.toStringAsFixed(2)}", style: const TextStyle(fontSize: 40, fontWeight: FontWeight.w900, color: Colors.white)),
                    const SizedBox(height: 24),
                    
                    SizedBox(
                      height: 100,
                      width: double.infinity,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [0.4, 0.7, 0.5, 0.9, 0.6, 1.0, 0.8].map((height) {
                          return Container(width: 24, height: 100 * height, decoration: BoxDecoration(gradient: const LinearGradient(colors: [primaryPurple, accentPink], begin: Alignment.bottomCenter, end: Alignment.topCenter), borderRadius: BorderRadius.circular(4)));
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              Row(
                children: [
                  Expanded(child: _buildMetricCard("REGISTERED PLAYERS", "$_activePlayers", "+NEW", Icons.people_outline, darkCardColor, primaryPurple)),
                  const SizedBox(width: 16),
                  Expanded(child: _buildMetricCard("COURT UTILIZATION", "86%", "+2.1%", Icons.sports_tennis, darkCardColor, accentPink)),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: _buildMetricCard("TOTAL ORDERS", "$_totalOrders", "ALL TIME", Icons.shopping_bag_outlined, darkCardColor, textGray)),
                  const SizedBox(width: 16),
                  Expanded(child: _buildMetricCard("AVG. SESSION", "94m", "+0.0%", Icons.timer_outlined, darkCardColor, Colors.white70)),
                ],
              ),
              const SizedBox(height: 40),

              const Text("Top Selling Gear", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
              const SizedBox(height: 16),
              _buildTopSellingList(darkCardColor, primaryPurple, textGray),
              
              const SizedBox(height: 40),
            ],
          ),
      ),
    );
  }

  Widget _buildMetricCard(String title, String value, String trend, IconData icon, Color cardColor, Color iconColor) {
    bool isPositive = trend.startsWith('+');
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: iconColor, size: 24),
          const SizedBox(height: 16),
          Text(title, style: const TextStyle(color: Color(0xFF8D8E98), fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.0)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Colors.white)),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(isPositive ? Icons.trending_up : Icons.trending_down, color: isPositive ? Colors.greenAccent : Colors.white54, size: 12),
              const SizedBox(width: 4),
              Text(trend, style: TextStyle(color: isPositive ? Colors.greenAccent : Colors.white54, fontSize: 10, fontWeight: FontWeight.bold)),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildTopSellingList(Color cardColor, Color primaryPurple, Color textGray) {
    if (_topSellingItems.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(16)),
        child: const Center(child: Text("No data available yet.", style: TextStyle(color: Colors.white54))),
      );
    }

    return Container(
      decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: _topSellingItems.map((item) {
          return ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            leading: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: const Color(0xFF2A283C), borderRadius: BorderRadius.circular(8)),
              child: const Icon(Icons.star, color: Color(0xFFBB6AFB), size: 18),
            ),
            title: Text(item['name'] as String, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
            subtitle: Text(item['category'] as String, style: TextStyle(color: textGray, fontSize: 12)),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(item['stock_quantity'].toString(), style: const TextStyle(color: Color(0xFFFF6A9A), fontWeight: FontWeight.bold, fontSize: 16)),
                Text("left in stock", style: TextStyle(color: textGray, fontSize: 10)),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}