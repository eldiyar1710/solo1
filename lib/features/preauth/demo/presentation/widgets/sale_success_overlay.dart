import 'package:flutter/material.dart';
import 'package:solo1/core/theme/glassmorphism.dart';
import 'package:solo1/l10n/l10n.dart';

void showSaleSuccessOverlay(BuildContext context, {required int terminals, required double monthlyIncomePerTerminal}) {
  final l10n = AppLocalizations.of(context);
  final amount = (terminals * monthlyIncomePerTerminal).toInt();
  final overlay = OverlayEntry(
    builder: (context) => Positioned(
      top: MediaQuery.of(context).size.height / 3,
      left: MediaQuery.of(context).size.width / 2 - 100,
      child: Material(
        color: Colors.transparent,
        child: GlassContainer(
          padding: const EdgeInsets.all(30),
          blur: 20,
          opacity: 0.3,
          borderRadius: BorderRadius.circular(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.shopping_bag, color: Colors.amber, size: 40),
              const SizedBox(height: 10),
              Text('+$amount ₸', style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 5),
              Text(l10n.demo_sale_success_message, style: const TextStyle(color: Colors.white70, fontSize: 14)),
            ],
          ),
        ),
      ),
    ),
  );
  Overlay.of(context).insert(overlay);
  Future.delayed(const Duration(seconds: 2), () => overlay.remove());
}