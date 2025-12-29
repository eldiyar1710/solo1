import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:solo1/core/theme/glassmorphism.dart';
import 'package:solo1/features/main_app/profile/presentation/providers/profile_provider.dart';
import 'package:solo1/features/auth/presentation/controllers/auth_controller.dart';
import 'package:go_router/go_router.dart';
import 'package:solo1/core/routes/app_routes.dart';
import 'package:solo1/features/main_app/sales/presentation/providers/sales_provider.dart';
import 'package:intl/intl.dart';
import 'package:solo1/features/main_app/profile/presentation/providers/payouts_provider.dart';
import 'package:solo1/features/main_app/profile/data/models/payout_model.dart';

class MainProfileSection extends ConsumerWidget {
  const MainProfileSection({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(profileProvider);
    final auth = ref.watch(authControllerProvider);
    final sales = ref.watch(salesProvider);
    final payouts = ref.watch(payoutsProvider);
    ref.read(profileProvider.notifier).load();
    String fmt(int v) => NumberFormat('#,###', 'ru').format(v).replaceAll(',', ' ');
    String etaText(int ts) {
      final d = DateTime.fromMillisecondsSinceEpoch(ts);
      final now = DateTime.now();
      final days = d.difference(now).inDays;
      if (days <= 0) return 'Сегодня';
      return 'Через $days дней';
    }
    Future<void> showDetailsModal(String title, List<PayoutModel> items) async {
      await showDialog(
        context: context,
        barrierDismissible: true,
        builder: (ctx) {
          String query = '';
          String status = 'all';
          String range = 'all';
          bool filtersExpanded = false;
          int? minAmount;
          int? maxAmount;
          DateTimeRange? exactRange;
          int page = 0;
          const int pageSize = 10;
          return StatefulBuilder(builder: (ctx, setState) {
            List<PayoutModel> filtered() {
              final now = DateTime.now();
              DateTime? start;
              if (range == 'week') start = now.subtract(const Duration(days: 7));
              if (range == 'month') start = DateTime(now.year, now.month - 1, now.day);
              if (range == 'year') start = DateTime(now.year - 1, now.month, now.day);
              final q = query.trim().toLowerCase();
              final res = items.where((e) {
                final byStatus = status == 'all' ? true : e.status == status;
                final date = DateTime.fromMillisecondsSinceEpoch(e.date);
                final byQuickRange = start == null ? true : date.isAfter(start);
                final byExactRange = exactRange == null ? true : (date.isAfter(exactRange!.start) && date.isBefore(exactRange!.end));
                final byRange = exactRange != null ? byExactRange : byQuickRange;
                final byQuery = q.isEmpty ? true : (e.client.toLowerCase().contains(q));
                final byMin = minAmount == null ? true : e.amount >= minAmount!;
                final byMax = maxAmount == null ? true : e.amount <= maxAmount!;
                return byStatus && byRange && byQuery && byMin && byMax;
              }).toList()
                ..sort((a, b) => b.date.compareTo(a.date));
              return res;
            }
            final all = filtered();
            final totalPages = all.isEmpty ? 1 : ((all.length + pageSize - 1) ~/ pageSize);
            if (page >= totalPages) page = totalPages - 1;
            if (page < 0) page = 0;
            final pageItems = all.skip(page * pageSize).take(pageSize).toList();
            return Material(
              type: MaterialType.transparency,
              child: Center(
                child: GlassContainer(
                  padding: const EdgeInsets.all(20),
                  borderRadius: BorderRadius.circular(16),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 560, minWidth: 340),
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(child: Text(title, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800))),
                              IconButton(onPressed: () => Navigator.of(ctx).pop(), icon: const Icon(Icons.close, color: Colors.white)),
                            ],
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            onChanged: (v) => setState(() { query = v; page = 0; }),
                            decoration: InputDecoration(
                              hintText: 'Поиск клиента',
                              prefixIcon: const Icon(Icons.search),
                              suffixIcon: IconButton(onPressed: () => setState(() => filtersExpanded = !filtersExpanded), icon: const Icon(Icons.tune)),
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            ),
                          ),
                          const SizedBox(height: 10),
                          AnimatedCrossFade(
                            duration: const Duration(milliseconds: 200),
                            crossFadeState: filtersExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                            firstChild: const SizedBox.shrink(),
                            secondChild: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Wrap(spacing: 8, runSpacing: 8, children: [
                                  ChoiceChip(label: const Text('Все'), selected: range == 'all', onSelected: (_) => setState(() { range = 'all'; exactRange = null; page = 0; })),
                                  ChoiceChip(label: const Text('Неделя'), selected: range == 'week', onSelected: (_) => setState(() { range = 'week'; exactRange = null; page = 0; })),
                                  ChoiceChip(label: const Text('Месяц'), selected: range == 'month', onSelected: (_) => setState(() { range = 'month'; exactRange = null; page = 0; })),
                                  ChoiceChip(label: const Text('Год'), selected: range == 'year', onSelected: (_) => setState(() { range = 'year'; exactRange = null; page = 0; })),
                                  TextButton.icon(
                                    onPressed: () async {
                                      final picked = await showDateRangePicker(context: ctx, firstDate: DateTime(2020), lastDate: DateTime.now().add(const Duration(days: 365)), initialDateRange: exactRange);
                                      if (picked != null) setState(() { exactRange = picked; range = 'all'; page = 0; });
                                    },
                                    icon: const Icon(Icons.date_range),
                                    label: Text(exactRange == null ? 'Календарь' : '${DateFormat('dd.MM.yyyy').format(exactRange!.start)} — ${DateFormat('dd.MM.yyyy').format(exactRange!.end)}'),
                                  ),
                                ]),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Expanded(
                                      child: TextFormField(
                                        keyboardType: TextInputType.number,
                                        initialValue: minAmount?.toString() ?? '',
                                        onChanged: (v) => setState(() { minAmount = int.tryParse(v.replaceAll(' ', '')); page = 0; }),
                                        decoration: InputDecoration(
                                          hintText: 'Сумма от',
                                          filled: true,
                                          fillColor: Colors.white,
                                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: TextFormField(
                                        keyboardType: TextInputType.number,
                                        initialValue: maxAmount?.toString() ?? '',
                                        onChanged: (v) => setState(() { maxAmount = int.tryParse(v.replaceAll(' ', '')); page = 0; }),
                                        decoration: InputDecoration(
                                          hintText: 'Сумма до',
                                          filled: true,
                                          fillColor: Colors.white,
                                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Wrap(spacing: 8, runSpacing: 8, children: [
                                  ChoiceChip(label: const Text('Статус: все'), selected: status == 'all', onSelected: (_) => setState(() { status = 'all'; page = 0; })),
                                  ChoiceChip(label: const Text('Выплачено'), selected: status == 'paid', onSelected: (_) => setState(() { status = 'paid'; page = 0; })),
                                  ChoiceChip(label: const Text('Ожидается'), selected: status == 'pending', onSelected: (_) => setState(() { status = 'pending'; page = 0; })),
                                  TextButton(onPressed: () => setState(() { query = ''; status = 'all'; range = 'all'; exactRange = null; minAmount = null; maxAmount = null; page = 0; }), child: const Text('Сбросить')),
                                ]),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Найдено: ${all.length}', style: const TextStyle(color: Colors.white)),
                              Row(children: [
                                IconButton(onPressed: page > 0 ? () => setState(() { page--; }) : null, icon: const Icon(Icons.chevron_left, color: Colors.white)),
                                Text('${page + 1}/${totalPages}', style: const TextStyle(color: Colors.white)),
                                IconButton(onPressed: (page + 1) < totalPages ? () => setState(() { page++; }) : null, icon: const Icon(Icons.chevron_right, color: Colors.white)),
                              ]),
                            ],
                          ),
                          const SizedBox(height: 12),
                          ...pageItems.map((e) => Container(
                                margin: const EdgeInsets.only(bottom: 8),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: const [BoxShadow(color: Color(0x22000000), blurRadius: 10, offset: Offset(0, 5))]),
                                child: Row(children: [
                                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(e.client, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w600)), const SizedBox(height: 4), Text(DateFormat('dd.MM.yyyy', 'ru').format(DateTime.fromMillisecondsSinceEpoch(e.date)), style: const TextStyle(color: Colors.black54))])),
                                  Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                                    Text('${fmt(e.amount)} ₸', style: TextStyle(color: e.status == 'paid' ? const Color(0xFF2E7D32) : Colors.black, fontWeight: FontWeight.w800)),
                                    Container(
                                      margin: const EdgeInsets.only(top: 6),
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(color: e.status == 'paid' ? const Color(0xFFE8F5E9) : const Color(0xFFFFF3E0), borderRadius: BorderRadius.circular(999)),
                                      child: Text(e.status == 'paid' ? 'Выплачено' : 'Ожидается', style: TextStyle(color: e.status == 'paid' ? const Color(0xFF1B5E20) : const Color(0xFFEF6C00), fontWeight: FontWeight.w600)),
                                    ),
                                  ])
                                ]),
                              )),
                          const SizedBox(height: 8),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          });
        },
      );
    }
    final total = sales.items.fold<int>(0, (p, e) => p + e.monthlyPrice * e.quantity);
    final expected = (total * 0.62).round();
    final email = (auth.agent?.email ?? '').trim();
    final phone = (auth.agent?.phone ?? '').trim();
    final handle = email.contains('@') ? '@${email.split('@').first}' : '@agent';
    ref.read(payoutsProvider.notifier).load();
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: GlassContainer(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: const [Icon(Icons.person_outline, color: Colors.white), SizedBox(width: 8), Text('Профиль', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold))]),
              if (state.loading) const Padding(padding: EdgeInsets.only(top: 8), child: LinearProgressIndicator()),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: const [BoxShadow(color: Color(0x22000000), blurRadius: 12, offset: Offset(0, 6))]),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 56,
                          height: 56,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(colors: [Color(0xFF4A69FF), Color(0xFF00BFA5)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                          ),
                          alignment: Alignment.center,
                          child: Text(state.profile.name.isNotEmpty ? state.profile.name.trim().split(' ').map((e) => e.isNotEmpty ? e[0] : '').take(2).join().toUpperCase() : 'А', style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text(state.profile.name.isEmpty ? 'Агент' : state.profile.name, style: const TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.w700)),
                            const SizedBox(height: 4),
                            Text(handle, style: const TextStyle(color: Colors.black45)),
                          ]),
                        ),
                        const Icon(Icons.verified_outlined, color: Color(0xFF6A1B9A)),
                      ],
                    ),
                    const SizedBox(height: 10),
                    if (state.profile.agentId != null && state.profile.agentId!.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(color: const Color(0xFFE3F2FD), borderRadius: BorderRadius.circular(8)),
                        child: Text('ID: ${state.profile.agentId!}', style: const TextStyle(color: Color(0xFF1976D2), fontWeight: FontWeight.w600)),
                      ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            const Text('Email', style: TextStyle(color: Colors.black54)),
                            const SizedBox(height: 4),
                            Text(email.isEmpty ? '—' : email, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w600)),
                          ]),
                        ),
                        Expanded(
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            const Text('Телефон', style: TextStyle(color: Colors.black54)),
                            const SizedBox(height: 4),
                            Text(phone.isEmpty ? '—' : phone, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w600)),
                          ]),
                        ),
                      ],
                    ),
                    if ((auth.agent?.status == 'test') || ((auth.agent?.email ?? '').toLowerCase() == 'test@solo1.app'))
                      const Padding(
                        padding: EdgeInsets.only(top: 8),
                        child: Text('Тестовый аккаунт', style: TextStyle(color: Color(0xFFEF6C00), fontWeight: FontWeight.w600)),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: const [BoxShadow(color: Color(0x22000000), blurRadius: 12, offset: Offset(0, 6))]),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Row(children: const [Icon(Icons.account_balance_wallet, color: Color(0xFF2E7D32)), SizedBox(width: 8), Text('Баланс', style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600))]),
                        const SizedBox(height: 10),
                        Text('${fmt(total)} ₸', style: const TextStyle(color: Colors.black, fontSize: 22, fontWeight: FontWeight.w800)),
                        const SizedBox(height: 6),
                        InkWell(
                            onTap: () async {
                              await ref.read(payoutsProvider.notifier).load();
                              final current = ref.read(payoutsProvider).paid;
                              await showDetailsModal('История выплат', current);
                            },
                            child: const Text('История →', style: TextStyle(color: Colors.blue))),
                      ]),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: const [BoxShadow(color: Color(0x22000000), blurRadius: 12, offset: Offset(0, 6))]),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Row(children: const [Icon(Icons.schedule, color: Color(0xFFEF6C00)), SizedBox(width: 8), Text('Ожидается', style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600))]),
                        const SizedBox(height: 10),
                        Text('${fmt(expected)} ₸', style: const TextStyle(color: Colors.black, fontSize: 22, fontWeight: FontWeight.w800)),
                        const SizedBox(height: 6),
                        InkWell(
                            onTap: () async {
                              await ref.read(payoutsProvider.notifier).load();
                              final current = ref.read(payoutsProvider).pending;
                              await showDetailsModal('Ожидаемые выплаты', current);
                            },
                            child: const Text('Подробнее →', style: TextStyle(color: Colors.blue))),
                      ]),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text('Достижения', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: const [BoxShadow(color: Color(0x22000000), blurRadius: 12, offset: Offset(0, 6))]),
                child: Row(children: const [Icon(Icons.school, color: Color(0xFF374151)), SizedBox(width: 12), Expanded(child: Text('Диплом агента', style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600))), Text('15.11.2025', style: TextStyle(color: Colors.black54))]),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: const [BoxShadow(color: Color(0x22000000), blurRadius: 12, offset: Offset(0, 6))]),
                child: Row(children: [
                  const Icon(Icons.emoji_events, color: Color(0xFFF59E0B)),
                  const SizedBox(width: 12),
                  const Expanded(child: Text('Топ месяца', style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600))),
                  Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6), decoration: BoxDecoration(color: const Color(0xFFFDE68A), borderRadius: BorderRadius.circular(999)), child: const Text('+2%', style: TextStyle(color: Color(0xFF92400E), fontWeight: FontWeight.w600))),
                  const SizedBox(width: 10),
                  const Text('01.11.2025', style: TextStyle(color: Colors.black54)),
                ]),
              ),
              const SizedBox(height: 16),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: const [BoxShadow(color: Color(0x22000000), blurRadius: 12, offset: Offset(0, 6))]),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: const [Icon(Icons.credit_card, color: Colors.black54), SizedBox(width: 8), Expanded(child: Text('Банковская карта', style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600))), Text('Изменить', style: TextStyle(color: Colors.blue))]),
              const SizedBox(height: 12),
              TextFormField(initialValue: payouts.card ?? '**** **** **** 1234', onFieldSubmitted: (v) => ref.read(payoutsProvider.notifier).saveCard(v.trim()), decoration: InputDecoration(border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)), contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14))),
                ]),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: const [BoxShadow(color: Color(0x22000000), blurRadius: 12, offset: Offset(0, 6))]),
                child: Row(children: const [Icon(Icons.info_outline), SizedBox(width: 8), Expanded(child: Text('О компании Amanbai Tech', style: TextStyle(color: Colors.black)))]),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () async {
                  await ref.read(authControllerProvider.notifier).logout();
                  if (context.mounted) context.go(AppRoutes.preHome);
                },
                icon: const Icon(Icons.logout),
                label: const Text('Выйти'),
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFD32F2F), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              ),
            ],
          ),
        ),
      ),
    );
  }
}