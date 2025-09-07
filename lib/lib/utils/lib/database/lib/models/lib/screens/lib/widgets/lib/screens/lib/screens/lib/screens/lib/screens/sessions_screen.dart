import 'package:flutter/material.dart';
import '../database/db_helper.dart';
import '../models/child_model.dart';

class SessionsScreen extends StatefulWidget {
  const SessionsScreen({super.key});

  @override
  State<SessionsScreen> createState() => _SessionsScreenState();
}

class _SessionsScreenState extends State<SessionsScreen> {
  late DBHelper dbHelper;
  List<Map<String, dynamic>> sessionsList = [];
  List<Child> childrenList = [];

  @override
  void initState() {
    super.initState();
    dbHelper = DBHelper();
    _loadData();
  }

  Future<void> _loadData() async {
    final db = await dbHelper.db;
    final sessionMaps = await db.rawQuery('''
      SELECT s.*, c.name as child_name 
      FROM sessions s 
      JOIN children c ON s.child_id = c.id
      ORDER BY s.date, s.time
    ''');
    final childMaps = await db.query('children');
    setState(() {
      sessionsList = sessionMaps;
      childrenList = childMaps.map((e) => Child.fromMap(e)).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('جدولة الحصص')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: sessionsList.length,
                itemBuilder: (context, index) {
                  final session = sessionsList[index];
                  return Card(
                    child: ListTile(
                      title: Text("حصة مع: ${session['child_name']}"),
                      subtitle: Text("${session['date']} - ${session['time']}"),
                      trailing: const Icon(Icons.calendar_today),
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
              child: const Text("إضافة حصة جديدة"),
            ),
          ],
        ),
      ),
    );
  }
}
