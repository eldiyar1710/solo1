import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:solo1/features/main_app/learning/presentation/providers/learning_provider.dart';

class SendDocsButton extends StatelessWidget {
  const SendDocsButton({super.key});
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          final ref = ProviderScope.containerOf(context, listen: false);
          ref.read(sendDocsOverlayVisibleProvider.notifier).state = true;
        },
        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF22C55E), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
        child: const Text('Отправить документы'),
      ),
    );
  }
}