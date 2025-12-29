class Lesson {
  final String id;
  final String title;
  final String difficulty;
  final String duration;
  final int questions;
  final int? completedPercent;
  final bool locked;
  const Lesson({
    required this.id,
    required this.title,
    required this.difficulty,
    required this.duration,
    required this.questions,
    this.completedPercent,
    this.locked = false,
  });
}