class Student {
  final int id;
  final String name;
  final int age;

  Student({required this.id, required this.name, required this.age});

  factory Student.fromJson(Map<String, dynamic> json) {
    return Student(
      id: json['id'] as int,
      name: json['name'] as String,
      age: json['age'] as int,
    );
  }
}
