import 'package:flutter/material.dart';

class TicketDetailsScreen extends StatelessWidget {
  final VoidCallback onBack;

  const TicketDetailsScreen({super.key, required this.onBack});

  // --- دالة إظهار واجهة التقييم (مثل الصورة تماماً) ---
  void _showRatingDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text("قييم الرحلة",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 15),
                // النجوم (هنا عرض ثابت، يمكنك استخدام مكتبة stars_rating لاحقاً للتفاعل)
                const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.star_border, color: Colors.grey, size: 35),
                    Icon(Icons.star_border, color: Colors.grey, size: 35),
                    Icon(Icons.star_border, color: Colors.grey, size: 35),
                    Icon(Icons.star_border, color: Colors.grey, size: 35),
                    Icon(Icons.star_border, color: Colors.grey, size: 35),
                  ],
                ),
                const SizedBox(height: 15),
                // حقل التعليق
                TextField(
                  decoration: InputDecoration(
                    hintText: "أكتب تعليق...",
                    filled: true,
                    fillColor: Colors.grey[100],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 20),
                // زر إرسال
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context); // إغلاق الواجهة
                    // إظهار رسالة النجاح
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("تم ارسال التعليق بنجاح", textAlign: TextAlign.center),
                        backgroundColor: Colors.green,
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    minimumSize: const Size(120, 45),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  ),
                  child: const Text("إرسال", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F5F5),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: const Text("عرض التذكرة...", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: onBack,
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // كرت الشركة
              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15)),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("السراج للسياحة والسفر", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    CircleAvatar(backgroundColor: Color(0xFF1C2E4A), child: Icon(Icons.bus_alert, color: Colors.orange, size: 20)),
                  ],
                ),
              ),
              const SizedBox(height: 15),
              // تفاصيل التذكرة
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15)),
                child: Column(
                  children: [
                    _buildRouteSection(),
                    const Divider(height: 30),
                    _buildInfoRow("الحساب", "محمد المحمد"),
                    _buildPassengerInfo("اسم الراكب الأول", "محمد المحمد", "16", "T_12345_1"),
                    _buildPassengerInfo("اسم الراكب الثاني", "سعيد المحسن", "17", "T_12345_2"),
                    const Divider(),
                    _buildInfoRow("التاريخ", "mm/dd/yyyy"),
                    _buildInfoRow("الوقت", "08:00 ص"),
                    const Divider(),
                    _buildInfoRow("تكلفة الحجز كاملة", "800 ل.س", isPrice: true),
                    _buildInfoRow("رقم الحجز المرجعي", "REF_8776764"),
                    const SizedBox(height: 25),
                    // زر التقييم الذي يفتح الواجهة
                    ElevatedButton(
                      onPressed: () => _showRatingDialog(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        minimumSize: const Size(120, 45),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      ),
                      child: const Text("تقييم", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // الـ Widgets المساعدة (نفس اللي كانت عندك)
  Widget _buildRouteSection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Column(children: [Text("درعا", style: TextStyle(fontWeight: FontWeight.bold))]),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(color: Colors.green, borderRadius: BorderRadius.circular(10)),
          child: const Text("مدة الرحلة: 2 ساعات", style: TextStyle(color: Colors.white, fontSize: 10)),
        ),
        const Column(children: [Text("دمشق", style: TextStyle(fontWeight: FontWeight.bold))]),
      ],
    );
  }

  Widget _buildPassengerInfo(String label, String name, String seat, String ticket) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 11)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
              Text("رقم المقعد: $seat", style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
            ],
          ),
          Text("رقم التذكرة: $ticket", style: const TextStyle(color: Colors.grey, fontSize: 10)),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isPrice = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(value, style: TextStyle(fontWeight: FontWeight.bold, color: isPrice ? Colors.green : Colors.black)),
        ],
      ),
    );
  }
}