import 'package:flutter/material.dart';
import 'package:shuttlesync/database/database_helper.dart';
import 'package:shuttlesync/screens/main_navigation.dart';

class CourtBookingPage extends StatefulWidget {
  final Map<String, dynamic>? currentUser;

  const CourtBookingPage({super.key, this.currentUser});

  @override
  State<CourtBookingPage> createState() => _CourtBookingScreenState();
}

class _CourtBookingScreenState extends State<CourtBookingPage> {
  DateTime _focusedMonth = DateTime.now();
  late DateTime _selectedDate; 
  
  String? _startTime;
  String? _endTime;
  int _selectedCourtId = 1;
  bool _isProcessing = false; 

  // Stores all existing bookings for the selected date & court
  List<Map<String, dynamic>> _dayBookings = [];

  // NEW: Facility expanded to 6 Courts with varying prices!
  final List<Map<String, dynamic>> _courts = [
    {'id': 1, 'name': 'Championship Court 1', 'price': 300.0, 'isPremium': true, 'desc': 'Tournament-grade wooden floor with enhanced glare-free lighting.', 'image': 'assets/img/court.jpeg'},
    {'id': 2, 'name': 'Championship Court 2', 'price': 300.0, 'isPremium': true, 'desc': 'Tournament-grade wooden floor with enhanced glare-free lighting.', 'image': 'assets/img/court.jpeg'},
    {'id': 3, 'name': 'Standard Court 3', 'price': 200.0, 'isPremium': false, 'desc': 'Professional synthetic mat with standard lighting.', 'image': 'assets/img/court.jpeg'},
    {'id': 4, 'name': 'Standard Court 4', 'price': 200.0, 'isPremium': false, 'desc': 'Professional synthetic mat with standard lighting.', 'image': 'assets/img/court.jpeg'},
    {'id': 5, 'name': 'Practice Court 5', 'price': 150.0, 'isPremium': false, 'desc': 'Basic setup for drills and casual play.', 'image': 'assets/img/court.jpeg'},
    {'id': 6, 'name': 'Practice Court 6', 'price': 150.0, 'isPremium': false, 'desc': 'Basic setup for drills and casual play.', 'image': 'assets/img/court.jpeg'},
  ];

  final List<String> _allHours = [
    '08:00', '09:00', '10:00', '11:00', '12:00', '13:00', 
    '14:00', '15:00', '16:00', '17:00', '18:00', '19:00', '20:00', '21:00'
  ];

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime(_focusedMonth.year, _focusedMonth.month, _focusedMonth.day);
    _loadBookingsForDate();
  }

  // --- HELPER FUNCTIONS FOR TIME & PRICE MATH ---
  double _timeToDouble(String t) {
    var parts = t.split(':');
    return int.parse(parts[0]) + (int.parse(parts[1]) / 60.0);
  }

  String _doubleToTime(double d) {
    int h = d.truncate();
    int m = ((d - h) * 60).round();
    return "${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}";
  }

  // Calculates exactly how much the user owes based on duration!
  double _calculateTotal() {
    if (_startTime == null || _endTime == null) return 0.0;
    int durationMins = ((_timeToDouble(_endTime!) - _timeToDouble(_startTime!)) * 60).round();
    double hours = durationMins / 60.0;
    double hourlyRate = _courts.firstWhere((c) => c['id'] == _selectedCourtId)['price'];
    return hourlyRate * hours;
  }

  // --- CORE LOGIC: FETCH & CHECK BLOCKED SLOTS ---
  void _loadBookingsForDate() async {
    String formattedMonth = _selectedDate.month.toString().padLeft(2, '0');
    String formattedDay = _selectedDate.day.toString().padLeft(2, '0');
    String dateString = "${_selectedDate.year}-$formattedMonth-$formattedDay";

    final bookings = await DatabaseHelper.instance.getBookingsByDate(dateString);
    
    if (mounted) {
      setState(() {
        _dayBookings = bookings.where((b) => b['court_id'] == _selectedCourtId && b['status'] != 'CANCELLED').toList();
        _startTime = null;
        _endTime = null;
      });
    }
  }

  bool _isTimeBlocked(String time) {
    double t = _timeToDouble(time);

    if (_selectedDate.year == DateTime.now().year && _selectedDate.month == DateTime.now().month && _selectedDate.day == DateTime.now().day) {
      double currentHour = DateTime.now().hour + (DateTime.now().minute / 60.0);
      if (t <= currentHour) return true;
    }

    for (var b in _dayBookings) {
      double bStart = _timeToDouble(b['start_time']);
      double bEnd = bStart + (b['duration_minutes'] / 60.0);
      if (t >= bStart && t < bEnd) {
        return true;
      }
    }
    return false;
  }

  List<String> _getValidEndTimes() {
    if (_startTime == null) return [];
    double start = _timeToDouble(_startTime!);
    List<String> validEnds = [];

    for (double e = start + 1.0; e <= 22.0; e += 1.0) { 
      bool overlaps = false;
      for (var b in _dayBookings) {
          double bStart = _timeToDouble(b['start_time']);
          double bEnd = bStart + (b['duration_minutes'] / 60.0);
          if (start < bEnd && e > bStart) {
              overlaps = true;
              break;
          }
      }
      if (overlaps) break; 
      validEnds.add(_doubleToTime(e));
    }
    return validEnds;
  }

  int _getDaysInMonth(int year, int month) {
    if (month == 12) return DateTime(year + 1, 1, 0).day;
    return DateTime(year, month + 1, 0).day;
  }

  void _confirmBooking() async {
    if (widget.currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please log in to book a court."), backgroundColor: Colors.red));
      return;
    }
    if (_startTime == null || _endTime == null) return;

    setState(() => _isProcessing = true);

    String formattedMonth = _selectedDate.month.toString().padLeft(2, '0');
    String formattedDay = _selectedDate.day.toString().padLeft(2, '0');
    String dateString = "${_selectedDate.year}-$formattedMonth-$formattedDay";
    
    int durationMins = ((_timeToDouble(_endTime!) - _timeToDouble(_startTime!)) * 60).round();
    double totalPay = _calculateTotal(); // Get the exact amount!

    int bookingId = await DatabaseHelper.instance.insertBooking({
      'user_id': widget.currentUser!['user_id'],
      'court_id': _selectedCourtId,
      'booking_date': dateString,
      'start_time': _startTime,
      'duration_minutes': durationMins,
      'status': 'PENDING'
    });

    setState(() => _isProcessing = false);

    if (mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          backgroundColor: const Color(0xFF1B1A24),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Column(
            children: const [
              Icon(Icons.check_circle, color: Colors.greenAccent, size: 48),
              SizedBox(height: 16),
              Text("RESERVATION SECURED", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
            ]
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Booking #$bookingId", style: const TextStyle(color: Colors.white54)),
              const SizedBox(height: 12),
              // Tells the user exactly how much cash to bring!
              Text(
                "Your court is reserved!\n\nTotal to pay: ₱${totalPay.toStringAsFixed(2)}\n\nPlease proceed to the facility counter and pay with CASH to fully confirm your slot.", 
                textAlign: TextAlign.center, 
                style: const TextStyle(color: Colors.white70, fontSize: 13, height: 1.4)
              ),
            ]
          ),
          actions: [
             TextButton(
               onPressed: () {
                 Navigator.pop(context); // Close the dialog
                 // Safely reset the navigation stack to the Home tab
                 Navigator.pushAndRemoveUntil(
                   context,
                   MaterialPageRoute(builder: (context) => MainNavigation(currentUser: widget.currentUser)),
                   (route) => false,
                 );
               },
               child: const Text("GO TO DASHBOARD", style: TextStyle(color: Color(0xFFBB6AFB), fontWeight: FontWeight.bold))
             )
          ]
        )
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    const bgColor = Color(0xFF0F0E17);
    const darkCardColor = Color(0xFF1B1A24);
    const primaryPurple = Color(0xFFBB6AFB);
    const textGray = Color(0xFF8D8E98);

    List<String> monthNames = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"];
    int daysInMonth = _getDaysInMonth(_focusedMonth.year, _focusedMonth.month);
    DateTime firstDayOfMonth = DateTime(_focusedMonth.year, _focusedMonth.month, 1);
    int startingWeekday = firstDayOfMonth.weekday;

    List<String> validEndTimes = _getValidEndTimes();
    
    // Check if both times are selected to update button text
    bool isReadyToBook = _startTime != null && _endTime != null;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios, color: Colors.white70, size: 20), onPressed: () => Navigator.pop(context)),
        title: const Text("RESERVE COURT", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: primaryPurple)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Select Court", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 16),
            ..._courts.map((court) => _buildCourtCard(court, primaryPurple, darkCardColor)),
            const SizedBox(height: 32),
            
            const Text("Select Date", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: darkCardColor, borderRadius: BorderRadius.circular(16)),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(onTap: () { setState(() => _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month - 1, 1)); _loadBookingsForDate(); }, child: const Icon(Icons.chevron_left, color: Colors.white70)),
                      Text("${monthNames[_focusedMonth.month - 1]} ${_focusedMonth.year}", style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                      GestureDetector(onTap: () { setState(() => _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month + 1, 1)); _loadBookingsForDate(); }, child: const Icon(Icons.chevron_right, color: Colors.white70)),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: ['MO', 'TU', 'WE', 'TH', 'FR', 'SA', 'SU'].map((day) => Text(day, style: const TextStyle(color: textGray, fontSize: 12, fontWeight: FontWeight.bold))).toList(),
                  ),
                  const SizedBox(height: 16),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 7, childAspectRatio: 1),
                    itemCount: daysInMonth + startingWeekday - 1,
                    itemBuilder: (context, index) {
                      if (index < startingWeekday - 1) return const SizedBox(); 
                      
                      int day = index - startingWeekday + 2;
                      DateTime thisDate = DateTime(_focusedMonth.year, _focusedMonth.month, day);
                      bool isSelected = _selectedDate.year == thisDate.year && _selectedDate.month == thisDate.month && _selectedDate.day == thisDate.day;
                      bool isPast = thisDate.isBefore(DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day));

                      return GestureDetector(
                        onTap: isPast ? null : () {
                          setState(() => _selectedDate = thisDate);
                          _loadBookingsForDate();
                        },
                        child: Container(
                          margin: const EdgeInsets.all(4),
                          decoration: BoxDecoration(color: isSelected ? primaryPurple : Colors.transparent, borderRadius: BorderRadius.circular(8)),
                          alignment: Alignment.center,
                          child: Text(day.toString(), style: TextStyle(color: isPast ? Colors.white24 : (isSelected ? Colors.white : Colors.white70), fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildLegendItem(darkCardColor, "Available", Colors.white70),
                const SizedBox(width: 16),
                _buildLegendItem(primaryPurple, "Selected", Colors.white),
                const SizedBox(width: 16),
                _buildLegendItem(Colors.redAccent.withOpacity(0.2), "Booked", Colors.redAccent),
              ],
            ),
            const SizedBox(height: 24),

            const Text("Select Start Time", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12, runSpacing: 12,
              children: _allHours.map((time) {
                bool isBlocked = _isTimeBlocked(time);
                bool isSelected = _startTime == time;
                Color boxColor = isSelected ? primaryPurple : (isBlocked ? Colors.redAccent.withOpacity(0.2) : darkCardColor);
                Color textColor = isBlocked ? Colors.redAccent : (isSelected ? Colors.white : Colors.white70);
                
                return GestureDetector(
                  onTap: isBlocked ? null : () {
                    setState(() {
                      _startTime = time;
                      _endTime = null;
                    });
                  },
                  child: Container(
                    width: (MediaQuery.of(context).size.width - 72) / 4, 
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(color: boxColor, borderRadius: BorderRadius.circular(12), border: Border.all(color: isSelected ? primaryPurple : (isBlocked ? Colors.redAccent.withOpacity(0.5) : Colors.white10))),
                    alignment: Alignment.center,
                    child: Text(time, style: TextStyle(color: textColor, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal, fontSize: 13, decoration: isBlocked ? TextDecoration.lineThrough : null)),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 32),

            if (_startTime != null) ...[
              const Text("Select End Time", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(color: darkCardColor, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.white10)),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    hint: const Text("Choose an End Time", style: TextStyle(color: Colors.white54)),
                    value: _endTime,
                    dropdownColor: darkCardColor,
                    icon: const Icon(Icons.keyboard_arrow_down, color: primaryPurple),
                    isExpanded: true,
                    style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                    onChanged: (String? newValue) => setState(() => _endTime = newValue),
                    items: validEndTimes.map<DropdownMenuItem<String>>((String value) => DropdownMenuItem<String>(value: value, child: Text(value))).toList(),
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ]
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(color: darkCardColor, borderRadius: BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24)), boxShadow: [BoxShadow(color: Colors.black45, blurRadius: 10, offset: Offset(0, -5))]),
        child: SafeArea(
          child: SizedBox(
            height: 56,
            child: ElevatedButton(
              onPressed: (_isProcessing || !isReadyToBook) ? null : _confirmBooking,
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryPurple, 
                disabledBackgroundColor: primaryPurple.withOpacity(0.3),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))
              ),
              child: _isProcessing 
                ? const CircularProgressIndicator(color: Colors.black)
                : Text(
                    isReadyToBook ? "CONFIRM BOOKING (₱${_calculateTotal().toStringAsFixed(2)})" : "SELECT TIMES TO BOOK", 
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87)
                  ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLegendItem(Color boxColor, String label, Color textColor) {
    return Row(
      children: [
        Container(width: 12, height: 12, decoration: BoxDecoration(color: boxColor, borderRadius: BorderRadius.circular(3), border: Border.all(color: Colors.white10))),
        const SizedBox(width: 6),
        Text(label, style: TextStyle(color: textColor, fontSize: 12, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildCourtCard(Map<String, dynamic> court, Color primaryPurple, Color darkCardColor) {
    bool isSelected = _selectedCourtId == court['id'];
    return GestureDetector(
      onTap: () {
        setState(() => _selectedCourtId = court['id']);
        _loadBookingsForDate(); 
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(color: darkCardColor, borderRadius: BorderRadius.circular(20), border: Border.all(color: isSelected ? primaryPurple : Colors.transparent, width: 2)),
        child: Column(
          children: [
            Container(
              height: 140, width: double.infinity,
              decoration: BoxDecoration(borderRadius: const BorderRadius.only(topLeft: Radius.circular(18), topRight: Radius.circular(18)), image: DecorationImage(image: AssetImage(court['image']), fit: BoxFit.cover)),
              child: Stack(
                children: [
                  Container(decoration: BoxDecoration(borderRadius: const BorderRadius.only(topLeft: Radius.circular(18), topRight: Radius.circular(18)), gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.transparent, Colors.black.withValues(alpha: 0.8)]))),
                  if (court['isPremium']) Positioned(top: 12, left: 12, child: Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(color: primaryPurple, borderRadius: BorderRadius.circular(4)), child: const Text("PREMIUM", style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)))),
                  if (isSelected) Positioned(top: 10, right: 10, child: CircleAvatar(backgroundColor: primaryPurple, radius: 14, child: const Icon(Icons.check, color: Colors.white, size: 18))),
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
                      Row(children: [Text("₱${court['price'].toInt()}", style: const TextStyle(color: Color(0xFFFF6A9A), fontSize: 18, fontWeight: FontWeight.bold)), const Text(" /hr", style: TextStyle(color: Colors.white54, fontSize: 12))]),
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