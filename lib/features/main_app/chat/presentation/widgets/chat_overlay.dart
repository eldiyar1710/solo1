import 'package:flutter/material.dart';
import 'package:solo1/core/theme/glassmorphism.dart';

class ChatOverlay extends StatelessWidget {
  final Widget child;
  const ChatOverlay({super.key, required this.child});
  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final size = mq.size;
    final insets = mq.viewInsets;
    return AnimatedPadding(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOutCubic,
      padding: EdgeInsets.only(bottom: insets.bottom),
      child: Center(
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.94, end: 1),
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutBack,
          builder: (context, s, inner) => Transform.scale(scale: s, child: inner!),
          child: GlassContainer(
            borderRadius: const BorderRadius.all(Radius.circular(24)),
            blur: 12,
            opacity: 0.15,
            withBorder: true,
            child: SafeArea(
              child: SizedBox(
                width: size.width * 0.92,
                height: size.height * 0.82,
                child: child,
              ),
            ),
          ),
        ),
      ),
    );
  }
}