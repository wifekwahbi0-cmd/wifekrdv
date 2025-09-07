import 'package:flutter/material.dart';
import '../database/db_helper.dart';
import '../models/child_model.dart';

class ChildrenScreen extends StatefulWidget {
  const ChildrenScreen({super.key});

  @override
  State<ChildrenScreen> createState() => _ChildrenScreenState();
}

class _ChildrenScreenState extends State<ChildrenScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _birthDateController = TextEditingController();
  final _phoneController = TextEditingController();
  final _diagnosisController = TextEditingController();
  final _notesController = TextEditingController();

  late DBHelper dbHelper;
  List<Child> childrenList = [];

  @override
  void initState() {
    super.initState();
    dbHelper = DBHelper();
    _refreshChildrenList();
  }

  Future<void> _refreshChildrenList() async {
    final db = await dbHelper.db;
    final maps = await db.query('children');
    setState(() {
      childrenList = maps.map((e) => Child.fromMap(e)).toList();
    });
  }

  Future<void> _saveChild() async {
    if (_formKey.currentState!.validate()) {
      final child = Child(
        name: _nameController.text,
        age: int.tryParse(_ageController.text),
        birthDate: _birthDateController.text,
        phone: _phoneController.text,
        diagnosis: _diagnosisController.text,
        notes: _notesController.text,
      );

      final db = await dbHelper.db;
      await db.insert('children', child.toMap());

      _refreshChildrenList();
      _clearForm();
      Navigator.pop(context);
    }
  }

  void _clearForm() {
    _nameController.clear();
    _ageController.clear();
    _birthDateController.clear();
    _phoneController.clear();
    _diagnosisController.clear();
    _notesController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ملفات الأطفال')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: childrenList.length,
                itemBuilder: (context, index) {
                  final child = childrenList[index];
                  return Card(
                    child: ListTile(
                      title: Text(child.name),
                      subtitle: Text("العمر: ${child.age ?? 'غير محدد'}"),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () async {
                          final db = await dbHelper.db;
                          await db.delete('children', where: 'id = ?', whereArgs: [child.id]);
                          _refreshChildrenList();
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
            ElevatedButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text("إضافة طفل جديد"),
                    content: Form(
                      key: _formKey,
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            TextFormField(
                              controller: _nameController,
                              decoration: const InputDecoration(labelText: "الاسم الكامل"),
                              validator: (value) => value!.isEmpty ? "الاسم مطلوب" : null,
                            ),
                            TextFormField(
                              controller: _ageController,
                              decoration: const InputDecoration(labelText: "العمر"),
                              keyboardType: TextInputType.number,
                            ),
                            TextFormField(
                              controller: _birthDateController,
                              decoration: const InputDecoration(labelText: "تاريخ الميلاد"),
                            ),
                            TextFormField(
                              controller: _phoneController,
                              decoration: const InputDecoration(labelText: "رقم الهاتف"),
                            ),
                            TextFormField(
                              controller: _diagnosisController,
                              decoration: const InputDecoration(labelText: "التشخيص"),
                            ),
                            TextFormField(
                              controller: _notesController,
                              decoration: const InputDecoration(labelText: "ملاحظات"),
                              maxLines: 3,
                            ),
                          ],
                        ),
                      ),
                    ),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(context), child: const Text("إلغاء")),
                      ElevatedButton(onPressed: _saveChild, child: const Text("حفظ")),
                    ],
                  ),
                );
              },
              child: const Text("إضافة طفل جديد"),
            ),
          ],
        ),
      ),
    );
  }
}
