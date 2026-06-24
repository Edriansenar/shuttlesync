import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart'; 
import 'package:path_provider/path_provider.dart'; 
import 'package:path/path.dart' as p; 
import 'package:shuttlesync/database/database_helper.dart';
import 'package:shuttlesync/screens/analyticspage.dart'; 

class AdminDashboard extends StatefulWidget {
  final Map<String, dynamic>? currentUser;

  const AdminDashboard({super.key, this.currentUser});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _stockController = TextEditingController();
  
  final List<String> _productCategories = ['Rackets', 'Shuttlecocks', 'Apparel', 'Accessories'];
  String _selectedCategory = "Rackets"; 
  
  File? _selectedImage;
  bool _isPublishing = false;
  bool _isPickingImage = false; 

  // PINALITAN: Imbes na today's bookings lang, kukunin natin lahat!
  List<Map<String, dynamic>> _allBookings = [];
  bool _isLoadingSchedule = true;
  
  List<Map<String, dynamic>> _inventoryItems = [];
  bool _isLoadingInventory = true;

  List<Map<String, dynamic>> _orders = [];
  bool _isLoadingOrders = true;

  @override
  void initState() {
    super.initState();
    _fetchAllData();
  }

  Future<void> _fetchAllData() async {
    _fetchSchedule();
    _fetchInventory(); 
    _fetchOrders();
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

  void _fetchOrders() async {
    setState(() => _isLoadingOrders = true);
    final orders = await DatabaseHelper.instance.getAllOrders();
    if (!mounted) return;
    setState(() {
      _orders = orders;
      _isLoadingOrders = false;
    });
  }

  void _updateOrderStatus(int orderId, String newStatus) async {
    await DatabaseHelper.instance.updateOrderStatus(orderId, newStatus);
    _fetchOrders(); 
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Order marked as $newStatus'), backgroundColor: newStatus == 'PAID' ? Colors.green : Colors.redAccent));
    }
  }

  // BAGONG LOGIC: Kukunin lahat ng bookings at ipapakita ang PENDING sa taas
  void _fetchSchedule() async {
    setState(() => _isLoadingSchedule = true);
    final db = await DatabaseHelper.instance.database;
    
    // Kukunin natin pati pangalan ng player para alam ng admin kung sino ang nagbook!
    final bookings = await db.rawQuery('''
      SELECT Bookings.*, Users.full_name 
      FROM Bookings 
      INNER JOIN Users ON Bookings.user_id = Users.user_id
      ORDER BY 
        CASE WHEN Bookings.status = 'PENDING' THEN 0 ELSE 1 END,
        Bookings.booking_date ASC,
        Bookings.start_time ASC
    ''');

    if (!mounted) return;
    setState(() {
      _allBookings = bookings;
      _isLoadingSchedule = false;
    });
  }

  void _updateBookingStatus(int bookingId, String newStatus) async {
    await DatabaseHelper.instance.updateBookingStatus(bookingId, newStatus);
    _fetchSchedule(); // I-refresh ang listahan pagkatapos ma-update
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Booking $newStatus'), backgroundColor: newStatus == 'CONFIRMED' ? Colors.green : Colors.redAccent));
    }
  }

  void _deleteProduct(int productId, String name) async {
    await DatabaseHelper.instance.deleteProduct(productId);
    _fetchInventory(); 
  }

  Future<void> _pickImage() async {
    if (_isPickingImage) return;
    setState(() => _isPickingImage = true);

    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
      if (image != null && mounted) {
        setState(() => _selectedImage = File(image.path));
      }
    } catch (e) {
      debugPrint("Image picker error: $e");
    } finally {
      if (mounted) setState(() => _isPickingImage = false);
    }
  }

  void _publishProduct() async {
    if (_nameController.text.isEmpty || _priceController.text.isEmpty || _selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please fill all fields and select an image.'), backgroundColor: Colors.red));
      return;
    }
    setState(() => _isPublishing = true);
    
    String newSku = 'NEW-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}';
    String savedImagePath = "";

    try {
      final Directory appDocDir = await getApplicationDocumentsDirectory();
      final String fileExtension = p.extension(_selectedImage!.path);
      final String targetPath = p.join(appDocDir.path, '$newSku$fileExtension');
      
      final File savedImage = await _selectedImage!.copy(targetPath);
      savedImagePath = savedImage.path;
    } catch (e) {
      debugPrint("Error saving image: $e");
    }

    await DatabaseHelper.instance.insertProduct({
      'name': _nameController.text.trim(),
      'description': 'Added via Admin Console',
      'sku': newSku,
      'category': _selectedCategory, 
      'price': double.tryParse(_priceController.text) ?? 0.0,
      'stock_quantity': int.tryParse(_stockController.text) ?? 10,
      'low_stock_threshold': 5,
      'image_path': savedImagePath,
    });

    if (!mounted) return;
    
    setState(() {
      _isPublishing = false;
      _selectedImage = null;
      _nameController.clear();
      _priceController.clear();
      _stockController.clear();
    });

    _fetchInventory(); 
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Product Published!'), backgroundColor: Colors.green));
  }

  void _logout() {
    FocusScope.of(context).unfocus();
    final navigator = Navigator.of(context, rootNavigator: true);
    navigator.pushReplacementNamed('/login');
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
        title: const Text("Command Center", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: primaryPurple)),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: CircleAvatar(backgroundColor: const Color(0xFF2E2A44), child: Text(firstName[0].toUpperCase(), style: const TextStyle(color: Colors.white))),
          ),
          IconButton(icon: const Icon(Icons.logout, color: Colors.redAccent), onPressed: _logout),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _fetchAllData,
        color: primaryPurple,
        backgroundColor: darkCardColor,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(), 
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AnalyticsPage())),
                child: Container(
                  width: double.infinity, padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF2A1C40), Color(0xFF1B1A24)]), borderRadius: BorderRadius.circular(16), border: Border.all(color: primaryPurple.withValues(alpha: 0.5), width: 1)),
                  child: Row(
                    children: [
                      Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: primaryPurple.withValues(alpha: 0.2), shape: BoxShape.circle), child: const Icon(Icons.bar_chart_rounded, color: primaryPurple, size: 32)),
                      const SizedBox(width: 20),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [Text("Deep Analytics", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)), SizedBox(height: 4), Text("View player retention, peak hours, and shop revenue trends.", style: TextStyle(color: textGray, fontSize: 12, height: 1.4))])),
                      const Icon(Icons.arrow_forward_ios, color: Colors.white54, size: 16),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 40),

              const Text("Store Orders (Cash Only)", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: darkCardColor, borderRadius: BorderRadius.circular(16)),
                child: _isLoadingOrders 
                  ? const Center(child: CircularProgressIndicator(color: primaryPurple))
                  : _orders.isEmpty 
                    ? const Center(child: Padding(padding: EdgeInsets.all(20), child: Text("No pending orders.", style: TextStyle(color: textGray))))
                    : ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _orders.length,
                        itemBuilder: (context, index) {
                          final order = _orders[index];
                          bool isPending = order['status'] == 'PENDING';
                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(color: inputFillColor, borderRadius: BorderRadius.circular(12), border: Border(left: BorderSide(color: isPending ? Colors.orange : Colors.green, width: 4))),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("Order #${order['order_id']} - ${order['full_name']}", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                    const SizedBox(height: 4),
                                    Text("Amount: ₱${order['total_amount'].toStringAsFixed(2)}", style: const TextStyle(color: textGray)),
                                    Text("Status: ${order['status']}", style: TextStyle(color: isPending ? Colors.orange : Colors.green, fontSize: 12, fontWeight: FontWeight.bold)),
                                  ],
                                ),
                                if (isPending)
                                  Row(
                                    children: [
                                      IconButton(icon: const Icon(Icons.check_circle, color: Colors.green), onPressed: () => _updateOrderStatus(order['order_id'], 'PAID')),
                                      IconButton(icon: const Icon(Icons.cancel, color: Colors.redAccent), onPressed: () => _updateOrderStatus(order['order_id'], 'CANCELLED')),
                                    ],
                                  )
                              ],
                            ),
                          );
                        },
                      ),
              ),
              const SizedBox(height: 40),

              // PINALITAN: "Today's Bookings" naging "View Bookings"
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("View Bookings", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(color: inputFillColor, borderRadius: BorderRadius.circular(8)),
                    child: const Text("ALL DATES", style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                  )
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: darkCardColor, borderRadius: BorderRadius.circular(16)),
                child: _isLoadingSchedule 
                  ? const Center(child: CircularProgressIndicator(color: primaryPurple))
                  : _allBookings.isEmpty 
                    ? const Center(child: Padding(padding: EdgeInsets.all(20), child: Text("No bookings found.", style: TextStyle(color: textGray))))
                    : ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _allBookings.length,
                        itemBuilder: (context, index) {
                          final booking = _allBookings[index];
                          bool isPending = booking['status'] == 'PENDING';

                          // Ipakita nang maayos kung anong court ito
                          String courtTitle;
                          switch(booking['court_id']) {
                            case 1: courtTitle = "Championship Court 1"; break;
                            case 2: courtTitle = "Championship Court 2"; break;
                            case 3: courtTitle = "Standard Court 3"; break;
                            case 4: courtTitle = "Standard Court 4"; break;
                            case 5: courtTitle = "Practice Court 5"; break;
                            case 6: courtTitle = "Practice Court 6"; break;
                            default: courtTitle = "Court ${booking['court_id']}";
                          }

                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(color: inputFillColor, borderRadius: BorderRadius.circular(12), border: Border(left: BorderSide(color: isPending ? Colors.orange : Colors.green, width: 4))),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      // Added Player Name!
                                      Text("Booking #${booking['booking_id']} - ${booking['full_name']}", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                      const SizedBox(height: 4),
                                      Text("$courtTitle", style: const TextStyle(color: Colors.white70, fontSize: 13)),
                                      Text("Date: ${booking['booking_date']} @ ${booking['start_time']} (${booking['duration_minutes']}m)", style: const TextStyle(color: textGray, fontSize: 12)),
                                      const SizedBox(height: 4),
                                      Text("Status: ${booking['status']}", style: TextStyle(color: isPending ? Colors.orange : Colors.green, fontSize: 12, fontWeight: FontWeight.bold)),
                                    ],
                                  ),
                                ),
                                if (isPending)
                                  Row(
                                    children: [
                                      IconButton(icon: const Icon(Icons.check_circle, color: Colors.green), onPressed: () => _updateBookingStatus(booking['booking_id'], 'CONFIRMED')),
                                      IconButton(icon: const Icon(Icons.cancel, color: Colors.redAccent), onPressed: () => _updateBookingStatus(booking['booking_id'], 'CANCELLED')),
                                    ],
                                  )
                              ],
                            ),
                          );
                        },
                      ),
              ),
              const SizedBox(height: 40),

              const Text("Global Inventory", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: darkCardColor, borderRadius: BorderRadius.circular(16)),
                child: _isLoadingInventory 
                  ? const Center(child: CircularProgressIndicator())
                  : _inventoryItems.isEmpty
                    ? const Center(child: Padding(padding: EdgeInsets.all(20), child: Text("Inventory is empty.", style: TextStyle(color: textGray))))
                    : Column(
                      children: _inventoryItems.map((item) {
                        return ListTile(
                          leading: const Icon(Icons.inventory, color: primaryPurple),
                          title: Text(item['name'], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          subtitle: Text("₱${item['price']} • Stock: ${item['stock_quantity']} • ${item['category']}", style: const TextStyle(color: textGray)),
                          trailing: IconButton(icon: const Icon(Icons.delete, color: Colors.redAccent), onPressed: () => _deleteProduct(item['product_id'], item['name'])),
                        );
                      }).toList(),
                    ),
              ),
              const SizedBox(height: 40),

              const Text("Add New Product", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(color: darkCardColor, borderRadius: BorderRadius.circular(16)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: _isPickingImage ? null : _pickImage,
                      child: Container(
                        width: double.infinity, height: 160,
                        decoration: BoxDecoration(color: const Color(0xFF110F18), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.white24, width: 1)),
                        child: _selectedImage != null 
                          ? ClipRRect(borderRadius: BorderRadius.circular(12), child: Image.file(_selectedImage!, fit: BoxFit.cover))
                          : Column(mainAxisAlignment: MainAxisAlignment.center, children: const [Icon(Icons.add_photo_alternate, color: Colors.white, size: 32), SizedBox(height: 12), Text("Upload Picture", style: TextStyle(color: Colors.white))]),
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    TextField(
                      controller: _nameController, 
                      style: const TextStyle(color: Colors.white), 
                      decoration: InputDecoration(
                        filled: true, fillColor: inputFillColor, 
                        prefixIcon: const Icon(Icons.shopping_bag, color: Colors.white54),
                        hintText: "Product Name", hintStyle: const TextStyle(color: Colors.white54),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none)
                      )
                    ),
                    const SizedBox(height: 16),

                    DropdownButtonFormField<String>(
                      value: _selectedCategory,
                      dropdownColor: inputFillColor,
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                      decoration: InputDecoration(
                        filled: true, fillColor: inputFillColor,
                        prefixIcon: const Icon(Icons.category, color: Colors.white54),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none)
                      ),
                      items: _productCategories.map((cat) => DropdownMenuItem(value: cat, child: Text(cat))).toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => _selectedCategory = val);
                      },
                    ),
                    const SizedBox(height: 16),

                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _priceController, 
                            keyboardType: TextInputType.number, 
                            style: const TextStyle(color: Colors.white), 
                            decoration: InputDecoration(
                              filled: true, fillColor: inputFillColor, 
                              prefixIcon: const Padding(
                                padding: EdgeInsets.all(15.0), 
                                child: Text("₱", style: TextStyle(color: Colors.white54, fontSize: 18, fontWeight: FontWeight.bold)),
                              ), 
                              hintText: "Price (₱)", hintStyle: const TextStyle(color: Colors.white54), 
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none)
                            )
                          )
                        ),
                        const SizedBox(width: 16),
                        Expanded(child: TextField(controller: _stockController, keyboardType: TextInputType.number, style: const TextStyle(color: Colors.white), decoration: InputDecoration(filled: true, fillColor: inputFillColor, prefixIcon: const Icon(Icons.inventory_2, color: Colors.white54), hintText: "Stock", hintStyle: const TextStyle(color: Colors.white54), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none)))),
                      ],
                    ),
                    const SizedBox(height: 24),

                    SizedBox(
                      width: double.infinity, height: 56,
                      child: ElevatedButton(
                        onPressed: _isPublishing ? null : _publishProduct,
                        style: ElevatedButton.styleFrom(backgroundColor: accentPink, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                        child: _isPublishing 
                          ? const CircularProgressIndicator(color: Colors.black)
                          : const Text("PUBLISH TO STORE", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}