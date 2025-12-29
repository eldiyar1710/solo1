import 'package:flutter/material.dart';
import 'package:solo1/core/theme/glassmorphism.dart';

class StatusCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color circleColor;
  final VoidCallback? onTap;
  const StatusCard({super.key, required this.icon, required this.title, required this.subtitle, required this.circleColor, this.onTap});
  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [BoxShadow(color: Color(0x552A184B), blurRadius: 24, spreadRadius: 0.5)],
        ),
        child: Container(
          padding: const EdgeInsets.all(1.2),
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [Color(0xFF6A1B9A), Color(0xFF42A5F5)], begin: Alignment.topLeft, end: Alignment.bottomRight),
            borderRadius: BorderRadius.circular(22),
          ),
          child: GlassContainer(
            onTap: onTap,
            padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
            borderRadius: BorderRadius.circular(20),
            opacity: 0.16,
            color: const Color(0xFF1A1442).withValues(alpha: 0.18),
            withBorder: false,
            child: Stack(
              children: [
                Positioned(
                  top: -40,
                  right: -20,
                  child: Container(
                    width: 160,
                    height: 160,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                    ),
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: RadialGradient(colors: [const Color(0x663F51B5), const Color(0x003F51B5)], radius: 0.8),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: -50,
                  left: -30,
                  child: Container(
                    width: 180,
                    height: 180,
                    decoration: const BoxDecoration(shape: BoxShape.circle),
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: RadialGradient(colors: [const Color(0x6642A5F5), const Color(0x0042A5F5)], radius: 0.9),
                      ),
                    ),
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(color: circleColor, shape: BoxShape.circle, boxShadow: [BoxShadow(color: circleColor.withValues(alpha: 0.35), blurRadius: 18, spreadRadius: 0.5)]),
                      alignment: Alignment.center,
                      child: Icon(icon, color: Colors.white, size: 30),
                    ),
                    const SizedBox(height: 12),
                    Text(title, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800), textAlign: TextAlign.center),
                    const SizedBox(height: 6),
                    Text(subtitle, style: const TextStyle(color: Colors.white70), textAlign: TextAlign.center),
                  ],
                ),
              ],
            ),
          ),
        ));
  }
}