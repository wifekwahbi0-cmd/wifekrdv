import 'package:flutter/material.dart';
import 'children_screen.dart';
import 'sessions_screen.dart';
import 'reports_screen.dart';
import '../widgets/notification_bar.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset('assets/logo.png', height: 30),
            const SizedBox(width: 8),
            const Text(
              "wifek rdv",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          const NotificationBar(),
          Expanded(
            child: GridView.count(
              padding: const EdgeInsets.all(16),
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              children: [
                _buildCard(context, "ملفات الأطفال", Icons.person, () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const ChildrenScreen()));
                }),
                _buildCard(context, "جدولة الحصص", Icons.calendar_today, () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const SessionsScreen()));
                }),
                _buildCard(context, "التقارير اليومية", Icons.description, () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const ReportsScreen()));
                }),
                _buildCard(context, "متابعة التقدم", Icons.show_chart, () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("قيد التطوير")),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard(BuildContext context, String title, IconData icon, VoidCallback onTap) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: Theme.of(context).primaryColor),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
