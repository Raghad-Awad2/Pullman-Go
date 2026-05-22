import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  final Color primaryGreen = const Color(0xFF2ECC71); // الأخضر الغامق للتحديد والتأكيد
  final Color lightAvailableGreen = const Color(0xFFA3E4D7); // الأخضر الفاتح للمقاعد المتاحة
  final Color navyColor = const Color(0xFF1A237E);
  List<int> selectedSeats = [];

  // قائمة المقاعد المحجوزة مسبقاً
  final List<int> reservedSeats = [5, 6, 11, 12, 25, 33];

  late String currentSelectedDate;

  @override
  void initState() {
    super.initState();
    currentSelectedDate = widget.selectedDate;
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FA), // خلفية أهدأ وأكثر عصرية للواجهة
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0.8,
          title: const Text(
            "تحديد المقاعد",
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16, letterSpacing: 0.5),
          ),
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 18),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (widget.companyName != null) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 12, offset: const Offset(0, 4))],
                      border: Border.all(color: Colors.grey.shade100),
                    ),
                    child: Column(
                      children: [
                        Text(widget.companyName!,
                            style: TextStyle(color: navyColor, fontWeight: FontWeight.bold, fontSize: 16)),
                        const SizedBox(height: 6),
                        Text(widget.tripRoute ?? "",
                            style: const TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.w500)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // الكارد العلوي المدمج للمحافظات والتاريخ والوقت
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 12, offset: const Offset(0, 4))],
                    border: Border.all(color: Colors.grey.shade100),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Column(
                            children: [
                              Icon(Icons.circle, size: 9, color: primaryGreen),
                              Container(width: 1.5, height: 26, color: Colors.grey.shade300),
                              const Icon(Icons.location_on, size: 14, color: Colors.redAccent),
                            ],
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(widget.fromCity, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black87)),
                                    const SizedBox(width: 4),
                                    const Text("(كراجات شرقي_غربي)", style: TextStyle(color: Colors.grey, fontSize: 12)),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  children: [
                                    Text(widget.toCity, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black87)),
                                    const SizedBox(width: 4),
                                    const Text("(نهر عيشة)", style: TextStyle(color: Colors.grey, fontSize: 12)),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Divider(height: 1, thickness: 1, color: Color(0xFFF5F5F5)),
                      const SizedBox(height: 16),
                      // صف التاريخ الثابت والوقت
                      Row(
                        children: [
                          Expanded(child: _buildCompactInfoField("تاريخ الرحلة", currentSelectedDate, Icons.calendar_month)),
                          const SizedBox(width: 12),
                          Expanded(child: _buildCompactInfoField("وقت الانطلاق", widget.tripTime, Icons.watch_later)),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),
                const Text(
                  "حدد عدد المقاعد التي تريد حجزها لهذه الرحلة",
                  style: TextStyle(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 16),

                // هيكل الحافلة المطور بلمسات جمالية انسيابية
                Center(
                  child: Container(
                    width: MediaQuery.of(context).size.width > 450 ? 360 : double.infinity,
                    padding: const EdgeInsets.only(top: 12, bottom: 24, left: 24, right: 24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(35),
                      border: Border.all(color: Colors.grey.shade200, width: 2),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 15, offset: const Offset(0, 5))],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // تمثيل زجاج مقدمة الباص الجمالي العلوي
                        Container(
                          width: 60,
                          height: 4,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(height: 12),

                        // كابينة الشوفير الأمامية بمقعد مريح ومستقل
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Icon(Icons.tune_rounded, color: Colors.grey.shade400, size: 22),
                              Column(
                                children: [
                                  Icon(Icons.airline_seat_recline_normal_rounded, color: Colors.grey.shade800, size: 28),
                                  const SizedBox(height: 2),
                                  Text("السائق", style: TextStyle(fontSize: 10, color: Colors.grey.shade800, fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Divider(thickness: 1, color: Colors.grey.shade100, height: 10),
                        const SizedBox(height: 12),

                        // شبكة المقاعد الانسيابية المستقلة
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: 35,
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 5,
                            mainAxisSpacing: 14, // أبعاد ممتازة لمنع تداخل النصوص مع الأيقونات
                            crossAxisSpacing: 8,
                            childAspectRatio: 0.85,
                          ),
                          itemBuilder: (context, index) {
                            if (index % 5 == 2) {
                              return const SizedBox(); // ممر الركاب مفرغ
                            }

                            int currentSeat = seatCounter(index);
                            return _buildIndependentSeatItem(currentSeat);
                          },
                        ),
                        const SizedBox(height: 14),

                        // الصف الأخير الخلفي المكون من 5 كراسي
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: List.generate(5, (index) {
                            int backSeatNum = 29 + index;
                            return Expanded(
                              child: _buildIndependentSeatItem(backSeatNum),
                            );
                          }),
                        ),
                      ],
                    ),
                  ),
                ),

                // حالة وإحصائيات المقاعد
                const SizedBox(height: 24),
                _buildSeatStats(),

                const SizedBox(height: 24),
                Center(
                  child: Container(
                    width: double.infinity,
                    height: 50,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: selectedSeats.isEmpty ? [] : [
                        BoxShadow(
                          color: primaryGreen.withOpacity(0.25),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        )
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: selectedSeats.isEmpty ? null : () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PassengerDetailsScreen(
                              selectedSeats: selectedSeats,
                              pricePerSeat: 400, // السعر الافتراضي لكل مقعد والمستخدم في الحسابات
                              fromCity: widget.fromCity,
                              toCity: widget.toCity,
                              travelDate: currentSelectedDate,
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryGreen,
                        disabledBackgroundColor: Colors.grey.shade300,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        elevation: 0,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            selectedSeats.isEmpty ? "التالي" : "التالي (${selectedSeats.length} مقاعد)",
                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                          const SizedBox(width: 8),
                          const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 18),
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

  int seatCounter(int index) {
    int row = index ~/ 5;
    int col = index % 5;
    return row * 4 + (col > 2 ? col : col + 1);
  }

  Widget _buildCompactInfoField(String label, String value, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 14, color: Colors.grey.shade500),
            const SizedBox(width: 4),
            Text(label, style: TextStyle(color: Colors.grey.shade600, fontSize: 11, fontWeight: FontWeight.w500)),
          ],
        ),
        const SizedBox(height: 6),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
          decoration: BoxDecoration(
            color: const Color(0xFFF8F9FA),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey.shade200, width: 0.5),
          ),
          child: Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.black87),
          ),
        ),
      ],
    );
  }

  // بناء الكرسي المستقل بالأيقونة الاحترافية والمحسنة جمالياً
  Widget _buildIndependentSeatItem(int seatNum) {
    bool isReserved = reservedSeats.contains(seatNum);
    bool isSelected = selectedSeats.contains(seatNum);

    // دقة واحترافية الألوان طبقاً لطلبك مع تحسين درجات التباين
    Color iconColor = isReserved
        ? Colors.grey.shade300
        : (isSelected ? primaryGreen : lightAvailableGreen);

    Color textColor = isReserved
        ? Colors.grey.shade400
        : (isSelected ? primaryGreen : Colors.black87);

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
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeIn,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.event_seat_rounded, // تم تغيير شكل الأيقونة لتصبح أكثر انسيابية وجمالية للـ UI
              color: iconColor,
              size: 26,
            ),
            const SizedBox(height: 3),
            Text(
              seatNum.toString(),
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSeatStats() {
    int totalActualSeats = 33;
    int availableCount = totalActualSeats - reservedSeats.length;

    return Container(
      width: MediaQuery.of(context).size.width > 450 ? 360 : double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _statBox("متاح", availableCount.toString(), lightAvailableGreen),
          _statBox("محجوز", reservedSeats.length.toString(), Colors.grey.shade300),
          _statBox("محدد", selectedSeats.length.toString(), primaryGreen),
        ],
      ),
    );
  }

  Widget _statBox(String label, String count, Color color) {
    return Row(
      children: [
        Icon(Icons.event_seat_rounded, size: 18, color: color),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w500)),
        const SizedBox(width: 4),
        Text(count, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.black87)),
      ],
    );
  }
}