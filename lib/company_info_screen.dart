import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';
import 'booking_trips_screen.dart';

class CompanyInfoScreen extends StatefulWidget {
  final Map<String, dynamic> company;
  final String fromCity;
  final String toCity;
  final String selectedDate;
  final bool isInitiallyFavorite;
  final VoidCallback onFavoriteToggle;

  const CompanyInfoScreen({
    super.key,
    required this.company,
    required this.fromCity,
    required this.toCity,
    required this.selectedDate,
    required this.isInitiallyFavorite,
    required this.onFavoriteToggle
  });

  @override
  State<CompanyInfoScreen> createState() => _CompanyInfoScreenState();
}

class _CompanyInfoScreenState extends State<CompanyInfoScreen> {
  late bool isFavorite;
  final Color primaryGreen = const Color(0xFF2ECC71);

  @override
  void initState() {
    super.initState();
    isFavorite = widget.isInitiallyFavorite;
  }

  // دالة فتح الروابط الخارجية (تصميمك الأصلي)
  Future<void> _launchURL(String? urlString) async {
    if (urlString == null || urlString.isEmpty || urlString == 'null') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("عذراً، الرابط غير متوفر لهذه الشركة")),
      );
      return;
    }

    final Uri url = Uri.parse(urlString);
    try {
      if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
        throw Exception('Could not launch $url');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("تعذر فتح الرابط، تأكد من صحة التنسيق")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    List<dynamic> featuresList = [];
    var rawFeatures = widget.company['features'];

    if (rawFeatures != null) {
      if (rawFeatures is String) {
        try {
          featuresList = jsonDecode(rawFeatures);
        } catch (e) {
          featuresList = [rawFeatures];
        }
      } else if (rawFeatures is List) {
        featuresList = rawFeatures;
      }
    }

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
          actions: [
            Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5)],
              ),
              child: IconButton(
                icon: Icon(
                  isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: isFavorite ? primaryGreen : Colors.black54,
                  size: 22,
                ),
                onPressed: () {
                  setState(() => isFavorite = !isFavorite);
                  widget.onFavoriteToggle();
                },
              ),
            ),
          ],
        ),
        extendBodyBehindAppBar: true,
        body: SingleChildScrollView(
          child: Column(
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    height: 220,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [primaryGreen.withOpacity(0.2), Colors.white],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                      borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(80)),
                    ),
                  ),
                  Positioned(
                    top: 90,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 20)],                      ),
                      child: CircleAvatar(
                        radius: 65,
                        backgroundColor: Colors.white,
                        backgroundImage: (widget.company['logo_url'] != null && widget.company['logo_url'].toString().isNotEmpty)
                            ? NetworkImage("http://127.0.0.1:8000/storage/${widget.company['logo_url']}")
                            : const AssetImage('assets/images/logo.png') as ImageProvider,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              Text(
                widget.company['name'] ?? "اسم الشركة غير متوفر",
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF2D3436)),
              ),

              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Text(
                  widget.company['slogan'] != null ? "\"${widget.company['slogan']}\"" : "لا يوجد شعار متاح لهذه الشركة",
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.blueGrey, fontSize: 15, fontStyle: FontStyle.italic),
                ),
              ),
              const SizedBox(height: 25), // تم الحفاظ على المسافة لتناسق العناصر بعد إزالة النجوم
              if (featuresList.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 10.0,
                    runSpacing: 10.0,
                    children: featuresList.map((feature) => _buildBadge(feature.toString())).toList(),
                  ),
                )
              else
                const Text("لا توجد ميزات إضافية مسجلة حالياً", style: TextStyle(fontSize: 12, color: Colors.grey)),
              const SizedBox(height: 30),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    _buildModernTile(
                      icon: Icons.phone_android_rounded,
                      title: "رقم التواصل",
                      value: widget.company['phone'] ?? 'غير متوفر',
                    ),
                    const SizedBox(height: 12),
                    _buildModernTile(
                      icon: Icons.location_on_rounded,
                      title: "الموقع الرئيسي",
                      value: widget.company['address'] ?? 'غير محدد',
                    ),
                    const SizedBox(height: 12),
                    GestureDetector(
                      onTap: () => _launchURL(widget.company['location_url']),
                      child: _buildModernTile(
                        icon: Icons.language_rounded,
                        title: "الموقع الإلكتروني",
                        value: (widget.company['location_url'] != null && widget.company['location_url'] != 'null')
                            ? widget.company['location_url']
                            : 'غير متوفر',
                        isLink: true,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryGreen,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                    elevation: 8,
                    shadowColor: primaryGreen.withOpacity(0.4),
                  ),
                  onPressed: () {
                    try {
                      // تعديل ذكي لمعالجة التاريخ مهما كان تنسيقه (يحل مشكلة عدم النقل)
                      DateTime date;
                      List<String> parts = widget.selectedDate.split(RegExp(r'[/-]'));
                      if (parts.length == 3 && parts[0].length < 4) {
                        // إذا كان التنسيق يوم/شهر/سنة (مثل صورتك 27/4/2026)
                        date = DateTime(int.parse(parts[2]), int.parse(parts[1]), int.parse(parts[0]));
                      } else {
                        // التنسيق الافتراضي سنة-شهر-يوم
                        date = DateTime.parse(widget.selectedDate);
                      }

                      int dayIndex = date.weekday % 7;

                      final int? companyId = widget.company['id'] != null
                          ? int.tryParse(widget.company['id'].toString())
                          : null;

                      final int? routeId = widget.company['route_id'] != null
                          ? int.tryParse(widget.company['route_id'].toString())
                          : null;

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => BookingTripsScreen(
                            companyId: companyId,
                            routeId: routeId,
                            companyName: widget.company['name'] ?? 'اسم الشركة',
                            logo: 'assets/images/logo.png',
                            fromCity: widget.fromCity,
                            toCity: widget.toCity,
                            selectedDate: widget.selectedDate,
                            dayIndex: dayIndex,
                          ),
                        ),
                      );
                    } catch (e) {
                      print("Error during navigation: $e");
                      // تنبيه في حال وجود خطأ في البيانات
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("حدث خطأ في معالجة التاريخ: $e")),
                      );
                    }
                  },
                  child: const Text(
                    "احجز رحلتك الآن",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                  ),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  // --- ويدجت الميزات بنفس تصميمك ---
  Widget _buildBadge(String label) {
    Map<String, String> translation = {
      'comfortable_seats': 'مقاعد مريحة',
      'comfortable seats': 'مقاعد مريحة',
      'water': 'توزيع مياه',
      'snacks': 'ضيافة خفيفة',
      'wifi': 'واي فاي مجاني',
      'air_conditioning': 'تكييف مركزي',
      'screen': 'شاشات عرض',
      'gps': 'تتبع الرحلة',
      'insurance': 'تأمين سفر',
    };

    String translatedText = translation[label.toLowerCase()] ?? label;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: primaryGreen.withOpacity(0.3)),
        boxShadow: [BoxShadow(color: primaryGreen.withOpacity(0.05), blurRadius: 5)],
      ),
      child: Text(
        translatedText,
        style: TextStyle(color: primaryGreen, fontSize: 13, fontWeight: FontWeight.bold),
      ),
    );
  }

  // --- ويدجت المعلومات بنفس تصميمك ---
  Widget _buildModernTile({required IconData icon, required String title, required String value, bool isLink = false}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: primaryGreen.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: primaryGreen, size: 22),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(color: Colors.grey[500], fontSize: 12)),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: isLink ? Colors.blue : const Color(0xFF2D3436),
                    decoration: isLink ? TextDecoration.underline : TextDecoration.none,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}