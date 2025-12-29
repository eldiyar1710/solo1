// lib/core/theme/glassmorphism.dart

import 'package:flutter/material.dart';
import 'dart:ui';

/// Виджет, реализующий эффект Glassmorphism (эффект матового стекла).
class GlassContainer extends StatelessWidget {
  final Widget child;
  final double blur;
  final double opacity;
  final Color? color;
  final bool withBorder;
  final BorderRadius borderRadius;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;

  const GlassContainer({
    super.key,
    required this.child,
    this.blur = 10,
    this.opacity = 0.2,
    this.color,
    this.withBorder = true,
    this.borderRadius = const BorderRadius.all(Radius.circular(15)),
    this.padding,
    this.margin,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: margin,
        // Обязательный ClipRRect для корректной работы BackdropFilter
        child: ClipRRect(
          borderRadius: borderRadius,
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
            child: Container(
              padding: padding,
              decoration: BoxDecoration(
                // Цвет контейнера с прозрачностью
                color: color ?? Colors.white.withValues(alpha: opacity),
                borderRadius: borderRadius,
                // Тонкая белая рамка для выделения "стекла"
                border: withBorder
                    ? Border.all(
                        color: Colors.white.withValues(alpha: 0.3),
                      )
                    : null,
              ),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}