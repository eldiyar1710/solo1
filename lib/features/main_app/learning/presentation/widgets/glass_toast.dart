import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:solo1/core/theme/glassmorphism.dart';
import 'package:solo1/features/main_app/learning/presentation/providers/learning_provider.dart';

class GlassToast extends ConsumerStatefulWidget {
  const GlassToast({super.key});
  @override
  ConsumerState<GlassToast> createState() => _GlassToastState();
}

class _GlassToastState extends ConsumerState<GlassToast> {
  @override
  Widget build(BuildContext context) {
    final msg = ref.watch(toastProvider);
    if (msg == null || msg.isEmpty) return const SizedBox.shrink();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Future.delayed(const Duration(seconds: 5));
      ref.read(toastProvider.notifier).state = null;
    });
    return Align(
      alignment: Alignment.topCenter,
      child: Padding(
        padding: const EdgeInsets.only(top: 16),
        child: GlassContainer(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          borderRadius: BorderRadius.circular(16),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.info_outline, color: Colors.white70),
            const SizedBox(width: 8),
            Flexible(child: Text(msg, style: const TextStyle(color: Colors.white))),
          ]),
        ),
      ),
    );
  }
}