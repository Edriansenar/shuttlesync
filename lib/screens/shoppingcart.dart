import 'package:flutter/material.dart';
import 'package:shuttlesync/database/database_helper.dart';
import 'dart:io';
import 'package:shuttlesync/screens/checkout.dart'; 

class ShoppingCartScreen extends StatefulWidget {
  final Map<String, dynamic>? currentUser;

  const ShoppingCartScreen({super.key, this.currentUser});

  @override
  State<ShoppingCartScreen> createState() => _ShoppingCartScreenState();
}

class _ShoppingCartScreenState extends State<ShoppingCartScreen> {
  List<Map<String, dynamic>> _cartItems = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchCartItems();
  }

  void _fetchCartItems() async {
    if (widget.currentUser == null) {
      setState(() => _isLoading = false);
      return;
    }

    int userId = widget.currentUser!['user_id'];
    
    // ONLY fetching physical products (no more court bookings in cart)
    final items = await DatabaseHelper.instance.getCartItems(userId);

    if (!mounted) return;
    
    setState(() {
      _cartItems = List<Map<String, dynamic>>.from(items);
      _isLoading = false;
    });
  }

  double get _subtotal => _cartItems.fold(0, (sum, item) => sum + (item['price'] * item['quantity']));
  double get _estimatedTax => _subtotal * 0.12; 
  double get _totalAmount => _subtotal + _estimatedTax;

  void _updateQuantity(int index, int delta) async {
    int cartId = _cartItems[index]['cart_id'];
    int currentQty = _cartItems[index]['quantity'];
    int newQty = currentQty + delta;

    if (newQty <= 0) {
      _removeItem(index);
    } else {
      await DatabaseHelper.instance.updateCartQuantity(cartId, newQty);
      _fetchCartItems(); 
    }
  }

  void _removeItem(int index) async {
    int cartId = _cartItems[index]['cart_id'];
    await DatabaseHelper.instance.removeFromCart(cartId);
    _fetchCartItems(); 
  }

  void _checkout() async {
    if (widget.currentUser == null) return;
    
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CheckoutScreen(
          currentUser: widget.currentUser!,
          totalAmount: _totalAmount,
        ),
      ),
    );

    if (mounted) {
      setState(() => _isLoading = true);
      _fetchCartItems();
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
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios, color: Colors.white70, size: 20), onPressed: () => Navigator.pop(context)),
        title: const Text("SHOPPING CART", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: 1.5, color: primaryPurple)),
        centerTitle: true,
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator(color: primaryPurple))
        : RefreshIndicator(
            onRefresh: () async => _fetchCartItems(),
            color: primaryPurple,
            backgroundColor: darkCardColor,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Your Gear", style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.white)),
                  const SizedBox(height: 32),

                  if (_cartItems.isEmpty)
                    const Center(child: Padding(padding: EdgeInsets.symmetric(vertical: 40), child: Text("Your cart is empty.", style: TextStyle(color: textGray, fontSize: 16))))
                  else
                    ...List.generate(_cartItems.length, (index) => _buildCartItem(_cartItems[index], index, darkCardColor, primaryPurple, accentPink, textGray)),

                  const SizedBox(height: 40),

                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(color: darkCardColor, borderRadius: BorderRadius.circular(20)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Order Summary", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
                        const SizedBox(height: 24),
                        
                        _buildSummaryRow("Subtotal", "₱${_subtotal.toStringAsFixed(2)}", Colors.white),
                        const SizedBox(height: 16),
                        _buildSummaryRow("VAT (12%)", "₱${_estimatedTax.toStringAsFixed(2)}", Colors.white),
                        const SizedBox(height: 16),
                        
                        const Divider(color: Color(0xFF2A283C), height: 40),
                        
                        const Text("TOTAL AMOUNT", style: TextStyle(color: textGray, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                        const SizedBox(height: 4),
                        Text("₱${_totalAmount.toStringAsFixed(2)}", style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w900)),
                        const SizedBox(height: 32),

                        SizedBox(
                          width: double.infinity, height: 56,
                          child: ElevatedButton(
                            onPressed: _cartItems.isEmpty ? null : _checkout, 
                            style: ElevatedButton.styleFrom(backgroundColor: primaryPurple, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                            child: const Text("PROCEED TO CHECKOUT", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87)),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
    );
  }

  Widget _buildCartItem(Map<String, dynamic> item, int index, Color darkCardColor, Color primaryPurple, Color accentPink, Color textGray) {
    double itemTotal = item['price'] * item['quantity'];
    String? imagePath = item['image_path'];

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(color: darkCardColor, borderRadius: BorderRadius.circular(20)),
      child: Column(
        children: [
          Container(
            height: 120, width: double.infinity,
            decoration: const BoxDecoration(color: Color(0xFF110F18), borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20))),
            child: ClipRRect(
              borderRadius: const BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
              child: imagePath != null && imagePath.isNotEmpty
                  ? Image.file(File(imagePath), fit: BoxFit.cover, errorBuilder: (c,e,s) => const Icon(Icons.broken_image, color: Colors.white30, size: 40))
                  : Image.asset('assets/img/${item['sku']}.png', fit: BoxFit.cover, errorBuilder: (c,e,s) => const Icon(Icons.shopping_bag, size: 60, color: Colors.white10)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                Text(item['name'], textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold, height: 1.4)),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        GestureDetector(onTap: () => _updateQuantity(index, -1), child: const Icon(Icons.remove_circle_outline, color: Colors.white54)),
                        const SizedBox(width: 12),
                        Text(item['quantity'].toString(), style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                        const SizedBox(width: 12),
                        GestureDetector(onTap: () => _updateQuantity(index, 1), child: const Icon(Icons.add_circle_outline, color: Colors.white54)),
                      ],
                    ),
                    Text("₱${itemTotal.toStringAsFixed(2)}", style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, Color valueColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [Text(label, style: const TextStyle(color: Color(0xFF8D8E98), fontSize: 14)), Text(value, style: TextStyle(color: valueColor, fontSize: 16, fontWeight: FontWeight.bold))],
    );
  }
}