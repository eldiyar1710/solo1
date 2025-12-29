// lib/features/preauth/pre_learning/presentation/pages/pre_learning_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:solo1/features/preauth/pre_learning/presentation/providers/pre_learning_provider.dart';
import 'package:go_router/go_router.dart';
import 'package:solo1/core/routes/app_routes.dart';
import 'package:solo1/l10n/l10n.dart'; 
import 'package:solo1/core/theme/glassmorphism.dart';
import 'package:solo1/features/preauth/pre_home/presentation/widgets/pre_home_header.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:solo1/features/preauth/pre_learning/presentation/widgets/learning_stat_item.dart';
import 'package:solo1/features/preauth/pre_learning/presentation/widgets/learning_option_button.dart';

// Используем DefaultTabController для верхних вкладок "Обучение" и "Демо"
class PreLearningPage extends StatelessWidget {
  const PreLearningPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    
    // Хедер вынесен в готовый виджет

    return DefaultTabController(
      length: 2, // Две вкладки: Обучение и Калькулятор
      child: Scaffold(
        backgroundColor: const Color(0xFF1A1A2E), // Темный фон
        body: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () => FocusScope.of(context).unfocus(),
          child: Stack(
          children: [
            SafeArea(
              child: Column(
                children: [
                  // HEADER
                  Padding(
                    padding: const EdgeInsets.only(top: 10, left: 16, right: 16, bottom: 10),
                    child: const PreHomeHeader(),
                  ),

                  // ВЕРХНИЙ НАВИГАЦИОННЫЙ БЛОК (Home, Learning, Demo)
                  _buildPreAuthNavBar(context),

                  // Вкладки Обучение / Калькулятор
                  Expanded(
                    child: TabBarView(
                      children: [
                        // 1. Вкладка Обучение (Video & Test)
                        _TabLearningContent(l10n: l10n),
                        // 2. Вкладка Калькулятор (Demo Calculator)
                        _TabCalculatorContent(l10n: l10n),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
          ),
      ),
    );
  }

  // --- Вспомогательные методы UI ---

  

  // В соответствии с дизайном, навигация теперь вверху, под заголовком.
  Widget _buildPreAuthNavBar(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildTopNavItem(context, Icons.home_filled, AppRoutes.preHome), // Главная
          // Вкладки TabBar
          Expanded(
            child: TabBar(
              indicator: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                gradient: const LinearGradient(
                  colors: [Color(0xFF6A1B9A), Color(0xFF42A5F5)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              indicatorPadding: EdgeInsets.zero,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white70,
              overlayColor: WidgetStateProperty.all(Colors.transparent),
              tabs: [
                Tab(icon: const Icon(Icons.school_outlined), text: l10n.tab_learning),
                Tab(icon: const Icon(Icons.calculate_outlined), text: l10n.tab_calculator),
              ],
            ),
          ),
          _buildTopNavItem(context, Icons.play_circle_outline, AppRoutes.demo), // Демо (если оно не калькулятор)
        ],
      ),
    );
  }
  
  // Отдельные кнопки для перехода между основными экранами
  Widget _buildTopNavItem(BuildContext context, IconData icon, String route) {
    return InkWell(
      onTap: () => context.go(route),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 5),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF2C2C3D),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: Colors.white70, size: 24),
      ),
    );
  }
}

// --- Вкладка 1: Обучающая программа (Video & Test) ---

class _TabLearningContent extends ConsumerWidget {
  final AppLocalizations l10n;
  const _TabLearningContent({required this.l10n});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(learningTestProvider);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!t.isTesting && !t.testPassed)
            _buildLearningSection(context, ref),
          if (t.isTesting)
            _buildTestSection(ref),
          if (t.testPassed)
            _buildTestResult(context, ref),
        ],
      ),
    );
  }

  // Секция 1: Видео и Информация
  Widget _buildLearningSection(BuildContext context, WidgetRef ref) {
    return GlassContainer(
      padding: const EdgeInsets.all(15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.laptop_chromebook, color: Color.fromARGB(255, 164, 74, 220), size: 30),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.learning_program_title, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                  Text(l10n.learning_program_subtitle, style: const TextStyle(color: Colors.white70, fontSize: 12)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          // Имитация видеоплеера
          Container(
            height: 180,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.black,
            ),
            alignment: Alignment.center,
            child: const Icon(Icons.gamepad, color: Color(0xFF6A1B9A), size: 60),
          ),
          
          const SizedBox(height: 20),

          // Кнопка посмотреть видео (YouTube)
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () async {
                final uri = Uri.parse('https://www.youtube.com/watch?v=BaW_jenozKc');
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                }
              },
              icon: const Icon(Icons.ondemand_video),
              label: Text(l10n.learning_watch_video_button),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6A1B9A),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ),
          
          // Статистика (5 мин, 5 вопросов, 80% порог)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              const LearningStatItem(value: '5 МИН', label: 'Длительность'),
              const LearningStatItem(value: '5', label: 'Вопросов'),
              const LearningStatItem(value: '80%', label: 'Порог'),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // Список "Что вы узнаете"
          Text(l10n.learning_what_you_learn, style: const TextStyle(color: Colors.lightGreenAccent, fontWeight: FontWeight.bold)),
          ...[
            l10n.learning_topic1, 
            l10n.learning_topic2,
            l10n.learning_topic3,
            l10n.learning_topic4,
          ].map((topic) => Padding(
            padding: const EdgeInsets.only(top: 4.0),
            child: Row(
              children: [
                const Icon(Icons.circle, color: Color(0xFF6A1B9A), size: 8),
                const SizedBox(width: 8),
                Text(topic, style: const TextStyle(color: Colors.white70)),
              ],
            ),
          )),
          
          const SizedBox(height: 30),
          
          // Кнопка "Начать тестирование"
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => ref.read(learningTestProvider.notifier).startTesting(),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF42A5F5),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(l10n.learning_start_test_button, style: const TextStyle(fontSize: 18)),
            ),
          ),
        ],
      ),
    );
  }

  // Секция 2: Тестирование
  Widget _buildTestSection(WidgetRef ref) {
    final t = ref.watch(learningTestProvider);
    final currentQ = ref.read(learningTestProvider.notifier).questions[t.currentQuestion - 1];
    final progress = (t.currentQuestion / ref.read(learningTestProvider.notifier).questions.length);

    return GlassContainer(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.school, color: Color(0xFF6A1B9A), size: 24),
                  const SizedBox(width: 8),
                  Text(l10n.test_title, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                ],
              ),
              Text('${t.score.round()}%', style: const TextStyle(color: Colors.blueAccent, fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 15),
          
          // Прогресс-бар
          LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.white12,
            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF6A1B9A)),
          ),
          const SizedBox(height: 5),
          Text('${l10n.test_question_number} ${t.currentQuestion} из ${ref.read(learningTestProvider.notifier).questions.length}', style: const TextStyle(color: Colors.white70, fontSize: 12)),
          
          const SizedBox(height: 20),
          
          // Вопрос
          Text(currentQ['q'] as String, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w500)),
          
          const SizedBox(height: 20),
          
          // Варианты ответов (A, B, C, D)
          ...List.generate(currentQ['options'].length, (index) {
            final option = currentQ['options'][index];
            final label = String.fromCharCode(65 + index);
            return LearningOptionButton(label: label, option: option, onTap: () => ref.read(learningTestProvider.notifier).answerQuestion(option));
          }),

          const SizedBox(height: 20),
          Text('${l10n.test_min_score_required}: 80%', style: const TextStyle(color: Colors.white54, fontSize: 12)),
      ],
    ),
  );
}

  // Секция 3: Результат Теста
  Widget _buildTestResult(BuildContext context, WidgetRef ref) {
    final t = ref.watch(learningTestProvider);
    return GlassContainer(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Icon(Icons.workspace_premium, color: Colors.greenAccent, size: 80),
          const SizedBox(height: 10),
          Text(l10n.test_result_great, style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
          Text(l10n.test_result_success_message, style: const TextStyle(color: Colors.white70, fontSize: 16)),
          const SizedBox(height: 20),
          
          // Результат
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(l10n.test_result_score, style: const TextStyle(color: Colors.white70, fontSize: 16)),
              const SizedBox(width: 10),
              Text('${t.score.round()}%', style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 10),
          // Прогресс-бар (повторно)
          LinearProgressIndicator(
            value: t.score / 100,
            backgroundColor: Colors.white12,
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.greenAccent),
          ),
          const SizedBox(height: 5),
          Text('${l10n.test_result_correct_answers}: ${(t.score / 20).round()} из ${ref.read(learningTestProvider.notifier).questions.length}', style: const TextStyle(color: Colors.white70, fontSize: 12)),
          
          const SizedBox(height: 30),
          
          // Кнопка "Зарегистрироваться"
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => context.go(AppRoutes.register),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF42A5F5),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(l10n.test_result_register_button, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
          ),

          const SizedBox(height: 10),

          // Кнопка "Связаться с модератором"
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: Text(l10n.contact_moderator_button),
                    content: Text(l10n.auth_required_message),
                    actions: [
                      TextButton(onPressed: () => context.go(AppRoutes.register), child: Text(l10n.auth_go_register)),
                      TextButton(onPressed: () => context.go(AppRoutes.login), child: Text(l10n.auth_go_login)),
                    ],
                  ),
                );
              },
              icon: const Icon(Icons.support_agent),
              label: Text(l10n.contact_moderator_button),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                side: const BorderSide(color: Colors.white24),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  // Вспомогательный виджет для статистики
  // Статический виджет и кнопки вынесены в presentation/widgets
}

// --- Вкладка 2: Калькулятор Дохода (Демо) ---

class _TabCalculatorContent extends ConsumerWidget {
  final AppLocalizations l10n;
  const _TabCalculatorContent({required this.l10n});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final terminalCount = ref.watch(learningCalcProvider).terminalCount;
    const double terminalPrice = 20000.0;
    const double commissionRate = 0.10;
    const int payoutPeriodMonths = 36;
    final double totalIncome = terminalPrice * terminalCount * commissionRate * payoutPeriodMonths;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: GlassContainer(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.calculate, color: Color(0xFFE57373), size: 30),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        l10n.calculator_title,
                        softWrap: true,
                        maxLines: 3,
                        style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Align(
                  alignment: Alignment.centerRight,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.orange,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(l10n.calculator_demo_label, style: const TextStyle(color: Colors.white, fontSize: 12)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 5),
            Text(l10n.calculator_subtitle, style: const TextStyle(color: Colors.white70, fontSize: 14)),
            
            const SizedBox(height: 20),
            
            // Выбор количества терминалов
            Text(l10n.calculator_terminals_question, style: const TextStyle(color: Colors.white, fontSize: 16)),
            const SizedBox(height: 10),
            
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.white30),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '$terminalCount', 
                    style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ),
                Text(l10n.calculator_unit, style: const TextStyle(color: Colors.white70, fontSize: 18)),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white),
                      onPressed: terminalCount > 1 ? () => ref.read(learningCalcProvider.notifier).setTerminalCount(terminalCount - 1) : null,
                    ),
                    IconButton(
                      icon: const Icon(Icons.keyboard_arrow_up, color: Colors.white),
                      onPressed: () => ref.read(learningCalcProvider.notifier).setTerminalCount(terminalCount + 1),
                    ),
                  ],
                ),
              ],
            ),
            
            const SizedBox(height: 20),
            
            // Быстрый выбор
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [1, 5, 10, 20].map((count) => _buildQuickSelectButton(count, ref)).toList(),
            ),

            const SizedBox(height: 25),
            
            // Детали комиссии
            _buildDetailRow(l10n.calculator_terminal_price, '${terminalPrice.toInt()} ₸'),
            _buildDetailRow(l10n.calculator_commission, '10%', isCommission: true),
            _buildDetailRow(l10n.calculator_payout_period, '$payoutPeriodMonths ${l10n.calculator_months}'),
            
            const SizedBox(height: 25),

            // Общий доход
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                gradient: const LinearGradient(
                  colors: [Color(0xFF6A1B9A), Color(0xFF42A5F5)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.calculator_total_income_label, style: const TextStyle(color: Colors.white70, fontSize: 16)),
                  const SizedBox(height: 5),
                  Text(
                    '${totalIncome.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]} ')} ₸',
                    style: const TextStyle(color: Colors.white, fontSize: 34, fontWeight: FontWeight.w900),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildQuickSelectButton(int count, WidgetRef ref) {
    final isSelected = ref.watch(learningCalcProvider).terminalCount == count;
    return InkWell(
      onTap: () => ref.read(learningCalcProvider.notifier).setTerminalCount(count),
      child: Container(
        width: 60,
        height: 40,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF6A1B9A).withValues(alpha: 0.8) : const Color(0xFF2C2C3D),
          borderRadius: BorderRadius.circular(10),
          border: isSelected ? Border.all(color: Colors.white, width: 1.5) : Border.all(color: Colors.transparent),
        ),
        child: Text('$count', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isCommission = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.white70, fontSize: 16)),
          isCommission
              ? Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.blueAccent,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                )
              : Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}