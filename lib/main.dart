import 'dart:async';

import 'package:flutter/material.dart';

import 'login_screen.dart';
import 'hom.dart'; // تأكدي من كتابة اسم الملف البرمجي الصحيح لصفحة الهوم
void main() {
  runApp(
    const MaterialApp(debugShowCheckedModeBanner: false, home: SplashScreen()),
  );//SplashScreen
  //PullmanMainScreen

}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    //مدة بقاء شاشة اللوغو
    Timer(const Duration(seconds: 3), () {
      //pushReplacement: عشان المستخدم لما يوصل للشاشات الترحيبية ويضغط زر "رجوع" بالموبايل، ما يرجع لصفحة اللوجو مرة ثانية الدالة
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const IntroScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0C1D2E),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.blueAccent.withOpacity(0.5),
                  width: 2,
                ),
                image: const DecorationImage(
                  image: AssetImage('assets/images/logo.png'),
                  // BoxFit.cover: بتخلي الصورة تعبي الدائرة كاملة وبتمسح الفراغات
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 30),
            const Text(
              'PULLMAN GO',
              style: TextStyle(
                color: Colors.white,
                fontSize: 26,
                letterSpacing: 3,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// كلاس للشاشة الترحيب الشخصي للمستخدمين الي بعد اللوغو او السبلاش سكرين
class IntroScreen extends StatefulWidget {
  const IntroScreen({super.key});

  @override
  State<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2), // سرعة اللمعة
    )..repeat();
  }

  //بيمسح" الأنميشن من ذاكرة الجوال تماماً
  @override
  void dispose() {
    //وقف النبض فوراً عشان تريح المعالج
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0C1D2E),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 1. البسملة
            const Text(
              'بِسْــمِ اللَّـهِ الرَّحْمَــٰنِ الرَّحِيـمِ',
              style: TextStyle(color: Colors.white70, fontSize: 22),
            ),
            const SizedBox(height: 40),

            // 2. الإيموجي
            const Text('👋', style: TextStyle(fontSize: 70)),
            const SizedBox(height: 30),

            const Text(
              'أهلاً بك في عائلة',
              style: TextStyle(color: Colors.white70, fontSize: 18),
            ),

            // 3. النص اللامع
            AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return ShaderMask(
                  blendMode: BlendMode.srcATop,
                  shaderCallback: (rect) {
                    return LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      stops: [
                        _controller.value - 0.2,
                        _controller.value,
                        _controller.value + 0.2,
                      ],
                      colors: [
                        const Color(0xFF00E676),
                        Colors.white,
                        const Color(0xFF00E676),
                      ],
                    ).createShader(rect);
                  },
                  child: const Text(
                    'PULLMAN GO',
                    style: TextStyle(
                      fontSize: 42,
                      fontWeight: FontWeight.w900, // استخدمنا w900 بدل black
                      letterSpacing: 2,
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 20),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                'رحلتك القادمة تبدأ بضغطة زر واحدة فقط.استعد للراحة',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white54, fontSize: 16),
              ),
            ),

            const SizedBox(height: 50),
            // هاد هو الكود اللي سألت عنه (الزر مع النبض والتوهج)
            ScaleTransition(
              scale: Tween<double>(begin: 1.0, end: 1.1).animate(
                CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
              ),
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(35),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(
                            0xFF00E676,
                          ).withOpacity(0.3 * _controller.value),
                          blurRadius: 15,
                          spreadRadius: 5 * _controller.value,
                        ),
                      ],
                    ),
                    child: child,
                  );
                },
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const WelcomeScreen(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00E676),
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 50,
                      vertical: 18,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(35),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'لنبدأ الرحلة 🚀',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

//الشاشة الترحيبية الاولى
class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with SingleTickerProviderStateMixin {
  // 1. هون حط التعريفات (قبل أي شي ثاني)
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  double _buttonScale = 1.0; // هاد المتغير القديم تبعك خليه مثل ما هو
  //المسؤولة عن تشغيل النبض أول ما تفتح الشاشة
  @override
  void initState() {
    super.initState();
    // هون المحرك بيبدأ يشتغل
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  //تطفي المحرك لما تطلع من الشاشة عشان توفر بطارية
  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: Stack(
        // استخدمنا Stack عشان نتحكم بمكان الزر والنقاط بدقة
        children: [
          Column(
            children: [
              // 1. الصورة العلوية الاولى
              Container(
                height: MediaQuery.of(context).size.height * 0.45,
                width: double.infinity,
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(50),
                    bottomRight: Radius.circular(50),
                  ),
                  image: DecorationImage(
                    image: AssetImage('assets/images/onboarding1.png'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 50),
              // 2. النصوص مع النجمة اللي بتلمع
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // --- هون حطينا كود اللمعة للنجمة ---
                  Stack(
                    children: [
                      const Text('✨', style: TextStyle(fontSize: 28)),
                      Positioned.fill(
                        child: AnimatedBuilder(
                          animation: _pulseController,
                          builder: (context, child) {
                            return ShaderMask(
                              blendMode: BlendMode.srcATop,
                              shaderCallback: (rect) {
                                return LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  stops: [
                                    _pulseController.value - 0.2,
                                    _pulseController.value,
                                    _pulseController.value + 0.2,
                                  ],
                                  colors: [
                                    Colors.transparent,
                                    Colors.white.withOpacity(0.8),
                                    Colors.transparent,
                                  ],
                                ).createShader(rect);
                              },
                              child: const Text(
                                '✨',
                                style: TextStyle(
                                  fontSize: 28,
                                  color: Colors.white,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),

                  // --- نهاية كود اللمعة ---
                  const Text(
                    ' راحة في كل مكان',
                    style: TextStyle(
                      color: Color(0xFF000814),
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              const Text(
                'حجوزات سهلة ومقاعد مريحة',
                textAlign: TextAlign.center,
                style: TextStyle(color: Color(0xFF000814), fontSize: 19),
              ),
            ],
          ),

          // 3. النقاط في المنتصف (بالأسفل)
          Positioned(
            bottom: 100,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildDot(true), //النقطة الاولى هي الي شغالة
                const SizedBox(width: 8),
                _buildDot(false),
                const SizedBox(width: 8),
                _buildDot(false),
              ],
            ),
          ),

          // زر السهم مع حركة النبض والانتقال
          Positioned(
            bottom: 80,
            right: 30,
            child: ScaleTransition(
              scale: _pulseAnimation, // <<< تم إضافة الربط بالنبض هنا
              child: GestureDetector(
                onTap: () {
                  // دالة الانتقال الفخمة (Slide)
                  Navigator.of(context).push(_createRoute());
                },
                // شكل الدائرة الي حوالي السهم في الشاشة الترحيبية الاولى
                child: AnimatedScale(
                  scale: _buttonScale, // هون بنطبق الحجم
                  duration: const Duration(milliseconds: 100),
                  child: Hero(
                    tag: 'arrow_button', // ويدجت الـ Hero بتبدأ هون
                    child: Container(
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: const Color(0xFF00E676),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.arrow_forward_rounded,
                        color: Colors.black,
                        size: 26,
                      ),
                    ), // إغلاق الـ Container
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // دالة الانتقال "من اليمين لليسار"
  Route _createRoute() {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) =>
      const SecondOnboarding(),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        var tween = Tween(
          begin: const Offset(1.0, 0.0),
          end: Offset.zero,
        ).chain(CurveTween(curve: Curves.easeOutQuart));
        return SlideTransition(position: animation.drive(tween), child: child);
      },
    );
  }

  //تصميم النقاط
  Widget _buildDot(bool isActive) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: 8,
      width: isActive ? 30 : 10,
      decoration: BoxDecoration(
        // إذا كانت النقطة شغالة خليها أخضر، وإذا لا خليها رمادي غامق عشان تبين عالأبيض
        color: isActive ? Color(0xFF00E676) : Colors.grey.withOpacity(0.5),
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }
}

//الشاشة الترحيبية الثانية
class SecondOnboarding extends StatefulWidget {
  const SecondOnboarding({super.key});

  @override
  State<SecondOnboarding> createState() => _SecondOnboardingState();
}

class _SecondOnboardingState extends State<SecondOnboarding>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _pulseAnimation;
  late Animation<double> _shimmerAnimation;

  @override
  void initState() {
    super.initState();
    // إعداد المحرك المسؤول عن الحركات (مدة الدورة ثانية واحدة)
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true); // الحركة بتروح وبترجع بشكل مستمر

    // 1. أنميشن النبض للدائرة (بتكبر من 1.0 لـ 1.12)
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.12,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    // 2. أنميشن اللمعان للسمايل (بيغير الشفافية من 0.3 لـ 1.0)
    _shimmerAnimation = Tween<double>(
      begin: 0.3,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose(); // تنظيف الذاكرة عند الخروج
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: Stack(
        children: [
          Column(
            children: [
              // 1. الصورة العلوية للشاشة الثانية (حجز بكل سهولة)
              Container(
                height: MediaQuery.of(context).size.height * 0.45,
                width: double.infinity,
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(50),
                    bottomRight: Radius.circular(50),
                  ),
                  image: DecorationImage(
                    image: AssetImage('assets/images/onboarding2.png'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 50),

              // 2. العنوان الجديد مع السمايل اللي بيلمع بمسحة ضوء
              Row(
                mainAxisAlignment: MainAxisAlignment.center,

                children: [
                  // 1. النص العريض أولاً (بيظهر عاليمين)
                  const Text(
                    'حجز بكل سهولة',
                    style: TextStyle(
                      color: Color(0xFF000814),
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(width: 10),

                  // 2. الموبايل اللامع (بيظهر على يسار النص)
                  Stack(
                    children: [
                      // الموبايل الأصلي
                      const Text('📱', style: TextStyle(fontSize: 32)),

                      // طبقة اللمعة اللي بتمر من فوق الموبايل
                      Positioned.fill(
                        child: AnimatedBuilder(
                          animation: _controller,
                          builder: (context, child) {
                            return ShaderMask(
                              blendMode: BlendMode.srcATop,
                              shaderCallback: (rect) {
                                return LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  stops: [
                                    _controller.value - 0.2,
                                    _controller.value,
                                    _controller.value + 0.2,
                                  ],
                                  colors: [
                                    Colors.transparent,
                                    Colors.white.withOpacity(0.8),
                                    Colors.transparent,
                                  ],
                                ).createShader(rect);
                              },
                              child: const Text(
                                '📱', // تأكد إنك غيرت الإيموجي هون كمان
                                style: TextStyle(
                                  fontSize: 32,
                                  color: Colors.white,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 15),

              // 3. النص الفرعي الجديد
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  '، اختر رحلتك واحجز مقعدك في ثواني\nواجهة بسيطة مصممة لضمان راحتك ',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Color(0xFF000814), fontSize: 19),
                ),
              ),
            ],
          ),

          // 4. النقاط (النقطة الثانية هي النشطة)
          Positioned(
            bottom: 100,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildDot(false),
                const SizedBox(width: 8),
                _buildDot(true), // النقطة الثانية هي الي شغالة
                const SizedBox(width: 8),
                _buildDot(false),
              ],
            ),
          ),

          // 5. زر السهم مع الدائرة النابضة بشكل مستمر
          Positioned(
            bottom: 80,
            right: 30,
            child: ScaleTransition(
              scale: _pulseAnimation, // تأثير النبض المستمر للدائرة
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (context, anim, secAnim) =>
                      const ThirdOnboarding(),
                      transitionsBuilder: (context, anim, secAnim, child) {
                        // تأثير السحب الناعم (Slide)
                        return SlideTransition(
                          position: anim.drive(
                            Tween(
                              begin: const Offset(1, 0),
                              end: Offset.zero,
                            ).chain(CurveTween(curve: Curves.easeOutQuart)),
                          ),
                          child: child,
                        );
                      },
                    ),
                  );
                },
                child: Hero(
                  tag:
                  'arrow_button', // لازم يكون نفس الـ tag اللي بالشاشة الأولى بالظبط
                  child: Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: const Color(0xFF00E676), // أخضر فاتح وفخم
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.arrow_forward_rounded,
                      color: Colors.black,
                      size: 26,
                    ),
                  ),
                ), // تأكد من إغلاق قوس الـ Hero هون
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ويدجت النقاط ( التصميم )
  Widget _buildDot(bool isActive) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: 8,
      width: isActive ? 30 : 10,
      decoration: BoxDecoration(
        // إذا كانت النقطة شغالة خليها أخضر، وإذا لا خليها رمادي غامق عشان تبين عالأبيض
        color: isActive ? Color(0xFF00E676) : Colors.grey.withOpacity(0.5),
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }
}

// الشاشة الترحيبية الثالثة
class ThirdOnboarding extends StatefulWidget {
  const ThirdOnboarding({super.key});

  @override
  State<ThirdOnboarding> createState() => _ThirdOnboardingState();
}

class _ThirdOnboardingState extends State<ThirdOnboarding>
    with SingleTickerProviderStateMixin {
  //التعريفات
  //للنبض المستمر للزر
  late AnimationController _controller;
  //للمعان على علامة الصح
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: Stack(
        children: [
          Column(
            children: [
              // 1. الصورة العلوية
              Container(
                height: MediaQuery.of(context).size.height * 0.45,
                width: double.infinity,
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(50),
                    bottomRight: Radius.circular(50),
                  ),
                  image: DecorationImage(
                    image: AssetImage('assets/images/onboarding3.png'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 50),

              // 2. العنوان العريض وبعده علامة الصح ✅
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'دفع إلكتروني آمن',
                    style: TextStyle(
                      color: Color(0xFF000814),
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(width: 8), // مسافة بسيطة بين النص والصح
                  // علامة الصح اللي بتلمع ✅
                  _buildShiningCheck(),
                ],
              ),
              const SizedBox(height: 15),

              // 3. الشرح (سلس وآمن)
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 40),
                child: Text(
                  'استمتع بتجربة دفع سريعة ومحمية بالكامل\nلضمان حجز مقعدك بسهولة عبر تطبيقنا',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFF000814),
                    fontSize: 19,
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),

          // 4. نقاط التنقل
          Positioned(
            //بتحكم بارتفاع النقاط
            bottom: 70,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildDot(false),
                const SizedBox(width: 8),
                _buildDot(false),
                const SizedBox(width: 8),
                _buildDot(true),
              ],
            ),
          ),

          // 5. الزر العريض والنابض
          Positioned(
            //بتحكم بارتفاع الزر تبع ابدأ الان
            bottom: 100,
            left: 50,
            right: 50,
            child: ScaleTransition(
              scale: _pulseAnimation,
              child: Hero(
                tag: 'arrow_button',
                child: ElevatedButton(
                  onPressed: () {
                    // . وقف النبض فوراً عشان تريح المعالج
                    _controller.stop();
                    // الانتقال لصفحة التسجيل
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LoginScreen(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    //لون الزر ابدأ الان فقط من دون الكلمة الي بداخل ازر
                    backgroundColor: Color(0xFF00E676),
                    //لون كلمة ابدأ الان
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    elevation: 5,
                    shadowColor: Colors.black.withOpacity(0.3),
                  ),
                  child: const Text(
                    ' بسم الله نبدأ',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ويدجت علامة الصح اللامعة ✅
  Widget _buildShiningCheck() {
    return Stack(
      children: [
        const Text('✅', style: TextStyle(fontSize: 28)),
        Positioned.fill(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return ShaderMask(
                blendMode: BlendMode.srcATop,
                shaderCallback: (rect) {
                  return LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    stops: [
                      _controller.value - 0.2,
                      _controller.value,
                      _controller.value + 0.2,
                    ],
                    colors: [
                      Colors.transparent,
                      Colors.white.withOpacity(0.8),
                      Colors.transparent,
                    ],
                  ).createShader(rect);
                },
                child: const Text(
                  '✅',
                  style: TextStyle(fontSize: 28, color: Colors.white),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // ويدجت النقاط
  Widget _buildDot(bool isActive) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: 8,
      width: isActive ? 30 : 10,
      decoration: BoxDecoration(
        color: isActive ? Color(0xFF00E676) : Colors.grey.withOpacity(0.5),
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }
}
