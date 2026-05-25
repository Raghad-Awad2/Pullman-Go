import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; //هي المكتبة مشان تمنع الكتابة بالعربي داخل حقل البريد الالكرتوني(FilteringTextInputFormatter)
//هي مكتبة لحفظ التوكن واسم المستخدم
import 'package:shared_preferences/shared_preferences.dart';

import 'api_service.dart';
import 'custom_button.dart'; //مشان استدعي ملف الاهتزاز تبع الازرار عند الضغط عليهن
import 'forgot_password_screen.dart'; //الانتقال الى صفحة ادخال البريد الالكتروني بعد الضغط على كملة نسيت كلمة المرور
import 'hom.dart'; // استدعاء ملف الشاشة الرئيسية الجديد
//استدعاء ملف انشاء حساب جديد
import 'signup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  //مفتاح النموذج: ضروري لتفعيل عملية التحقق (Validation) عند الضغط على الزر
  final _formKey = GlobalKey<FormState>();

  // تعريف المتحكمات في بداية كلاس الشاشة مشان الربط
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passController = TextEditingController();

  bool _isObscure = true;
  bool _isLoggingIn = false; // متغير لحالة التحميل

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      body: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Stack(
                children: [
                  const RepaintBoundary(child: ImageSection()),
                  Positioned(
                    bottom: -1,
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      height: 130,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(90),
                          topRight: Radius.circular(90),
                        ),
                      ),
                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'مرحباً بك مجدداً',
                            style: TextStyle(
                              fontSize: 33,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          SizedBox(height: 5),
                          Text(
                            'سجل الدخول لحجز رحلتك القادمة',
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25),
                child: Column(
                  children: [
                    _buildEmailField(
                      label: 'رقم الهاتف أو البريد الإلكتروني',
                      hint: 'أدخل رقمك أو بريدك الإلكتروني',
                      icon: Icons.email,
                      validator: (value) => (value == null || value.isEmpty)
                          ? 'يرجى ملء هذا الحقل '
                          : null,
                      isEmail: true,
                      controller: _emailController,
                      labelFontSize: 15,
                    ),
                    const SizedBox(height: 20),

                    _buildPasswordField(
                      controller: _passController,
                      labelFontSize: 15,
                    ),

                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ForgotPasswordScreen(),
                            ),
                          );
                        },
                        child: const Text(
                          'نسيت كلمة السر؟',
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    MyMainButton(
                      text: 'تسجيل الدخول',
                      isLoading: _isLoggingIn,
                      onTap: () async {
                        if (_formKey.currentState!.validate()) {
                          setState(() {
                            _isLoggingIn = true; // بدء التحميل
                          });

                          // 1. استدعاء الساعي (ApiService)
                          ApiService api = ApiService();

                          // 2. إرسال البيانات للسيرفر
                          var response = await api.loginUser(
                            loginField: _emailController.text,
                            password: _passController.text,
                          );

                          if (mounted) {
                            setState(() {
                              _isLoggingIn = false; // إيقاف التحميل
                            });

                            // 3. فحص رد السيرفر
                            if (response.statusCode == 200) {
                              // نجاح! (البيانات صحيحة)

                              // 1. استخراج التوكن وبيانات المستخدم القادمة من رد اللارافيل
                              String token = response.data['token'];
                              var userData = response.data['user']; // كائن بيانات المستخدم

                              // 2. فتح ذاكرة الموبايل وحفظ كل البيانات تلقائياً
                              final SharedPreferences prefs = await SharedPreferences.getInstance();
                              await prefs.setString('token', token);
                              await prefs.setBool('is_logged_in', true);

                              // حفظ البيانات المقروءة لتظهر في الملف الشخصي تلقائياً
                              await prefs.setString('user_name', userData['name'] ?? '');
                              await prefs.setString('user_email', userData['email'] ?? '');
                              await prefs.setString('user_phone', userData['phone'] ?? '');

                              // الانتقال للصفحة الرئيسية
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const PullmanMainScreen(),
                                ),
                              );
                            } else {
                              // فشل!
                              String errorMsg = response.data['message'] ?? "حدث خطأ في تسجيل الدخول";

                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    errorMsg,
                                    textAlign: TextAlign.center,
                                  ),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          }
                        }
                      },
                    ),

                    const SizedBox(height: 30),
                    const Row(
                      children: [
                        Expanded(child: Divider()),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20),
                          child: Text('أو'),
                        ),
                        Expanded(child: Divider()),
                      ],
                    ),
                    const SizedBox(height: 20),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const SignUpScreen(),
                              ),
                            );
                          },
                          child: const Text(
                            'أنشاء حساب جديد',
                            style: TextStyle(
                              color: Colors.blue,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const Text('ليس لديك حساب بالفعل؟'),
                      ],
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- حقل الإدخال: مؤشر يسار والـ Hint يمين ---
  Widget _buildEmailField({
    required String label,
    required String hint,
    required IconData icon,
    bool isEmail = false,
    double labelFontSize = 14,
    required TextEditingController controller,
    required String? Function(String?) validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: TextFormField(
            controller: controller,
            keyboardType: isEmail ? TextInputType.emailAddress : TextInputType.text,
            textAlign: controller.text.startsWith('09') ? TextAlign.right : TextAlign.left,
            textDirection: controller.text.startsWith('09') ? TextDirection.rtl : TextDirection.ltr,
            onChanged: (value) {
              setState(() {});
            },
            textInputAction: TextInputAction.next,
            inputFormatters: [
              FilteringTextInputFormatter.deny(RegExp(r'[أ-ي]')),
            ],
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'يرجى ملء هذا الحقل';
              }

              final bool isEmail = RegExp(r'^[a-zA-Z0-9.]+@gmail\.com$').hasMatch(value);
              final bool isPhone = RegExp(r'^09[0-9]{8}$').hasMatch(value);

              if (isEmail) {
                return null;
              } else if (isPhone) {
                return null;
              } else {
                return 'أدخل إيميل صحيح أو رقم هاتف يبدأ بـ 09 (10 أرقام)';
              }
            },
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.grey[100],
              hintText: hint,
              hintStyle: const TextStyle(fontSize: 15, color: Colors.grey),
              suffixIcon: Icon(icon, color: Colors.grey),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide.none,
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: const BorderSide(color: Colors.red, width: 1),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: const BorderSide(color: Colors.red, width: 2),
              ),
              errorStyle: const TextStyle(fontSize: 12, color: Colors.red),
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            ),
          ),
        ),
      ],
    );
  }

  // --- حقل كلمة السر
  Widget _buildPasswordField({
    double labelFontSize = 14,
    required TextEditingController controller,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        const Text(
          'كلمة السر',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: TextFormField(
            controller: controller,
            textAlign: TextAlign.left,
            textDirection: TextDirection.ltr,
            textInputAction: TextInputAction.done,
            obscureText: _isObscure,
            inputFormatters: [
              FilteringTextInputFormatter.deny(RegExp(r'[أ-ي]')),
            ],
            validator: (value) => (value == null || value.length < 6) ? 'يرجى ملء هذا الحقل' : null,
            decoration: InputDecoration(
              hintText: 'أدخل كلمة السر',
              hintStyle: const TextStyle(color: Colors.grey, fontSize: 15),
              hintTextDirection: TextDirection.rtl,
              suffixIcon: const Icon(Icons.lock, color: Colors.grey),
              prefixIcon: IconButton(
                icon: Icon(
                  _isObscure ? Icons.visibility_off : Icons.visibility,
                  color: Colors.grey,
                ),
                onPressed: () => setState(() => _isObscure = !_isObscure),
              ),
              border: InputBorder.none,
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: const BorderSide(color: Colors.red, width: 1),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: const BorderSide(color: Colors.red, width: 2),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passController.dispose();
    super.dispose();
  }
}

class ImageSection extends StatelessWidget {
  const ImageSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.44,
      width: double.infinity,
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/bus_Login_image.png'),
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}