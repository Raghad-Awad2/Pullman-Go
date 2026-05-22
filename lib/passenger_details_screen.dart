import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'payment_gateway_screen.dart';

class PassengerDetailsScreen extends StatefulWidget {
  final List<int> selectedSeats;
  final String? busNumber;
  final String? fromCity;
  final String? toCity;
  final int? tripId;
  final int? userId;
  final String? travelDate;
  final int pricePerSeat;

  const PassengerDetailsScreen({
    super.key,
    required this.selectedSeats,
    required this.pricePerSeat,
    this.tripId,
    this.userId,
    this.travelDate,
    this.busNumber,
    this.fromCity,
    this.toCity,
  });

  @override
  State<PassengerDetailsScreen> createState() => _PassengerDetailsScreenState();
}

class _PassengerDetailsScreenState extends State<PassengerDetailsScreen> {
  final Color primaryGreen = const Color(0xFF2ECC71);
  final Color navyColor = const Color(0xFF2D3436);
  final Color backgroundColor = const Color(0xFFF8F9FA);

  final TextEditingController phoneController = TextEditingController();
  final List<TextEditingController> nameControllers = [];
  final ScrollController _scrollController = ScrollController();

  bool _isScrolled = false;

  String get safeBusNumber => widget.busNumber?.toString() ?? "1";
  String get safeFromCity => widget.fromCity ?? "غير متوفر";
  String get safeToCity => widget.toCity ?? "غير متوفر";

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.offset > 20 && !_isScrolled) {
        setState(() => _isScrolled = true);
      } else if (_scrollController.offset <= 20 && _isScrolled) {
        setState(() => _isScrolled = false);
      }
    });

    for (int i = 0; i < widget.selectedSeats.length; i++) {
      nameControllers.add(TextEditingController());
    }
  }

  bool _isAllDataEntered() {
    bool isPhoneEntered = phoneController.text.length == 9;
    bool areNamesEntered = nameControllers.every((controller) => controller.text.trim().isNotEmpty);
    return isPhoneEntered && areNamesEntered;
  }

  @override
  void dispose() {
    _scrollController.dispose();
    phoneController.dispose();
    for (var controller in nameControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _navigateToPaymentScreen(BuildContext modalContext) {
    Navigator.pop(modalContext);

    List<Map<String, dynamic>> passengerList = [];
    for (int i = 0; i < widget.selectedSeats.length; i++) {
      passengerList.add({
        "seat_number": widget.selectedSeats[i],
        "passenger_name": nameControllers[i].text.trim(),
      });
    }

    int seatCount = widget.selectedSeats.length;
    int totalPrice = seatCount * widget.pricePerSeat;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PaymentGatewayScreen(
          totalAmount: totalPrice,
          passengerList: passengerList,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: backgroundColor,
        body: NestedScrollView(
          controller: _scrollController,
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              SliverAppBar(
                expandedHeight: 110.0,
                floating: false,
                pinned: true,
                elevation: _isScrolled ? 1 : 0,
                backgroundColor: _isScrolled ? const Color(0xFFEFEFEF) : Colors.white,
                leading: IconButton(
                  icon: Icon(Icons.arrow_back_ios_new, color: _isScrolled ? const Color(0xFF2D3436) : Colors.black, size: 20),
                  onPressed: () => Navigator.pop(context),
                ),
                centerTitle: true,
                title: AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 200),
                  style: TextStyle(color: _isScrolled ? const Color(0xFF2D3436) : Colors.black, fontWeight: FontWeight.w900, fontSize: _isScrolled ? 16 : 18),
                  child: const Text("بيانات المسافرين"),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    color: Colors.white,
                    padding: const EdgeInsets.only(top: 80, right: 20, left: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.directions_bus_outlined, color: primaryGreen, size: 20),
                            const SizedBox(width: 8),
                            Text("من $safeFromCity إلى $safeToCity", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: navyColor)),
                          ],
                        ),
                        Text("باص رقم: $safeBusNumber  •  ${widget.selectedSeats.length} مقاعد", style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w500)),
                      ],
                    ),
                  ),
                ),
              ),
            ];
          },
          body: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionTitle(Icons.contact_phone_outlined, "معلومات الاتصال (لصاحب الحساب)"),
                const SizedBox(height: 15),
                _buildNewPhoneField(),
                const SizedBox(height: 35),
                Row(
                  children: [
                    const Expanded(child: Divider(endIndent: 10, thickness: 1)),
                    Text("تفاصيل الركاب والمقاعد", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: navyColor.withOpacity(0.7))),
                    const Expanded(child: Divider(indent: 10, thickness: 1)),
                  ],
                ),
                const SizedBox(height: 25),
                ...widget.selectedSeats.asMap().entries.map((entry) {
                  int index = entry.key;
                  int seatNum = entry.value;
                  return _buildPassengerCard(index, seatNum);
                }).toList(),
                const SizedBox(height: 80),
              ],
            ),
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: _buildConfirmButton(),
      ),
    );
  }

  Widget _buildSectionTitle(IconData icon, String title) {
    return Row(
      children: [
        Icon(icon, color: primaryGreen, size: 18),
        const SizedBox(width: 8),
        Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: navyColor)),
      ],
    );
  }

  Widget _buildNewPhoneField() {
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))]),
      child: Row(
        children: [
          Expanded(
            child: Directionality(
              textDirection: TextDirection.ltr,
              child: TextField(
                controller: phoneController,
                onChanged: (val) => setState(() {}),
                keyboardType: TextInputType.number,
                textAlign: TextAlign.left,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(9), FilteringTextInputFormatter.deny(RegExp(r'^0'))],
                style: TextStyle(fontSize: 15, letterSpacing: 2.0, fontWeight: FontWeight.w600, color: navyColor),
                decoration: const InputDecoration(hintText: "9xxxxxxxxx", hintStyle: TextStyle(color: Colors.grey, fontSize: 14, letterSpacing: 1.0), border: InputBorder.none, contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 16)),
              ),
            ),
          ),
          Container(width: 1, height: 22, color: Colors.grey.withOpacity(0.3)),
          Padding(
            padding: const EdgeInsets.only(left: 15, right: 10),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text("+963", style: TextStyle(color: navyColor, fontWeight: FontWeight.bold, fontSize: 14, letterSpacing: 0.5)),
                const SizedBox(width: 6),
                Icon(Icons.phone_android_rounded, color: primaryGreen.withOpacity(0.7), size: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPassengerCard(int index, int seatNumber) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 8, offset: const Offset(0, 2))]),
      child: IntrinsicHeight(
        child: Row(
          children: [
            Container(width: 5, decoration: BoxDecoration(color: primaryGreen, borderRadius: const BorderRadius.only(topRight: Radius.circular(16), bottomRight: Radius.circular(16)))),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("الراكب ${index + 1}", style: TextStyle(color: navyColor, fontWeight: FontWeight.w900, fontSize: 15)),
                        _buildSeatBadge(seatNumber),
                      ],
                    ),
                    const SizedBox(height: 15),
                    TextField(
                      controller: nameControllers[index],
                      onChanged: (val) => setState(() {}),
                      style: TextStyle(fontSize: 14, color: navyColor),
                      decoration: InputDecoration(
                        hintText: "الاسم الثلاثي المكتوب في الهوية",
                        hintStyle: TextStyle(color: Colors.grey[400], fontSize: 13),
                        prefixIcon: Icon(Icons.person_outline, color: primaryGreen.withOpacity(0.7), size: 18),
                        filled: true,
                        fillColor: const Color(0xFFF8F9FA),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSeatBadge(int seatNumber) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(color: primaryGreen.withOpacity(0.08), borderRadius: BorderRadius.circular(8)),
      child: Row(
        children: [
          Icon(Icons.airline_seat_recline_normal_outlined, size: 14, color: primaryGreen),
          const SizedBox(width: 4),
          Text("مقعد ${seatNumber.toString().padLeft(2, '0')}", style: TextStyle(color: primaryGreen, fontWeight: FontWeight.bold, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildConfirmButton() {
    return Container(
      width: double.infinity,
      height: 55,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: ElevatedButton.icon(
        onPressed: _isAllDataEntered() ? () => _showBookingSummary(context) : null,
        icon: Icon(Icons.check_circle_outline, color: _isAllDataEntered() ? Colors.white : Colors.grey[500], size: 18),
        label: Text("تأكيد وحفظ البيانات", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: _isAllDataEntered() ? Colors.white : Colors.grey[500])),
        style: ElevatedButton.styleFrom(backgroundColor: primaryGreen, disabledBackgroundColor: Colors.grey[300], shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)), elevation: _isAllDataEntered() ? 3 : 0),
      ),
    );
  }

  void _showBookingSummary(BuildContext context) {
    int seatCount = widget.selectedSeats.length;
    int totalPrice = seatCount * widget.pricePerSeat;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (modalContext) => Directionality(
        textDirection: TextDirection.rtl,
        child: Container(
          padding: const EdgeInsets.all(25),
          decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.only(topLeft: Radius.circular(25), topRight: Radius.circular(25))),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 35, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
              const SizedBox(height: 20),
              Text("ملخص وتأكيد الحجز", style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900, color: navyColor)),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(color: const Color(0xFFF8F9FA), borderRadius: BorderRadius.circular(12)),
                child: Row(
                  children: [
                    Icon(Icons.local_activity_outlined, color: primaryGreen, size: 20),
                    const SizedBox(width: 10),
                    Expanded(child: Text("من $safeFromCity إلى $safeToCity", style: TextStyle(fontWeight: FontWeight.bold, color: navyColor))),
                    Text("باص $safeBusNumber", style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              _row("سعر التذكرة الواحدة", "${widget.pricePerSeat} ل.س", false),
              _row("عدد المقاعد المحجوزة", "$seatCount", false),
              const Divider(height: 25, thickness: 1),
              _row("إجمالي تكلفة الحجز", "$totalPrice ل.س", true),
              const SizedBox(height: 25),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _navigateToPaymentScreen(modalContext),
                      style: ElevatedButton.styleFrom(backgroundColor: primaryGreen, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), padding: const EdgeInsets.all(14), elevation: 0),
                      child: const Text("متابعة للدفع", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(modalContext),
                      style: OutlinedButton.styleFrom(side: BorderSide(color: Colors.grey[300]!), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), padding: const EdgeInsets.all(14)),
                      child: Text("مراجعة", style: TextStyle(color: navyColor, fontWeight: FontWeight.bold)),
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
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: isTotal ? primaryGreen : Colors.grey, fontWeight: isTotal ? FontWeight.bold : FontWeight.normal)),
          Text(val, style: TextStyle(fontWeight: FontWeight.w900, color: isTotal ? primaryGreen : navyColor, fontSize: isTotal ? 18 : 14)),
        ],
      ),
    );
  }
}