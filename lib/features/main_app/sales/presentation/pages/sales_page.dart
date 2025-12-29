import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:solo1/core/theme/glassmorphism.dart';
import 'package:solo1/features/main_app/sales/presentation/providers/sales_provider.dart';
import 'package:solo1/features/main_app/sales/presentation/widgets/sales_summary_card.dart';
import 'package:solo1/features/auth/presentation/controllers/auth_controller.dart';

class MainSalesSection extends ConsumerWidget {
  const MainSalesSection({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(salesProvider);
    final auth = ref.watch(authControllerProvider);
    ref.read(salesProvider.notifier).load();
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: GlassContainer(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: const [Icon(Icons.point_of_sale, color: Colors.white), SizedBox(width: 8), Text('Продажи', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold))]),
            if ((auth.agent?.status == 'test') || ((auth.agent?.email ?? '').toLowerCase() == 'test@solo1.app'))
              const Padding(
                padding: EdgeInsets.only(top: 6),
                child: Text('Тестовый аккаунт — данные только локально', style: TextStyle(color: Colors.amberAccent)),
              ),
            const SizedBox(height: 10),
            const Text('Здесь будут продажи и лицензии', style: TextStyle(color: Colors.white70)),
            const SizedBox(height: 16),
            if (state.loading) const CircularProgressIndicator(),
            if (!state.loading) SalesSummaryCard(items: state.items),
            const SizedBox(height: 12),
            ElevatedButton(onPressed: () => ref.read(salesProvider.notifier).createQuickSale(), child: const Text('Быстрая продажа')),
          ],
        ),
      ),
    );
  }
}