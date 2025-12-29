import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:solo1/core/theme/glassmorphism.dart';

class NotificationCard extends StatelessWidget {
  final String title;
  final String message;
  final DateTime date;
  final bool embedded;
  const NotificationCard({super.key, required this.title, required this.message, required this.date, this.embedded = false});
  @override
  Widget build(BuildContext context) {
    final d = DateFormat('d MMMM yyyy, HH:mm', 'ru').format(date);
    if (embedded) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(message, style: const TextStyle(color: Colors.white70)),
          const SizedBox(height: 8),
          Text(d, style: const TextStyle(color: Colors.white54, fontSize: 12)),
        ],
      );
    }
    return GlassContainer(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      borderRadius: BorderRadius.circular(16),
      opacity: 0.18,
      color: const Color(0xFF8E24AA),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0x33FFFFFF),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(Icons.warning_amber_rounded, color: Color(0xFFFFD54F)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                Text(message, style: const TextStyle(color: Colors.white70)),
                const SizedBox(height: 8),
                Text(d, style: const TextStyle(color: Colors.white54, fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}