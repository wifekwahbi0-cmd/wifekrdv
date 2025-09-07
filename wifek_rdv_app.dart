import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';
import 'dart:io';

void main() {
  runApp(WifekRDVApp());
}

class WifekRDVApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Wifek RDV',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Arial',
        textTheme: TextTheme(
          bodyLarge: TextStyle(fontSize: 16),
          bodyMedium: TextStyle(fontSize: 14),
        ),
      ),
      home: LoginScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

// شاشة تسجيل الدخول
class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _codeController = TextEditingController();
  final String correctCode = '1110';

  void _checkCode() {
    if (_codeController.text == correctCode) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => DashboardScreen()),
      );
    } else {
      _showErrorDialog();
    }
  }

  void _showErrorDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('خطأ', textAlign: TextAlign.right),
        content: Text('الكود المدخل غير صحيح. يرجى المحاولة مرة أخرى.', textAlign: TextAlign.right),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('حسناً'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue.shade50,
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // الشعار
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.blue.shade700,
                  borderRadius: BorderRadius.circular(60),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.3),
                      spreadRadius: 5,
                      blurRadius: 7,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.medical_services,
                  size: 60,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 40),
              
              // العنوان
              Text(
                'عيادة تقويم النطق',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade800,
                ),
                textAlign: TextAlign.center,
              ),
              Text(
                'Wifek RDV',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.blue.shade600,
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 50),
              
              // حقل إدخال الكود
              Container(
                width: 300,
                child: TextField(
                  controller: _codeController,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 20, letterSpacing: 8),
                  decoration: InputDecoration(
                    hintText: 'أدخل الكود',
                    hintStyle: TextStyle(fontSize: 16, letterSpacing: 0),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.blue.shade300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.blue.shade700, width: 2),
                    ),
                    prefixIcon: Icon(Icons.lock, color: Colors.blue.shade600),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  onSubmitted: (value) => _checkCode(),
                ),
              ),
              SizedBox(height: 30),
              
              // زر الدخول
              ElevatedButton(
                onPressed: _checkCode,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade700,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 60, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 5,
                ),
                child: Text(
                  'دخول',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// فئة المريض
class Patient {
  int? id;
  String name;
  String phone;
  int age;
  String notes;

  Patient({
    this.id,
    required this.name,
    required this.phone,
    required this.age,
    required this.notes,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'age': age,
      'notes': notes,
    };
  }

  factory Patient.fromMap(Map<String, dynamic> map) {
    return Patient(
      id: map['id'],
      name: map['name'],
      phone: map['phone'],
      age: map['age'],
      notes: map['notes'],
    );
  }
}

// فئة الموعد
class Appointment {
  int? id;
  int patientId;
  String patientName;
  DateTime date;
  String time;
  String status;
  String notes;

  Appointment({
    this.id,
    required this.patientId,
    required this.patientName,
    required this.date,
    required this.time,
    required this.status,
    required this.notes,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'patientId': patientId,
      'patientName': patientName,
      'date': date.toIso8601String(),
      'time': time,
      'status': status,
      'notes': notes,
    };
  }

  factory Appointment.fromMap(Map<String, dynamic> map) {
    return Appointment(
      id: map['id'],
      patientId: map['patientId'],
      patientName: map['patientName'],
      date: DateTime.parse(map['date']),
      time: map['time'],
      status: map['status'],
      notes: map['notes'],
    );
  }
}

// قاعدة البيانات
class DatabaseHelper {
  static Database? _database;

  static Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  static Future<Database> _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, 'wifek_rdv.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  static Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE patients(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        phone TEXT NOT NULL,
        age INTEGER NOT NULL,
        notes TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE appointments(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        patientId INTEGER NOT NULL,
        patientName TEXT NOT NULL,
        date TEXT NOT NULL,
        time TEXT NOT NULL,
        status TEXT NOT NULL,
        notes TEXT,
        FOREIGN KEY (patientId) REFERENCES patients (id)
      )
    ''');
  }

  // عمليات المرضى
  static Future<int> insertPatient(Patient patient) async {
    final db = await database;
    return await db.insert('patients', patient.toMap());
  }

  static Future<List<Patient>> getPatients() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('patients');
    return List.generate(maps.length, (i) => Patient.fromMap(maps[i]));
  }

  static Future<int> updatePatient(Patient patient) async {
    final db = await database;
    return await db.update(
      'patients',
      patient.toMap(),
      where: 'id = ?',
      whereArgs: [patient.id],
    );
  }

  static Future<int> deletePatient(int id) async {
    final db = await database;
    // حذف المواعيد المرتبطة بالمريض أولاً
    await db.delete('appointments', where: 'patientId = ?', whereArgs: [id]);
    return await db.delete('patients', where: 'id = ?', whereArgs: [id]);
  }

  // عمليات المواعيد
  static Future<int> insertAppointment(Appointment appointment) async {
    final db = await database;
    return await db.insert('appointments', appointment.toMap());
  }

  static Future<List<Appointment>> getAppointments() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('appointments');
    return List.generate(maps.length, (i) => Appointment.fromMap(maps[i]));
  }

  static Future<int> updateAppointment(Appointment appointment) async {
    final db = await database;
    return await db.update(
      'appointments',
      appointment.toMap(),
      where: 'id = ?',
      whereArgs: [appointment.id],
    );
  }

  static Future<int> deleteAppointment(int id) async {
    final db = await database;
    return await db.delete('appointments', where: 'id = ?', whereArgs: [id]);
  }
}

// لوحة التحكم الرئيسية
class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;
  List<Patient> patients = [];
  List<Appointment> appointments = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final loadedPatients = await DatabaseHelper.getPatients();
    final loadedAppointments = await DatabaseHelper.getAppointments();
    setState(() {
      patients = loadedPatients;
      appointments = loadedAppointments;
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _logout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('تسجيل الخروج', textAlign: TextAlign.right),
        content: Text('هل تريد تسجيل الخروج من التطبيق؟', textAlign: TextAlign.right),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('إلغاء'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => LoginScreen()),
              );
            },
            child: Text('خروج'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> _widgetOptions = [
      OverviewTab(patients: patients, appointments: appointments),
      PatientsTab(patients: patients, onDataChanged: _loadData),
      AppointmentsTab(appointments: appointments, patients: patients, onDataChanged: _loadData),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text('عيادة تقويم النطق - Wifek RDV', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blue.shade700,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.logout, color: Colors.white),
            onPressed: _logout,
          ),
        ],
      ),
      body: _widgetOptions[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'نظرة عامة',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'المرضى',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'المواعيد',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue.shade700,
        onTap: _onItemTapped,
      ),
    );
  }
}

// تبويب النظرة العامة
class OverviewTab extends StatelessWidget {
  final List<Patient> patients;
  final List<Appointment> appointments;

  OverviewTab({required this.patients, required this.appointments});

  @override
  Widget build(BuildContext context) {
    final todayAppointments = appointments.where((apt) => 
      DateFormat('yyyy-MM-dd').format(apt.date) == DateFormat('yyyy-MM-dd').format(DateTime.now())
    ).toList();

    final pendingAppointments = appointments.where((apt) => apt.status == 'مجدول').length;
    final completedAppointments = appointments.where((apt) => apt.status == 'مكتمل').length;

    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'مرحباً بك في لوحة التحكم',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blue.shade800),
            textAlign: TextAlign.right,
          ),
          SizedBox(height: 20),
          
          // بطاقات الإحصائيات
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            childAspectRatio: 1.5,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            children: [
              _buildStatCard('إجمالي المرضى', patients.length.toString(), Icons.people, Colors.blue),
              _buildStatCard('إجمالي المواعيد', appointments.length.toString(), Icons.calendar_today, Colors.green),
              _buildStatCard('مواعيد اليوم', todayAppointments.length.toString(), Icons.today, Colors.orange),
              _buildStatCard('مواعيد مكتملة', completedAppointments.toString(), Icons.check_circle, Colors.purple),
            ],
          ),
          SizedBox(height: 30),
          
          // مواعيد اليوم
          Text(
            'مواعيد اليوم',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            textAlign: TextAlign.right,
          ),
          SizedBox(height: 10),
          
          todayAppointments.isEmpty
            ? Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(
                    child: Text(
                      'لا توجد مواعيد لليوم',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  ),
                ),
              )
            : ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: todayAppointments.length,
                itemBuilder: (context, index) {
                  final appointment = todayAppointments[index];
                  return Card(
                    child: ListTile(
                      leading: Icon(Icons.person, color: Colors.blue),
                      title: Text(appointment.patientName, textAlign: TextAlign.right),
                      subtitle: Text('${appointment.time} - ${appointment.status}', textAlign: TextAlign.right),
                      trailing: Icon(
                        appointment.status == 'مكتمل' ? Icons.check_circle : Icons.schedule,
                        color: appointment.status == 'مكتمل' ? Colors.green : Colors.orange,
                      ),
                    ),
                  );
                },
              ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 4,
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          gradient: LinearGradient(
            colors: [color.withOpacity(0.1), color.withOpacity(0.05)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: color),
            SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color),
            ),
            Text(
              title,
              style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// تبويب المرضى
class PatientsTab extends StatefulWidget {
  final List<Patient> patients;
  final VoidCallback onDataChanged;

  PatientsTab({required this.patients, required this.onDataChanged});

  @override
  _PatientsTabState createState() => _PatientsTabState();
}

class _PatientsTabState extends State<PatientsTab> {
  void _addPatient() {
    showDialog(
      context: context,
      builder: (context) => PatientDialog(
        onSave: (patient) async {
          await DatabaseHelper.insertPatient(patient);
          widget.onDataChanged();
        },
      ),
    );
  }

  void _editPatient(Patient patient) {
    showDialog(
      context: context,
      builder: (context) => PatientDialog(
        patient: patient,
        onSave: (updatedPatient) async {
          await DatabaseHelper.updatePatient(updatedPatient);
          widget.onDataChanged();
        },
      ),
    );
  }

  void _deletePatient(Patient patient) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('حذف المريض', textAlign: TextAlign.right),
        content: Text('هل تريد حذف ${patient.name}؟ سيتم حذف جميع مواعيده أيضاً.', textAlign: TextAlign.right),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('إلغاء'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await DatabaseHelper.deletePatient(patient.id!);
              widget.onDataChanged();
            },
            child: Text('حذف', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.patients.isEmpty
        ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.people_outline, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'لا توجد مرضى مسجلين',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
              ],
            ),
          )
        : ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: widget.patients.length,
            itemBuilder: (context, index) {
              final patient = widget.patients[index];
              return Card(
                margin: EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.blue.shade100,
                    child: Text(
                      patient.name.substring(0, 1),
                      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue.shade700),
                    ),
                  ),
                  title: Text(patient.name, textAlign: TextAlign.right),
                  subtitle: Text('العمر: ${patient.age} - الهاتف: ${patient.phone}', textAlign: TextAlign.right),
                  trailing: PopupMenuButton(
                    onSelected: (value) {
                      if (value == 'edit') {
                        _editPatient(patient);
                      } else if (value == 'delete') {
                        _deletePatient(patient);
                      }
                    },
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit, size: 18),
                            SizedBox(width: 8),
                            Text('تعديل'),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, size: 18, color: Colors.red),
                            SizedBox(width: 8),
                            Text('حذف', style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addPatient,
        backgroundColor: Colors.blue.shade700,
        child: Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

// حوار إضافة/تعديل المريض
class PatientDialog extends StatefulWidget {
  final Patient? patient;
  final Function(Patient) onSave;

  PatientDialog({this.patient, required this.onSave});

  @override
  _PatientDialogState createState() => _PatientDialogState();
}

class _PatientDialogState extends State<PatientDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _ageController;
  late TextEditingController _notesController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.patient?.name ?? '');
    _phoneController = TextEditingController(text: widget.patient?.phone ?? '');
    _ageController = TextEditingController(text: widget.patient?.age.toString() ?? '');
    _notesController = TextEditingController(text: widget.patient?.notes ?? '');
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        widget.patient == null ? 'إضافة مريض جديد' : 'تعديل بيانات المريض',
        textAlign: TextAlign.right,
      ),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'الاسم',
                  border: OutlineInputBorder(),
                ),
                textAlign: TextAlign.right,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'يرجى إدخال الاسم';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                decoration: InputDecoration(
                  labelText: 'رقم الهاتف',
                  border: OutlineInputBorder(),
                ),
                textAlign: TextAlign.right,
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'يرجى إدخال رقم الهاتف';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _ageController,
                decoration: InputDecoration(
                  labelText: 'العمر',
                  border: OutlineInputBorder(),
                ),
                textAlign: TextAlign.right,
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'يرجى إدخال العمر';
                  }
                  if (int.tryParse(value) == null) {
                    return 'يرجى إدخال عمر صحيح';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _notesController,
                decoration: InputDecoration(
                  labelText: 'ملاحظات',
                  border: OutlineInputBorder(),
                ),
                textAlign: TextAlign.right,
                maxLines: 3,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('إلغاء'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              final patient = Patient(
                id: widget.patient?.id,
                name: _nameController.text,
                phone: _phoneController.text,
                age: int.parse(_ageController.text),
                notes: _notesController.text,
              );
              widget.onSave(patient);
              Navigator.pop(context);
            }
          },
          child: Text('حفظ'),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _ageController.dispose();
    _notesController.dispose();
    super.dispose();
  }
}

// تبويب المواعيد
class AppointmentsTab extends StatefulWidget {
  final List<Appointment> appointments;
  final List<Patient> patients;
  final VoidCallback onDataChanged;

  AppointmentsTab({required this.appointments, required this.patients, required this.onDataChanged});

  @override
  _AppointmentsTabState createState() => _AppointmentsTabState();
}

class _AppointmentsTabState extends State<AppointmentsTab> {
  void _addAppointment() {
    if (widget.patients.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('يجب إضافة مريض واحد على الأقل قبل حجز موعد'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AppointmentDialog(
        patients: widget.patients,
        onSave: (appointment) async {
          await DatabaseHelper.insertAppointment(appointment);
          widget.onDataChanged();
        },
      ),
    );
  }

  void _editAppointment(Appointment appointment) {
    showDialog(
      context: context,
      builder: (context) => AppointmentDialog(
        appointment: appointment,
        patients: widget.patients,
        onSave: (updatedAppointment) async {
          await DatabaseHelper.updateAppointment(updatedAppointment);
          widget.onDataChanged();
        },
      ),
    );
  }

  void _deleteAppointment(Appointment appointment) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('حذف الموعد', textAlign: TextAlign.right),
        content: Text('هل تريد حذف موعد ${appointment.patientName}؟', textAlign: TextAlign.right),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('إلغاء'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await DatabaseHelper.deleteAppointment(appointment.id!);
              widget.onDataChanged();
            },
            child: Text('حذف', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'مجدول':
        return Colors.blue;
      case 'مكتمل':
        return Colors.green