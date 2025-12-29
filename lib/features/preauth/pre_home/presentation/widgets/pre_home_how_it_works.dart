import 'package:flutter/material.dart';
import 'package:solo1/l10n/l10n.dart';

class PreHomeHowItWorks extends StatelessWidget {
  const PreHomeHowItWorks({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final steps = [
      {
        'title': l10n.prehome_step1_title,
        'subtitle': l10n.prehome_step1_subtitle,
        'image': 'assets/foto/0_contactless-unsplash.jpg.webp',
      },
      {
        'title': l10n.prehome_step2_title,
        'subtitle': l10n.prehome_step2_subtitle,
        'image': 'assets/foto/0f4e7688cc85be0ccd6a18e6a300df10.jpg',
      },
      {
        'title': l10n.prehome_step3_title,
        'subtitle': l10n.prehome_step3_subtitle,
        'image': 'assets/foto/shutterstock-2254461739-2.png',
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.prehome_how_it_works_title, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 15),
        SizedBox(
          height: 200,
          child: PageView.builder(
            itemCount: steps.length,
            controller: PageController(viewportFraction: 0.9),
            itemBuilder: (context, index) {
              final step = steps[index];
              return Padding(
                padding: const EdgeInsets.only(right: 10.0),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    image: DecorationImage(
                      image: AssetImage(step['image'] as String),
                      fit: BoxFit.cover,
                      colorFilter: ColorFilter.mode(const Color(0xFF000000).withValues(alpha: 0.45), BlendMode.darken),
                    ),
                  ),
                  padding: const EdgeInsets.all(20),
                  alignment: Alignment.bottomLeft,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF6A1B9A).withValues(alpha: 0.8),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text('Шаг ${index + 1} из 3', style: const TextStyle(color: Colors.white, fontSize: 12)),
                      ),
                      const SizedBox(height: 5),
                      Text(step['title'] as String, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                      Text(step['subtitle'] as String, style: const TextStyle(color: Colors.white70, fontSize: 14)),
                      const SizedBox(height: 5),
                      Row(
                        children: List.generate(3, (i) => Container(
                          margin: const EdgeInsets.only(right: 4),
                          width: i == index ? 20 : 8,
                          height: 4,
                          decoration: BoxDecoration(
                            color: i == index ? Colors.white : Colors.white54,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        )),
                      )
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}