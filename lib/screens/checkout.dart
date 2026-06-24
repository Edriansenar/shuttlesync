import 'package:flutter/material.dart';
import 'package:shuttlesync/database/database_helper.dart';
import 'package:shuttlesync/screens/receipt.dart';

class CheckoutScreen extends StatefulWidget {
  final Map<String, dynamic> currentUser;
  final double totalAmount;

  const CheckoutScreen({
    super.key, 
    required this.currentUser, 
    required this.totalAmount,
  });

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _zipController = TextEditingController();
  bool _isProcessing = false;

  void _placeOrder() async {
    if (_addressController.text.isEmpty || _cityController.text.isEmpty || _zipController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please fill out your full shipping address.'), backgroundColor: Colors.red));
      return;
    }

    setState(() => _isProcessing = true);

    String fullAddress = "${_addressController.text.trim()}, ${_cityController.text.trim()} ${_zipController.text.trim()}";

    // 1. Insert the physical order into the database
    int orderId = await DatabaseHelper.instance.insertOrder({
      'user_id': widget.currentUser['user_id'],
      'total_amount': widget.totalAmount,
      'status': 'PENDING',
      'order_date': DateTime.now().toIso8601String(),
      'shipping_address': fullAddress, 
    });

    // 2. Clear ONLY physical items from the Cart table
    await DatabaseHelper.instance.clearCart(widget.currentUser['user_id']);

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => ReceiptScreen(
        orderId: orderId,
        totalAmount: widget.totalAmount,
        shippingAddress: fullAddress,
        customerName: widget.currentUser['full_name'],
      )),
    );
  }

  @override
  Widget build(BuildContext context) {
    const bgColor = Color(0xFF0F0E17);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white70, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("Checkout", style: TextStyle(color: Color(0xFFBB6AFB), fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Shipping Details", style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            _buildTextField(_addressController, "Street Address", Icons.home),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _buildTextField(_cityController, "City", Icons.location_city)),
                const SizedBox(width: 16),
                Expanded(child: _buildTextField(_zipController, "Zip Code", Icons.markunread_mailbox)),
              ],
            ),
            const SizedBox(height: 40),

            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: const Color(0xFF1B1A24), borderRadius: BorderRadius.circular(16)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Total to Pay:", style: TextStyle(color: Colors.white70, fontSize: 16)),
                  Text("₱${widget.totalAmount.toStringAsFixed(2)}", style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            const SizedBox(height: 40),

            SizedBox(
              width: double.infinity, height: 56,
              child: ElevatedButton(
                onPressed: _isProcessing ? null : _placeOrder,
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFBB6AFB), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                child: _isProcessing 
                  ? const CircularProgressIndicator(color: Colors.black) 
                  : const Text("CONFIRM ORDER (COD)", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint, IconData icon) {
    return TextField(
      controller: controller,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        filled: true, fillColor: const Color(0xFF232231),
        prefixIcon: Icon(icon, color: Colors.white54),
        hintText: hint, hintStyle: const TextStyle(color: Colors.white38),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      ),
    );
  }
}