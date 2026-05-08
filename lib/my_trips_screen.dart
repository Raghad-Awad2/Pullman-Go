import 'package:flutter/material.dart';
import 'ticket_details_screen.dart';
import 'hom.dart'; // استيراد ملف الهوم

class MyTripsScreen extends StatefulWidget {
  const MyTripsScreen({super.key});

  @override
  State<MyTripsScreen> createState() => _MyTripsScreenState();
}

class _MyTripsScreenState extends State<MyTripsScreen> {
  bool isUpcoming = true;
  bool isTicketVisible = true;
  final Color primaryGreen = const Color(0xFF2ECC71);
  final Color inactiveBox = const Color(0xFFF1F3F4); // لون المربع الفاتح
  final Color inactiveText = Colors.grey.shade700; // لون الخط الرمادي الغامق

  void _showCancelDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            title: const Center(
              child: Text("هل انت متأكد من الغاء رحلتك؟؟",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
            actionsAlignment: MainAxisAlignment.center,
            actions: [
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(backgroundColor: primaryGreen),
                child: const Text("لا", style: TextStyle(color: Colors.white)),
              ),
              const SizedBox(width: 20),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    isTicketVisible = false;
                  });
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("تم الغاء رحلتك بنجاح", textAlign: TextAlign.center),
                      backgroundColor: Colors.redAccent,
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(backgroundColor: inactiveBox),
                child: const Text("نعم", style: TextStyle(color: Colors.black)),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildTabsSection(),
        Expanded(child: isUpcoming ? _buildUpcomingContent() : _buildPastContent()),
      ],
    );
  }

  Widget _buildTabsSection() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Expanded(child: InkWell(onTap: () => setState(() => isUpcoming = true), child: _buildTabButton("الرحلات القادمة", isUpcoming))),
          const SizedBox(width: 10),
          Expanded(child: InkWell(onTap: () => setState(() => isUpcoming = false), child: _buildTabButton("الرحلات السابقة", !isUpcoming))),
        ],
      ),
    );
  }

  Widget _buildTabButton(String label, bool isActive) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
          color: isActive ? primaryGreen : inactiveBox,
          borderRadius: BorderRadius.circular(12),
          boxShadow: isActive ? [BoxShadow(color: primaryGreen.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))] : null
      ),
      child: Center(
          child: Text(label,
              style: TextStyle(
                  color: isActive ? Colors.white : inactiveText,
                  fontWeight: FontWeight.bold
              )
          )
      ),
    );
  }

  Widget _buildUpcomingContent() {
    if (!isTicketVisible) {
      return const Center(child: Text("لا توجد رحلات قادمة حالياً"));
    }
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)]
          ),
          child: Column(
            children: [
              const Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text("السراج للسياحة والسفر", style: TextStyle(fontWeight: FontWeight.bold)),
                CircleAvatar(backgroundColor: Color(0xFF1C2E4A), child: Icon(Icons.bus_alert, color: Colors.orange, size: 20))
              ]),
              const Divider(),
              // السهم يشير من درعا إلى دمشق
              const Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
                Column(children: [Text("درعا", style: TextStyle(fontWeight: FontWeight.bold)), Text("08:00 ص", style: TextStyle(fontSize: 10))]),
                Icon(Icons.arrow_forward, color: Color(0xFF2ECC71)),
                Column(children: [Text("دمشق", style: TextStyle(fontWeight: FontWeight.bold)), Text("10:00 ص", style: TextStyle(fontSize: 10))]),
              ]),
              const SizedBox(height: 25),

              Row(
                children: [
                  // زر عرض التذكرة - ملون بالأخضر
                  Expanded(child: _buildActionButton("عرض التذكرة", primaryGreen, Colors.white, () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => TicketDetailsScreen(onBack: () => Navigator.pop(context))),
                    );
                  })),
                  const SizedBox(width: 8),

                  // زر إلغاء الحجز - مربع فاتح
                  Expanded(child: _buildActionButton("إلغاء الحجز", inactiveBox, inactiveText, () => _showCancelDialog(context))),
                  const SizedBox(width: 8),

                  // زر تعديل الحجز - الانتقال لـ PullmanMainScreen وحذف السجل
                  Expanded(child: _buildActionButton("تعديل الحجز", inactiveBox, inactiveText, () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => const PullmanMainScreen()),
                          (route) => false,
                    );
                  })),
                ],
              )
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(String label, Color bgColor, Color textColor, VoidCallback onTap) {
    return SizedBox(
      height: 40,
      child: ElevatedButton(
          onPressed: onTap,
          style: ElevatedButton.styleFrom(
            backgroundColor: bgColor,
            elevation: 0,
            padding: EdgeInsets.zero,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          child: Text(label, style: TextStyle(color: textColor, fontSize: 11, fontWeight: FontWeight.bold))
      ),
    );
  }

  Widget _buildPastContent() {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)]
          ),
          child: Column(
            children: [
              const Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
                Column(children: [Text("الانطلاق", style: TextStyle(color: Colors.grey, fontSize: 12)), Text("دمشق", style: TextStyle(fontWeight: FontWeight.bold))]),
                Icon(Icons.arrow_back, color: Colors.grey),
                Column(children: [Text("الوصول", style: TextStyle(color: Colors.grey, fontSize: 12)), Text("القنيطرة", style: TextStyle(fontWeight: FontWeight.bold))]),
              ]),
              const SizedBox(height: 15),
              Align(
                alignment: Alignment.centerLeft,
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => TicketDetailsScreen(onBack: () => Navigator.pop(context))),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(color: primaryGreen, borderRadius: BorderRadius.circular(20)),
                    child: const Text("عرض تفاصيل الرحلة", style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                  ),
                ),
              )
            ],
          ),
        ),
      ],
    );
  }
}