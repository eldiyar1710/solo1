import 'package:flutter/material.dart';
import 'package:solo1/core/theme/glassmorphism.dart';

class BalanceCard extends StatelessWidget {
  final String title;
  final String value;
  final Color bgColor;
  final Color textColor;
  const BalanceCard({super.key, required this.title, required this.value, required this.bgColor, required this.textColor});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GlassContainer(
        padding: const EdgeInsets.all(15),
        opacity: 0.1,
        borderRadius: BorderRadius.circular(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(color: Colors.white70, fontSize: 14)),
            const SizedBox(height: 5),
            Text(value, style: TextStyle(color: textColor, fontSize: 24, fontWeight: FontWeight.w900)),
          ],
        ),
      ),
    );
  }
}