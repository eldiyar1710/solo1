import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:solo1/features/main_app/home/presentation/providers/home_leaderboard_provider.dart';

class LeaderboardSection extends ConsumerWidget {
  const LeaderboardSection({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final st = ref.watch(homeLeaderboardProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Рейтинг агентов', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        Row(
          children: [
            _periodChip(context, ref, 'Неделя', 'week', st.period == 'week'),
            const SizedBox(width: 8),
            _periodChip(context, ref, 'Месяц', 'month', st.period == 'month'),
            const SizedBox(width: 8),
            _periodChip(context, ref, 'Год', 'year', st.period == 'year'),
          ],
        ),
        const SizedBox(height: 12),
        if (st.loading) const CircularProgressIndicator(),
        if (!st.loading && st.error != null) const Text('Ошибка загрузки', style: TextStyle(color: Colors.redAccent)),
        if (!st.loading && st.error == null && st.ranks.isEmpty) const Text('Нет данных', style: TextStyle(color: Colors.white70)),
        if (!st.loading && st.error == null && st.ranks.isNotEmpty)
          Column(
            children: st.ranks
                .map(
                  (e) => Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: const [BoxShadow(color: Color(0x22000000), blurRadius: 12, offset: Offset(0, 6))]),
                    child: Row(
                      children: [
                        const Icon(Icons.emoji_events, color: Color(0xFFF59E0B)),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text(e.name, style: const TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.w600)),
                            const SizedBox(height: 4),
                            Text('${e.sales} продаж', style: const TextStyle(color: Colors.black54)),
                          ]),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(color: const Color(0xFFFDE68A), borderRadius: BorderRadius.circular(999)),
                          child: Text('+${e.bonusPercent.toStringAsFixed(1)}%', style: const TextStyle(color: Color(0xFF92400E), fontWeight: FontWeight.w600)),
                        ),
                        const SizedBox(width: 12),
                        Text('#${e.rank}', style: const TextStyle(color: Color(0xFF2563EB), fontSize: 18, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                )
                .toList(),
          ),
      ],
    );
  }

  Widget _periodChip(BuildContext context, WidgetRef ref, String label, String period, bool selected) {
    return GestureDetector(
      onTap: () => ref.read(homeLeaderboardProvider.notifier).load(period),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF2563EB) : Colors.white.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(999),
          boxShadow: const [BoxShadow(color: Color(0x22000000), blurRadius: 8, offset: Offset(0, 4))],
        ),
        child: Text(label, style: TextStyle(color: selected ? Colors.white : Colors.black87, fontWeight: FontWeight.w600)),
      ),
    );
  }
}