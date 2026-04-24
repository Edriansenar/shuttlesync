import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart'; 
import 'package:shuttlesync/database/database_helper.dart';
import 'package:shuttlesync/screens/analyticspage.dart';

class AdminDashboard extends StatefulWidget {
  final Map<String, dynamic>? currentUser;

  const AdminDashboard({super.key, this.currentUser});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  // Form Controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _stockController = TextEditingController();
  String _selectedCategory = "Apparel";
  File? _selectedImage;
  bool _isPublishing = false;

  DateTime _selectedDate = DateTime.now();
  List<Map<String, dynamic>> _todaysBookings = [];
  bool _isLoadingSchedule = true;
  
  List<Map<String, dynamic>> _inventoryItems = [];
  bool _isLoadingInventory = true;

  @override
  void initState() {
    super.initState();
    _fetchSchedule();
    _fetchInventory(); 
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    super.dispose();
  }


  void _fetchInventory() async {
    setState(() => _isLoadingInventory = true);
    final products = await DatabaseHelper.instance.getAllProducts();
    if (!mounted) return;
    setState(() {
      _inventoryItems = products;
      _isLoadingInventory = false;
    });
  }

  void _deleteProduct(int productId, String name) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1B1A24),
        title: const Text("Delete Product?", style: TextStyle(color: Colors.white)),
        content: Text("Are you sure you want to permanently delete $name?", style: const TextStyle(color: Colors.white70)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel", style: TextStyle(color: Colors.white54))),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await DatabaseHelper.instance.deleteProduct(productId);
              _fetchInventory(); // Refresh the list
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Item deleted."), backgroundColor: Colors.redAccent));
              }
            }, 
            child: const Text("Delete", style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold))
          ),
        ],
      ),
    );
  }

  void _viewProductDetails(Map<String, dynamic> product) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1B1A24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(product['name'], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("SKU: ${product['sku']}", style: const TextStyle(color: Color(0xFF8D8E98), fontSize: 12)),
            const SizedBox(height: 16),
            Text("Category: ${product['category']}", style: const TextStyle(color: Colors.white70)),
            const SizedBox(height: 8),
            Text("Price: \$${product['price']}", style: const TextStyle(color: Colors.white70)),
            const SizedBox(height: 8),
            Text("Current Stock: ${product['stock_quantity']}", style: const TextStyle(color: Colors.white70)),
            const SizedBox(height: 16),
            const Text("Description:", style: TextStyle(color: Color(0xFF8D8E98), fontSize: 12)),
            const SizedBox(height: 4),
            Text(product['description'], style: const TextStyle(color: Colors.white70, fontSize: 13, height: 1.4)),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Close", style: TextStyle(color: Color(0xFFBB6AFB)))),
        ],
      ),
    );
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) setState(() => _selectedImage = File(image.path));
  }

  void _publishProduct() async {
    if (_nameController.text.isEmpty || _priceController.text.isEmpty || _selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please fill all fields and select an image.'), backgroundColor: Colors.red));
      return;
    }
    setState(() => _isPublishing = true);
    String newSku = 'NEW-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}';

    await DatabaseHelper.instance.insertProduct({
      'name': _nameController.text.trim(),
      'description': 'Added via Admin Console',
      'sku': newSku,
      'category': _selectedCategory,
      'price': double.tryParse(_priceController.text) ?? 0.0,
      'stock_quantity': int.tryParse(_stockController.text) ?? 10,
      'low_stock_threshold': 5,
    });

    if (!mounted) return;
    
    setState(() {
      _isPublishing = false;
      _selectedImage = null;
      _nameController.clear();
      _priceController.clear();
      _stockController.clear();
    });

    _fetchInventory(); // Instantly update the inventory UI!
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Product Published to Store!'), backgroundColor: Colors.green));
  }


  void _fetchSchedule() async {
    setState(() => _isLoadingSchedule = true);
    String formattedMonth = _selectedDate.month.toString().padLeft(2, '0');
    String formattedDay = _selectedDate.day.toString().padLeft(2, '0');
    String dateString = "${_selectedDate.year}-$formattedMonth-$formattedDay";

    final bookings = await DatabaseHelper.instance.getBookingsByDate(dateString);
    
    bookings.sort((a, b) => a['start_time'].compareTo(b['start_time']));

    if (!mounted) return;
    setState(() {
      _todaysBookings = bookings;
      _isLoadingSchedule = false;
    });
  }

  Map<String, dynamic>? _getBookingForSlot(int courtId, String time) {
    try {
      return _todaysBookings.firstWhere((b) => b['court_id'] == courtId && b['start_time'] == time);
    } catch (e) {
      return null;
    }
  }

  void _handleSlotClick(int courtId, String time, Map<String, dynamic>? booking) {
    if (booking == null) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: const Color(0xFF1B1A24),
          title: const Text("Block Court?", style: TextStyle(color: Colors.white)),
          content: Text("Do you want to block Court $courtId at $time for maintenance?", style: const TextStyle(color: Colors.white70)),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel", style: TextStyle(color: Colors.white54))),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                String dateString = "${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}";
                await DatabaseHelper.instance.insertBooking({
                  'user_id': 0, 
                  'court_id': courtId,
                  'booking_date': dateString,
                  'start_time': time,
                  'duration_minutes': 60,
                  'status': 'MAINTENANCE'
                });
                _fetchSchedule(); 
              }, 
              child: const Text("Block Court", style: TextStyle(color: Color(0xFFFF6A9A), fontWeight: FontWeight.bold))
            ),
          ],
        ),
      );
    } else if (booking['status'] == 'CONFIRMED') {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: const Color(0xFF1B1A24),
          title: const Text("Cancel Booking?", style: TextStyle(color: Colors.white)),
          content: const Text("This will forcefully cancel the user's booking and free up the court.", style: TextStyle(color: Colors.white70)),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("Keep Booking", style: TextStyle(color: Colors.white54))),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                await DatabaseHelper.instance.updateBookingStatus(booking['booking_id'], 'CANCELLED');
                _fetchSchedule(); 
              }, 
              child: const Text("Force Cancel", style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold))
            ),
          ],
        ),
      );
    } else if (booking['status'] == 'MAINTENANCE') {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: const Color(0xFF1B1A24),
          title: const Text("Unblock Court?", style: TextStyle(color: Colors.white)),
          content: const Text("Make this court available for users to book again?", style: TextStyle(color: Colors.white70)),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel", style: TextStyle(color: Colors.white54))),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                await DatabaseHelper.instance.updateBookingStatus(booking['booking_id'], 'CANCELLED'); 
                _fetchSchedule(); 
              }, 
              child: const Text("Make Available", style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold))
            ),
          ],
        ),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    const bgColor = Color(0xFF0F0E17);
    const darkCardColor = Color(0xFF1B1A24);
    const primaryPurple = Color(0xFFBB6AFB);
    const accentPink = Color(0xFFFF6A9A);
    const textGray = Color(0xFF8D8E98);
    const inputFillColor = Color(0xFF232231);

    String adminName = widget.currentUser?['full_name'] ?? 'Admin';
    String firstName = adminName.split(' ')[0];

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: const Padding(padding: EdgeInsets.all(12.0), child: Icon(Icons.shield_moon, color: primaryPurple, size: 24)),
        title: const Text("Command Center", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: primaryPurple)),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: CircleAvatar(backgroundColor: const Color(0xFF2E2A44), child: Text(firstName[0].toUpperCase(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14))),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Welcome back, $firstName", style: const TextStyle(color: textGray, fontSize: 16)),
            const SizedBox(height: 4),
            const Text("Facility Overview", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 24),

            GestureDetector(
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AnalyticsPage())),
              child: Container(
                width: double.infinity, padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF2A1C40), Color(0xFF1B1A24)]), borderRadius: BorderRadius.circular(16), border: Border.all(color: primaryPurple.withOpacity(0.5), width: 1), boxShadow: [BoxShadow(color: primaryPurple.withOpacity(0.1), blurRadius: 20, offset: const Offset(0, 8))]),
                child: Row(
                  children: [
                    Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: primaryPurple.withOpacity(0.2), shape: BoxShape.circle), child: const Icon(Icons.bar_chart_rounded, color: primaryPurple, size: 32)),
                    const SizedBox(width: 20),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [Text("Deep Analytics", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)), SizedBox(height: 4), Text("View player retention, peak hours, and shop revenue trends.", style: TextStyle(color: textGray, fontSize: 12, height: 1.4))])),
                    const Icon(Icons.arrow_forward_ios, color: Colors.white54, size: 16),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 40),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Global Inventory", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
                IconButton(icon: const Icon(Icons.refresh, color: textGray), onPressed: _fetchInventory),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: darkCardColor, borderRadius: BorderRadius.circular(16)),
              child: _isLoadingInventory 
                ? const Center(child: CircularProgressIndicator(color: primaryPurple))
                : _inventoryItems.isEmpty 
                  ? const Padding(padding: EdgeInsets.all(20), child: Center(child: Text("No items in inventory.", style: TextStyle(color: textGray))))
                  : Column(
                      children: _inventoryItems.map((item) {
                        bool isLowStock = (item['stock_quantity'] as int) <= (item['low_stock_threshold'] as int);
                        IconData icon = item['category'] == 'Rackets' ? Icons.sports_tennis : (item['category'] == 'Shuttlecocks' ? Icons.kitchen : Icons.checkroom);
                        Color iconCol = isLowStock ? accentPink : primaryPurple;

                        return Column(
                          children: [
                            Row(
                              children: [
                                Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: const Color(0xFF2A283C), borderRadius: BorderRadius.circular(10)), child: Icon(icon, color: iconCol, size: 24)),
                                const SizedBox(width: 16),
                                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                  Text(item['name'], style: TextStyle(color: isLowStock ? accentPink : Colors.white, fontSize: 15, fontWeight: FontWeight.bold)), 
                                  const SizedBox(height: 4), 
                                  Text("${item['category']} • Stock: ${item['stock_quantity']}", style: const TextStyle(color: Color(0xFF8D8E98), fontSize: 11))
                                ])),
                                IconButton(icon: const Icon(Icons.visibility, color: Colors.white54, size: 20), onPressed: () => _viewProductDetails(item)),
                                IconButton(icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20), onPressed: () => _deleteProduct(item['product_id'], item['name'])),
                              ],
                            ),
                            const Divider(color: Color(0xFF2A283C), height: 20),
                          ],
                        );
                      }).toList(),
                    ),
            ),
            const SizedBox(height: 40),


            const Text("Add New Apparel", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 4),
            const Text("Upload directly to database", style: TextStyle(color: textGray, fontSize: 13)),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: darkCardColor, borderRadius: BorderRadius.circular(16)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: _pickImage,
                    child: Container(
                      width: double.infinity, height: 160,
                      decoration: BoxDecoration(color: const Color(0xFF110F18), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.white24, width: 1, style: BorderStyle.solid)),
                      child: _selectedImage != null 
                        ? ClipRRect(borderRadius: BorderRadius.circular(12), child: Image.file(_selectedImage!, fit: BoxFit.cover))
                        : Column(mainAxisAlignment: MainAxisAlignment.center, children: const [Icon(Icons.add_photo_alternate_outlined, color: Colors.white, size: 32), SizedBox(height: 12), Text("Browse Local Storage", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)), SizedBox(height: 4), Text("Tap to select image from gallery", textAlign: TextAlign.center, style: TextStyle(color: textGray, fontSize: 11))]),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text("PRODUCT NAME", style: const TextStyle(color: Color(0xFF8D8E98), fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                  const SizedBox(height: 8),
                  TextField(controller: _nameController, style: const TextStyle(color: Colors.white), decoration: InputDecoration(filled: true, fillColor: inputFillColor, hintText: "e.g. Kinetic Zip Pullover", hintStyle: const TextStyle(color: Color(0xFF4B495C)), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none))),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text("PRICE (\$)", style: const TextStyle(color: Color(0xFF8D8E98), fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.2)), const SizedBox(height: 8), TextField(controller: _priceController, keyboardType: TextInputType.number, style: const TextStyle(color: Colors.white), decoration: InputDecoration(filled: true, fillColor: inputFillColor, hintText: "0.00", hintStyle: const TextStyle(color: Color(0xFF4B495C)), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none)))])),
                      const SizedBox(width: 16),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text("STOCK", style: const TextStyle(color: Color(0xFF8D8E98), fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.2)), const SizedBox(height: 8), TextField(controller: _stockController, keyboardType: TextInputType.number, style: const TextStyle(color: Colors.white), decoration: InputDecoration(filled: true, fillColor: inputFillColor, hintText: "0", hintStyle: const TextStyle(color: Color(0xFF4B495C)), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none)))])),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text("CATEGORY", style: const TextStyle(color: Color(0xFF8D8E98), fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16), decoration: BoxDecoration(color: inputFillColor, borderRadius: BorderRadius.circular(12)),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedCategory, isExpanded: true, dropdownColor: darkCardColor, icon: const Icon(Icons.keyboard_arrow_down, color: textGray), style: const TextStyle(color: textGray, fontSize: 14),
                        onChanged: (String? newValue) { if (newValue != null) setState(() => _selectedCategory = newValue); },
                        items: <String>["Apparel", "Rackets", "Shuttlecocks"].map<DropdownMenuItem<String>>((String value) => DropdownMenuItem<String>(value: value, child: Text(value))).toList(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity, height: 50,
                    child: OutlinedButton.icon(
                      onPressed: _isPublishing ? null : _publishProduct,
                      icon: _isPublishing ? const SizedBox() : const Icon(Icons.arrow_upward_rounded, size: 16),
                      label: _isPublishing ? const CircularProgressIndicator(color: accentPink) : const Text("Publish to Store", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                      style: OutlinedButton.styleFrom(foregroundColor: accentPink, side: const BorderSide(color: accentPink, width: 1.5), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(children: const [Icon(Icons.calendar_month, color: accentPink, size: 22), SizedBox(width: 8), Text("Court Matrix", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white))]),
                IconButton(icon: const Icon(Icons.refresh, color: textGray), onPressed: _fetchSchedule),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: darkCardColor, borderRadius: BorderRadius.circular(16)),
              child: _isLoadingSchedule 
                ? const Center(child: CircularProgressIndicator(color: primaryPurple))
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                        decoration: BoxDecoration(color: inputFillColor, borderRadius: BorderRadius.circular(8)),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            GestureDetector(onTap: () { setState(() => _selectedDate = _selectedDate.subtract(const Duration(days: 1))); _fetchSchedule(); }, child: const Icon(Icons.chevron_left, color: textGray)), 
                            Text("${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2,'0')}-${_selectedDate.day.toString().padLeft(2,'0')}", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)), 
                            GestureDetector(onTap: () { setState(() => _selectedDate = _selectedDate.add(const Duration(days: 1))); _fetchSchedule(); }, child: const Icon(Icons.chevron_right, color: textGray)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      _buildAdminCourtRow("Court 1", 1, primaryPurple, textGray, accentPink),
                      const SizedBox(height: 32),
                      _buildAdminCourtRow("Court 2", 2, primaryPurple, textGray, accentPink),
                    ],
                  ),
            ),
            const SizedBox(height: 40),


            const Text("Daily Booking Timeline", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 4),
            const Text("Chronological list of all reservations", style: TextStyle(color: textGray, fontSize: 13)),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: darkCardColor, borderRadius: BorderRadius.circular(16)),
              child: _isLoadingSchedule 
                  ? const Center(child: CircularProgressIndicator(color: primaryPurple))
                  : _todaysBookings.isEmpty
                    ? const Center(child: Padding(padding: EdgeInsets.all(20), child: Text("No bookings for this date.", style: TextStyle(color: textGray))))
                    : ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _todaysBookings.length,
                        itemBuilder: (context, index) {
                          final b = _todaysBookings[index];
                          Color statColor = b['status'] == 'CONFIRMED' ? primaryPurple : (b['status'] == 'MAINTENANCE' ? accentPink : textGray);
                          
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Timeline Dot and Time
                                Column(
                                  children: [
                                    Text(b['start_time'], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                                    const SizedBox(height: 4),
                                    Container(width: 2, height: 40, color: statColor.withOpacity(0.3)), // Line connecting dots
                                  ],
                                ),
                                const SizedBox(width: 16),
                                // Card Data
                                Expanded(
                                  child: Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(color: inputFillColor, borderRadius: BorderRadius.circular(12), border: Border(left: BorderSide(color: statColor, width: 4))),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text("Court ${b['court_id']}", style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                                            Text(b['status'], style: TextStyle(color: statColor, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.0)),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Text("Duration: ${b['duration_minutes']} mins", style: const TextStyle(color: textGray, fontSize: 12)),
                                        if (b['status'] == 'CONFIRMED') ...[
                                          const SizedBox(height: 8),
                                          Text("User ID: ${b['user_id']}", style: const TextStyle(color: Colors.white54, fontSize: 12)),
                                        ]
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      )
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildAdminCourtRow(String title, int courtId, Color primaryPurple, Color textGray, Color accentPink) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
            Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: primaryPurple.withOpacity(0.15), borderRadius: BorderRadius.circular(4)), child: Text(courtId == 1 ? "Premium" : "Standard", style: TextStyle(color: primaryPurple, fontSize: 10, fontWeight: FontWeight.bold))),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: ['18:00', '19:00', '20:00', '21:00'].map((time) {
            Map<String, dynamic>? booking = _getBookingForSlot(courtId, time);
            
            String status = "Open";
            Color bgColor = const Color(0xFF110F18);
            Color textColor = textGray;

            if (booking != null) {
              if (booking['status'] == 'CONFIRMED') {
                status = "Booked";
                bgColor = const Color(0xFF332A4C);
                textColor = primaryPurple;
              } else if (booking['status'] == 'MAINTENANCE') {
                status = "Maint.";
                bgColor = const Color(0xFF4A2030);
                textColor = accentPink;
              }
            }

            return GestureDetector(
              onTap: () => _handleSlotClick(courtId, time, booking),
              child: Container(
                width: 70, padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(8), border: Border.all(color: textColor.withOpacity(0.3), width: 1)),
                child: Column(children: [Text(time, style: TextStyle(color: textColor, fontSize: 13, fontWeight: FontWeight.bold)), const SizedBox(height: 4), Text(status, style: TextStyle(color: textColor.withOpacity(0.8), fontSize: 10))]),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}