import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:solo1/core/theme/glassmorphism.dart';
import 'package:solo1/features/main_app/home/presentation/providers/home_provider.dart';
import 'package:solo1/features/main_app/home/presentation/providers/home_notifications_provider.dart';
import 'package:solo1/features/main_app/home/presentation/widgets/home_banner_list.dart';
import 'package:solo1/features/main_app/home/presentation/widgets/notification_card.dart';
import 'package:solo1/features/main_app/home/presentation/widgets/leaderboard_section.dart';
import 'package:solo1/features/auth/presentation/controllers/auth_controller.dart';
import 'package:hive/hive.dart';
import 'package:solo1/features/main_app/chat/presentation/pages/chat_center_page.dart';

class MainHomeSection extends ConsumerStatefulWidget {
  const MainHomeSection({super.key});
  @override
  ConsumerState<MainHomeSection> createState() => _MainHomeSectionState();
}

class _MainHomeSectionState extends ConsumerState<MainHomeSection> {
  late final PageController _notifController;
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(homeProvider.notifier).load();
      ref.read(homeNotifierProvider.notifier).load();
      ref.read(homeNotifierProvider.notifier).watch();
      ref.read(authControllerProvider.notifier).loadCurrent();
    });
    _notifController = PageController(viewportFraction: 0.95);
  }
  @override
  void dispose() {
    _notifController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    
    final state = ref.watch(homeProvider);
    final notif = ref.watch(homeNotifierProvider);
    final auth = ref.watch(authControllerProvider);
    final boxNotif = Hive.box('notifications');
    final int? lastSeen = boxNotif.get('last_seen_at');
    final DateTime? latest = notif.notifications.isNotEmpty
        ? notif.notifications.map((e) => e.date).reduce((a, b) => a.isAfter(b) ? a : b)
        : null;
    final bool hasUnread = latest != null && (lastSeen == null || latest.millisecondsSinceEpoch > lastSeen);
    final int monthlyTarget = 20;
    final int monthlySold = 15;
    final double monthlyProgress = monthlyTarget > 0 ? monthlySold / monthlyTarget : 0;
    final int monthlyPercent = (monthlyProgress * 100).round();
    final now = DateTime.now();
    final lastDay = DateTime(now.year, now.month + 1, 1).subtract(const Duration(days: 1));
    final int daysLeft = lastDay.difference(DateTime(now.year, now.month, now.day)).inDays;
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16.0, 10.0, 16.0, 90.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFF4A69FF), Color(0xFF8E24AA)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                borderRadius: BorderRadius.circular(24),
              ),
              padding: const EdgeInsets.all(20),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  const Text('Главная', style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w800)),
                  const Spacer(),
                  GestureDetector(
                    onTap: () {
                      final int ts = latest?.millisecondsSinceEpoch ?? DateTime.now().millisecondsSinceEpoch;
                      boxNotif.put('last_seen_at', ts);
                      showDialog(
                        context: context,
                        barrierDismissible: true,
                        barrierColor: Colors.black54,
                        builder: (ctx) {
                          final size = MediaQuery.of(ctx).size;
                          return Center(
                            child: GlassContainer(
                              borderRadius: BorderRadius.circular(24),
                              blur: 12,
                              opacity: 0.18,
                              color: const Color(0xFF1A1442),
                              withBorder: false,
                              child: SizedBox(
                                width: size.width * 0.92,
                                height: size.height * 0.82,
                                child: ChatCenterPage(asOverlay: true),
                              ),
                            ),
                          );
                        },
                      );
                    },
                    child: Stack(alignment: Alignment.topRight, children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(14)),
                        child: const Icon(Icons.notifications, color: Colors.white),
                      ),
                      if (hasUnread)
                        Container(width: 18, height: 18, decoration: const BoxDecoration(color: Color(0xFFFFA726), shape: BoxShape.circle))
                    ]),
                  )
                ]),
                const SizedBox(height: 6),
                Text('ID: ${ref.watch(authControllerProvider).agent?.agentId ?? 'AG-XXXXXX'}', style: const TextStyle(color: Colors.white70, fontSize: 15)),
                const SizedBox(height: 16),
                Row(children: [
                  Expanded(
                    child: SizedBox(
                      height: 155,
                      child: GlassContainer(
                        borderRadius: BorderRadius.circular(20),
                        opacity: 0.18,
                        padding: const EdgeInsets.all(12),
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          const Icon(Icons.track_changes, color: Colors.white70),
                          const SizedBox(height: 6),
                          Text('$monthlySold', style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 2),
                          const Text('Продаж', style: TextStyle(color: Colors.white70)),
                          const SizedBox(height: 4),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(999),
                            child: Stack(children: [
                              const SizedBox(height: 6, width: double.infinity, child: ColoredBox(color: Color(0x33FFFFFF))),
                              FractionallySizedBox(widthFactor: monthlyProgress.clamp(0, 1), child: const SizedBox(height: 6, child: ColoredBox(color: Color(0xFF8E24AA)))),
                            ]),
                          ),
                          const SizedBox(height: 2),
                          Text('Цель: $monthlyTarget', style: const TextStyle(color: Colors.white54, fontSize: 12)),
                        ]),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: SizedBox(
                      height: 155,
                      child: GlassContainer(
                        borderRadius: BorderRadius.circular(20),
                        opacity: 0.18,
                        padding: const EdgeInsets.all(6),
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [
                          Icon(Icons.group, color: Colors.white70),
                          SizedBox(height: 6),
                          Text('60', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                          SizedBox(height: 2),
                          Text('Терминалов', style: TextStyle(color: Colors.white70)),
                          SizedBox(height: 4),
                          Text('+8 за неделю', style: TextStyle(color: Color(0xFF66BB6A))),
                        ]),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: SizedBox(
                      height: 155,
                      child: GlassContainer(
                        borderRadius: BorderRadius.circular(20),
                        opacity: 0.18,
                        padding: const EdgeInsets.all(8),
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [
                          Icon(Icons.local_fire_department, color: Colors.white70),
                          SizedBox(height: 6),
                          Text('3.5%', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                          SizedBox(height: 2),
                          Text('Процент', style: TextStyle(color: Colors.white70)),
                          SizedBox(height: 4),
                          Text('↑0.5% bonus', style: TextStyle(color: Color(0xFFFFD54F))),
                        ]),
                      ),
                    ),
                  ),
                ]),
                const SizedBox(height: 16),
                GlassContainer(
                  opacity: 0.18,
                  padding: const EdgeInsets.all(14),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(children: [const Icon(Icons.calendar_month, color: Colors.white70), const SizedBox(width: 8), const Text('Цель месяца', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)), const Spacer(), Chip(label: Text('$monthlyPercent%', style: const TextStyle(color: Colors.white)), backgroundColor: const Color(0xFF7E57C2))]),
                    const SizedBox(height: 10),
                    ClipRRect(borderRadius: BorderRadius.circular(999), child: Stack(children: [Container(height: 10, color: Colors.white24), FractionallySizedBox(widthFactor: monthlyProgress.clamp(0, 1), child: Container(height: 10, color: const Color(0xFF8E24AA)))])),
                    const SizedBox(height: 8),
                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('$monthlySold / $monthlyTarget продаж', style: const TextStyle(color: Colors.white70)), Text('осталось $daysLeft дней', style: const TextStyle(color: Colors.white70))]),
                  ]),
                ),
              ]),
            ),
            const SizedBox(height: 20),

            if (notif.loading) const CircularProgressIndicator(),
            if (!notif.loading && notif.error != null) const Text('Ошибка загрузки', style: TextStyle(color: Colors.redAccent)),
            if (!notif.loading && notif.error == null && notif.notifications.isEmpty)
              const Text('Нет уведомлений', style: TextStyle(color: Colors.white70)),
            if (!notif.loading && notif.error == null && notif.notifications.isNotEmpty)
              GlassContainer(
                borderRadius: BorderRadius.circular(24),
                padding: const EdgeInsets.all(16),
                opacity: 0.18,
                color: const Color(0xFF1A1442),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: const [
                        Icon(Icons.notifications_active, color: Color(0xFFFF4D4D)),
                        SizedBox(width: 8),
                        Icon(Icons.warning_amber_rounded, color: Color(0xFFFFD54F)),
                        SizedBox(width: 10),
                        Text('Важное уведомление', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 90,
                      child: PageView.builder(
                        controller: _notifController,
                        itemCount: notif.notifications.length,
                        onPageChanged: (i) {},
                        itemBuilder: (ctx, i) {
                          final e = notif.notifications[i];
                          return NotificationCard(title: e.title, message: e.message, date: e.date, embedded: true);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 20),
            GlassContainer(
              borderRadius: BorderRadius.circular(24),
              opacity: 0.18,
              color: const Color(0xFF1A1442),
              padding: const EdgeInsets.all(16),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: const [Icon(Icons.attach_money, color: Color(0xFF00E676)), SizedBox(width: 8), Text('Доход этой недели', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)), Spacer(), Chip(label: Text('+15%', style: TextStyle(color: Colors.white)), backgroundColor: Color(0xFF2ECC71))]),
                const SizedBox(height: 12),
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: const [Text('Получено', style: TextStyle(color: Colors.white70)), Text('25,500₸', style: TextStyle(color: Color(0xFF00E676), fontWeight: FontWeight.w700))]),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: Stack(children: [
                    Container(height: 10, color: Colors.white12),
                    FractionallySizedBox(
                      widthFactor: 0.7,
                      child: Container(
                        height: 10,
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(colors: [Color(0xFF7E57C2), Color(0xFF42A5F5)], begin: Alignment.centerLeft, end: Alignment.centerRight),
                        ),
                      ),
                    ),
                  ]),
                ),
                const SizedBox(height: 12),
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: const [Text('Ожидается', style: TextStyle(color: Colors.white70)), Text('17,000₸', style: TextStyle(color: Color(0xFF8E24AA), fontWeight: FontWeight.w700))]),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: Stack(children: [
                    Container(height: 10, color: Colors.white12),
                    FractionallySizedBox(widthFactor: 0.45, child: Container(height: 10, color: const Color(0xFF7E57C2))),
                  ]),
                ),
              ]),
            ),
            const SizedBox(height: 20),
            if (state.loading) const CircularProgressIndicator(),
            if (!state.loading) HomeBannerList(items: state.banners),
            const SizedBox(height: 20),
            const LeaderboardSection(),
            const SizedBox(height: 30),
            if (auth.loading) const LinearProgressIndicator(),
            if (!auth.loading && auth.agent != null)
              ListTile(
                leading: const Icon(Icons.verified_user, color: Colors.white),
                title: Text(auth.agent!.fullName, style: const TextStyle(color: Colors.white)),
                subtitle: Text(auth.agent!.email, style: const TextStyle(color: Colors.white70)),
              ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}