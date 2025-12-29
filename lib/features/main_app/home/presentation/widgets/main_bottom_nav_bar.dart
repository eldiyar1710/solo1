import 'package:flutter/material.dart';
// Навбар в стиле pre_home: темная полупрозрачная плашка с тенью

class MainBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  const MainBottomNavBar({super.key, required this.currentIndex, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          margin: const EdgeInsets.only(bottom: 20, left: 20, right: 20),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: const Color(0xFF2C2C3D).withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(50),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 15)],
          ),
          child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _item(icon: Icons.home_filled, index: 0),
            _item(icon: Icons.school_outlined, index: 1),
            _item(icon: Icons.point_of_sale, index: 2),
            _item(icon: Icons.person_outline, index: 3),
          ],
        ),
      ),
    ));
  }

  Widget _item({required IconData icon, required int index}) {
    final active = index == currentIndex;
    return InkWell(
      onTap: () => onTap(index),
      borderRadius: BorderRadius.circular(40),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        decoration: active
            ? BoxDecoration(color: const Color(0xFF6A1B9A), borderRadius: BorderRadius.circular(40))
            : null,
        child: Icon(icon, color: active ? Colors.white : Colors.white70, size: 24),
      ),
    );
  }
}