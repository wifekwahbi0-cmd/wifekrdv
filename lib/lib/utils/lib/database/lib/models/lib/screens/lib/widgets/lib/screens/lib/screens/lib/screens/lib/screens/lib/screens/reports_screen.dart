import 'package:flutter/material.dart';
import '../database/db_helper.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  late DBHelper dbHelper;
  List<Map<String, dynamic>> reportsList = [];

  @override
  void initState() {
    super.initState();
    dbHelper = DBHelper();
    _loadReports();
  }

  Future<void> _loadReports() async {
    final db = await dbHelper.db;
    final reports = await db.rawQuery('''
      SELECT r.*, s.date as session_date, c.name as child_name
      FROM reports r
      JOIN sessions s ON r.session_id = s.id
      JOIN children c ON s.child_id = c.id
      ORDER BY r.report_date DESC
    ''');
    setState(() {
      reportsList = reports;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('التقارير اليومية')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: reportsList.length,
                itemBuilder: (context, index) {
                  final report = reportsList[index];
                  return Card(
                    child: ListTile(
                      title: Text("تقرير: ${report['child_name']}"),
                      subtitle: Text("التاريخ: ${report['session_date']}"),
                      trailing: const Icon(Icons.description),
                    ),
                  );
                },
              ),
            ),
            ElevatedButton(
              onPressed: () {
                // سيتم تطويرها لاحقاً
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("قيد التطوير")),
                );
              },
              child: const Text("كتابة تقرير جديد"),
            ),
          ],
        ),
      ),
    );
  }
}
