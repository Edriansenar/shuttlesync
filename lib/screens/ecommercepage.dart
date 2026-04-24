import 'package:flutter/material.dart';
import 'package:shuttlesync/screens/shoppingcart.dart';
import 'package:shuttlesync/screens/playerdashboard.dart';
import 'package:shuttlesync/database/database_helper.dart'; 

class ShopPage extends StatefulWidget {
  final Map<String, dynamic>? currentUser;
  const ShopPage({super.key, this.currentUser});

  @override
  State<ShopPage> createState() => _ShopPageState();
}

class _ShopPageState extends State<ShopPage> {
  int _selectedCategoryIndex = 0;
  final List<String> _categories = ['All Gear', 'Rackets', 'Shuttlecocks', 'Apparel'];

  List<Map<String, dynamic>> _products = [];
  bool _isLoading = true; 

  @override
  void initState() {
    super.initState();
    _loadProductsFromDB();
  }

  void _loadProductsFromDB() async {
    final dbProducts = await DatabaseHelper.instance.getAllProducts();

    if (!mounted) return;

    List<Map<String, dynamic>> formattedProducts = dbProducts.map((row) {
      bool isLowStock = (row['stock_quantity'] as int) <= (row['low_stock_threshold'] as int);

      String imagePath = 'assets/img/${row['sku']}.png';

      return {
        'id': row['product_id'],
        'title': row['name'],
        'desc': row['description'],
        'price': row['price'],
        'category': row['category'],
        'badge': isLowStock ? 'LOW STOCK' : null,
        'badgeColor': const Color(0xFFFF6A9A), 
        'badgeTextColor': Colors.white,
        'image': imagePath, 
      };
    }).toList();

    setState(() {
      _products = formattedProducts;
      _isLoading = false; 
    });
  }

  @override
  Widget build(BuildContext context) {
    const bgColor = Color(0xFF0F0E17);
    const darkCardColor = Color(0xFF1B1A24);
    const primaryPurple = Color(0xFFBB6AFB);
    const textGray = Color(0xFF8D8E98);

    String selectedCategoryString = _categories[_selectedCategoryIndex];
    List<Map<String, dynamic>> filteredProducts = _products.where((p) {
      if (selectedCategoryString == 'All Gear') return true;
      return p['category'] == selectedCategoryString;
    }).toList();

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
              Navigator.push(context, MaterialPageRoute(builder: (context) => PlayerDashboard(currentUser: widget.currentUser)));
            },
            child: const CircleAvatar(backgroundColor: darkCardColor, child: Icon(Icons.person, color: Colors.white70, size: 20)),
          ),
        ),
        title: const Text("SHUTTLESYNC", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: 1.5, color: primaryPurple)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_bag, color: primaryPurple),
            onPressed: () {
              // --- FIXED: Passed currentUser to the Shopping Cart ---
              Navigator.push(
                context, 
                MaterialPageRoute(builder: (context) => ShoppingCartScreen(currentUser: widget.currentUser))
              );
            },
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text("PRO SHOP", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
                SizedBox(height: 4),
                Text("EQUIP FOR VELOCITY", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.5, color: textGray)),
              ],
            ),
          ),

          SizedBox(
            height: 40,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                bool isSelected = _selectedCategoryIndex == index;
                return GestureDetector(
                  onTap: () => setState(() => _selectedCategoryIndex = index),
                  child: Container(
                    margin: const EdgeInsets.only(right: 12),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(color: isSelected ? primaryPurple : const Color(0xFF22202E), borderRadius: BorderRadius.circular(20)),
                    child: Text(_categories[index], style: TextStyle(color: isSelected ? Colors.black : Colors.white70, fontWeight: FontWeight.bold, fontSize: 13)),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 20),

          Expanded(
            child: _isLoading 
              ? const Center(child: CircularProgressIndicator(color: primaryPurple))
              : filteredProducts.isEmpty
                  ? const Center(child: Text("No items found in this category.", style: TextStyle(color: textGray)))
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
                      itemCount: filteredProducts.length,
                      itemBuilder: (context, index) {
                        return _buildProductCard(filteredProducts[index], darkCardColor, primaryPurple, textGray);
                      },
                    ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard(Map<String, dynamic> product, Color cardColor, Color primaryPurple, Color textGray) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 10, offset: const Offset(0, 5))]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              Container(
                height: 180, width: double.infinity,
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)), 
                  color: Color(0xFF11101A) 
                ),
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)),
                  child: Image.asset(
                    product['image'], 
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return const Center(child: Icon(Icons.image_not_supported, size: 50, color: Colors.white30));
                    },
                  ),
                ),
              ),
              if (product['badge'] != null)
                Positioned(top: 16, left: 16, child: Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(color: product['badgeColor'], borderRadius: BorderRadius.circular(6)), child: Text(product['badge'], style: TextStyle(color: product['badgeTextColor'], fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.0)))),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(product['title'], style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                const SizedBox(height: 8),
                Text(product['desc'], style: TextStyle(color: textGray, fontSize: 13, height: 1.4)),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("\$${product['price'].toStringAsFixed(2)}", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: primaryPurple)),
                    
                    // --- FIXED: Add to Cart Database Logic ---
                    GestureDetector(
                      onTap: () async {
                        if (widget.currentUser != null) {
                          // Insert the item into the SQLite database!
                          await DatabaseHelper.instance.addToCart(widget.currentUser!['user_id'], product['id']);
                          
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${product['title']} added to cart!'), backgroundColor: Colors.green));
                          }
                        } else {
                          // If they are browsing as a guest, warn them
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please log in to add items to your cart.'), backgroundColor: Colors.red));
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(color: product['badge'] == 'LIMITED DROP' ? primaryPurple : const Color(0xFF2A283C), borderRadius: BorderRadius.circular(10)),
                        child: Icon(Icons.add, color: product['badge'] == 'LIMITED DROP' ? Colors.black : Colors.white70, size: 24),
                      ),
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