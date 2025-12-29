import 'package:flutter/material.dart';
import 'package:solo1/core/theme/glassmorphism.dart';
import 'package:solo1/features/main_app/learning/presentation/widgets/send_docs_button.dart';

class AllCompletedBanner extends StatelessWidget {
  const AllCompletedBanner({super.key});
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 90),
        child: GlassContainer(
          padding: const EdgeInsets.all(16),
          borderRadius: BorderRadius.circular(16),
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: const [
            Text('Все уроки пройдены!', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text('Отправьте документы для верификации и начните продавать', style: TextStyle(color: Colors.white70)),
            SizedBox(height: 12),
            SendDocsButton(),
          ]),
        ),
      ),
    );
  }
}