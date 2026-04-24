import 'package:flutter/material.dart';
import 'package:shuttlesync/database/database_helper.dart'; 
import 'package:shuttlesync/screens/playerdashboard.dart';

class CourtBookingPage extends StatefulWidget {
  final Map<String, dynamic>? currentUser;

  const CourtBookingPage({super.key, this.currentUser});

  @override
  State<CourtBookingPage> createState() => _CourtBookingScreenState();
}

class _CourtBookingScreenState extends State<CourtBookingPage> {
  final DateTime _today = DateTime.now();
  late int _selectedDate; 
  
  String _selectedDuration = '90m'; 
  String _selectedTime = '18:30';
  int _selectedCourtId = 1;
  bool _isProcessing = false; 

  @override
  void initState() {
    super.initState();
    _selectedDate = _today.day; 
  }

  final List<Map<String, dynamic>> _courts = [
    {'id': 1, 'name': 'Championship Court 1', 'price': 24.0, 'isPremium': true, 'desc': 'Tournament-grade wooden floor with enhanced glare-free lighting.', 'image': 'assets/img/court1.png'},
    {'id': 2, 'name': 'Standard Court 2', 'price': 20.0, 'isPremium': false, 'desc': 'Professional synthetic mat over sprung wood floor.', 'image': 'assets/img/court2.png'},
    {'id': 3, 'name': 'Standard Court 3', 'price': 20.0, 'isPremium': false, 'desc': 'Professional synthetic mat over sprung wood floor.', 'image': 'assets/img/court3.png'},
    {'id': 4, 'name': 'Standard Court 4', 'price': 20.0, 'isPremium': false, 'desc': 'Professional synthetic mat over sprung wood floor.', 'image': 'assets/img/court4.png'},
    {'id': 5, 'name': 'Training Court 5', 'price': 15.0, 'isPremium': false, 'desc': 'Slightly smaller clearance. Perfect for drills and coaching.', 'image': 'assets/img/court5.png'},
    {'id': 6, 'name': 'Standard Court 6', 'price': 20.0, 'isPremium': false, 'desc': 'Great for practice and casual matches.', 'image': 'assets/img/court6.png'},
    {'id': 7, 'name': 'VIP Neon Court 7', 'price': 30.0, 'isPremium': true, 'desc': 'Private court with exclusive lounge area and neon accents.', 'image': 'assets/img/court7.png'},
    {'id': 8, 'name': 'Standard Court 8', 'price': 20.0, 'isPremium': false, 'desc': 'Great for practice and casual matches.', 'image': 'assets/img/court8.png'},
  ];

  double get _totalPrice {
    double courtPrice = _courts.firstWhere((c) => c['id'] == _selectedCourtId)['price'];
    double hours = 1.0;
    if (_selectedDuration == '90m') hours = 1.5;
    if (_selectedDuration == '120m') hours = 2.0;
    return courtPrice * hours;
  }

  // ==========================================
  // NEW: CONFIRMATION DIALOG
  // ==========================================
  void _showConfirmationDialog() {
    if (widget.currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please log in to book a court.", style: TextStyle(color: Colors.white)), backgroundColor: Colors.red));
      return;
    }

    String formattedMonth = _today.month.toString().padLeft(2, '0');
    String formattedDay = _selectedDate.toString().padLeft(2, '0');
    String formattedDate = "${_today.year}-$formattedMonth-$formattedDay";

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1B1A24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("Confirm Booking", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: Text(
          "Court: Court $_selectedCourtId\nDate: $formattedDate\nTime: $_selectedTime\nDuration: $_selectedDuration\n\nTotal Cost: \$${_totalPrice.toStringAsFixed(2)}\n\nDo you want to proceed and reserve this slot?",
          style: const TextStyle(color: Colors.white70, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), // Cancels the dialog
            child: const Text("Cancel", style: TextStyle(color: Colors.white54))
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Closes the dialog
              _processBooking(); // RUNS THE DATABASE SAVE!
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFBB6AFB)),
            child: const Text("Confirm & Pay", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _processBooking() async {
    setState(() => _isProcessing = true);

    String formattedMonth = _today.month.toString().padLeft(2, '0');
    String formattedDay = _selectedDate.toString().padLeft(2, '0');
    String formattedDate = "${_today.year}-$formattedMonth-$formattedDay";
    
    int durationMins = _selectedDuration == '90m' ? 90 : (_selectedDuration == '120m' ? 120 : 60);
    int userId = widget.currentUser!['user_id'];

    bool isAvailable = await DatabaseHelper.instance.isSlotAvailable(
      _selectedCourtId, 
      formattedDate, 
      _selectedTime
    );

    if (!mounted) return;

    if (!isAvailable) {
      setState(() => _isProcessing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Conflict: This court is already booked for that time! Please select another time or court."), 
          backgroundColor: Colors.redAccent,
          duration: Duration(seconds: 4),
        ),
      );
      return;
    }

    // Confirm & Save Booking to SQLite
    await DatabaseHelper.instance.insertBooking({
      'user_id': userId,
      'court_id': _selectedCourtId,
      'booking_date': formattedDate,
      'start_time': _selectedTime,
      'duration_minutes': durationMins,
      'status': 'CONFIRMED' // Status set!
    });

    if (!mounted) return;
    setState(() => _isProcessing = false);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Booking Confirmed! Pull down on your Dashboard to refresh."), 
        backgroundColor: Colors.green,
        duration: Duration(seconds: 4),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const bgColor = Color(0xFF0F0E17); 
    const darkCardColor = Color(0xFF1B1A28); 
    const primaryPurple = Color(0xFFBB6AFB); 
    const accentPink = Color(0xFFFF6A9A); 
    const textGray = Color(0xFF8D8E98);

    List<String> months = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'];
    String currentMonthName = months[_today.month - 1];

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
            child: CircleAvatar(
              backgroundColor: darkCardColor, 
              child: ClipOval(
                child: Image.asset(
                  'assets/img/profile.png',
                  width: 40, height: 40, fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => const Icon(Icons.person, color: Colors.white70, size: 20),
                ),
              ),
            ),
          ),
        ),
        title: const Text("SHUTTLESYNC", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: 1.5, color: primaryPurple)),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.only(left: 20, right: 20, bottom: 180),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),
                const Text("Book Court", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
                const SizedBox(height: 4),
                const Text("SELECT DATE & DURATION", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.5, color: textGray)),
                const SizedBox(height: 20),

                _buildCalendarCard(darkCardColor, primaryPurple, currentMonthName),
                const SizedBox(height: 16),
                _buildDurationSelector(darkCardColor, primaryPurple),
                const SizedBox(height: 24),
                const Text("Available Courts", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
                const SizedBox(height: 16),
                _buildTimeSlots(primaryPurple, darkCardColor),
                const SizedBox(height: 20),
                ..._courts.map((court) => _buildCourtCard(court, darkCardColor, primaryPurple)),
              ],
            ),
          ),

          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              margin: const EdgeInsets.all(20),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: darkCardColor, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 30, offset: const Offset(0, -10))]),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Booking Summary", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          Text("${currentMonthName.substring(0,3)} $_selectedDate • $_selectedTime [$_selectedDuration] • Court $_selectedCourtId", style: const TextStyle(color: textGray, fontSize: 12)),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text("\$${_totalPrice.toStringAsFixed(2)}", style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                          const Text("TOTAL DUE", style: TextStyle(color: textGray, fontSize: 10, letterSpacing: 1.0)),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      // --- CHANGED: Now calls the Confirmation Dialog instead of processing immediately ---
                      onPressed: _isProcessing ? null : _showConfirmationDialog,
                      style: ElevatedButton.styleFrom(backgroundColor: accentPink, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                      child: _isProcessing 
                        ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text("Confirm Booking", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                              SizedBox(width: 8),
                              Icon(Icons.arrow_forward, color: Colors.white, size: 20),
                            ],
                          ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- Widgets ---

  Widget _buildCalendarCard(Color darkCardColor, Color primaryPurple, String monthName) {
    int daysInMonth = DateUtils.getDaysInMonth(_today.year, _today.month);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: darkCardColor, borderRadius: BorderRadius.circular(20)),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Icon(Icons.chevron_left, color: Colors.white54),
              Text("$monthName ${_today.year}", style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              const Icon(Icons.chevron_right, color: Colors.white54),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: ['MO', 'TU', 'WE', 'TH', 'FR', 'SA', 'SU'].map((day) => Text(day, style: const TextStyle(color: Colors.white54, fontSize: 12))).toList(),
          ),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 7, childAspectRatio: 1),
            itemCount: daysInMonth,
            itemBuilder: (context, index) {
              int day = index + 1;
              bool isSelected = day == _selectedDate;
              bool isPast = day < _today.day; 
              
              return GestureDetector(
                onTap: isPast ? null : () => setState(() => _selectedDate = day),
                child: Container(
                  margin: const EdgeInsets.all(4),
                  decoration: BoxDecoration(color: isSelected ? primaryPurple : Colors.transparent, borderRadius: BorderRadius.circular(10)),
                  alignment: Alignment.center,
                  child: Text(
                    day.toString(), 
                    style: TextStyle(
                      color: isPast ? Colors.white24 : (isSelected ? Colors.white : Colors.white70), 
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal
                    )
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDurationSelector(Color darkCardColor, Color primaryPurple) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(color: darkCardColor, borderRadius: BorderRadius.circular(16)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text("Duration", style: TextStyle(color: Colors.white54, fontSize: 14)),
          Row(
            children: ['60m', '90m', '120m'].map((duration) {
              bool isSelected = duration == _selectedDuration;
              return GestureDetector(
                onTap: () => setState(() => _selectedDuration = duration),
                child: Container(
                  margin: const EdgeInsets.only(left: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(color: isSelected ? primaryPurple : const Color(0xFF2E2A44), borderRadius: BorderRadius.circular(8)),
                  child: Text(duration, style: TextStyle(color: isSelected ? Colors.white : Colors.white70, fontWeight: FontWeight.bold)),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeSlots(Color primaryPurple, Color darkCardColor) {
    List<Map<String, dynamic>> times = [
      {'time': '16:00', 'status': 'AVAILABLE', 'color': Colors.white54},
      {'time': '17:00', 'status': 'AVAILABLE', 'color': Colors.white54},
      {'time': '18:00', 'status': 'FEW LEFT', 'color': Colors.redAccent},
      {'time': '18:30', 'status': 'AVAILABLE', 'color': Colors.white54},
      {'time': '19:00', 'status': 'AVAILABLE', 'color': Colors.white54},
      {'time': '20:00', 'status': 'AVAILABLE', 'color': Colors.white54},
    ];

    return SizedBox(
      height: 60,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: times.length,
        itemBuilder: (context, index) {
          bool isSelected = times[index]['time'] == _selectedTime;
          return GestureDetector(
            onTap: () => setState(() => _selectedTime = times[index]['time']),
            child: Container(
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: isSelected ? primaryPurple : darkCardColor, 
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: isSelected ? primaryPurple : Colors.transparent),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(times[index]['time'], style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 2),
                  Text(isSelected ? 'SELECTED' : times[index]['status'], style: TextStyle(color: isSelected ? Colors.white : times[index]['color'], fontSize: 8, fontWeight: FontWeight.bold, letterSpacing: 1.0)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCourtCard(Map<String, dynamic> court, Color darkCardColor, Color primaryPurple) {
    bool isSelected = court['id'] == _selectedCourtId;

    return GestureDetector(
      onTap: () => setState(() => _selectedCourtId = court['id']),
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          color: darkCardColor, 
          borderRadius: BorderRadius.circular(16), 
          border: isSelected ? Border.all(color: primaryPurple, width: 2) : Border.all(color: Colors.transparent, width: 2)
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 140,
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(topLeft: Radius.circular(14), topRight: Radius.circular(14)), 
                color: Color(0xFF11101A)
              ),
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.only(topLeft: Radius.circular(14), topRight: Radius.circular(14)),
                    child: SizedBox(
                      width: double.infinity,
                      child: Image.asset(
                        court['image'], 
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => const Center(child: Icon(Icons.sports_tennis, color: Colors.white10, size: 60)),
                      ),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.only(topLeft: Radius.circular(14), topRight: Radius.circular(14)),
                      gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.black.withOpacity(0.1), Colors.black.withOpacity(0.6)]),
                    ),
                  ),
                  if (court['isPremium'])
                    Positioned(top: 10, right: 10, child: Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: primaryPurple, borderRadius: BorderRadius.circular(4)), child: const Text("PREMIUM", style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)))),
                  if (isSelected)
                    Positioned(top: 10, right: 10, child: CircleAvatar(backgroundColor: primaryPurple, radius: 14, child: const Icon(Icons.check, color: Colors.white, size: 18))),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(child: Text(court['name'], style: TextStyle(color: isSelected ? primaryPurple : Colors.white, fontSize: 18, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis)),
                      Row(children: [Text("\$${court['price'].toInt()}", style: const TextStyle(color: Color(0xFFFF6A9A), fontSize: 18, fontWeight: FontWeight.bold)), const Text(" /hr", style: TextStyle(color: Colors.white54, fontSize: 12))]),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(court['desc'], style: const TextStyle(color: Colors.white54, fontSize: 12, height: 1.4)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}