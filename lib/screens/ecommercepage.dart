import 'package:flutter/material.dart';
import 'package:shuttlesync/screens/shoppingcart.dart';
import 'package:shuttlesync/database/database_helper.dart'; 
import 'dart:io';

class ShopPage extends StatefulWidget {
  final Map<String, dynamic>? currentUser;
  const ShopPage({super.key, this.currentUser});

  @override
  State<ShopPage> createState() => _ShopPageState();
}

class _ShopPageState extends State<ShopPage> {
  int _selectedCategoryIndex = 0;
  // Make sure these match the admin categories!
  final List<String> _categories = ['All Gear', 'Rackets', 'Shuttlecocks', 'Apparel', 'Accessories'];

  List<Map<String, dynamic>> _products = [];
  bool _isLoading = true; 

  @override
  void initState() {
    super.initState();
    _loadProductsFromDB();
  }

  // Changed to return a Future so the RefreshIndicator knows when it's done
  Future<void> _loadProductsFromDB() async {
    final dbProducts = await DatabaseHelper.instance.getAllProducts();
    if (!mounted) return;

    List<Map<String, dynamic>> formattedProducts = dbProducts.map((row) {
      bool isLowStock = (row['stock_quantity'] as int) <= (row['low_stock_threshold'] as int);

      return {
        'id': row['product_id'],
        'title': row['name'],
        'desc': row['description'],
        'price': row['price'],
        'category': row['category'],
        'sku': row['sku'],
        'badge': isLowStock ? 'LOW STOCK' : null,
        'badgeColor': const Color(0xFFFF6A9A), 
        'badgeTextColor': Colors.white,
        'image_path': row['image_path'], 
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
        // REPLACE your leading with this conditional logic:
        leading: Navigator.canPop(context) 
            ? IconButton(
                icon: const Icon(Icons.arrow_back_ios, color: Colors.white70),
                onPressed: () => Navigator.pop(context),
              )
            : null, // Hides the button if it's inside the Bottom Tab Navigation
        title: const Text("PRO SHOP", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: primaryPurple)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_bag, color: primaryPurple),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => ShoppingCartScreen(currentUser: widget.currentUser))),
          ),
        ],
      ),
      body: Column(
        children: [
          SizedBox(
            height: 60,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
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
          const SizedBox(height: 10),

          // PULL TO REFRESH ADDED HERE
          Expanded(
            child: RefreshIndicator(
              onRefresh: _loadProductsFromDB,
              color: primaryPurple,
              backgroundColor: darkCardColor,
              child: _isLoading 
                ? const Center(child: CircularProgressIndicator(color: primaryPurple))
                : filteredProducts.isEmpty
                    ? ListView(
                        physics: const AlwaysScrollableScrollPhysics(), // Ensures it can still be pulled down even when empty
                        children: const [
                          SizedBox(height: 100),
                          Center(child: Text("No items found in this category. Pull down to refresh.", style: TextStyle(color: textGray))),
                        ],
                      )
                    : ListView.builder(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
                        itemCount: filteredProducts.length,
                        itemBuilder: (context, index) => _buildProductCard(filteredProducts[index], darkCardColor, primaryPurple, textGray),
                      ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard(Map<String, dynamic> product, Color cardColor, Color primaryPurple, Color textGray) {
    String? imgPath = product['image_path'];

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 180, width: double.infinity,
            decoration: const BoxDecoration(color: Color(0xFF11101A), borderRadius: BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16))),
            child: ClipRRect(
              borderRadius: const BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)),
              child: imgPath != null && imgPath.isNotEmpty
                  ? Image.file(File(imgPath), fit: BoxFit.cover, errorBuilder: (c,e,s) => const Icon(Icons.broken_image, color: Colors.white30, size: 50))
                  : Image.asset('assets/img/${product['sku']}.png', fit: BoxFit.cover, errorBuilder: (c,e,s) => const Icon(Icons.image_not_supported, size: 50, color: Colors.white30)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(child: Text(product['title'], style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white))),
                    // Displays the Category as a little tag
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(color: const Color(0xFF2A283C), borderRadius: BorderRadius.circular(6)),
                      child: Text(product['category'], style: TextStyle(color: textGray, fontSize: 10, fontWeight: FontWeight.bold)),
                    )
                  ],
                ),
                const SizedBox(height: 8),
                Text(product['desc'], style: TextStyle(color: textGray, fontSize: 13, height: 1.4)),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("₱${product['price'].toStringAsFixed(2)}", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: primaryPurple)),
                    GestureDetector(
                      onTap: () async {
                        if (widget.currentUser != null) {
                          await DatabaseHelper.instance.addToCart(widget.currentUser!['user_id'], product['id']);
                          if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${product['title']} added!'), backgroundColor: Colors.green));
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please log in.'), backgroundColor: Colors.red));
                        }
                      },
                    child: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: primaryPurple.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(10)), child: Icon(Icons.add, color: primaryPurple, size: 24)),                    ),
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