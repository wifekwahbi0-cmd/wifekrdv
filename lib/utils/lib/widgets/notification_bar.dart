import 'package:flutter/material.dart';

class NotificationBar extends StatelessWidget {
  const NotificationBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.orange[100],
      child: Row(
        children: [
          const Icon(Icons.notifications, color: Colors.orange, size: 20),
          const SizedBox(width: 8),
          const Text(
            "لديك 3 حصص اليوم • تقريران بانتظار الحفظ",
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
          const Spacer(),
          IconButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("تم إخفاء الإشعارات")),
              );
            },
            icon: const Icon(Icons.close, size: 18),
          ),
        ],
      ),
    );
  }
}
