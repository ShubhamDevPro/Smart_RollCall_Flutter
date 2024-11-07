class Student {
  final String name;
  final String rollNumber;
  bool isPresent;

  Student(
      {required this.name, required this.rollNumber, this.isPresent = false});
}