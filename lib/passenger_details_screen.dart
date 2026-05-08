import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PassengerDetailsScreen extends StatefulWidget {
  final List<int> selectedSeats;

  const PassengerDetailsScreen({super.key, required this.selectedSeats});

  @override
  State<PassengerDetailsScreen> createState() => _PassengerDetailsScreenState();
}

class _PassengerDetailsScreenState extends State<PassengerDetailsScreen> {
  final Color primaryGreen = const Color(0xFF2ECC71);
  final Color navyColor = const Color(0xFF1A237E);

  // Controllers لمراقبة الحقول وتفعيل زر التأكيد
  final TextEditingController phoneController = TextEditingController();
  final List<TextEditingController> nameControllers = [];

  @override
  void initState() {
    super.initState();
    // إنشاء Controller لكل راكب بناءً على عدد المقاعد المختارة
    for (int i = 0; i < widget.selectedSeats.length; i++) {
      nameControllers.add(TextEditingController());
    }
  }

  // دالة للتحقق من أن جميع الحقول (الهاتف + كل الأسماء) ممتلئة
  bool _isAllDataEntered() {
    bool isPhoneEntered = phoneController.text.length == 9;
    bool areNamesEntered = nameControllers.every((controller) => controller.text.trim().isNotEmpty);
    return isPhoneEntered && areNamesEntered;
  }

  @override
  void dispose() {
    phoneController.dispose();
    for (var controller in nameControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0.5,
          title: const Text("احجز رحلتك الآن...",
              style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18)),
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black, size: 28),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 30),
              _buildSectionTitle(Icons.phone_in_talk_outlined, "معلومات الاتصال (لصاحب الحساب)"),
              const SizedBox(height: 15),
              _buildPhoneField(),
              const SizedBox(height: 40),
              const Center(
                child: Text("الرجاء ادخال بيانات الركاب",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87)),
              ),
              const SizedBox(height: 25),
              // عرض كروت الركاب مع الـ Controllers الخاصة بكل واحد
              ...widget.selectedSeats.asMap().entries.map((entry) {
                int index = entry.key;
                int seatNum = entry.value;
                return _buildPassengerCard(index, seatNum);
              }).toList(),
              const SizedBox(height: 30),
              Center(
                child: SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: ElevatedButton.icon(
                    // الزر لا يعمل إلا إذا تم إدخال كافة البيانات
                    onPressed: _isAllDataEntered() ? () => _showBookingSummary(context) : null,
                    icon: Icon(Icons.check_box_outlined, color: _isAllDataEntered() ? Colors.white : Colors.grey, size: 24),
                    label: Text("تأكيد",
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: _isAllDataEntered() ? Colors.white : Colors.grey)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryGreen,
                      disabledBackgroundColor: Colors.grey.shade300, // لون الزر وهو معطل
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(35)),
                      elevation: _isAllDataEntered() ? 3 : 0,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(IconData icon, String title) {
    return Row(
      children: [
        Icon(icon, color: Colors.black54, size: 22),
        const SizedBox(width: 10),
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.black87)),
      ],
    );
  }

  Widget _buildPhoneField() {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 12, offset: const Offset(0, 4))],
        ),
        child: Row(
          children: [
            Container(
              // تصغير حجم الصندوق الأخضر قليلاً
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              decoration: BoxDecoration(
                color: primaryGreen,
                borderRadius: const BorderRadius.only(topLeft: Radius.circular(15), bottomLeft: Radius.circular(15)),
              ),
              child: const Text("+963", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
            ),
            Expanded(
              child: TextField(
                controller: phoneController,
                onChanged: (val) => setState(() {}), // تحديث حالة الزر عند الكتابة
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(9),
                  FilteringTextInputFormatter.deny(RegExp(r'^0')),
                ],
                textAlign: TextAlign.left,
                // تصغير حجم الخط والمسافات بناءً على طلبك
                style: const TextStyle(fontSize: 15, letterSpacing: 1.5, fontWeight: FontWeight.w500),
                decoration: const InputDecoration(
                  hintText: "9xxxxxxxxx",
                  hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPassengerCard(int index, int seatNumber) {
    return Container(
      margin: const EdgeInsets.only(bottom: 25),
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 15)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("الراكب ${index == 0 ? 'الأول' : index == 1 ? 'الثاني' : (index + 1).toString()}",
              style: TextStyle(color: navyColor, fontWeight: FontWeight.bold, fontSize: 17)),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(flex: 3, child: _buildInputCol("اسم الراكب", "الاسم الثلاثي", nameControllers[index])),
              const SizedBox(width: 15),
              Expanded(flex: 1, child: _buildReadOnlyCol("رقم المقعد", seatNumber.toString().padLeft(2, '0'))),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInputCol(String label, String hint, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(color: const Color(0xFFF1F3F4), borderRadius: BorderRadius.circular(12)),
          child: TextField(
            controller: controller,
            onChanged: (val) => setState(() {}), // تحديث حالة الزر عند الكتابة
            decoration: InputDecoration(hintText: hint, border: InputBorder.none, hintStyle: const TextStyle(fontSize: 14)),
          ),
        ),
      ],
    );
  }

  Widget _buildReadOnlyCol(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13)),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(color: const Color(0xFFF1F3F4), borderRadius: BorderRadius.circular(12)),
          child: Center(child: Text(value, style: TextStyle(color: navyColor, fontWeight: FontWeight.bold))),
        ),
      ],
    );
  }

  void _showBookingSummary(BuildContext context) {
    int seatCount = widget.selectedSeats.length;
    int totalPrice = seatCount * 400;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: Container(
          padding: const EdgeInsets.all(25),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("ملخص الحجز", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 25),
              _row("سعر التذكرة", "400 ل.س", false),
              _row("عدد المقاعد", "$seatCount", false),
              const Divider(height: 30),
              _row("تكلفة الحجز الكاملة", "$totalPrice ل.س", true),
              const SizedBox(height: 30),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        // هنا نضع منطق الحفظ الفعلي
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("تم تأكيد الحجز بنجاح"), backgroundColor: Colors.green),
                        );
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: primaryGreen, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)), padding: const EdgeInsets.all(15)),
                      child: const Text("تأكيد الحجز", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("تم إلغاء الحجز"), backgroundColor: Colors.red),
                        );
                      },
                      style: OutlinedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)), padding: const EdgeInsets.all(15)),
                      child: const Text("إلغاء", style: TextStyle(color: Colors.black)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _row(String label, String val, bool isTotal) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: isTotal ? primaryGreen : Colors.grey, fontWeight: isTotal ? FontWeight.bold : FontWeight.normal)),
          Text(val, style: TextStyle(fontWeight: FontWeight.bold, color: isTotal ? primaryGreen : Colors.black, fontSize: isTotal ? 18 : 15)),
        ],
      ),
    );
  }
}