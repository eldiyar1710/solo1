import 'package:flutter/material.dart';
import 'package:solo1/core/theme/glassmorphism.dart';

class IncreaseIncomeBlock extends StatelessWidget {
  final String title;
  final String text;
  const IncreaseIncomeBlock({super.key, required this.title, required this.text});

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      padding: const EdgeInsets.all(15),
      opacity: 0.1,
      borderRadius: BorderRadius.circular(15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.flash_on, color: Colors.purpleAccent, size: 20),
              const SizedBox(width: 8),
              Text(title, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 10),
          Text(text, style: const TextStyle(color: Colors.white70)),
        ],
      ),
    );
  }
}