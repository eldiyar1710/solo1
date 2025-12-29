import 'package:flutter/material.dart';
import '../../domain/entities/sale.dart';

class SalesSummaryCard extends StatelessWidget {
  final List<Sale> items;
  const SalesSummaryCard({super.key, required this.items});
  @override
  Widget build(BuildContext context) {
    final total = items.fold<int>(0, (p, e) => p + e.monthlyPrice * e.quantity);
    return Column(children: [
      Text('Продаж: ${items.length}', style: const TextStyle(color: Colors.white)),
      Text('Сумма/мес: $total ₸', style: const TextStyle(color: Colors.white70)),
    ]);
  }
}