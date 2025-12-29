import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:solo1/core/theme/glassmorphism.dart';
import 'package:solo1/features/preauth/pre_learning/presentation/providers/pre_learning_provider.dart';

class LearningTestOverlay extends StatefulWidget {
  const LearningTestOverlay({super.key});
  @override
  State<LearningTestOverlay> createState() => _LearningTestOverlayState();
}

class _LearningTestOverlayState extends State<LearningTestOverlay> {
  String? selected;
  bool _visible = false;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => setState(() => _visible = true));
  }
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: Padding(
        padding: const EdgeInsets.only(top: 24),
        child: AnimatedOpacity(
          opacity: _visible ? 1 : 0,
          duration: const Duration(milliseconds: 200),
          child: AnimatedScale(
            scale: _visible ? 1 : 0.94,
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutBack,
            child: GlassContainer(
              padding: const EdgeInsets.all(20),
              borderRadius: BorderRadius.circular(20),
              child: Consumer(builder: (ctx, ref, _) {
                final t = ref.watch(learningTestProvider);
                final c = ref.read(learningTestProvider.notifier);
                final idx = t.currentQuestion - 1;
                final q = c.questions[idx];
                final total = c.questions.length;
                return Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [const Icon(Icons.psychology_outlined, color: Colors.white), const SizedBox(width: 8), const Expanded(child: Text('Тестирование', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold))), IconButton(onPressed: () => ref.read(learningTestProvider.notifier).cancelTesting(), icon: const Icon(Icons.close, color: Colors.white54))]),
                  const SizedBox(height: 6),
                  const Text('Ответьте на вопросы. Минимальный балл: 80%', style: TextStyle(color: Colors.white70)),
                  const SizedBox(height: 12),
                  Row(children: [
                    Text('Вопрос ${t.currentQuestion} / $total', style: const TextStyle(color: Colors.white)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TweenAnimationBuilder<double>(
                        duration: const Duration(milliseconds: 420),
                        curve: Curves.easeOutCubic,
                        tween: Tween(begin: 0, end: (t.currentQuestion - 1) / total),
                        builder: (context, v, _) => LinearProgressIndicator(value: v),
                      ),
                    ),
                  ]),
                  const SizedBox(height: 12),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 260),
                    switchInCurve: Curves.easeOut,
                    switchOutCurve: Curves.easeIn,
                    transitionBuilder: (child, anim) => FadeTransition(
                      opacity: anim,
                      child: SlideTransition(position: Tween<Offset>(begin: const Offset(0, 0.02), end: Offset.zero).animate(anim), child: child),
                    ),
                    child: Text(q['q'] as String, key: ValueKey(idx), style: const TextStyle(color: Colors.white, fontSize: 16)),
                  ),
                  const SizedBox(height: 8),
                  Column(
                    children: List<Widget>.from((q['options'] as List<String>).map((o) => GestureDetector(
                          onTap: () => setState(() => selected = o),
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1A1A2E),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: selected == o ? const Color(0xFF8B3EFF) : const Color(0x338B3EFF)),
                            ),
                            child: Row(
                              children: [
                                Icon(selected == o ? Icons.radio_button_checked : Icons.radio_button_unchecked, color: Colors.white),
                                const SizedBox(width: 8),
                                Expanded(child: Text(o, style: const TextStyle(color: Colors.white))),
                              ],
                            ),
                          ),
                        ))),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: selected == null
                            ? null
                            : () {
                                c.answerQuestion(selected!);
                                setState(() => selected = null);
                              },
                        child: const Text('Далее'),
                      )),
                ]);
              }),
            ),
          ),
        ),
      ),
    );
  }
}