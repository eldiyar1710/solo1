import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:solo1/core/routes/app_routes.dart';
import 'package:solo1/l10n/l10n.dart';

class DemoTopNavBar extends StatelessWidget {
  final AppLocalizations l10n;
  const DemoTopNavBar({super.key, required this.l10n});
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: const [
        _TopNavItem(icon: Icons.home_filled, labelKey: 'tab_home', route: AppRoutes.preHome, active: false),
        _TopNavItem(icon: Icons.school_outlined, labelKey: 'tab_learning', route: AppRoutes.preLearning, active: false),
        _TopNavItem(icon: Icons.gamepad_outlined, labelKey: 'tab_demo', route: AppRoutes.demo, active: true),
      ],
    );
  }
}

class _TopNavItem extends StatelessWidget {
  final IconData icon;
  final String labelKey;
  final String route;
  final bool active;
  const _TopNavItem({required this.icon, required this.labelKey, required this.route, required this.active});
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final label = _labelFromKey(l10n, labelKey);
    return InkWell(
      onTap: () => context.go(route),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 5),
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
        decoration: active
            ? BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                gradient: const LinearGradient(colors: [Color(0xFF6A1B9A), Color(0xFF42A5F5)], begin: Alignment.topLeft, end: Alignment.bottomRight),
              )
            : BoxDecoration(color: const Color(0xFF2C2C3D), borderRadius: BorderRadius.circular(10)),
        child: Row(children: [Icon(icon, color: active ? Colors.white : Colors.white70, size: 20), const SizedBox(width: 5), Text(label, style: TextStyle(color: active ? Colors.white : Colors.white70, fontSize: 14))]),
      ),
    );
  }
  String _labelFromKey(AppLocalizations l10n, String key) {
    switch (key) {
      case 'tab_home':
        return l10n.tab_home;
      case 'tab_learning':
        return l10n.tab_learning;
      default:
        return l10n.tab_demo;
    }
  }
}