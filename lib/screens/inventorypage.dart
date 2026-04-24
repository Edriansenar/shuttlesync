import 'package:flutter/material.dart';

class InventoryPage extends StatefulWidget {
  const InventoryPage({super.key});

  @override
  State<InventoryPage> createState() => _InventoryPageState();
}

class _InventoryPageState extends State<InventoryPage> {
  // Mock Data for the Inventory (Easily replaceable with your SQLite database)
  final List<Map<String, dynamic>> _inventory = [
    {
      'id': 1,
      'name': 'AeroStrike Pro X1',
      'sku': 'AS-PRO-X1-BLK',
      'qty': 124,
      'status': 'IN STOCK',
      'isLowStock': false,
      'icon': Icons.sports_tennis,
    },
    {
      'id': 2,
      'name': 'Tournament Shuttles (12pk)',
      'sku': 'TS-12-FEA-WHT',
      'qty': 8,
      'status': 'LOW STOCK',
      'isLowStock': true,
      'icon': Icons.sports_kabaddi, // Placeholder for shuttles
    },
    {
      'id': 3,
      'name': 'Velocity Light V2',
      'sku': 'VL-V2-WHT',
      'qty': 56,
      'status': 'IN STOCK',
      'isLowStock': false,
      'icon': Icons.sports_tennis,
    },
    {
      'id': 4,
      'name': 'Court Grip Pro Shoes',
      'sku': 'CG-PRO-SH-NAVY',
      'qty': 42,
      'status': 'IN STOCK',
      'isLowStock': false,
      'icon': Icons.dry_cleaning, // Placeholder for shoes
    },
  ];

  @override
  Widget build(BuildContext context) {
    const bgColor = Color(0xFFF4F4F9); // Light background like the court booking page
    const darkCardColor = Color(0xFF1B1A28); // Dark navy cards
    const primaryPurple = Color(0xFFBB6AFB);
    const accentPink = Color(0xFFFF6A9A);
    const textGray = Color(0xFF8D8E98);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: CircleAvatar(
            backgroundColor: darkCardColor,
            child: const Icon(Icons.person, color: Colors.white70, size: 20),
          ),
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
      
      // --- Floating Add Product Button ---
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Container(
        height: 54,
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [primaryPurple, Color(0xFFFF9CDE)]),
          borderRadius: BorderRadius.circular(27),
          boxShadow: [
            BoxShadow(color: primaryPurple.withOpacity(0.4), blurRadius: 15, offset: const Offset(0, 5)),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(27),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Open Add Product Modal")));
            },
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.add, color: Colors.white, size: 20),
                  SizedBox(width: 8),
                  Text(
                    "ADD NEW PRODUCT",
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1.0, fontSize: 13),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),

      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- Fixed Header Section ---
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "INVENTORY",
                  style: TextStyle(
                    fontSize: 32, 
                    fontWeight: FontWeight.w900, 
                    color: Color(0xFFDCDCE5), // Very light grey to match design
                    letterSpacing: 1.0,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  "REAL-TIME STOCK CONTROL",
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.5, color: textGray),
                ),
                const SizedBox(height: 24),

                // --- Top Summary Cards ---
                Row(
                  children: [
                    Expanded(
                      child: _buildSummaryCard("TOTAL ASSETS", "842", primaryPurple, darkCardColor),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildSummaryCard("LOW STOCK", "14", accentPink, darkCardColor),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 10),

          // --- Scrollable Inventory List ---
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.only(left: 24.0, right: 24.0, bottom: 80.0), // Extra bottom padding for the FAB
              itemCount: _inventory.length,
              itemBuilder: (context, index) {
                final item = _inventory[index];
                return _buildInventoryCard(item, darkCardColor, primaryPurple, accentPink, textGray);
              },
            ),
          ),
        ],
      ),
    );
  }

  // --- Widget Builders ---

  Widget _buildSummaryCard(String title, String value, Color valueColor, Color cardColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: Colors.white54, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
          const SizedBox(height: 8),
          Text(value, style: TextStyle(color: valueColor, fontSize: 24, fontWeight: FontWeight.w900)),
        ],
      ),
    );
  }

  Widget _buildInventoryCard(Map<String, dynamic> item, Color darkCardColor, Color primaryPurple, Color accentPink, Color textGray) {
    bool isLow = item['isLowStock'];

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: darkCardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 5)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- Image Area with Badge ---
          Stack(
            children: [
              Container(
                height: 160,
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Color(0xFF11101A), // Darker inner background
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)),
                ),
                // Replace this Icon with an Image widget when your assets are ready
                child: Center(
                  child: Icon(item['icon'], size: 80, color: Colors.white10),
                ),
              ),
              Positioned(
                top: 16,
                left: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: isLow ? accentPink.withOpacity(0.15) : primaryPurple.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircleAvatar(radius: 3, backgroundColor: isLow ? accentPink : primaryPurple),
                      const SizedBox(width: 6),
                      Text(
                        item['status'],
                        style: TextStyle(
                          color: isLow ? accentPink : primaryPurple,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // --- Product Data Area ---
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['name'],
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const SizedBox(height: 4),
                Text(
                  "SKU: ${item['sku']}",
                  style: TextStyle(color: textGray, fontSize: 11, letterSpacing: 1.0),
                ),
                const SizedBox(height: 20),
                
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("QUANTITY", style: TextStyle(color: Colors.white54, fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                        const SizedBox(height: 4),
                        Text(
                          item['qty'].toString(),
                          style: TextStyle(
                            fontSize: 20, 
                            fontWeight: FontWeight.bold, 
                            color: isLow ? accentPink : Colors.white,
                          ),
                        ),
                      ],
                    ),
                    
                    // --- Action Buttons ---
                    Row(
                      children: [
                        _buildActionButton(Icons.edit, () {}),
                        const SizedBox(width: 12),
                        _buildActionButton(Icons.delete_outline, () {}),
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

  Widget _buildActionButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: const BoxDecoration(
          color: Color(0xFF2A283C), // Slightly lighter grey for buttons
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white70, size: 18),
      ),
    );
  }
}