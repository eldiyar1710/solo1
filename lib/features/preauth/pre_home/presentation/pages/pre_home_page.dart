// lib/features/preauth/pages/pre_home_page.dart (Адаптированная версия)

import 'package:flutter/material.dart';
import 'package:solo1/features/preauth/pre_home/presentation/widgets/pre_home_header.dart';
import 'package:solo1/features/preauth/pre_home/presentation/widgets/pre_home_main_slogan.dart';
import 'package:solo1/features/preauth/pre_home/presentation/widgets/pre_home_success_stories.dart';
import 'package:solo1/features/preauth/pre_home/presentation/widgets/pre_home_how_it_works.dart';
import 'package:solo1/features/preauth/pre_home/presentation/widgets/pre_home_monthly_income_panel.dart';
import 'package:solo1/features/preauth/pre_home/presentation/widgets/pre_home_call_to_action.dart';
import 'package:solo1/features/preauth/pre_home/presentation/widgets/pre_home_top_nav_bar.dart';

// Важно: GlassContainer и AgentIdGenerator должны быть доступны 
// (см. предыдущие ответы для их реализации).

class PreHomePage extends StatelessWidget {
  const PreHomePage({super.key});

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E), // Темный фон
      
      // Используем Stack для размещения AppBar и Nav Bar, 
      // но в данном дизайне AppBar интегрирован в основной UI.
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () => FocusScope.of(context).unfocus(),
        child: Stack(
        children: [
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),
                  // 1. HEADER (Лого и кнопка Войти)
                  const PreHomeHeader(),
                  
                  const SizedBox(height: 20),

                  // 2. ГЛАВНЫЙ СЛОГАН
                  const PreHomeMainSlogan(),

                  const SizedBox(height: 30),

                  // 3. ИСТОРИИ УСПЕХА (Горизонтальный свайпер)
                  const PreHomeSuccessStories(),

                  const SizedBox(height: 30),

                  // 4. КАК ЭТО РАБОТАЕТ (Пошаговая инструкция)
                  const PreHomeHowItWorks(),

                  const SizedBox(height: 30),

                  // 5. ПОТЕНЦИАЛЬНЫЙ ДОХОД ПО МЕСЯЦАМ (График)
                  const PreHomeMonthlyIncomePanel(),

                  const SizedBox(height: 40),

                  // 6. ПРИЗЫВ К ДЕЙСТВИЮ (Регистрация)
                  const PreHomeCallToAction(),

                  const SizedBox(height: 120), // Отступ для нижнего меню
                ],
              ),
            ),
          ),
          
          // НИЖНИЙ НАВИГАЦИОННЫЙ БЛОК (рулетка) - согласно файлу !1.jpg
          const PreHomeTopNavBar(),
        ],
        ),
      ),
    );
  }
}