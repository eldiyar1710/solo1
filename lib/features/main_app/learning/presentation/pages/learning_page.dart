import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:solo1/features/main_app/learning/presentation/providers/learning_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:solo1/features/preauth/pre_learning/presentation/providers/pre_learning_provider.dart';
import 'package:solo1/features/main_app/learning/presentation/widgets/learning_test_overlay.dart';
import 'package:solo1/features/main_app/learning/presentation/widgets/learning_result_overlay.dart';
import 'package:solo1/features/main_app/learning/presentation/widgets/glass_toast.dart';
import 'package:solo1/features/main_app/learning/presentation/widgets/lesson_card.dart';
import 'package:solo1/features/main_app/learning/presentation/widgets/all_completed_banner.dart';
import 'package:solo1/features/main_app/learning/presentation/widgets/docs_modal.dart';
import 'package:solo1/features/main_app/learning/presentation/widgets/status_card.dart';
import 'package:solo1/features/main_app/learning/presentation/widgets/lesson_questions.dart';
import 'package:solo1/features/main_app/learning/domain/entities/lesson.dart';

class MainLearningSection extends ConsumerWidget {
  const MainLearningSection({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progressState = ref.watch(learningProvider);
    ref.read(learningProvider.notifier).load();
    final t = ref.watch(learningTestProvider);
    final lessonsProgress = ref.watch(lessonsProgressProvider).maybeWhen(data: (m) => m, orElse: () => const <String, int>{});
    final lessonsBase = _defaultLessons
        .map((e) => Lesson(id: e.id, title: e.title, difficulty: e.difficulty, duration: e.duration, questions: e.questions, completedPercent: lessonsProgress[e.id] ?? e.completedPercent, locked: e.locked))
        .toList();
    final lessons = <Lesson>[];
    for (var i = 0; i < lessonsBase.length; i++) {
      final prevOk = i == 0 ? true : ((lessonsBase[i - 1].completedPercent ?? 0) >= 80);
      lessons.add(Lesson(
        id: lessonsBase[i].id,
        title: lessonsBase[i].title,
        difficulty: lessonsBase[i].difficulty,
        duration: lessonsBase[i].duration,
        questions: lessonsBase[i].questions,
        completedPercent: lessonsBase[i].completedPercent,
        locked: !prevOk,
      ));
    }
    final completedCount = lessons.where((e) => (e.completedPercent ?? 0) >= 80).length;
    return Stack(children: [
      SingleChildScrollView(
        physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _ProgressHeader(totalLessons: lessons.length, completedLessons: completedCount, percent: progressState.progress.percent.toDouble()),
          const SizedBox(height: 16),
          LessonCard(lesson: lessons[0], onWatch: () async {
            final uri = Uri.parse('https://www.youtube.com/watch?v=BaW_jenozKc');
            if (await canLaunchUrl(uri)) await launchUrl(uri, mode: LaunchMode.externalApplication);
          }, onTest: () {
            final id = lessons[0].id;
            ref.read(activeLessonIdProvider.notifier).state = id;
            final qs = lessonQuestions[id] ?? ref.read(learningTestProvider.notifier).questions;
            ref.read(learningTestProvider.notifier).startTestingWith(qs);
          }),
          const SizedBox(height: 12),
          ...lessons.skip(1).map((l) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: LessonCard(lesson: l, onWatch: () {}, onTest: () {
                  final id = l.id;
                  ref.read(activeLessonIdProvider.notifier).state = id;
                  final qs = lessonQuestions[id] ?? ref.read(learningTestProvider.notifier).questions;
                  ref.read(learningTestProvider.notifier).startTestingWith(qs);
                }),
              )),
          const SizedBox(height: 24),
          if (completedCount == lessons.length)
            (
              ref.watch(docsSubmittedProvider)
                  ? StatusCard(
                      icon: Icons.chat_bubble_outline,
                      title: 'Документы на проверке',
                      subtitle: 'Модератор свяжется с вами в ближайшее время',
                      circleColor: const Color(0xFF22C55E),
                      onTap: () => ref.read(sendDocsOverlayVisibleProvider.notifier).state = true,
                    )
                  : const AllCompletedBanner()
            ),
        ]),
      ),
      if (t.isTesting) const LearningTestOverlay(),
      if (!t.isTesting && (ref.watch(activeLessonIdProvider) != null)) const LearningResultOverlay(),
      if (ref.watch(sendDocsOverlayVisibleProvider)) const DocsModal(),
      const GlassToast(),
    ]);
  }
}

class _ProgressHeader extends StatelessWidget {
  final int totalLessons;
  final int completedLessons;
  final double percent;
  const _ProgressHeader({required this.totalLessons, required this.completedLessons, required this.percent});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF42A5F5), Color(0xFF8B3EFF)], begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Обучение', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Row(children: [
          const Icon(Icons.psychology_alt, color: Colors.white),
          const SizedBox(width: 8),
          Text('Пройдено $completedLessons из $totalLessons уроков', style: const TextStyle(color: Colors.white)),
          const Spacer(),
          Text('${percent.toStringAsFixed(0)}%', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ]),
        const SizedBox(height: 8),
        LinearProgressIndicator(value: percent / 100, color: Colors.white, backgroundColor: Colors.white24),
        const SizedBox(height: 8),
        Row(children: const [Icon(Icons.star_border, color: Colors.white), SizedBox(width: 6), Text('0 тестов пройдено', style: TextStyle(color: Colors.white70)), Spacer(), Icon(Icons.schedule, color: Colors.white), SizedBox(width: 6), Text('~75 мин осталось', style: TextStyle(color: Colors.white70))]),
      ]),
    );
  }
}


const _defaultLessons = [
  Lesson(id: 'intro', title: 'Введение в продажу терминалов', difficulty: 'Легко', duration: '15 мин', questions: 5, completedPercent: null, locked: false),
  Lesson(id: 'finding', title: 'Как находить клиентов', difficulty: 'Средне', duration: '20 мин', questions: 5, completedPercent: null, locked: true),
  Lesson(id: 'techniques', title: 'Техника эффективных продаж', difficulty: 'Сложно', duration: '25 мин', questions: 5, completedPercent: null, locked: true),
  Lesson(id: 'objections', title: 'Работа с возражениями', difficulty: 'Средне', duration: '18 мин', questions: 5, completedPercent: null, locked: true),
  Lesson(id: 'closing', title: 'Заключение сделки', difficulty: 'Сложно', duration: '22 мин', questions: 5, completedPercent: null, locked: true),
];

// moved to widgets/lesson_card.dart

// moved to widgets/send_docs_button.dart

// moved to widgets/all_completed_banner.dart