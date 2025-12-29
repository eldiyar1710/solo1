import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:solo1/core/theme/glassmorphism.dart';
import 'package:solo1/features/main_app/learning/presentation/providers/learning_provider.dart';
import 'package:solo1/features/preauth/pre_learning/presentation/providers/pre_learning_provider.dart';

class LearningResultOverlay extends ConsumerStatefulWidget {
  const LearningResultOverlay({super.key});
  @override
  ConsumerState<LearningResultOverlay> createState() => _LearningResultOverlayState();
}

class _LearningResultOverlayState extends ConsumerState<LearningResultOverlay> {
  bool _visible = true;
  bool _saved = false;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!_saved) {
        final t = ref.read(learningTestProvider);
        final id = ref.read(activeLessonIdProvider) ?? 'intro';
        ref.read(learningTestProvider.notifier).finishTesting();
        await ref.read(learningProvider.notifier).setLessonPercent(id, t.score.round());
        if (t.score < 80) {
          ref.read(toastProvider.notifier).state = 'Набрано мало баллов. Посмотрите видео внимательнее и попробуйте снова.';
        }
        _saved = true;
      }
      await Future.delayed(const Duration(seconds: 5));
      if (!mounted) return;
      setState(() => _visible = false);
      await Future.delayed(const Duration(milliseconds: 200));
      if (!mounted) return;
      ref.read(learningTestProvider.notifier).cancelTesting();
      ref.read(activeLessonIdProvider.notifier).state = null;
    });
  }
  @override
  Widget build(BuildContext context) {
    final t = ref.watch(learningTestProvider);
    return Align(
      alignment: Alignment.topCenter,
      child: Padding(
        padding: const EdgeInsets.only(top: 24),
        child: AnimatedOpacity(
          opacity: _visible ? 1 : 0,
          duration: const Duration(milliseconds: 180),
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.94, end: 1),
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutBack,
            builder: (ctx, scale, child) => Transform.scale(scale: scale, child: child!),
            child: GlassContainer(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              borderRadius: BorderRadius.circular(16),
              child: Row(children: [
                Icon(t.score >= 80 ? Icons.workspace_premium : Icons.info_outline, color: t.score >= 80 ? Colors.greenAccent : Colors.orangeAccent),
                const SizedBox(width: 10),
                Expanded(child: Text('Ваш результат: ${t.score.round()}%', style: const TextStyle(color: Colors.white))),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () async {
                    final id = ref.read(activeLessonIdProvider) ?? 'intro';
                    if (!_saved) {
                      ref.read(learningTestProvider.notifier).finishTesting();
                      await ref.read(learningProvider.notifier).setLessonPercent(id, t.score.round());
                      if (t.score < 80) {
                        ref.read(toastProvider.notifier).state = 'Набрано мало баллов. Посмотрите видео внимательнее и попробуйте снова.';
                      }
                      _saved = true;
                    }
                    ref.read(learningTestProvider.notifier).cancelTesting();
                    ref.read(activeLessonIdProvider.notifier).state = null;
                  },
                  child: Text(t.testPassed ? 'ОК' : 'Повторить позже'),
                ),
              ]),
            ),
          ),
        ),
      ),
    );
  }
}