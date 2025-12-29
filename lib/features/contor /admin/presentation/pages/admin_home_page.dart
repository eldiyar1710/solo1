import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:ui';
import 'package:solo1/features/contor%20/admin/presentation/providers/admin_requests_provider.dart';
import 'package:solo1/features/contor%20/admin/presentation/widgets/admin_header.dart';
import 'package:solo1/features/contor%20/admin/presentation/widgets/request_item.dart';
import 'package:solo1/features/auth/presentation/controllers/auth_controller.dart';
import 'package:go_router/go_router.dart';
import 'package:solo1/core/routes/app_routes.dart';
import 'package:solo1/features/main_app/home/presentation/providers/home_provider.dart';
import 'package:solo1/features/main_app/home/domain/entities/home_banner.dart';
import 'package:solo1/features/main_app/home/domain/entities/home_notification_entity.dart';
import 'package:solo1/core/sync/sync_service.dart';

 class AdminHomePage extends ConsumerStatefulWidget {
  const AdminHomePage({super.key});
  @override
  ConsumerState<AdminHomePage> createState() => _AdminHomePageState();
 }

 class _AdminHomePageState extends ConsumerState<AdminHomePage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(adminRequestsProvider.notifier).load());
  }
  @override
  Widget build(BuildContext context) {
    final role = ref.watch(authControllerProvider).agent?.role;
    if (role != 'admin') {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) context.go(AppRoutes.preHome);
      });
      return const SizedBox.shrink();
    }
    final st = ref.watch(adminRequestsProvider);
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1A),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: DefaultTabController(
            length: 2,
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const AdminHeader(title: 'Админ Панель'),
                  const SizedBox(height: 6),
                  const Text('Управление баннерами и заявками', style: TextStyle(color: Color(0xFFB0B0D0), fontSize: 16)),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A1A2E),
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: const [
                        BoxShadow(color: Color(0x40000000), blurRadius: 32, offset: Offset(0, 8)),
                        BoxShadow(color: Color(0x408B3EFF), blurRadius: 20),
                      ],
                      border: Border.all(color: const Color(0x4D8B3EFF), width: 1),
                    ),
                    child: TabBar(
                      indicatorSize: TabBarIndicatorSize.tab,
                      labelPadding: const EdgeInsets.symmetric(horizontal: 20),
                      indicator: BoxDecoration(
                        borderRadius: BorderRadius.circular(28),
                        gradient: const LinearGradient(colors: [Color(0xFF007BFF), Color(0xFF8B3EFF)]),
                      ),
                      labelColor: Colors.white,
                      unselectedLabelColor: const Color(0xFFB0B0D0),
                      tabs: const [
                        Tab(icon: Icon(Icons.photo_size_select_actual), text: 'Баннеры'),
                        Tab(icon: Icon(Icons.shopping_cart_outlined), text: 'Заявки'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: TabBarView(children: [
                      SingleChildScrollView(
                        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AdminSectionCard(
                              title: 'Уведомление',
                              trailing: GradientPillButton(text: 'Изменить', onPressed: () {}),
                              child: _AddNotificationForm(onSubmit: (title, message) async {
                                final repo = ref.read(homeRepositoryProvider);
                                try {
                                  await repo.addNotification(title: title, message: message, date: DateTime.now());
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Уведомление добавлено')));
                                  }
                                } catch (_) {
                                  try {
                                    await SyncService().enqueueNotificationCreate(title: title, message: message, date: DateTime.now().millisecondsSinceEpoch);
                                  } catch (_) {}
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Ошибка добавления')));
                                  }
                                }
                              }),
                            ),
                            const SizedBox(height: 32),
                            AdminSectionCard(
                              title: 'Рекламные баннеры',
                              trailing: GradientIconButton(text: 'Добавить', icon: Icons.add, onPressed: _openAddBannerDialog),
                              child: const _AdminBannerManager(),
                            ),
                            const SizedBox(height: 20),
                            AdminSectionCard(
                              title: 'Список уведомлений',
                              child: const _AdminNotificationsList(),
                            ),
                          ],
                        ),
                      ),
                      SingleChildScrollView(
                        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                        child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 24),
                          AdminSectionCard(
                            title: 'Входящие заявки',
                            child: Column(
                              children: [
                                if (st.loading) const Center(child: CircularProgressIndicator()),
                                if (!st.loading && st.error != null) const Text('Ошибка загрузки', style: TextStyle(color: Colors.redAccent)),
                                if (!st.loading && st.error == null)
                                  ListView.builder(
                                    shrinkWrap: true,
                                    physics: const NeverScrollableScrollPhysics(),
                                    itemCount: st.items.length,
                                    itemBuilder: (ctx, i) {
                                      final e = st.items[i];
                                      return Padding(
                                        padding: const EdgeInsets.only(bottom: 20),
                                        child: AdminRequestItem(
                                          item: e,
                                          onApprove: () => ref.read(adminRequestsProvider.notifier).approveItem(e.id),
                                          onReject: () => ref.read(adminRequestsProvider.notifier).rejectItem(e.id),
                                          onContact: () {},
                                        ),
                                      );
                                    },
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      ),
                    ]),
                  ),
                ],
              ),
          ),
        ),
      ),
    );
  }
  void _openAddBannerDialog() {
    _showAdminModal(
      context: context,
      title: 'Добавить баннер',
      contentBuilder: (ctx) {
        final t = TextEditingController();
        final s = TextEditingController();
        final u = TextEditingController();
        var loading = false;
        return StatefulBuilder(builder: (ctx, setModalState) {
          return Column(mainAxisSize: MainAxisSize.min, children: [
            const Text('Заголовок', style: TextStyle(color: Colors.white)),
            const SizedBox(height: 8),
            _AdminInput(controller: t, hintText: 'Заголовок баннера'),
            const SizedBox(height: 16),
            const Text('Подзаголовок', style: TextStyle(color: Colors.white)),
            const SizedBox(height: 8),
            _AdminInput(controller: s, hintText: 'Описание'),
            const SizedBox(height: 16),
            const Text('Ссылка на изображение', style: TextStyle(color: Colors.white)),
            const SizedBox(height: 8),
            _AdminInput(controller: u, hintText: 'https://...'),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: AnimatedGradientButton(
                text: 'Сохранить',
                onPressed: loading
                    ? null
                    : () async {
                        final title = t.text.trim();
                        final imageUrl = u.text.trim();
                        if (title.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Укажите заголовок')));
                          return;
                        }
                        setModalState(() => loading = true);
                        try {
                          await ref.read(homeProvider.notifier).addBanner(title: title, imageUrl: imageUrl, active: true, priority: 1);
                        } catch (_) {
                          try {
                            await SyncService().enqueueBannerCreate(title: title, imageUrl: imageUrl, active: true, priority: 1);
                          } catch (_) {}
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Ошибка добавления баннера')));
                          }
                        } finally {
                          if (!mounted) return;
                          setModalState(() => loading = false);
                        }
                        if (ctx.mounted) Navigator.of(ctx).pop();
                      },
              ),
            ),
          ]);
        });
      },
    );
  }
}

class _AdminBannerManager extends ConsumerStatefulWidget {
  const _AdminBannerManager();
  @override
  ConsumerState<_AdminBannerManager> createState() => _AdminBannerManagerState();
}

class _AdminBannerManagerState extends ConsumerState<_AdminBannerManager> {
  final _title = TextEditingController();
  final _imageUrl = TextEditingController();
  bool _active = true;
  int _priority = 1;
  bool _loading = false;
  @override
  Widget build(BuildContext context) {
    final st = ref.watch(homeProvider);
    return Column(
      children: [
        Row(children: [
          Expanded(child: _AdminInput(controller: _title, hintText: 'Заголовок баннера')),
          const SizedBox(width: 12),
          Expanded(child: _AdminInput(controller: _imageUrl, hintText: 'Ссылка на изображение')),
        ]),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            Row(mainAxisSize: MainAxisSize.min, children: [
              const Text('Активно', style: TextStyle(color: Colors.white)),
              const SizedBox(width: 6),
              Switch(value: _active, onChanged: (v) => setState(() => _active = v)),
            ]),
            ConstrainedBox(
              constraints: const BoxConstraints.tightFor(width: 160),
              child: _AdminInput(
                hintText: 'Приоритет',
                keyboardType: TextInputType.number,
                onChanged: (v) => setState(() => _priority = int.tryParse(v) ?? 1),
              ),
            ),
            GradientPillButton(
              text: 'Добавить',
              onPressed: _loading
                  ? null
                  : () async {
                      final t = _title.text.trim();
                      final u = _imageUrl.text.trim();
                      if (t.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Укажите заголовок')));
                        return;
                      }
                      setState(() => _loading = true);
                      try {
                        await ref.read(homeProvider.notifier).addBanner(title: t, imageUrl: u, active: _active, priority: _priority);
                      } catch (_) {
                        try {
                          await SyncService().enqueueBannerCreate(title: t, imageUrl: u, active: _active, priority: _priority);
                        } catch (_) {}
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Ошибка добавления баннера')));
                        }
                      } finally {
                        if (!mounted) return;
                        setState(() => _loading = false);
                      }
                      _title.clear();
                      _imageUrl.clear();
                      _active = true;
                      _priority = 1;
                    },
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (st.loading) const LinearProgressIndicator(),
        Column(
          children: st.banners
              .map(
                (b) => Container(
                  margin: const EdgeInsets.only(bottom: 20),
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A1A2E),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: const Color(0x4D8B3EFF), width: 1),
                    boxShadow: const [
                      BoxShadow(color: Color(0x408B3EFF), blurRadius: 20),
                      BoxShadow(color: Color(0x5E000000), blurRadius: 32, offset: Offset(0, 8)),
                    ],
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.campaign, color: Colors.white),
                      const SizedBox(width: 12),
                      Expanded(child: Text(b.title, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold))),
                      Switch(
                          value: b.active,
                          onChanged: (v) async {
                            try {
                              await ref.read(homeProvider.notifier).updateBanner(b.id, title: b.title, imageUrl: b.imageUrl, active: v, priority: b.priority);
                            } catch (_) {
                              try {
                                await SyncService().enqueueBannerUpdate(id: b.id, title: b.title, imageUrl: b.imageUrl, active: v, priority: b.priority);
                              } catch (_) {}
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Ошибка обновления баннера')));
                              }
                            }
                          }),
                      IconButton(onPressed: () => _editBannerDialog(b), icon: const Icon(Icons.edit, color: Colors.white)),
                      IconButton(
                          onPressed: () async {
                            try {
                              await ref.read(homeProvider.notifier).deleteBanner(b.id);
                            } catch (_) {
                              try {
                                await SyncService().enqueueBannerDelete(id: b.id);
                              } catch (_) {}
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Ошибка удаления баннера')));
                              }
                            }
                          },
                          icon: const Icon(Icons.delete, color: Color(0xFFFF3B6B))),
                    ],
                  ),
                ),
              )
              .toList(),
        ),
      ],
    );
  }
  void _editBannerDialog(HomeBanner b) {
    _showAdminModal(
      context: context,
      title: 'Редактировать баннер',
      contentBuilder: (ctx) {
        final t = TextEditingController(text: b.title);
        final u = TextEditingController(text: b.imageUrl);
        var a = b.active;
        var p = b.priority;
        return StatefulBuilder(builder: (ctx, setModalState) {
          return Column(mainAxisSize: MainAxisSize.min, children: [
            _AdminInput(controller: t, hintText: 'Заголовок'),
            const SizedBox(height: 16),
            _AdminInput(controller: u, hintText: 'Ссылка на изображение'),
            const SizedBox(height: 16),
            Row(children: [const Text('Активно', style: TextStyle(color: Colors.white)), const SizedBox(width: 6), Switch(value: a, onChanged: (v) => setModalState(() => a = v))]),
            const SizedBox(height: 16),
            _AdminInput(hintText: 'Приоритет', keyboardType: TextInputType.number, onChanged: (v) => p = int.tryParse(v) ?? b.priority),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: AnimatedGradientButton(
                text: 'Сохранить',
                onPressed: () async {
                  try {
                    await ref.read(homeProvider.notifier).updateBanner(b.id, title: t.text.trim().isEmpty ? b.title : t.text.trim(), imageUrl: u.text.trim(), active: a, priority: p);
                  } catch (_) {
                    try {
                      await SyncService().enqueueBannerUpdate(id: b.id, title: t.text.trim().isEmpty ? b.title : t.text.trim(), imageUrl: u.text.trim(), active: a, priority: p);
                    } catch (_) {}
                    if (!mounted) return;
                  }
                  if (!mounted) return;
                  Navigator.of(ctx).pop();
                },
              ),
            ),
          ]);
        });
      },
    );
  }
}

class _AddNotificationForm extends StatefulWidget {
  final Future<void> Function(String title, String message) onSubmit;
  const _AddNotificationForm({required this.onSubmit});
  @override
  State<_AddNotificationForm> createState() => _AddNotificationFormState();
}

class _AddNotificationFormState extends State<_AddNotificationForm> {
  final _title = TextEditingController();
  final _message = TextEditingController();
  bool _loading = false;
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _AdminInput(controller: _title, hintText: 'Заголовок'),
        const SizedBox(height: 16),
        _AdminInput(controller: _message, hintText: 'Сообщение', maxLines: 3),
        const SizedBox(height: 32),
        Row(children: [
          Expanded(
            child: AnimatedGradientButton(
              text: 'Сохранить',
              onPressed: _loading
                  ? null
                  : () async {
                      final t = _title.text.trim();
                      final m = _message.text.trim();
                      if (t.isEmpty || m.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Заполните заголовок и сообщение')));
                        return;
                      }
                      setState(() => _loading = true);
                      try {
                        await widget.onSubmit(t, m);
                      } finally {
                        if (!mounted) return;
                        setState(() => _loading = false);
                      }
                      _title.clear();
                      _message.clear();
                    },
            ),
          ),
        ]),
    ],
  );
  }
}

class _AdminNotificationsList extends ConsumerWidget {
  const _AdminNotificationsList();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.read(homeRepositoryProvider);
    return StreamBuilder<List<HomeNotificationEntity>>(
      stream: repo.watchNotifications(),
      builder: (ctx, snap) {
        if (snap.connectionState == ConnectionState.waiting) return const LinearProgressIndicator();
        if (!snap.hasData || (snap.data?.isEmpty ?? true)) return const Text('Нет уведомлений', style: TextStyle(color: Colors.white54));
        final items = snap.data!;
        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: items.length,
          itemBuilder: (ctx, i) {
            final e = items[i];
            return Container(
              margin: const EdgeInsets.only(bottom: 20),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A2E),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: const Color(0x4D8B3EFF), width: 1),
                boxShadow: const [
                  BoxShadow(color: Color(0x408B3EFF), blurRadius: 20),
                  BoxShadow(color: Color(0x5E000000), blurRadius: 32, offset: Offset(0, 8)),
                ],
              ),
              child: Row(children: [
                const Icon(Icons.notifications_none, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    const Icon(Icons.warning_amber_rounded, color: Color(0xFFFFB800)),
                    const SizedBox(width: 6),
                    const Expanded(
                      child: Text(
                        'Важное уведомление',
                        style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ]),
                  const SizedBox(height: 6),
                  Text(e.message, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white, fontSize: 16)),
                ])),
                IconButton(onPressed: () => _editDialog(context, ref, e), icon: const Icon(Icons.edit, color: Colors.white)),
                IconButton(
                  onPressed: () async {
                    try {
                      await ref.read(homeRepositoryProvider).deleteNotification(id: e.id);
                    } catch (_) {
                      try {
                        await SyncService().enqueueNotificationDelete(id: e.id);
                      } catch (_) {}
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Ошибка удаления уведомления')));
                      }
                    }
                  },
                  icon: const Icon(Icons.delete, color: Color(0xFFFF3B6B))),
              ]),
            );
          },
        );
      },
    );
  }
  void _editDialog(BuildContext context, WidgetRef ref, HomeNotificationEntity e) {
    final t = TextEditingController(text: e.title);
    final m = TextEditingController(text: e.message);
    _showAdminModal(
      context: context,
      title: 'Изменить уведомление',
      contentBuilder: (ctx) {
        return Column(mainAxisSize: MainAxisSize.min, children: [
          _AdminInput(controller: t, hintText: 'Заголовок'),
          const SizedBox(height: 16),
          _AdminInput(controller: m, hintText: 'Сообщение', maxLines: 3),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: AnimatedGradientButton(
              text: 'Сохранить',
              onPressed: () async {
                try {
                  await ref.read(homeRepositoryProvider).updateNotification(id: e.id, title: t.text.trim().isEmpty ? e.title : t.text.trim(), message: m.text.trim().isEmpty ? e.message : m.text.trim(), date: DateTime.now());
                } catch (_) {
                  try {
                    await SyncService().enqueueNotificationUpdate(id: e.id, title: t.text.trim().isEmpty ? e.title : t.text.trim(), message: m.text.trim().isEmpty ? e.message : m.text.trim(), date: DateTime.now().millisecondsSinceEpoch);
                  } catch (_) {}
                }
                if (ctx.mounted) Navigator.of(ctx).pop();
              },
            ),
          ),
        ]);
      },
    );
  }
}

class AdminSectionCard extends StatelessWidget {
  final String title;
  final Widget child;
  final Widget? trailing;
  const AdminSectionCard({super.key, required this.title, required this.child, this.trailing});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0x4D8B3EFF), width: 1),
        boxShadow: const [
          BoxShadow(color: Color(0x408B3EFF), blurRadius: 20),
          BoxShadow(color: Color(0x5E000000), blurRadius: 32, offset: Offset(0, 8)),
        ],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Icon(Icons.notifications_active, color: Colors.white),
          const SizedBox(width: 12),
          Expanded(child: Text(title, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold))),
          if (trailing != null) trailing!,
        ]),
        const SizedBox(height: 24),
        child,
      ]),
    );
  }
}

class GradientPillButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  const GradientPillButton({super.key, required this.text, this.onPressed});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {},
      onTap: onPressed,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [Color(0xFF007BFF), Color(0xFF8B3EFF)]),
          borderRadius: BorderRadius.circular(30),
        ),
        child: Text(text, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }
}

class GradientIconButton extends StatelessWidget {
  final String text;
  final IconData icon;
  final VoidCallback? onPressed;
  const GradientIconButton({super.key, required this.text, required this.icon, this.onPressed});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [Color(0xFF007BFF), Color(0xFF8B3EFF)]),
          borderRadius: BorderRadius.circular(30),
        ),
        child: Row(children: [const Icon(Icons.add, color: Colors.white), const SizedBox(width: 6), Text(text, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))]),
      ),
    );
  }
}

class AnimatedGradientButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  const AnimatedGradientButton({super.key, required this.text, this.onPressed});
  @override
  State<AnimatedGradientButton> createState() => _AnimatedGradientButtonState();
}

class _AnimatedGradientButtonState extends State<AnimatedGradientButton> with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: const Duration(seconds: 3))..repeat(reverse: true);
  }
  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (context, _) {
        final t = _c.value;
        return GestureDetector(
          onTap: widget.onPressed,
          child: Container(
            height: 56,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              gradient: LinearGradient(
                colors: const [Color(0xFF007BFF), Color(0xFF8B3EFF)],
                begin: Alignment(-1 + t, 0),
                end: Alignment(1 + t, 0),
              ),
              boxShadow: const [BoxShadow(color: Color(0x408B3EFF), blurRadius: 15)],
            ),
            child: Text(widget.text, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
          ),
        );
      },
    );
  }
}

class _AdminInput extends StatefulWidget {
  final TextEditingController? controller;
  final String hintText;
  final TextInputType? keyboardType;
  final int maxLines;
  final ValueChanged<String>? onChanged;
  const _AdminInput({this.controller, required this.hintText, this.keyboardType, this.maxLines = 1, this.onChanged});
  @override
  State<_AdminInput> createState() => _AdminInputState();
}

class _AdminInputState extends State<_AdminInput> {
  final _focus = FocusNode();
  @override
  void dispose() {
    _focus.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    final focused = _focus.hasFocus;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      decoration: BoxDecoration(
        boxShadow: focused ? const [BoxShadow(color: Color(0x808B3EFF), blurRadius: 15)] : const [],
        borderRadius: BorderRadius.circular(16),
      ),
      child: TextField(
        focusNode: _focus,
        controller: widget.controller,
        keyboardType: widget.keyboardType,
        maxLines: widget.maxLines,
        onChanged: widget.onChanged,
        style: const TextStyle(color: Colors.white, fontSize: 16),
        decoration: InputDecoration(
          hintText: widget.hintText,
          hintStyle: const TextStyle(color: Color(0xFFB0B0D0)),
          filled: true,
          fillColor: const Color(0xFF1A1A2E),
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0x338B3EFF), width: 1)),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFF8B3EFF), width: 2)),
        ),
      ),
    );
  }
}

void _showAdminModal({required BuildContext context, required String title, required WidgetBuilder contentBuilder}) {
  showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'modal',
    pageBuilder: (ctx, _, __) => const SizedBox.shrink(),
    transitionDuration: const Duration(milliseconds: 250),
    transitionBuilder: (ctx, anim, _, child) {
      final scale = Tween<double>(begin: 0.95, end: 1).animate(CurvedAnimation(parent: anim, curve: Curves.easeOut));
      final opacity = Tween<double>(begin: 0, end: 1).animate(anim);
      return Opacity(
        opacity: opacity.value,
        child: Center(
          child: Transform.scale(
            scale: scale.value,
            child: Stack(children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: BackdropFilter(filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12), child: const SizedBox(width: 560, height: 10)),
              ),
              Container(
                width: 560,
                constraints: const BoxConstraints(maxWidth: 560),
                padding: const EdgeInsets.fromLTRB(32, 32, 32, 32),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A2E),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: const Color(0x4D8B3EFF), width: 1),
                  boxShadow: const [
                    BoxShadow(color: Color(0x408B3EFF), blurRadius: 20),
                    BoxShadow(color: Color(0x5E000000), blurRadius: 32, offset: Offset(0, 8)),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    Expanded(child: Text(title, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold))),
                    IconButton(onPressed: () => Navigator.of(ctx).pop(), icon: const Icon(Icons.close, color: Color(0xFFB0B0D0)))
                  ]),
                  const SizedBox(height: 24),
                  contentBuilder(ctx),
                ]),
                ),
              ),
            ]),
          ),
        ),
      );
    },
  );
}