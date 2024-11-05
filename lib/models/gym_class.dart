class GymClass {
  final String name;
  final String instructor;
  final String schedule;
  bool isRegistered;

  GymClass({
    required this.name,
    required this.instructor,
    required this.schedule,
    this.isRegistered = false,
  });
}
