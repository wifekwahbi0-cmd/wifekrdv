class Child {
  final int? id;
  final String name;
  final int? age;
  final String? birthDate;
  final String? phone;
  final String? diagnosis;
  final String? notes;

  Child({
    this.id,
    required this.name,
    this.age,
    this.birthDate,
    this.phone,
    this.diagnosis,
    this.notes,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'age': age,
      'birth_date': birthDate,
      'phone': phone,
      'diagnosis': diagnosis,
      'notes': notes,
    };
  }

  factory Child.fromMap(Map<String, dynamic> map) {
    return Child(
      id: map['id'],
      name: map['name'],
      age: map['age'],
      birthDate: map['birth_date'],
      phone: map['phone'],
      diagnosis: map['diagnosis'],
      notes: map['notes'],
    );
  }
}
