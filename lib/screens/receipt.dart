import 'package:flutter/material.dart';

class ReceiptScreen extends StatelessWidget {
  final int orderId;
  final double totalAmount;
  final String shippingAddress;
  final String customerName;

  const ReceiptScreen({
    super.key,
    required this.orderId,
    required this.totalAmount,
    required this.shippingAddress,
    required this.customerName,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0E17),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.check_circle, color: Colors.greenAccent, size: 80),
                const SizedBox(height: 24),
                const Text("Order Confirmed!", style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text("Order #$orderId has been placed successfully.", style: const TextStyle(color: Colors.white70, fontSize: 16)),
                const SizedBox(height: 40),

                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(color: const Color(0xFF1B1A24), borderRadius: BorderRadius.circular(16)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildReceiptRow("Customer:", customerName),
                      const SizedBox(height: 12),
                      _buildReceiptRow("Shipping To:", shippingAddress),
                      const SizedBox(height: 12),
                      _buildReceiptRow("Payment Method:", "Cash on Delivery"),
                      const Divider(color: Colors.white24, height: 32),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("TOTAL:", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                          Text("₱${totalAmount.toStringAsFixed(2)}", style: const TextStyle(color: Color(0xFFBB6AFB), fontSize: 20, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),

                SizedBox(
                  width: double.infinity, height: 50,
                  child: OutlinedButton(
                    onPressed: () {
                      // Pop the receipt and go back to the shop/dashboard
                      Navigator.pop(context);
                    },
                    style: OutlinedButton.styleFrom(side: const BorderSide(color: Color(0xFFBB6AFB)), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                    child: const Text("Return to Shop", style: TextStyle(color: Color(0xFFBB6AFB), fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildReceiptRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(width: 120, child: Text(label, style: const TextStyle(color: Colors.white54, fontSize: 14))),
        Expanded(child: Text(value, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500), textAlign: TextAlign.right)),
      ],
    );
  }
}