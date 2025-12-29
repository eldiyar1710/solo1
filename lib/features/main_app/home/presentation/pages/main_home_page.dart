import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:solo1/features/main_app/home/presentation/pages/home_page.dart';
import 'package:solo1/features/main_app/learning/presentation/pages/learning_page.dart';
import 'package:solo1/features/main_app/sales/presentation/pages/sales_page.dart';
import 'package:solo1/features/main_app/profile/presentation/pages/profile_page.dart';
import 'package:solo1/features/main_app/home/presentation/widgets/main_bottom_nav_bar.dart';
import 'package:solo1/features/auth/presentation/controllers/auth_controller.dart';

class MainHomePage extends ConsumerStatefulWidget {
  const MainHomePage({super.key});
  @override
  ConsumerState<MainHomePage> createState() => _MainHomePageState();
}

class _MainHomePageState extends ConsumerState<MainHomePage> {
  int _index = 0;
  @override
  Widget build(BuildContext context) {
    final pages = [
      const MainHomeSection(),
      const MainLearningSection(),
      const MainSalesSection(),
      const MainProfileSection(),
    ];
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      body: Stack(
        children: [
          SafeArea(child: pages[_index]),
          Align(
            alignment: Alignment.bottomCenter,
          child: MainBottomNavBar(currentIndex: _index, onTap: (v) {
            if (v == 2) {
              final a = ref.read(authControllerProvider).agent;
              final role = a?.role;
              final status = a?.status;
              final email = (a?.email ?? '').toLowerCase();
              final allowed = role == 'admin' || role == 'moderator' || status == 'approved' || status == 'test' || email == 'test@solo1.app';
              if (!allowed) {
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Продажи недоступны'),
                      content: const Text('Раздел откроется после обучения и одобрения модератора.'),
                      actions: [TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Понятно'))],
                    ),
                  );
                  return;
                }
              }
              setState(() => _index = v);
            }),
          ),
        ],
      ),
    );
  }
}