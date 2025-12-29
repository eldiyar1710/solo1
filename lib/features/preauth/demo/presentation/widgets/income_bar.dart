import 'package:flutter/material.dart';

class IncomeBar extends StatelessWidget {
  final String monthLabel;
  final double income;
  final double maxIncome;
  const IncomeBar({super.key, required this.monthLabel, required this.income, required this.maxIncome});

  @override
  Widget build(BuildContext context) {
    final percentage = income / maxIncome;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(monthLabel, style: const TextStyle(color: Colors.white70)),
          Text('${income.toInt()} ₸', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 15.0),
              child: LinearProgressIndicator(
                value: percentage.clamp(0.1, 1.0),
                backgroundColor: Colors.white12,
                valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF6A1B9A)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}