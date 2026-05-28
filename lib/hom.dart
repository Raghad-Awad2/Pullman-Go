import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'company_selection_screen.dart';
import 'my_trips_screen.dart';
import 'offers_screen.dart';
import 'profile_screen.dart';
import 'notifications_screen.dart';
import 'login_screen.dart';

// --- موديل المدينة (City Model) ---
class City {
  final int id;
  final String name;
  City({required this.id, required this.name});

  factory City.fromJson(Map<String, dynamic> json) {
    return City(
      id: json['id'],
      name: json['name'],
    );
  }
}

class PullmanMainScreen extends StatefulWidget {
  const PullmanMainScreen({super.key});

  @override
  _PullmanMainScreenState createState() => _PullmanMainScreenState();
}

class _PullmanMainScreenState extends State<PullmanMainScreen> {
  int _pageIndex = 3;

  String userName = "جاري التحميل..."; // المتغير المخصص لحفظ الاسم وعرضه في الـ AppBar

  @override
  void initState() {
    super.initState();
    _loadUserName(); // تشغيل دالة القراءة فوراً عند فتح الشاشة
  }

  // الدالة التي تذهب لذاكرة الهاتف وتجلب الاسم الحقيقي
  Future<void> _loadUserName() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userName = prefs.getString('user_name') ?? "المسافر";
    });
  }


// 🎨 فلسفة تدرج الأخضر الغامق الملكي (Royal Deep Green Theme) - تعديل هندسي فخم
  final Color primaryNavy = const Color(0xFF06140D);       // أخضر غامق جداً (شبه أسود) - يبدأ من الأعلى
  final Color accentIceBlue = const Color(0xFF1E7A4D);     // أخضر ملكي عميق وغامق - ينتهي عنده التدريج وهو لون الزر والرموز النشطة👈 آخر درجة في التدرج (لون الأزرار والرموز النشطة متطابق تماماً)
  final Color lightGreyBackground = const Color(0xFFF4F6F9); // خلفية التطبيق رمادي ناعم
  final Color darkGrey = Colors.grey[600]!;

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            title: const Text("تسجيل الخروج", style: TextStyle(fontWeight: FontWeight.bold)),
            content: const Text("هل أنت متأكد أنك تريد الخروج والعودة لصفحة تسجيل الدخول؟"),
            actions: [
              TextButton(
                  child: const Text("إلغاء", style: TextStyle(color: Colors.grey)),
                  onPressed: () => Navigator.of(context).pop()
              ),
              TextButton(
                  child: const Text("خروج", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                  onPressed: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => const LoginScreen()),
                          (route) => false,
                    );
                  }
              ),
            ],
          ),
        );
      },
    );
  }

  String _getAppBarTitle() {
    switch (_pageIndex) {
      case 0: return "ملفي الشخصي";
      case 1: return "رحلاتي";
      case 2: return "أفضل العروض الحصرية";
      case 3: return "إلى أين ستسافر اليوم؟";
      default: return "";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: lightGreyBackground,
        body: NestedScrollView(
          headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
            return <Widget>[
              SliverAppBar(
                expandedHeight: 130.0, // 👈 تم تقليل الارتفاع الكلي لتقليص المساحة الخضراء ورفع المحتوى
                pinned: true,
                elevation: 0,
                // 1. إضافة الانحناء السفلي الذكي للشريط التدرجي بأكمله
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(50.0),
                    bottomRight: Radius.circular(50.0),
                  ),
                ),
                backgroundColor: primaryNavy,
                leadingWidth: 200,
                leading: Padding(
                  padding: const EdgeInsets.only(right: 16.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      InkWell(
                        onTap: () => setState(() => _pageIndex = 0),
                        child: CircleAvatar(
                          radius: 18, // تصغير متناسق لحجم الدائرة
                          backgroundColor: Colors.white.withOpacity(0.15),
                          child: const Icon(Icons.person, color: Colors.white, size: 20),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("مرحباً بعودتك", style: TextStyle(color: Colors.white70, fontSize: 10)),
                          Text(
                              userName,
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                actions: [
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.menu, color: Colors.white, size: 26),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    onSelected: (value) {
                      if (value == 'notifications') {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const NotificationsScreen()));
                      } else if (value == 'logout') {
                        _showLogoutDialog(context);
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(value: 'notifications', child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [Text("الإشعارات"), SizedBox(width: 10), Icon(Icons.notifications_active, color: Colors.black54)])),
                      const PopupMenuDivider(),
                      const PopupMenuItem(value: 'logout', child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [Text("تسجيل الخروج", style: TextStyle(color: Colors.red)), SizedBox(width: 10), Icon(Icons.logout, color: Colors.red)])),
                    ],
                  ),
                  const SizedBox(width: 8),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [primaryNavy, accentIceBlue],
                      ),
                    ),
                    // 👈 تعديل الـ padding لجعل الكرت قريباً جداً من الأعلى ومرفوعاً عن الأسفل
                    padding: const EdgeInsets.only(top: 70.0, left: 24.0, right: 24.0, bottom: 8.0),
                    child: Container(
                      // 👈 الكرت الأبيض بحجم أصغر وملموم
                      height: 45,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(25.0), // زوايا أنعم تناسب الحجم المصغر
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.06),
                            blurRadius: 6,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      // 👈 استخدام Center لضمان تموضع النص في منتصف الكرت تماماً وبشكل هندسي متوازن
                      child: Center(
                        child: Text(
                          _getAppBarTitle(),
                          style: TextStyle(
                            color: primaryNavy,
                            fontWeight: FontWeight.bold,
                            fontSize: 16, // تصغير حجم الخط ليناسب مقاس الكرت الجديد
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ];
          },
          body: _buildBody(),
        ),
        bottomNavigationBar: _buildCorrectedBottomNav(),
      ),
    );
  }

  Widget _buildBody() {
    switch (_pageIndex) {
      case 0: return const ProfileScreen();
      case 1: return const MyTripsScreen();
      case 2: return const OffersScreen();
      case 3: return _buildHomeScreenContent();
      default: return _buildHomeScreenContent();
    }
  }

  Widget _buildHomeScreenContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(children: [BusSearchForm(primaryColor: primaryNavy, accentColor: accentIceBlue), const SizedBox(height: 30)]),
    );
  }

  Widget _buildCorrectedBottomNav() {
    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        CurvedNavigationBar(
          index: _pageIndex == 3 ? 0 : (_pageIndex == 2 ? 1 : (_pageIndex == 1 ? 2 : 3)),
          height: 70.0,
          items: [
            Icon(Icons.home, size: 30, color: _pageIndex == 3 ? accentIceBlue : darkGrey),
            Icon(Icons.local_offer, size: 30, color: _pageIndex == 2 ? accentIceBlue : darkGrey),
            Icon(Icons.directions_bus, size: 30, color: _pageIndex == 1 ? accentIceBlue : darkGrey),
            Icon(Icons.person, size: 30, color: _pageIndex == 0 ? accentIceBlue : darkGrey),
          ],
          color: const Color(0xFFEAEDF2),
          buttonBackgroundColor: primaryNavy, // الدائرة تندمج باللون الكحلي العلوي المعدل
          backgroundColor: Colors.transparent,
          onTap: (index) {
            setState(() {
              if (index == 0) _pageIndex = 3;
              if (index == 1) _pageIndex = 2;
              if (index == 2) _pageIndex = 1;
              if (index == 3) _pageIndex = 0;
            });
          },
        ),
        Positioned(
          bottom: 5, left: 0, right: 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildLabel("الرئيسية", 3),
              _buildLabel("العروض", 2),
              _buildLabel("رحلاتي", 1),
              _buildLabel("حسابي", 0),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLabel(String text, int index) => Container(
    width: 80, alignment: Alignment.center,
    child: Text(text, style: TextStyle(color: _pageIndex == index ? accentIceBlue : darkGrey, fontSize: 12, fontWeight: FontWeight.bold)),
  );
}

class BusSearchForm extends StatefulWidget {
  final bool isMini;
  final Color? primaryColor;
  final Color? accentColor;

  const BusSearchForm({super.key, this.isMini = false, this.primaryColor, this.accentColor});
  @override
  State<BusSearchForm> createState() => _BusSearchFormState();
}

class _BusSearchFormState extends State<BusSearchForm> {
  final TextEditingController _fromController = TextEditingController();
  final TextEditingController _toController = TextEditingController();

  List<City> _allCities = [];
  bool _isFetching = true;
  int? _selectedFromId;
  int? _selectedToId;

  DateTime? _selectedDate;
  String? _fromError, _toError, _dateError;
  bool _isLoading = false;

  late Color localPrimary;
  late Color localAccent;

  @override
  void initState() {
    super.initState();
    localPrimary = widget.primaryColor ?? const Color(0xFF050E1A);
    localAccent = widget.accentColor ?? const Color(0xFF162D4A);
    _fetchCities();
  }

  Future<void> _fetchCities() async {
    try {
      final response = await Dio().get('http://10.180.125.108:8000/api/cities');
      if (response.statusCode == 200) {
        List data = response.data['data'];
        setState(() {
          _allCities = data.map((json) => City.fromJson(json)).toList();
          _isFetching = false;
        });
      }
    } catch (e) {
      print("خطأ في جلب المدن: $e");
      setState(() => _isFetching = false);
    }
  }

  String _getDayName(DateTime date) {
    List<String> days = ["الأحد", "الاثنين", "الثلاثاء", "الأربعاء", "الخميس", "الجمعة", "السبت"];
    return days[date.weekday % 7];
  }

  void _validateAndSearch() async {
    setState(() {
      _fromError = (_fromController.text.isEmpty || _selectedFromId == null) ? "الرجاء تحديد مدينة الانطلاق" : null;
      _toError = (_toController.text.isEmpty || _selectedToId == null) ? "الرجاء تحديد مدينة الوصول" : null;
      if (!widget.isMini) _dateError = _selectedDate == null ? "الرجاء تحديد التاريخ" : null;
    });

    if (_fromError == null && _toError == null && (_dateError == null || widget.isMini)) {
      setState(() => _isLoading = true);

      if (mounted) {
        String formattedDate = _selectedDate != null ? "${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}" : "لم يحدد";
        int dayIndex = _selectedDate != null ? (_selectedDate!.weekday % 7) : -1;

        Navigator.push(context, MaterialPageRoute(builder: (context) => CompanySelectionScreen(
          fromCity: _fromController.text,
          fromCityId: _selectedFromId!,
          toCity: _toController.text,
          toCityId: _selectedToId!,
          selectedDate: formattedDate,
          dayIndex: dayIndex,
        )));
      }
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isFetching) {
      return Center(child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: CircularProgressIndicator(color: localPrimary),
      ));
    }

    return Container(
      padding: widget.isMini ? EdgeInsets.zero : const EdgeInsets.all(20),
      decoration: widget.isMini ? null : BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: localPrimary.withOpacity(0.05), blurRadius: 15, offset: const Offset(0, 8))]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildField("من مدينة", "بحث عن مدينة الانطلاق", _fromController, _fromError, _selectedToId, (id) => _selectedFromId = id),
          const SizedBox(height: 15),
          _buildField("إلى مدينة", "بحث عن مدينة الوصول", _toController, _toError, _selectedFromId, (id) => _selectedToId = id),
          const SizedBox(height: 15),
          if (!widget.isMini) _buildDatePicker(),
          const SizedBox(height: 20),
          _buildSearchBtn(),
        ],
      ),
    );
  }

  Widget _buildField(String label, String hint, TextEditingController mainCtrl, String? error, int? excludedId, Function(int) onSelected) {
    List<City> filtered = _allCities.where((c) => c.id != excludedId).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        const SizedBox(height: 5),
        Autocomplete<City>(
          displayStringForOption: (City c) => c.name,
          optionsBuilder: (val) => val.text.isEmpty ? filtered : filtered.where((c) => c.name.contains(val.text)),
          onSelected: (City c) {
            setState(() {
              mainCtrl.text = c.name;
              onSelected(c.id);
              _fromError = null;
              _toError = null;
            });
          },
          fieldViewBuilder: (ctx, ctrl, focus, onSub) {
            if (mainCtrl.text != ctrl.text) ctrl.text = mainCtrl.text;
            return TextField(
              controller: ctrl, focusNode: focus, textAlign: TextAlign.right,
              decoration: InputDecoration(
                hintText: hint, errorText: error,
                prefixIcon: const Icon(Icons.location_on, color: Colors.grey, size: 20),
                suffixIcon: PopupMenuButton<City>(
                  icon: const Icon(Icons.arrow_drop_down),
                  onSelected: (City c) {
                    ctrl.text = c.name;
                    setState(() {
                      mainCtrl.text = c.name;
                      onSelected(c.id);
                      _fromError = null;
                      _toError = null;
                    });
                  },
                  itemBuilder: (ctx) => filtered.map((c) => PopupMenuItem(value: c, child: Text(c.name, textDirection: TextDirection.rtl))).toList(),
                ),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: localPrimary, width: 1.5)),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey[300]!)),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildDatePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("التاريخ", style: TextStyle(color: Colors.grey, fontSize: 12)),
        const SizedBox(height: 5),
        InkWell(
          onTap: () async {
            DateTime? p = await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime.now(), lastDate: DateTime(2027));
            if (p != null) setState(() { _selectedDate = p; _dateError = null; });
          },
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(border: Border.all(color: _dateError != null ? Colors.red : (_selectedDate != null ? localPrimary : Colors.grey[300]!)), borderRadius: BorderRadius.circular(10)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(_selectedDate == null ? "اختر التاريخ" : "${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}"),
                Icon(Icons.calendar_month, color: _selectedDate != null ? localPrimary : Colors.grey),
              ],
            ),
          ),
        ),
        if (_selectedDate != null)
          Padding(
            padding: const EdgeInsets.only(top: 8, right: 4),
            child: Row(
              children: [
                Icon(Icons.event_available, size: 16, color: localAccent),
                const SizedBox(width: 5),
                Text(
                  "يصادف يوم: ${_getDayName(_selectedDate!)}",
                  style: TextStyle(color: localAccent, fontWeight: FontWeight.bold, fontSize: 13),
                ),
              ],
            ),
          ),
        if (_dateError != null) Padding(padding: const EdgeInsets.only(top: 5), child: Text(_dateError!, style: const TextStyle(color: Colors.red, fontSize: 12))),
      ],
    );
  }

  Widget _buildSearchBtn() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isLoading ? () {} : _validateAndSearch,
        // تلوين الزر ليتطابق بالكامل مع آخر درجة بالتدرج العلوي (accentIceBlue)
        style: ElevatedButton.styleFrom(backgroundColor: localAccent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)), padding: const EdgeInsets.symmetric(vertical: 14)),
        child: _isLoading ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Text("بحث", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
      ),
    );
  }
}