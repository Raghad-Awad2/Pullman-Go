import 'package:flutter/material.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl, // ضروري عشان التنسيق العربي
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F5F5),
        appBar: AppBar(
          title: const Text("الإشعارات", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          centerTitle: true,
          backgroundColor: const Color(0xFF2ECC71),
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: 5,
          itemBuilder: (context, index) {
            return Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Color(0xFF2ECC71),
                  child: Icon(Icons.notifications_active, color: Colors.white),
                ),
                title: Text("تنبيه برحلة رقم ${index + 100}",
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: const Text("تم تأكيد حجزك بنجاح، نتمنى لك رحلة سعيدة."),
                trailing: const Text("منذ قليل",
                    style: TextStyle(fontSize: 10, color: Colors.grey)),
              ),
            );
          },
        ),
      ),
    );
  }
}