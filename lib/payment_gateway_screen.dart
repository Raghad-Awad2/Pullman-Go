import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PaymentGatewayScreen extends StatefulWidget {
  final int totalAmount;
  final List<Map<String, dynamic>> passengerList;

  const PaymentGatewayScreen({
    super.key,
    required this.totalAmount,
    required this.passengerList,
  });

  @override
  State<PaymentGatewayScreen> createState() => _PaymentGatewayScreenState();
}

class _PaymentGatewayScreenState extends State<PaymentGatewayScreen> {
  final Color primaryGreen = const Color(0xFF2ECC71);
  final Color navyColor = const Color(0xFF2D3436);
  final Color backgroundColor = const Color(0xFFF8F9FA);

  // المتغيرات المسؤولة عن تحديد المرحلة الحالية للمستخدم
  int _currentStep = 1; // 1: اختيار البوابة، 2: إدخال بيانات المحفظة والـ OTP
  String _selectedMethod = ''; // 'sham' أو 'syriatel' أو 'mtn'

  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();

  bool _isOtpSent = false;
  bool _isProcessing = false;

  String get _formattedAmount {
    return widget.totalAmount.toString().replaceAllMatches(RegExp(r'\B(?=(\d{3})+(?!\d))'), ',');
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: backgroundColor,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_new, color: navyColor, size: 20),
            onPressed: () {
              if (_currentStep == 2) {
                setState(() {
                  _currentStep = 1;
                  _isOtpSent = false;
                  _otpController.clear();
                });
              } else {
                Navigator.pop(context);
              }
            },
          ),
          title: Text(
            _currentStep == 1 ? "بوابة الدفع الإلكتروني" : "تأكيد الحساب المالي",
            style: TextStyle(color: navyColor, fontWeight: FontWeight.w900, fontSize: 16),
          ),
        ),
        body: _isProcessing
            ? Center(child: CircularProgressIndicator(color: primaryGreen))
            : SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            children: [
              _buildHeaderSummary(),
              const SizedBox(height: 30),
              if (_currentStep == 1) _buildStageOneSelection(),
              if (_currentStep == 2) _buildStageTwoForm(),
            ],
          ),
        ),
      ),
    );
  }

  // ملخص علوي ثابت للمبلغ المطلوب سداده لأمان ووضوح التعامل
  Widget _buildHeaderSummary() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)],
      ),
      child: Column(
        children: [
          Text("إجمالي قيمة حجز الرحلة", style: TextStyle(color: Colors.grey.shade500, fontSize: 13, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(_formattedAmount, style: TextStyle(fontSize: 34, fontWeight: FontWeight.w900, color: navyColor)),
              const SizedBox(width: 5),
              Text("ل.س", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: primaryGreen)),
            ],
          ),
        ],
      ),
    );
  }

  // ✨ المرحلة الأولى: شاشة اختيار طريقة الدفع المتاحة بالتطبيق
  Widget _buildStageOneSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("اختر طريقة الدفع المفضلة لديك:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: navyColor)),
        const SizedBox(height: 16),
        _buildPaymentMethodCard('sham', "شام كاش الإلكترونية", Icons.account_balance_wallet_rounded),
        _buildPaymentMethodCard('syriatel', "سيريتل كاش (Syriatel Cash)", Icons.phone_android_rounded),
        _buildPaymentMethodCard('mtn', "كاش موبايل (MTN Cash)", Icons.phonelink_setup_rounded),
        const SizedBox(height: 40),
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: _selectedMethod.isNotEmpty ? () => setState(() => _currentStep = 2) : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryGreen,
              disabledBackgroundColor: Colors.grey.shade300,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text("متابعة الدفع بالطريقة المختارة", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 15)),
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentMethodCard(String id, String title, IconData icon) {
    bool isSelected = _selectedMethod == id;
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: isSelected ? primaryGreen : Colors.transparent, width: 2),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.01), blurRadius: 8)],
      ),
      child: ListTile(
        onTap: () => setState(() => _selectedMethod = id),
        leading: Icon(icon, color: isSelected ? primaryGreen : navyColor.withOpacity(0.6), size: 24),
        title: Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: navyColor)),
        trailing: Radio<String>(
          value: id,
          groupValue: _selectedMethod,
          activeColor: primaryGreen,
          onChanged: (val) => setState(() => _selectedMethod = val!),
        ),
      ),
    );
  }

  // ✨ المرحلة الثانية: شاشة معالجة بيانات الحساب والـ OTP الآمن
  Widget _buildStageTwoForm() {
    String methodNameStr = _selectedMethod == 'sham' ? "شام كاش" : _selectedMethod == 'syriatel' ? "سيريتل كاش" : "كاش موبايل";
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.lock_outline_rounded, color: primaryGreen, size: 18),
            const SizedBox(width: 6),
            Text("حساب الدفع عبر: $methodNameStr", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: navyColor)),
          ],
        ),
        const SizedBox(height: 20),
        if (!_isOtpSent) ...[
          Text("أدخل رقم الهاتف المرتبط بمحفظتك:", style: TextStyle(fontSize: 13, color: navyColor.withOpacity(0.8))),
          const SizedBox(height: 10),
          _buildPhoneField(),
          const SizedBox(height: 35),
          _buildFormButton(
            label: "طلب رمز التحقق المرئي",
            icon: Icons.send_rounded,
            onPressed: _phoneController.text.length == 9 ? _simulateOtpSending : null,
          ),
        ],
        if (_isOtpSent) ...[
          Text("أدخل رمز التحقق (OTP) السري المستلم برسالة:", style: TextStyle(fontSize: 13, color: navyColor.withOpacity(0.8))),
          const SizedBox(height: 10),
          _buildOtpField(),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton(
              onPressed: () => setState(() => _isOtpSent = false),
              child: Text("تغيير رقم الهاتف", style: TextStyle(color: primaryGreen, fontWeight: FontWeight.bold, fontSize: 12)),
            ),
          ),
          const SizedBox(height: 25),
          _buildFormButton(
            label: "تأكيد وإتمام المعاملة بأمان",
            icon: Icons.verified_user_rounded,
            onPressed: _otpController.text.length == 4 ? _simulateFinalPayment : null,
          ),
        ],
      ],
    );
  }

  Widget _buildPhoneField() {
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.01), blurRadius: 5)]),
      child: Row(
        children: [
          Expanded(
            child: Directionality(
              textDirection: TextDirection.ltr,
              child: TextField(
                controller: _phoneController,
                onChanged: (val) => setState(() {}),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(9), FilteringTextInputFormatter.deny(RegExp(r'^0'))],
                style: TextStyle(fontSize: 16, letterSpacing: 1.5, fontWeight: FontWeight.bold, color: navyColor),
                decoration: const InputDecoration(border: InputBorder.none, hintText: "9xxxxxxxxx", contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 15)),
              ),
            ),
          ),
          Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: Text("+963", style: TextStyle(color: navyColor, fontWeight: FontWeight.bold))),
        ],
      ),
    );
  }

  Widget _buildOtpField() {
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: TextField(
        controller: _otpController,
        onChanged: (val) => setState(() {}),
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(4)],
        style: TextStyle(fontSize: 22, letterSpacing: 12.0, fontWeight: FontWeight.w900, color: navyColor),
        decoration: InputDecoration(border: InputBorder.none, hintText: "••••", hintStyle: TextStyle(color: Colors.grey.shade300), contentPadding: const EdgeInsets.symmetric(vertical: 12)),
      ),
    );
  }

  Widget _buildFormButton({required String label, required IconData icon, required VoidCallback? onPressed}) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, color: Colors.white, size: 18),
        label: Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        style: ElevatedButton.styleFrom(backgroundColor: primaryGreen, disabledBackgroundColor: Colors.grey.shade300, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
      ),
    );
  }

  void _simulateOtpSending() {
    setState(() => _isProcessing = true);
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) {
        setState(() {
          _isProcessing = false;
          _isOtpSent = true;
        });
      }
    });
  }

  void _simulateFinalPayment() {
    setState(() => _isProcessing = true);
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() => _isProcessing = false);
        _showSuccessStageDialog(); // الانتقال إلى المرحلة الثالثة والنهائية
      }
    });
  }

  // ✨ المرحلة الثالثة: شاشة النجاح الكامل والتأكيد البصري على حجز مقاعد الحافلة
  void _showSuccessStageDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => WillPopScope(
        onWillPop: () async => false,
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(color: primaryGreen.withOpacity(0.1), shape: BoxShape.circle),
                  child: Icon(Icons.check_circle_rounded, color: primaryGreen, size: 50),
                ),
                const SizedBox(height: 20),
                Text("تمت العملية بنجاح!", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: navyColor)),
                const SizedBox(height: 10),
                Text(
                  "تم سداد مبلغ $_formattedAmount ل.س بنجاح وتأكيد حجز مقاعدك في الحافلة. رحلة سعيدة!",
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 13, color: Colors.grey, height: 1.6),
                ),
                const SizedBox(height: 25),
                SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
                    style: ElevatedButton.styleFrom(backgroundColor: navyColor, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                    child: const Text("الانتقال إلى الرئيسية", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

extension StringExtension on String {
  String replaceAllMatches(RegExp regex, String replacement) {
    return regex.allMatches(this).fold(this, (String result, Match match) => result.replaceFirst(match.pattern, replacement));
  }
}