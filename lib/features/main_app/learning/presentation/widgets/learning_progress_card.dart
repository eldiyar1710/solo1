import 'package:flutter/material.dart';
import 'package:solo1/features/main_app/learning/domain/entities/learning_progress.dart';

class LearningProgressCard extends StatelessWidget {
  final LearningProgress progress;
  const LearningProgressCard({super.key, required this.progress});
  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Text('Прогресс: ${progress.percent}%', style: const TextStyle(color: Colors.white)),
      LinearProgressIndicator(value: progress.percent / 100),
    ]);
  }
}