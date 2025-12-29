import 'package:flutter/material.dart';
import 'package:solo1/core/theme/glassmorphism.dart';
import 'package:solo1/l10n/l10n.dart';

class DemoModeBanner extends StatelessWidget {
  final AppLocalizations l10n;
  final VoidCallback onGoLearning;
  final VoidCallback onGoRegister;
  const DemoModeBanner({super.key, required this.l10n, required this.onGoLearning, required this.onGoRegister});
  @override
  Widget build(BuildContext context) {
    return Column(children: [
      const Icon(Icons.gamepad, color: Color(0xFF6A1B9A), size: 40),
      const SizedBox(height: 10),
      Text(l10n.demo_mode_title, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
      Text(l10n.demo_mode_subtitle, style: const TextStyle(color: Colors.white70, fontSize: 14)),
      const SizedBox(height: 15),
      GlassContainer(padding: const EdgeInsets.all(15), opacity: 0.1, borderRadius: BorderRadius.circular(15), child: Text(l10n.demo_mode_instruction, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white70))),
      const SizedBox(height: 15),
      Row(children: [
        Expanded(
          child: ElevatedButton(onPressed: onGoLearning, style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF6A1B9A), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))), child: Row(mainAxisSize: MainAxisSize.min, children: [const Icon(Icons.school_outlined, size: 18), const SizedBox(width: 8), Expanded(child: Text(l10n.demo_go_to_learning_button, maxLines: 1, overflow: TextOverflow.ellipsis))]))),
        const SizedBox(width: 10),
        Expanded(
          child: OutlinedButton(onPressed: onGoRegister, style: OutlinedButton.styleFrom(foregroundColor: Colors.white, side: const BorderSide(color: Color(0xFF6A1B9A), width: 2), padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))), child: Row(mainAxisSize: MainAxisSize.min, children: [const Icon(Icons.person_add_alt_1, size: 18), const SizedBox(width: 8), Expanded(child: Text(l10n.demo_go_to_register_button, maxLines: 1, overflow: TextOverflow.ellipsis))]))),
      ]),
    ]);
  }
}