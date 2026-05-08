import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'company_info_screen.dart';

// موديل الرحلة لجلب البيانات من جدول routes وشركته
class TravelRoute {
  final int id;
  final String companyName;
  final String? companyLogo;
  final String price;
  final String startTime;
  final Map<String, dynamic> fullCompanyData;

  TravelRoute({
    required this.id,
    required this.companyName,
    this.companyLogo,
    required this.price,
    required this.startTime,
    required this.fullCompanyData,
  });

  factory TravelRoute.fromJson(Map<String, dynamic> json) {
    var companyJson = json['company'] ?? {};
    String? logoPath = companyJson['logo_url'];

    String? fullLogoUrl;
    if (logoPath != null && logoPath.isNotEmpty) {
      String fileName = logoPath.split(RegExp(r'[\\/]')).last;
      fullLogoUrl = "http://localhost:8000/companies-logos/$fileName";
    }

    return TravelRoute(
      id: json['id'],
      companyName: companyJson['name'] ?? "شركة غير معروفة",
      companyLogo: fullLogoUrl,
      price: json['base_price'].toString(),
      startTime: json['estimated_time'] ?? "غير محدد",
      fullCompanyData: companyJson,
    );
  }
}

class CompanySelectionScreen extends StatefulWidget {
  final String fromCity;
  final int fromCityId;
  final String toCity;
  final int toCityId;
  final String selectedDate;
  final int dayIndex; // --- التعديل: إضافة استقبال رقم اليوم ---

  const CompanySelectionScreen({
    super.key,
    required this.fromCity,
    required this.fromCityId,
    required this.toCity,
    required this.toCityId,
    required this.selectedDate,
    required this.dayIndex, // --- التعديل: إضافة اليوم للمشيد ---
  });

  @override
  State<CompanySelectionScreen> createState() => _CompanySelectionScreenState();
}

class _CompanySelectionScreenState extends State<CompanySelectionScreen> {
  bool showAll = true;
  final Color primaryGreen = const Color(0xFF2ECC71);

  List<TravelRoute> _allRoutes = [];
  bool _isLoading = true;
  List<TravelRoute> favoriteRoutes = [];

  @override
  void initState() {
    super.initState();
    _fetchRoutes();
  }

  Future<void> _fetchRoutes() async {
    try {
      final response = await Dio().get(
        'http://localhost:8000/api/search-trips',
        queryParameters: {
          'from_id': widget.fromCityId,
          'to_id': widget.toCityId,
          'day_index': widget.dayIndex, // --- التعديل: إرسال رقم اليوم للسيرفر ---
        },
      );

      if (response.statusCode == 200) {
        List data = response.data['data'];
        setState(() {
          _allRoutes = data.map((json) => TravelRoute.fromJson(json)).toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      print("خطأ في جلب الشركات: $e");
      setState(() => _isLoading = false);
    }
  }

  void toggleFavorite(TravelRoute route) {
    setState(() {
      if (favoriteRoutes.any((e) => e.id == route.id)) {
        favoriteRoutes.removeWhere((e) => e.id == route.id);
      } else {
        favoriteRoutes.add(route);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final displayedList = showAll ? _allRoutes : favoriteRoutes;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0.5,
          centerTitle: true,
          title: const Text("اختيار الشركة", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18)),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator(color: Color(0xFF2ECC71)))
            : Column(
          children: [
            _buildPromoCard(),
            _buildTabs(),
            const SizedBox(height: 20),
            Expanded(
              child: displayedList.isEmpty
                  ? Center(child: Text(showAll ? "لا يوجد رحلات متاحة لهذا المسار في هذا اليوم" : "قائمة المفضلة فارغة"))
                  : ListView.builder(
                itemCount: displayedList.length,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemBuilder: (context, index) => _buildCompanyCard(displayedList[index]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPromoCard() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [primaryGreen.withOpacity(0.1), Colors.white], begin: Alignment.topRight, end: Alignment.bottomLeft),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: primaryGreen.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          const Text("انطلق في رحلتك القادمة الآن!", style: TextStyle(fontSize: 19, fontWeight: FontWeight.w900, color: Colors.black87)),
          const SizedBox(height: 10),
          Text(
            "قارن بين أفضل شركات النقل واختر الأنسب لرحلتك من ${widget.fromCity} إلى ${widget.toCity}",
            style: TextStyle(fontSize: 14, color: Colors.grey[600], height: 1.5),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          Text("تاريخ الرحلة: ${widget.selectedDate}", style: TextStyle(color: primaryGreen, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildTabs() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(15)),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => showAll = true),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(color: showAll ? primaryGreen : Colors.transparent, borderRadius: BorderRadius.circular(12)),
                child: Center(child: Text("جميع الشركات", style: TextStyle(color: showAll ? Colors.white : Colors.grey[600], fontWeight: FontWeight.bold))),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => showAll = false),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(color: !showAll ? primaryGreen : Colors.transparent, borderRadius: BorderRadius.circular(12)),
                child: Center(child: Text("المفضلة", style: TextStyle(color: !showAll ? Colors.white : Colors.grey[600], fontWeight: FontWeight.bold))),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompanyCard(TravelRoute route) {
    bool isFav = favoriteRoutes.any((e) => e.id == route.id);
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15)]),
      child: InkWell(
        onTap: () {
          Map<String, dynamic> companyToPass = Map.from(route.fullCompanyData);
          companyToPass['logo_url_full'] = route.companyLogo;
          companyToPass['route_id'] = route.id;

          Navigator.push(context, MaterialPageRoute(builder: (context) => CompanyInfoScreen(
            company: companyToPass,
            fromCity: widget.fromCity,
            toCity: widget.toCity,
            selectedDate: widget.selectedDate,
            isInitiallyFavorite: isFav,
            onFavoriteToggle: () => toggleFavorite(route),
          )));
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: (route.companyLogo != null)
                    ? Image.network(
                  route.companyLogo!,
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                  const Icon(Icons.directions_bus_filled, color: Colors.green, size: 30),
                )
                    : const Icon(Icons.directions_bus_filled, color: Colors.green, size: 30),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(route.companyName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    Text("السعر: ${route.price} ل.س", style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                    Text("وقت الرحلة: ${route.startTime}", style: TextStyle(color: Colors.blueGrey, fontSize: 12)),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}