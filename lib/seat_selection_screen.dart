import 'package:flutter/material.dart';
import 'passenger_details_screen.dart';

class SeatSelectionScreen extends StatefulWidget {
  final String fromCity;
  final String toCity;
  final String selectedDate;
  final String tripTime;
  final String? companyName;
  final String? tripRoute;

  const SeatSelectionScreen({
    super.key,
    required this.fromCity,
    required this.toCity,
    required this.selectedDate,
    required this.tripTime,
    this.companyName,
    this.tripRoute,
  });

  @override
  State<SeatSelectionScreen> createState() => _SeatSelectionScreenState();
}

class _SeatSelectionScreenState extends State<SeatSelectionScreen> {
  final Color primaryGreen = const Color(0xFF2ECC71);
  final Color navyColor = const Color(0xFF1A237E);
  List<int> selectedSeats = [];

  // قائمة المقاعد المحجوزة
  final List<int> reservedSeats = [5, 6, 11, 12, 25];

  // القائمة المنسدلة للتاريخ
  late String currentSelectedDate;
  final List<String> offerDays = ["اليوم الأول من العرض", "اليوم الثاني من العرض", "اليوم الثالث من العرض"];

  @override
  void initState() {
    super.initState();
    // جعل التاريخ الافتراضي هو القادم من صفحة العروض أو أول يوم في القائمة
    currentSelectedDate = widget.selectedDate;
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Text("احجز رحلتك الآن...",
              style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18)),
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (widget.companyName != null) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: primaryGreen.withOpacity(0.3)),
                    ),
                    child: Column(
                      children: [
                        Text(widget.companyName!,
                            style: TextStyle(color: primaryGreen, fontWeight: FontWeight.bold, fontSize: 18)),
                        Text(widget.tripRoute ?? "",
                            style: const TextStyle(color: Colors.black54, fontSize: 14)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],

                const Text("مسار الرحلة:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 15),

                _buildLocationCard(widget.fromCity, "محطة الانطلاق: كراجات شرقي_غربي"),
                const SizedBox(height: 10),
                _buildLocationCard(widget.toCity, "محطة الوصول: نهر عيشة"),

                const SizedBox(height: 25),
                const Center(
                  child: Text("يرجى تحديد موعد الرحلة المناسب لك واختيار المقاعد",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black87)),
                ),

                const SizedBox(height: 20),
                Row(
                  children: [
                    // تم تعديل حقل التاريخ هنا ليصبح قائمة منسدلة
                    Expanded(child: _buildDateDropdown()),
                    const SizedBox(width: 15),
                    Expanded(child: _buildInfoBox("وقت الانطلاق", widget.tripTime, Icons.watch_later)),
                  ],
                ),

                const SizedBox(height: 30),
                const Center(
                  child: Text("حدد عدد المقاعد التي ترى حجزها لهذه الرحلة",
                      style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 13)),
                ),

                _buildBusLayout(),

                const SizedBox(height: 20),
                _buildSeatStats(),

                const SizedBox(height: 30),
                Center(
                  child: SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: selectedSeats.isEmpty ? null : () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PassengerDetailsScreen(selectedSeats: selectedSeats),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryGreen,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("التالي", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                          SizedBox(width: 10),
                          Icon(Icons.arrow_forward, color: Colors.white),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ويدجت القائمة المنسدلة للتاريخ
  Widget _buildDateDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("تاريخ الرحلة", style: TextStyle(color: Colors.grey, fontSize: 12)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: offerDays.contains(currentSelectedDate) ? currentSelectedDate : null,
              hint: Text(currentSelectedDate, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.black)),
              isExpanded: true,
              icon: const Icon(Icons.calendar_month, size: 18, color: Colors.black),
              items: offerDays.map((String day) {
                return DropdownMenuItem<String>(
                  value: day,
                  child: Text(day, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                );
              }).toList(),
              onChanged: (String? newValue) {
                if (newValue != null) {
                  setState(() {
                    currentSelectedDate = newValue;
                  });
                }
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLocationCard(String city, String station) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Row(
        children: [
          CircleAvatar(backgroundColor: primaryGreen, radius: 5),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(city, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              Text(station, style: const TextStyle(color: Colors.grey, fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoBox(String title, String value, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              Icon(icon, size: 18, color: Colors.black),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBusLayout() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 20),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 40,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 5,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
            ),
            itemBuilder: (context, index) {
              if (index % 5 == 2) return const SizedBox();

              int seatNum = index + 1;
              bool isReserved = reservedSeats.contains(seatNum);
              bool isSelected = selectedSeats.contains(seatNum);

              return GestureDetector(
                onTap: isReserved ? null : () {
                  setState(() {
                    if (isSelected) {
                      selectedSeats.remove(seatNum);
                    } else {
                      if (selectedSeats.length < 10) {
                        selectedSeats.add(seatNum);
                      }
                    }
                  });
                },
                child: Icon(
                  Icons.event_seat,
                  color: isReserved ? Colors.red : (isSelected ? primaryGreen : Colors.grey.shade300),
                  size: 30,
                ),
              );
            },
          ),
          const SizedBox(height: 10),
          const Text("الحد الأقصى 10 مقاعد للرحلة الواحدة", style: TextStyle(color: Colors.red, fontSize: 10)),
        ],
      ),
    );
  }

  Widget _buildSeatStats() {
    int totalActualSeats = 32;
    int availableCount = totalActualSeats - reservedSeats.length;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _statBox("المقاعد المتاحة", availableCount.toString(), Colors.grey.shade300),
        _statBox("المقاعد المحجوزة", reservedSeats.length.toString(), Colors.red),
        _statBox("محدد", selectedSeats.length.toString(), primaryGreen),
      ],
    );
  }

  Widget _statBox(String label, String count, Color color) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
          const SizedBox(height: 5),
          Row(
            children: [
              Text(count, style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(width: 5),
              Icon(Icons.event_seat, size: 15, color: color),
            ],
          )
        ],
      ),
    );
  }
}