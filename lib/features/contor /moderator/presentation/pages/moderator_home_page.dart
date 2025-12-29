import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:solo1/core/theme/glassmorphism.dart';
import 'package:solo1/features/contor%20/moderator/presentation/providers/moderator_requests_provider.dart';
import 'package:solo1/features/contor%20/moderator/presentation/widgets/moderator_header.dart';
import 'package:solo1/features/contor%20/moderator/presentation/widgets/moderator_request_item.dart';
import 'package:solo1/features/contor%20/moderator/domain/entities/moderator_request_entity.dart';
import 'package:solo1/features/auth/presentation/controllers/auth_controller.dart';
import 'package:solo1/features/main_app/chat/presentation/widgets/chat_list_tile.dart';
import 'package:go_router/go_router.dart';
import 'package:solo1/core/routes/app_routes.dart';
const _allowedModeratorEmail = 'moderator@solo1.app';

class ModeratorHomePage extends ConsumerStatefulWidget {
  const ModeratorHomePage({super.key});
  @override
  ConsumerState<ModeratorHomePage> createState() => _ModeratorHomePageState();
}

class _ModeratorHomePageState extends ConsumerState<ModeratorHomePage> {
  int _tab = 0; // 0: Верификация, 1: Поддержка
  ModeratorRequestEntity? _checking;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(moderatorRequestsProvider.notifier).load();
    });
  }
  @override
  Widget build(BuildContext context) {
    final a = ref.watch(authControllerProvider).agent;
    final role = a?.role;
    final email = (a?.email ?? '').toLowerCase();
    if (role != 'moderator' || email != _allowedModeratorEmail) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) context.go(AppRoutes.preHome);
      });
      return const SizedBox.shrink();
    }
    final st = ref.watch(moderatorRequestsProvider);
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
      body: Stack(children: [
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(colors: [Color(0xFF141227), Color(0xFF2A184B)], begin: Alignment.topLeft, end: Alignment.bottomRight),
          ),
        ),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const ModeratorHeader(title: 'Модератор Панель'),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(1.4),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  gradient: const LinearGradient(colors: [Color(0x33FFFFFF), Color(0x1AFFFFFF)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                  boxShadow: const [BoxShadow(color: Color(0x22000000), blurRadius: 24, offset: Offset(0, 10))],
                ),
                child: GlassContainer(
                  borderRadius: BorderRadius.circular(22),
                  opacity: 0.14,
                  blur: 16,
                  child: Row(children: [
                    Expanded(
                      child: TextButton.icon(
                        onPressed: () => setState(() => _tab = 0),
                        icon: Icon(Icons.verified, color: _tab == 0 ? Colors.white : Colors.white54),
                        label: Text('Верификация', style: TextStyle(color: _tab == 0 ? Colors.white : Colors.white54, fontWeight: FontWeight.w600)),
                      ),
                    ),
                    Expanded(
                      child: TextButton.icon(
                        onPressed: () => setState(() => _tab = 1),
                        icon: Icon(Icons.support_agent, color: _tab == 1 ? Colors.white : Colors.white54),
                        label: Text('Поддержка', style: TextStyle(color: _tab == 1 ? Colors.white : Colors.white54, fontWeight: FontWeight.w600)),
                      ),
                    ),
                  ]),
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: _tab == 0
                    ? GlassContainer(
                        padding: const EdgeInsets.all(20),
                        borderRadius: BorderRadius.circular(20),
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          const Text('Входящие запросы', style: TextStyle(color: Colors.white70)),
                          const SizedBox(height: 12),
                          if (st.loading) const Center(child: CircularProgressIndicator()),
                          if (!st.loading && st.error != null) const Text('Ошибка загрузки', style: TextStyle(color: Colors.redAccent)),
                          if (!st.loading && st.error == null)
                            Expanded(
                              child: ListView.builder(
                                itemCount: st.items.length,
                                itemBuilder: (ctx, i) {
                                  final e = st.items[i];
                                  return ModeratorRequestItem(
                                    item: e,
                                    onApprove: () => ref.read(moderatorRequestsProvider.notifier).approveItem(e.id),
                                    onReject: () => ref.read(moderatorRequestsProvider.notifier).rejectItem(e.id),
                                    onContact: () {},
                                    onCheck: () => setState(() => _checking = e),
                                  );
                                },
                              ),
                            ),
                        ]),
                      )
                    : GlassContainer(
                        padding: const EdgeInsets.all(20),
                        borderRadius: BorderRadius.circular(20),
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          const Text('Поддержка агентов', style: TextStyle(color: Colors.white70)),
                          const SizedBox(height: 12),
                          Expanded(
                            child: Builder(builder: (ctx) {
                              if (st.loading) return const Center(child: CircularProgressIndicator());
                              if (st.error != null) return const Center(child: Text('Ошибка загрузки', style: TextStyle(color: Colors.redAccent)));
                              if (st.items.isEmpty) return const Center(child: Text('Нет обращений', style: TextStyle(color: Colors.white70)));
                              return ListView.builder(
                                itemCount: st.items.length,
                                itemBuilder: (ctx, i) {
                                  final e = st.items[i];
                                  return ChatListTile(title: e.title, role: 'moderator', agentId: e.agentId);
                                },
                              );
                            }),
                          ),
                        ]),
                      ),
              ),
            ]),
          ),
        ),
        if (_checking != null)
          Align(
            alignment: Alignment.center,
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.96, end: 1),
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOutBack,
              builder: (context, s, child) => Transform.scale(scale: s, child: child!),
              child: GlassContainer(
                padding: const EdgeInsets.all(20),
                borderRadius: BorderRadius.circular(20),
                child: SizedBox(
                  width: 360,
                  child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(children: [const Icon(Icons.description_outlined, color: Colors.white), const SizedBox(width: 8), const Expanded(child: Text('Проверка документов', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold))), IconButton(onPressed: () => setState(() => _checking = null), icon: const Icon(Icons.close, color: Colors.white54))]),
                    const SizedBox(height: 10),
                    Text(_checking!.title, style: const TextStyle(color: Colors.white)),
                    const SizedBox(height: 10),
                    _docBox('Лицевая сторона ID'),
                    const SizedBox(height: 12),
                    _docBox('Обратная сторона ID'),
                    const SizedBox(height: 12),
                    _docBox('Селфи с документом'),
                    const SizedBox(height: 16),
                    Row(children: [
                      Expanded(child: ElevatedButton(onPressed: () { ref.read(moderatorRequestsProvider.notifier).approveItem(_checking!.id); setState(() => _checking = null); }, style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2ECC71), foregroundColor: Colors.black, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))), child: const Text('Одобрить', style: TextStyle(fontWeight: FontWeight.w700)))),
                      const SizedBox(width: 10),
                      Expanded(child: OutlinedButton(onPressed: () { ref.read(moderatorRequestsProvider.notifier).rejectItem(_checking!.id); setState(() => _checking = null); }, style: OutlinedButton.styleFrom(foregroundColor: const Color(0xFFE53935), side: const BorderSide(color: Color(0xFFE53935)), padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))), child: const Text('Отклонить', style: TextStyle(fontWeight: FontWeight.w700))))
                    ]),
                  ]),
                ),
              ),
            ),
          ),
      ]),
    );
  }

  Widget _docBox(String title) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [const Icon(Icons.image_outlined, color: Colors.white54), const SizedBox(width: 6), Text(title, style: const TextStyle(color: Colors.white70))]),
      const SizedBox(height: 6),
      Container(
        height: 140,
        decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.06), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.white24)),
        child: const Center(child: Icon(Icons.image, color: Colors.white24, size: 40)),
      ),
    ]);
  }
}