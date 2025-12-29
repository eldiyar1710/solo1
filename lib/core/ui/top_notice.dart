import 'package:flutter/material.dart';
import 'package:solo1/core/theme/glassmorphism.dart';

void showTopGlassNotice(BuildContext context, String message, {Duration duration = const Duration(seconds: 2)}) {
  final entry = OverlayEntry(
    builder: (_) => Positioned(
      left: 16,
      right: 16,
      top: MediaQuery.of(context).padding.top + 12,
      child: Material(
        color: Colors.transparent,
        child: GlassContainer(
          padding: const EdgeInsets.all(16),
          opacity: 0.15,
          borderRadius: BorderRadius.circular(12),
          child: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.redAccent),
              const SizedBox(width: 8),
              Expanded(child: Text(message, style: const TextStyle(color: Colors.redAccent))),
            ],
          ),
        ),
      ),
    ),
  );
  Overlay.of(context).insert(entry);
  Future.delayed(duration, () => entry.remove());
}