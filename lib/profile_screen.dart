import 'package:flutter/material.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool isEditingName = false;
  final _formKey = GlobalKey<FormState>();
  final Color primaryGreen = const Color(0xFF2ECC71);
  final FocusNode _nameFocusNode = FocusNode(); // لإجبار الكتابة عند الضغط

  String initialName = "وداد طارق الأبطح";
  String initialEmail = "wedad@example.com";
  String initialPhone = "09XXXXXXXX";

  late TextEditingController nameController;
  late TextEditingController emailController;
  late TextEditingController phoneController;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: initialName);
    emailController = TextEditingController(text: initialEmail);
    phoneController = TextEditingController(text: initialPhone);
  }

  void cancelEditing() {
    setState(() {
      isEditingName = false;
      nameController.text = initialName;
    });
  }

  void saveEditing() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        initialName = nameController.text;
        isEditingName = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("تم تحديث الاسم بنجاح", textAlign: TextAlign.center)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            const Center(
              child: CircleAvatar(
                radius: 50,
                backgroundColor: Colors.white,
                child: Icon(Icons.person, size: 70, color: Color(0xFF2ECC71)),
              ),
            ),
            const SizedBox(height: 30),

            // حقل الاسم
            _buildCustomField("الاسم الكامل", nameController, Icons.person_outline, canEdit: true),
            const SizedBox(height: 15),

            // حقل الإيميل
            _buildCustomField("البريد الإلكتروني", emailController, Icons.email_outlined, canEdit: false),
            const SizedBox(height: 15),

            // حقل الهاتف
            _buildCustomField("رقم الهاتف", phoneController, Icons.phone_android_outlined, canEdit: false),

            const SizedBox(height: 30),

            if (isEditingName)
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: saveEditing,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryGreen,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text("حفظ", style: TextStyle(color: Colors.white)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: cancelEditing,
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: primaryGreen),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text("إلغاء", style: TextStyle(color: primaryGreen)),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomField(String label, TextEditingController controller, IconData icon, {required bool canEdit}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        const SizedBox(height: 5),
        TextFormField(
          controller: controller,
          focusNode: canEdit ? _nameFocusNode : null,
          enabled: canEdit ? isEditingName : false,
          textAlign: TextAlign.right,
          decoration: InputDecoration(
            filled: true,
            fillColor: (canEdit && isEditingName) ? Colors.white : Colors.grey[200],

            // أيقونة البيانات (شخص/إيميل/هاتف) إجبارياً على اليمين
            suffixIcon: Icon(icon, color: primaryGreen),

            // أيقونة القلم إجبارياً على اليسار وفقط للاسم
            prefixIcon: canEdit ? IconButton(
              icon: Icon(Icons.edit, color: isEditingName ? primaryGreen : Colors.grey),
              onPressed: () {
                setState(() {
                  isEditingName = true;
                });
                // تأخير بسيط لإعطاء التركيز للحقل بعد تفعيله
                Future.delayed(Duration.zero, () => _nameFocusNode.requestFocus());
              },
            ) : null,

            disabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.grey[300]!), borderRadius: BorderRadius.circular(12)),
            enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: primaryGreen), borderRadius: BorderRadius.circular(12)),
            focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: primaryGreen, width: 2), borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ],
    );
  }
}