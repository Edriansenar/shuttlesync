import 'package:flutter/material.dart';
import 'package:shuttlesync/database/database_helper.dart';

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
    final items = await DatabaseHelper.instance.getCartItems(userId);

    if (!mounted) return;

    setState(() {
      _cartItems = List<Map<String, dynamic>>.from(items); // Make it modifiable
      _isLoading = false;
    });
  }

  double get _subtotal {
    return _cartItems.fold(0, (sum, item) => sum + (item['price'] * item['quantity']));
  }

  double get _estimatedTax {
    return _subtotal * 0.08; // 8% tax rate
  }

  double get _totalAmount {
    return _subtotal + _estimatedTax;
  }

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
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Item removed from cart.')));
    }
    _fetchCartItems(); 
  }

  void _checkout() async {
    if (widget.currentUser == null) return;
    
    await DatabaseHelper.instance.clearCart(widget.currentUser!['user_id']);
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Payment Successful! Order Placed.', style: TextStyle(color: Colors.white)), backgroundColor: Colors.green),
      );
      Navigator.pop(context); 
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
        title: const Text("SHUTTLESYNC", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: 1.5, color: primaryPurple)),
        centerTitle: true,
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator(color: primaryPurple))
        : SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("YOUR EQUIPMENT", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.5, color: accentPink)),
                const SizedBox(height: 4),
                const Text("Shopping Cart", style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.white)),
                const SizedBox(height: 32),

                if (_cartItems.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 40),
                    child: Center(child: Text("Your cart is empty.", style: TextStyle(color: textGray, fontSize: 16))),
                  )
                else
                  // --- Cart Items ---
                  ...List.generate(_cartItems.length, (index) {
                    return _buildCartItem(_cartItems[index], index, darkCardColor, primaryPurple, accentPink, textGray);
                  }),

                // --- Keep Browsing Button ---
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 32),
                    decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white12, width: 2)),
                    child: Column(
                      children: [
                        Container(padding: const EdgeInsets.all(8), decoration: const BoxDecoration(color: Color(0xFF2A283C), shape: BoxShape.circle), child: const Icon(Icons.add, color: textGray, size: 24)),
                        const SizedBox(height: 16),
                        const Text("Forgot something? Keep browsing\nour collection.", textAlign: TextAlign.center, style: TextStyle(color: textGray, fontSize: 14, fontWeight: FontWeight.w500)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 40),

                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(color: darkCardColor, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 15, offset: const Offset(0, 10))]),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Order Summary", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
                      const SizedBox(height: 24),
                      
                      _buildSummaryRow("Subtotal", "\$${_subtotal.toStringAsFixed(2)}", Colors.white),
                      const SizedBox(height: 16),
                      _buildSummaryRow("Estimated Tax", "\$${_estimatedTax.toStringAsFixed(2)}", Colors.white),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("Shipping", style: TextStyle(color: textGray, fontSize: 14)),
                          Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: accentPink, borderRadius: BorderRadius.circular(4)), child: const Text("FREE", style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold))),
                        ],
                      ),
                      
                      const Padding(padding: EdgeInsets.symmetric(vertical: 24.0), child: Divider(color: Color(0xFF2A283C), height: 1)),
                      
                      const Text("TOTAL AMOUNT", style: TextStyle(color: textGray, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                      const SizedBox(height: 4),
                      Text("\$${_totalAmount.toStringAsFixed(2)}", style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w900)),
                      const SizedBox(height: 32),

                      // Checkout Button
                      SizedBox(
                        width: double.infinity, height: 56,
                        child: Container(
                          decoration: BoxDecoration(gradient: const LinearGradient(colors: [primaryPurple, Color(0xFFD49CFF)]), borderRadius: BorderRadius.circular(14), boxShadow: [BoxShadow(color: primaryPurple.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4))]),
                          child: ElevatedButton(
                            onPressed: _cartItems.isEmpty ? null : _checkout,
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent, shadowColor: Colors.transparent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                            child: const Text("PROCEED TO CHECKOUT", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Badges
                      Row(children: const [Icon(Icons.verified_user_outlined, color: textGray, size: 16), SizedBox(width: 8), Text("Secure encrypted payment", style: TextStyle(color: textGray, fontSize: 12))]),
                      const SizedBox(height: 12),
                      Row(children: const [Icon(Icons.local_shipping_outlined, color: textGray, size: 16), SizedBox(width: 8), Text("Express delivery: 2-3 business days", style: TextStyle(color: textGray, fontSize: 12))]),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
    );
  }

  // --- Helper Widgets ---

  Widget _buildCartItem(Map<String, dynamic> item, int index, Color darkCardColor, Color primaryPurple, Color accentPink, Color textGray) {
    double itemTotal = item['price'] * item['quantity'];
    
    // Automatically match the SKU format for images!
    String imagePath = 'assets/img/${item['sku']}.png';

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(color: darkCardColor, borderRadius: BorderRadius.circular(20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Dynamic Product Image
          Container(
            height: 120, width: double.infinity,
            decoration: const BoxDecoration(color: Color(0xFF110F18), borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20))),
            child: ClipRRect(
              borderRadius: const BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
              child: Image.asset(
                imagePath,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => const Icon(Icons.shopping_bag, size: 60, color: Colors.white10),
              ),
            ),
          ),
          
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                Text(item['category'] ?? "GEAR", style: TextStyle(color: accentPink, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                const SizedBox(height: 8),
                Text(item['name'], textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(item['description'], textAlign: TextAlign.center, style: TextStyle(color: textGray, fontSize: 12)),
                const SizedBox(height: 24),

                // Quantity Selector
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(color: const Color(0xFF0F0E17), borderRadius: BorderRadius.circular(20)),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      GestureDetector(onTap: () => _updateQuantity(index, -1), child: const Icon(Icons.remove, color: Colors.white54, size: 18)),
                      const SizedBox(width: 20),
                      Text(item['quantity'].toString(), style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(width: 20),
                      GestureDetector(onTap: () => _updateQuantity(index, 1), child: const Icon(Icons.add, color: Colors.white54, size: 18)),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Price & Remove
                Text("\$${itemTotal.toStringAsFixed(2)}", style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: () => _removeItem(index),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.delete_outline, color: accentPink, size: 14),
                      const SizedBox(width: 4),
                      Text("REMOVE", style: TextStyle(color: accentPink, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.0)),
                    ],
                  ),
                ),
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
      children: [
        Text(label, style: const TextStyle(color: Color(0xFF8D8E98), fontSize: 14)),
        Text(value, style: TextStyle(color: valueColor, fontSize: 16, fontWeight: FontWeight.bold)),
      ],
    );
  }
}