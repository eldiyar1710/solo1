import 'package:flutter/material.dart';
import 'package:solo1/l10n/l10n.dart';

class StickyRegisterButton extends StatelessWidget {
  final AppLocalizations l10n;
  final VoidCallback onPressed;
  const StickyRegisterButton({super.key, required this.l10n, required this.onPressed});
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 20, left: 16, right: 16),
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(onPressed: onPressed, style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF9C27B0), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 18), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))), child: Text(l10n.demo_register_final_button, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
        ),
      ),
    );
  }
}