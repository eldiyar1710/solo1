import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:solo1/l10n/l10n.dart';
import 'package:solo1/features/preauth/pre_home/presentation/providers/pre_home_provider.dart';
import 'package:solo1/core/theme/glassmorphism.dart';

class PreHomeMonthlyIncomePanel extends ConsumerStatefulWidget {
  const PreHomeMonthlyIncomePanel({super.key});
  @override
  ConsumerState<PreHomeMonthlyIncomePanel> createState() => _PreHomeMonthlyIncomePanelState();
}

class _PreHomeMonthlyIncomePanelState extends ConsumerState<PreHomeMonthlyIncomePanel> with TickerProviderStateMixin {
  int activeIndex = -1;
  late final AnimationController pulse;

  @override
  void initState() {
    super.initState();
    pulse = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))..repeat(reverse: true);
  }

  @override
  void dispose() {
    pulse.dispose();
    super.dispose();
  }

  String fmt(num n) {
    final s = n.toInt().toString();
    return s.replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]} ');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final state = ref.watch(preHomeProvider);
    final controller = ref.read(preHomeProvider.notifier);
    const appPrice = 20000.0;
    const commissionRate = 0.10;

    final monthlyPerConnection = appPrice * commissionRate;
    final base = monthlyPerConnection * state.connections;
    final months = ['Янв','Фев','Мар','Апр','Май','Июн','Июл','Авг','Сен','Окт','Ноя','Дек'];
    final k = state.payoutMonths / 36.0;
    final factors = List<double>.generate(months.length, (i) => (0.6 + (i/(months.length-1)) * 0.7) * k);
    final values = List<double>.generate(months.length, (i) => base * factors[i]);
    final avgIncome = values.reduce((a,b)=>a+b) / values.length;
    final growthPercent = ((values.last - values.first) / values.first * 100).clamp(-999, 999);

    if (activeIndex == -1) {
      final maxVal = values.reduce(math.max);
      activeIndex = values.indexOf(maxVal);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.ssid_chart_sharp, color: Colors.lightGreenAccent, size: 20),
            const SizedBox(width: 8),
            Expanded(child: Text(l10n.prehome_income_chart_title, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold))),
            _control(
              label: 'Продажи',
              value: state.connections,
              onDec: controller.decConnections,
              onInc: controller.incConnections,
            ),
            const SizedBox(width: 8),
            _control(
              label: 'Период',
              value: state.payoutMonths,
              suffix: 'мес.',
              onDec: controller.decPayoutMonths,
              onInc: controller.incPayoutMonths,
            ),
          ],
        ),
        const SizedBox(height: 15),
        GlassContainer(
          padding: const EdgeInsets.all(15),
          borderRadius: BorderRadius.circular(20),
          opacity: 0.16,
          color: const Color(0xFF1A1442).withValues(alpha: 0.18),
          withBorder: false,
          child: Column(
                children: [
              Row(
                children: [
                  const Expanded(
                    child: Text('Выберите месяц на графике', style: TextStyle(color: Colors.white54, fontSize: 13)),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.trending_up, color: Colors.white70, size: 16),
                      const SizedBox(width: 6),
                      Text('+${growthPercent.toStringAsFixed(0)} %', style: const TextStyle(color: Colors.white70, fontSize: 13)),
                    ],
                  ),
                ],
              ),
              SizedBox(
                height: 140,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: months.length,
                  itemBuilder: (ctx, i) {
                    final label = months[i];
                    final value = values[i];
                    final targetH = math.min(100.0, value / (base / 1.5));
                    final isActive = i == activeIndex;
                    final glowAlpha = isActive ? (0.25 + 0.25 * pulse.value) : 0.15;
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: GestureDetector(
                        onTap: () => setState(() { activeIndex = i; }),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 250),
                            child: isActive
                                ? TweenAnimationBuilder<double>(
                                    key: ValueKey<int>(value.toInt()),
                                    tween: Tween(begin: 0.0, end: 1.0),
                                    duration: const Duration(milliseconds: 250),
                                    curve: Curves.easeOut,
                                    builder: (ctx, t, child) => Transform.translate(offset: Offset(0, (1 - t) * 8), child: Opacity(opacity: t, child: child)),
                                    child: Stack(
                                      clipBehavior: Clip.none,
                                      alignment: Alignment.center,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(12),
                                            boxShadow: [
                                              BoxShadow(color: const Color(0xFFED3DEB).withValues(alpha: 0.35), blurRadius: 14, spreadRadius: 0.6),
                                            ],
                                            gradient: const LinearGradient(colors: [Color(0xFFED3DEB), Color(0xFF8E2DE2)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                                            border: Border.all(color: const Color(0xFFEDEDFE).withValues(alpha: 0.15), width: 1),
                                          ),
                                          child: Text('${fmt(value)} ₸', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700)),
                                        ),
                                        const Positioned(
                                          bottom: -10,
                                          child: CustomPaint(size: Size(24, 12), painter: _BubbleTailPainter()),
                                        ),
                                      ],
                                    ),
                                  )
                                : const SizedBox.shrink(),
                          ),
                          AnimatedSlide(
                            duration: const Duration(milliseconds: 200),
                            curve: Curves.easeOut,
                            offset: isActive ? Offset.zero : const Offset(0, 0.15),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                AnimatedContainer(
                                  duration: const Duration(milliseconds: 400),
                                  curve: Curves.easeInOutCubic,
                                  width: 36,
                                  height: targetH,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(15),
                                    boxShadow: [
                                      BoxShadow(color: (isActive ? const Color(0xFF8E2DE2) : const Color(0xFF5A5A6B)).withValues(alpha: glowAlpha), blurRadius: isActive ? 18 : 12, spreadRadius: 0.7),
                                    ],
                                    gradient: isActive
                                        ? const LinearGradient(colors: [Color(0xFF8E2DE2), Color(0xFF4A00E0)], begin: Alignment.topCenter, end: Alignment.bottomCenter)
                                        : const LinearGradient(colors: [Color(0xFF5A5A6B), Color(0xFF3F3F4F)], begin: Alignment.topCenter, end: Alignment.bottomCenter),
                                  ),
                                ),
                                Positioned.fill(
                                  child: IgnorePointer(
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(15),
                                        gradient: LinearGradient(colors: [Colors.white.withValues(alpha: 0.18), Colors.transparent], begin: Alignment.topLeft, end: Alignment.bottomCenter),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 2),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: isActive ? BoxDecoration(color: const Color(0x3342A5F5), borderRadius: BorderRadius.circular(8)) : null,
                            child: Text(label, style: TextStyle(color: isActive ? Colors.white : Colors.white70, fontSize: 11, fontWeight: isActive ? FontWeight.w600 : FontWeight.w400)),
                          ),
                        ],
                      ),
                    ),
                  );
                  },
                ),
              ),
              const SizedBox(height: 15),
              Row(
                children: [
                  Expanded(child: _statItem('${fmt(avgIncome)} ₸', 'Средний доход', bg: const Color(0x232C2C3D))),
                  const SizedBox(width: 10),
                  Expanded(child: _statItem('${fmt(values.sublist(values.length-6).reduce((a,b)=>a+b))} ₸', 'За полгода', bg: const Color(0x332A104B), accent: true)),
                  const SizedBox(width: 10),
                  Expanded(child: _statItem('${fmt((avgIncome*12))} ₸', 'Проекция/год', bg: const Color(0x232C2C3D))),
                ],
              ),
              const SizedBox(height: 8),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: Text('Параметры: ${state.connections} продаж • комиссия 10% • период выплат ${state.payoutMonths} мес.', key: ValueKey<String>('${state.connections}-${state.payoutMonths}'), style: const TextStyle(color: Colors.white54, fontSize: 12)),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _control({required String label, required int value, String? suffix, required VoidCallback onDec, required VoidCallback onInc}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(color: const Color(0xFF2C2C3D), borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          InkWell(onTap: onDec, child: const Icon(Icons.remove, color: Colors.white70, size: 18)),
          const SizedBox(width: 6),
          Text('$value${suffix!=null?' $suffix':''}', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
          const SizedBox(width: 6),
          InkWell(onTap: onInc, child: const Icon(Icons.add, color: Colors.white70, size: 18)),
        ],
      ),
    );
  }

  Widget _statItem(String mainText, String subText, {Color? bg, bool accent = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(color: bg ?? const Color(0x232C2C3D), borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          Text(mainText, style: TextStyle(color: accent ? const Color(0xFFFFB3F5) : Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
          Text(subText, style: const TextStyle(color: Colors.white70, fontSize: 12)),
        ],
      ),
    );
  }
}

class _BubbleTailPainter extends CustomPainter {
  const _BubbleTailPainter();
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final path = Path()
      ..moveTo(w * 0.5, h)
      ..quadraticBezierTo(w * 0.25, h * 0.6, 0, 0)
      ..lineTo(w, 0)
      ..quadraticBezierTo(w * 0.75, h * 0.6, w * 0.5, h)
      ..close();
    final paint = Paint()
      ..shader = const LinearGradient(colors: [Color(0xFFED3DEB), Color(0xFF8E2DE2)], begin: Alignment.topCenter, end: Alignment.bottomCenter)
          .createShader(Rect.fromLTWH(0, 0, w, h));
    canvas.drawPath(path, paint);
    final border = Paint()
      ..color = const Color(0xFFEDEDFE).withValues(alpha: 0.18)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    canvas.drawPath(path, border);
  }
  @override
  bool shouldRepaint(covariant _BubbleTailPainter oldDelegate) => false;
}
