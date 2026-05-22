import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'seat_selection_screen.dart';

class BookingTripsScreen extends StatefulWidget {
  final int? companyId;
  final int? routeId;
  final String companyName;
  final String logo;
  final String fromCity;
  final String toCity;
  final String selectedDate;
  final int dayIndex;

  const BookingTripsScreen({
    super.key,
    this.companyId,
    this.routeId,
    required this.companyName,
    required this.logo,
    required this.fromCity,
    required this.toCity,
    required this.selectedDate,
    required this.dayIndex,
  });

  @override
  State<BookingTripsScreen> createState() => _BookingTripsScreenState();
}

class _BookingTripsScreenState extends State<BookingTripsScreen> {
  int activeTab = 0;
  final Color navyColor = const Color(0xFF2D3436);
  final Color primaryGreen = const Color(0xFF2ECC71);

  List<dynamic> serverTrips = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchTrips();
  }

  Future<void> fetchTrips() async {
    if (widget.companyId == null || widget.routeId == null) {
      setState(() => isLoading = false);
      return;
    }

    try {
      final response = await Dio().get(
        'http://127.0.0.1:8000/api/get-company-trips',
        queryParameters: {
          'company_id': widget.companyId,
          'route_id': widget.routeId,
          'day_index': widget.dayIndex,
        },
      );

      if (response.data['status'] == true) {
        setState(() {
          serverTrips = response.data['data'];
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  // دالة مخصصة لتحويل الوقت من نظام 24 ساعة إلى نظام 12 ساعة مع إضافة م / ص باللغة العربية
  String _formatTo12Hour(String time24) {
    try {
      List<String> parts = time24.split(':');
      int hour = int.parse(parts[0]);
      int minute = int.parse(parts[1]);

      String period = "ص";
      if (hour >= 12) {
        period = "م";
        if (hour > 12) hour -= 12;
      }
      if (hour == 0) hour = 12;

      String strHour = hour.toString().padLeft(2, '0');
      String strMinute = minute.toString().padLeft(2, '0');

      return "$strHour:$strMinute $period";
    } catch (e) {
      return time24; // حماية التطبيق من الانهيار في حال الخطأ
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF1F2F6),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text("اختيار موعد الرحلة",
              style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold)),
          centerTitle: true,
        ),
        body: Column(
          children: [
            const SizedBox(height: 10),
            Column(
              children: [
                Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15)],
                    border: Border.all(color: Colors.white, width: 3),
                  ),
                  child: ClipOval(
                    child: widget.logo.startsWith('http')
                        ? Image.network(widget.logo, fit: BoxFit.cover)
                        : Image.asset(widget.logo, fit: BoxFit.cover),
                  ),
                ),
                const SizedBox(height: 10),
                Text(widget.companyName,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
              ],
            ),
            const SizedBox(height: 20),
            _buildHeaderCard(),
            const SizedBox(height: 25),
            _buildFilterTabs(),
            Expanded(
              child: isLoading
                  ? Center(child: CircularProgressIndicator(color: primaryGreen))
                  : serverTrips.isEmpty
                  ? const Center(child: Text("لا توجد رحلات متاحة لهذا اليوم"))
                  : ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                children: _getFilteredTrips(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 20, offset: const Offset(0, 10))],
      ),
      child: Row(
        children: [
          Expanded(child: _headerInfo("من", widget.fromCity, Icons.location_on_outlined)),
          Icon(Icons.arrow_forward, color: primaryGreen.withOpacity(0.5), size: 20),
          Expanded(child: _headerInfo("إلى", widget.toCity, Icons.location_on)),
          Container(width: 1, height: 40, color: Colors.grey[100], margin: const EdgeInsets.symmetric(horizontal: 10)),
          Expanded(child: _headerInfo("التاريخ", widget.selectedDate, Icons.calendar_today_outlined)),
        ],
      ),
    );
  }

  Widget _headerInfo(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 16, color: primaryGreen),
        const SizedBox(height: 4),
        Text(value,
          style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w900, fontSize: 14),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildFilterTabs() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        children: [
          Expanded(child: _tabItem("الكل", 0)),
          Expanded(child: _tabItem("صباحاً", 1)),
          Expanded(child: _tabItem("مساءً", 2)),
        ],
      ),
    );
  }

  Widget _tabItem(String label, int index) {
    bool isSelected = activeTab == index;
    return GestureDetector(
      onTap: () => setState(() => activeTab = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? primaryGreen : Colors.transparent,
          borderRadius: BorderRadius.circular(25),
        ),
        child: Center(
          child: Text(label,
              style: TextStyle(
                  color: isSelected ? Colors.white : Colors.grey[600],
                  fontWeight: FontWeight.bold,
                  fontSize: 14
              )),
        ),
      ),
    );
  }

  List<Widget> _getFilteredTrips() {
    return serverTrips.where((t) {
      String timeStr = (t['scheduled_time'] ?? "").toString();
      if (activeTab == 0) return true;
      try {
        int hour = int.parse(timeStr.split(':')[0]);
        if (activeTab == 1) return hour < 12;
        if (activeTab == 2) return hour >= 12;
      } catch (e) { print(e); }
      return true;
    }).map((t) => _buildTripCard(t)).toList();
  }

  Widget _buildTripCard(Map<String, dynamic> tripData) {
    String time = tripData['scheduled_time']?.toString() ?? "00:00";

    DateTime now = DateTime.now();
    bool isPast = false;

    try {
      DateTime selectedDate;
      List<String> dateParts = widget.selectedDate.split(RegExp(r'[/-]'));
      if (dateParts[0].length < 4) {
        selectedDate = DateTime(int.parse(dateParts[2]), int.parse(dateParts[1]), int.parse(dateParts[0]));
      } else {
        selectedDate = DateTime.parse(widget.selectedDate);
      }

      List<String> timeParts = time.split(':');
      DateTime tripDateTime = DateTime(
        selectedDate.year,
        selectedDate.month,
        selectedDate.day,
        int.parse(timeParts[0]),
        int.parse(timeParts[1]),
      );

      if (tripDateTime.isBefore(now)) {
        isPast = true;
      }
    } catch (e) {
      print("Error parsing date/time: $e");
    }

    String displayTime = _formatTo12Hour(time.length >= 5 ? time.substring(0, 5) : time);

    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: isPast ? Colors.grey[100] : Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          if (!isPast) BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          onTap: isPast ? null : () {
            var routeData = tripData['route'] ?? {};
            String? fromStation = tripData['departure_address'] ?? routeData['departure_address'];
            String? toStation = tripData['arrival_address'] ?? routeData['arrival_address'];

            var busData = tripData['bus'] ?? {};
            int dynamicTotalSeats = busData['total_seats'] ?? 35;

            // 💡 مطابقة حقل قاعدة البيانات بدقة تامة لإنهاء الـ Null
            String dynamicBusNumber = busData['bus_numbernnn']?.toString() ?? "غير محدد";

            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SeatSelectionScreen(
                  tripId: tripData['id'],
                  fromCity: widget.fromCity,
                  toCity: widget.toCity,
                  selectedDate: widget.selectedDate,
                  tripTime: time,
                  fromStation: fromStation?.toString(),
                  toStation: toStation?.toString(),
                  companyName: widget.companyName,
                  totalSeats: dynamicTotalSeats,
                  busNumber: dynamicBusNumber,
                ),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isPast ? Colors.grey[300] : primaryGreen.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                      isPast ? Icons.timer_off_outlined : Icons.access_time_filled,
                      color: isPast ? Colors.grey[500] : primaryGreen,
                      size: 24
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isPast ? "انتهى وقت الرحلة ($displayTime)" : "انطلاق الرحلة: $displayTime",
                        style: TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 16,
                            color: isPast ? Colors.grey[400] : const Color(0xFF2D3436),
                            decoration: isPast ? TextDecoration.lineThrough : null
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.directions_bus_filled_outlined, size: 14, color: Colors.grey[400]),
                          const SizedBox(width: 5),
                          Text(
                              isPast ? "الحجز مغلق" : "رحلة مباشرة",
                              style: TextStyle(color: Colors.grey[500], fontSize: 12)
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (!isPast) Icon(Icons.arrow_forward_ios, color: Colors.grey[300], size: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}