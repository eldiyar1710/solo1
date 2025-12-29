import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart' as fba;
import 'package:firebase_database/firebase_database.dart';
import 'package:solo1/core/routes/app_routes.dart';
import 'package:solo1/features/auth/presentation/controllers/auth_controller.dart';
import 'dart:ui';

class AdminHeader extends ConsumerWidget {
  final String title;
  const AdminHeader({super.key, required this.title});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final menuKey = GlobalKey();
    Future<bool?> confirmGlass(BuildContext ctx, {required String title, required String message, String confirmText = 'Подтвердить', String cancelText = 'Отменить'}) {
      return showGeneralDialog<bool>(
        context: ctx,
        barrierDismissible: true,
        barrierLabel: 'confirm',
        transitionDuration: const Duration(milliseconds: 220),
        pageBuilder: (c, _, __) => const SizedBox.shrink(),
        transitionBuilder: (c, anim, __, child) {
          final scale = Tween<double>(begin: 0.96, end: 1).animate(CurvedAnimation(parent: anim, curve: Curves.easeOut));
          final opacity = Tween<double>(begin: 0, end: 1).animate(anim);
          final screenW = MediaQuery.of(c).size.width;
          double w = screenW - 48;
          if (w > 560) w = 560;
          if (w < 280) w = 280;
          return Opacity(
            opacity: opacity.value,
            child: Center(
              child: Transform.scale(
                scale: scale.value,
                child: Stack(children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: BackdropFilter(filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12), child: SizedBox(width: w, height: 10)),
                  ),
                  Container(
                    width: w,
                    constraints: const BoxConstraints(minWidth: 280, maxWidth: 560),
                    padding: const EdgeInsets.fromLTRB(28, 28, 28, 24),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.3), width: 1),
                      boxShadow: const [
                        BoxShadow(color: Color(0x33000000), blurRadius: 24, offset: Offset(0, 10)),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Row(children: [
                          Expanded(child: Text(title, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold))),
                          IconButton(onPressed: () => Navigator.of(c).pop(false), icon: const Icon(Icons.close, color: Color(0xFFB0B0D0)))
                        ]),
                        const SizedBox(height: 12),
                        Text(message, style: const TextStyle(color: Colors.white70)),
                        const SizedBox(height: 20),
                        Row(children: [
                          Expanded(child: OutlinedButton(onPressed: () => Navigator.of(c).pop(false), child: Text(cancelText))),
                          const SizedBox(width: 8),
                          Expanded(child: ElevatedButton(onPressed: () => Navigator.of(c).pop(true), child: Text(confirmText))),
                        ])
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
    Future<void> changePassword(BuildContext ctx) async {
      final ok = await confirmGlass(ctx, title: 'Сменить пароль', message: 'Вы действительно хотите сменить пароль?', confirmText: 'Подтвердить');
      if (ok != true) return;
      final controller = TextEditingController();
      if (!ctx.mounted) return;
      final result = await showGeneralDialog<String>(
        context: ctx,
        barrierDismissible: true,
        barrierLabel: 'changePwd',
        transitionDuration: const Duration(milliseconds: 220),
        pageBuilder: (c, _, __) => const SizedBox.shrink(),
        transitionBuilder: (c, anim, __, child) {
          final scale = Tween<double>(begin: 0.96, end: 1).animate(CurvedAnimation(parent: anim, curve: Curves.easeOut));
          final opacity = Tween<double>(begin: 0, end: 1).animate(anim);
          final screenW = MediaQuery.of(c).size.width;
          double w = screenW - 48;
          if (w > 560) w = 560;
          if (w < 280) w = 280;
          return Opacity(
            opacity: opacity.value,
            child: Center(
              child: Transform.scale(
                scale: scale.value,
                child: Stack(children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: BackdropFilter(filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12), child: SizedBox(width: w, height: 10)),
                  ),
                  Container(
                    width: w,
                    constraints: const BoxConstraints(minWidth: 280, maxWidth: 560),
                    padding: const EdgeInsets.fromLTRB(28, 28, 28, 24),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.3), width: 1),
                      boxShadow: const [
                        BoxShadow(color: Color(0x33000000), blurRadius: 24, offset: Offset(0, 10)),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Row(children: [
                          const Expanded(child: Text('Сменить пароль', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold))),
                          IconButton(onPressed: () => Navigator.of(c).pop(), icon: const Icon(Icons.close, color: Color(0xFFB0B0D0)))
                        ]),
                        const SizedBox(height: 12),
                        TextField(controller: controller, decoration: const InputDecoration(labelText: 'Новый пароль'), obscureText: true),
                        const SizedBox(height: 20),
                        Row(children: [
                          Expanded(child: OutlinedButton(onPressed: () => Navigator.of(c).pop(), child: const Text('Отмена'))),
                          const SizedBox(width: 8),
                          Expanded(child: ElevatedButton(onPressed: () => Navigator.of(c).pop(controller.text), child: const Text('Сохранить'))),
                        ])
                      ]),
                    ),
                  ),
                ]),
              ),
            ),
          );
        },
      );
      if (result == null || result.isEmpty) return;
      try {
        final user = fba.FirebaseAuth.instance.currentUser;
        if (user == null) throw Exception('Не авторизован');
        await user.updatePassword(result);
        final db = FirebaseDatabase.instance;
        await db.ref('/agents/${user.uid}/passwordLastChangedAt').set(DateTime.now().millisecondsSinceEpoch);
        if (!ctx.mounted) return;
        ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(content: Text('Пароль обновлен')));
      } catch (e) {
        if (!ctx.mounted) return;
        ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text('Ошибка: $e')));
      }
    }
    Future<void> logout(BuildContext ctx) async {
      final ok = await confirmGlass(ctx, title: 'Выйти из аккаунта', message: 'Вы действительно хотите выйти?', confirmText: 'Подтвердить');
      if (ok != true) return;
      await ref.read(authControllerProvider.notifier).logout();
      if (ctx.mounted) ctx.go(AppRoutes.preHome);
    }
    void showHeaderMenu(BuildContext ctx) {
      final overlay = Overlay.of(ctx);
      late OverlayEntry entry;
      entry = OverlayEntry(builder: (_) {
        final box = menuKey.currentContext?.findRenderObject() as RenderBox?;
        final size = box?.size ?? const Size(24, 24);
        final offset = box?.localToGlobal(Offset.zero) ?? Offset.zero;
        final screen = MediaQuery.of(ctx).size;
        double menuWidth = screen.width - 32;
        if (menuWidth > 280) menuWidth = 280;
        if (menuWidth < 220) menuWidth = 220;
        final menuHeight = 120.0;
        double left = offset.dx + size.width - menuWidth;
        double top = offset.dy + size.height + 8;
        left = left.clamp(16.0, screen.width - 16 - menuWidth);
        top = top.clamp(16.0, screen.height - 16 - menuHeight);
        return Stack(children: [
          Positioned.fill(child: GestureDetector(onTap: () => entry.remove(), child: Container(color: Colors.transparent))),
          Positioned(
            left: left,
            top: top,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                child: Container(
                  width: menuWidth,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.3), width: 1),
                    boxShadow: const [
                      BoxShadow(color: Color(0x33000000), blurRadius: 24, offset: Offset(0, 10)),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: Column(mainAxisSize: MainAxisSize.min, children: [
                      InkWell(
                        onTap: () {
                          entry.remove();
                          changePassword(ctx);
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                          child: Row(children: const [
                            Icon(Icons.lock_reset, color: Colors.white),
                            SizedBox(width: 8),
                            Expanded(child: Text('Сменить пароль', style: TextStyle(color: Colors.white))),
                          ]),
                        ),
                      ),
                      const Divider(color: Color(0x22FFFFFF), height: 1),
                      InkWell(
                        onTap: () {
                          entry.remove();
                          logout(ctx);
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                          child: Row(children: const [
                            Icon(Icons.logout, color: Colors.white),
                            SizedBox(width: 8),
                            Expanded(child: Text('Выйти', style: TextStyle(color: Colors.white))),
                          ]),
                        ),
                      ),
                    ]),
                  ),
                ),
              ),
            ),
          )
        ]);
      });
      overlay.insert(entry);
    }
    return LayoutBuilder(builder: (ctx, constraints) {
      return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Icon(Icons.admin_panel_settings, color: Colors.white),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
            ),
          ),
          IconButton(key: menuKey, onPressed: () => showHeaderMenu(context), icon: const Icon(Icons.warning_amber_rounded, color: Color(0xFFFFB800))),
        ]),
        const SizedBox(height: 6),
      ]);
    });
  }
}
