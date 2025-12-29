import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:solo1/features/main_app/learning/domain/entities/lesson.dart';

class LessonCard extends StatelessWidget {
  final Lesson lesson;
  final VoidCallback onWatch;
  final VoidCallback onTest;
  const LessonCard({super.key, required this.lesson, required this.onWatch, required this.onTest});
  @override
  Widget build(BuildContext context) {
    final completed = lesson.completedPercent;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.94, end: 1),
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutBack,
      builder: (ctx, scale, child) => Transform.scale(scale: scale, child: child!),
      child: Stack(children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: const Color(0xFF1A1A2E), borderRadius: BorderRadius.circular(16), boxShadow: const [BoxShadow(color: Color(0x40000000), blurRadius: 24)], border: Border.all(color: const Color(0x4D8B3EFF))),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Container(width: 44, height: 44, decoration: BoxDecoration(color: const Color(0xFF2C2C3D), borderRadius: BorderRadius.circular(12)), child: Icon(completed != null ? Icons.check_circle : (lesson.locked ? Icons.lock : Icons.play_circle_outline), color: completed != null ? Colors.greenAccent : Colors.white)),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(lesson.title, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                Wrap(spacing: 8, runSpacing: 6, crossAxisAlignment: WrapCrossAlignment.center, children: const [
                  Icon(Icons.ondemand_video, color: Colors.white54, size: 18),
                  SizedBox(width: 4),
                ]),
                Wrap(spacing: 8, runSpacing: 6, crossAxisAlignment: WrapCrossAlignment.center, children: [
                  Text(lesson.duration, style: const TextStyle(color: Colors.white54)),
                  const SizedBox(width: 12),
                  const Icon(Icons.help_outline, color: Colors.white54, size: 18),
                  const SizedBox(width: 4),
                  Text('${lesson.questions} вопросов', style: const TextStyle(color: Colors.white54)),
                ]),
              ])),
              Flexible(
                child: Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  alignment: WrapAlignment.end,
                  children: [
                    Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6), decoration: BoxDecoration(gradient: _difficultyGradient(lesson.difficulty), borderRadius: BorderRadius.circular(20), boxShadow: const [BoxShadow(color: Color(0x408B3EFF), blurRadius: 12)]), child: Text(lesson.difficulty, style: const TextStyle(color: Colors.white))),
                    if (completed != null && completed >= 80)
                      Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6), decoration: BoxDecoration(color: const Color(0x3327AE60), border: Border.all(color: const Color(0x6627AE60)), borderRadius: BorderRadius.circular(20)), child: Text('$completed%', style: const TextStyle(color: Color(0xFF2ECC71))))
                  ],
                ),
              ),
            ]),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(child: OutlinedButton(onPressed: onWatch, child: const Text('Смотреть'))),
              const SizedBox(width: 12),
              Expanded(child: ElevatedButton(onPressed: lesson.locked ? null : onTest, child: Text(completed != null ? 'Повторить тест' : 'Тест'))),
            ]),
          ]),
        ),
        if (lesson.locked)
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
                child: Container(
                  decoration: BoxDecoration(color: const Color(0xFF000000).withValues(alpha: 0.35), borderRadius: BorderRadius.circular(16)),
                  alignment: Alignment.center,
                  child: Row(mainAxisSize: MainAxisSize.min, children: const [
                    Icon(Icons.lock, color: Colors.white70),
                    SizedBox(width: 8),
                    Text('Недоступно', style: TextStyle(color: Colors.white70)),
                  ]),
                ),
              ),
            ),
          ),
      ]),
    );
  }
}

LinearGradient _difficultyGradient(String d) {
  switch (d) {
    case 'Легко':
      return const LinearGradient(colors: [Color(0xFF2ECC71), Color(0xFF00D4B4)]);
    case 'Средне':
      return const LinearGradient(colors: [Color(0xFF6C63FF), Color(0xFF7F53FF)]);
    default:
      return const LinearGradient(colors: [Color(0xFFFF3B6B), Color(0xFFFF6B97)]);
  }
}