import 'package:flutter/material.dart';
import 'seat_selection_screen.dart';

class OffersScreen extends StatelessWidget {
  const OffersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildOfferCard(context, "الحكيم للنقل الداخلي", "دمشق", "اللاذقية", "250 ل.س", "200 ل.س", "عرض لمدة 3 أيام"),
        _buildOfferCard(context, "الأهلية للنقل", "دمشق", "حمص", "400 ل.س", "300 ل.س", "عرض لمدة أسبوع"),
        _buildOfferCard(context, "القدموس للنقل والسياحة", "دمشق", "حلب", "375 ل.س", "300 ل.س", "عرض لمدة يومين"),
      ],
    );
  }

  Widget _buildOfferCard(BuildContext context, String company, String fromCity, String toCity, String oldPrice, String newPrice, String duration) {
    final Color primaryGreen = const Color(0xFF2ECC71);

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(15),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(company, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 8),

                      // السهم الأسود بالاتجاه الصحيح (من دمشق إلى الوجهة)
                      Row(
                        children: [
                          Text(fromCity, style: TextStyle(color: primaryGreen, fontWeight: FontWeight.bold)),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 10),
                            child: Icon(
                                Icons.arrow_forward, // يشير لليسر في الـ RTL (من الانطلاق للوصول)
                                color: Colors.black,
                                size: 20
                            ),
                          ),
                          Text(toCity, style: TextStyle(color: primaryGreen, fontWeight: FontWeight.bold)),
                        ],
                      ),

                      const SizedBox(height: 8),
                      Text("السعر القديم: $oldPrice", style: const TextStyle(decoration: TextDecoration.lineThrough, color: Colors.grey, fontSize: 13)),
                      Text(newPrice, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.black)),
                    ],
                  ),
                ),
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.local_offer, color: primaryGreen),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
            decoration: BoxDecoration(
              color: primaryGreen.withOpacity(0.1),
              borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(15), bottomRight: Radius.circular(15)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SeatSelectionScreen(
                          fromCity: fromCity,
                          toCity: toCity,
                          // تعديل بسيط هنا ليتناسب مع القائمة المنسدلة في صفحة السيت
                          selectedDate: "اختر يوم العرض",
                          tripTime: "حسب التوفر",
                          companyName: company,
                          tripRoute: "$fromCity ← $toCity",
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryGreen,
                    minimumSize: const Size(80, 30),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text("احجز الآن", style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                ),
                Text(duration, style: const TextStyle(color: Colors.black87, fontSize: 13, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}