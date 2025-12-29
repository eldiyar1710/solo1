import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:solo1/core/routes/app_routes.dart';

class PreHomeTopNavBar extends StatelessWidget {
  const PreHomeTopNavBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        margin: const EdgeInsets.only(bottom: 20, left: 20, right: 20),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: const Color(0xFF2C2C3D).withValues(alpha: 0.92),
          borderRadius: BorderRadius.circular(50),
          boxShadow: const [BoxShadow(color: Color(0x66000000), blurRadius: 20, offset: Offset(0, 10))],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _NavItem(icon: Icons.home_filled, route: AppRoutes.preHome, isActive: true),
            _NavItem(icon: Icons.school_outlined, route: AppRoutes.preLearning),
            _NavItem(icon: Icons.gamepad, route: AppRoutes.demo),
          ],
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String route;
  final bool isActive;
  const _NavItem({required this.icon, required this.route, this.isActive = false});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => context.go(route),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        decoration: isActive ? BoxDecoration(color: const Color(0xFF6A1B9A), borderRadius: BorderRadius.circular(40)) : null,
        child: Icon(icon, color: isActive ? Colors.white : Colors.white70, size: 24),
      ),
    );
  }
}