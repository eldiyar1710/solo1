import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:solo1/core/routes/app_routes.dart';
import 'package:solo1/l10n/l10n.dart';
import 'package:solo1/core/theme/glassmorphism.dart';

class PreHomeHeader extends StatelessWidget {
  const PreHomeHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: Colors.deepPurple,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text('JS', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
            ),
            const SizedBox(width: 8),
            Text(
              l10n.appName,
              style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.chat_bubble_outline, color: Colors.white70),
              onPressed: () {
                final overlay = OverlayEntry(
                  builder: (context) => SafeArea(
                    child: Align(
                      alignment: Alignment.topCenter,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Material(
                          color: Colors.transparent,
                          child: GlassContainer(
                            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                            borderRadius: BorderRadius.circular(18),
                            opacity: 0.18,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: const [
                                Icon(Icons.chat_bubble, color: Colors.white),
                                SizedBox(width: 8),
                                Text('Чаты скоро будут доступны', style: TextStyle(color: Colors.white)),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
                Overlay.of(context).insert(overlay);
                Future.delayed(const Duration(seconds: 3), () => overlay.remove());
              },
              tooltip: 'Чаты',
            ),
            const SizedBox(width: 4),
            ElevatedButton.icon(
              onPressed: () => context.go(AppRoutes.login),
              icon: const Icon(Icons.arrow_forward),
              label: Text(l10n.login_button),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6A1B9A),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
              ),
            ),
          ],
        ),
      ],
    );
  }
}