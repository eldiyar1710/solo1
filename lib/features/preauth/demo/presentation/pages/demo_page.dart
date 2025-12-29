// lib/features/preauth/demo/presentation/pages/demo_page.dart

import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:solo1/core/routes/app_routes.dart';
import 'package:solo1/l10n/l10n.dart';
import 'package:solo1/core/theme/glassmorphism.dart';
import 'package:solo1/features/preauth/pre_home/presentation/widgets/pre_home_header.dart';
import 'package:solo1/features/preauth/demo/presentation/widgets/demo_top_nav_bar.dart';
import 'package:solo1/features/preauth/demo/presentation/widgets/demo_mode_banner.dart';
import 'package:solo1/features/preauth/demo/presentation/widgets/sales_form.dart';
import 'package:solo1/features/preauth/demo/presentation/widgets/profile_view.dart';
import 'package:solo1/features/preauth/demo/presentation/widgets/sticky_register_button.dart';
import 'package:solo1/features/preauth/demo/presentation/widgets/sale_success_overlay.dart';
import 'package:solo1/features/preauth/demo/presentation/providers/demo_provider.dart';

class DemoPage extends ConsumerStatefulWidget {
  const DemoPage({super.key});

  @override
  ConsumerState<DemoPage> createState() => _DemoPageState();
}

class _DemoPageState extends ConsumerState<DemoPage> {
  // Константы для демо-расчета
  static const double _terminalPrice = 20000.0; // 20 000 ₸
  static const double _commissionRate = 0.10;   // 10%
  static const int _payoutPeriodMonths = 36;    // 36 мес.
  static const double _monthlyIncomePerTerminal = _terminalPrice * _commissionRate; // 2000 ₸

  // Состояние перенесено в Riverpod

  // Фейковые данные клиента
  final TextEditingController _fioController = TextEditingController(text: 'Amangeldi Uisbek');
  final TextEditingController _companyController = TextEditingController(text: 'Магазин Flowers');
  final TextEditingController _phoneController = TextEditingController(text: '+7 777 123 45 67');
  final TextEditingController _emailController = TextEditingController(text: 'demo@example.com');
  final TextEditingController _cardController = TextEditingController(text: '4400 1234 5678 9012');
  final TextEditingController _countController = TextEditingController(text: '1');
  String? _errorMessage;
  Timer? _errorTimer;
  double _scale = 1.0;

  // Расчет ожидаемого дохода (за весь период)
  double get _totalExpectedIncome => _monthlyIncomePerTerminal * _payoutPeriodMonths * ref.watch(demoProvider).totalTerminalsSold;

  @override
  void initState() {
    super.initState();
    // Инициализация теперь управляется провайдером
  }

  void _completeSale() async {
    _validateInputs();
    if (_errorMessage != null) {
      _startPulse(3);
      return;
    }
    final count = int.tryParse(_countController.text) ?? 0;
    ref.read(demoProvider.notifier).completeSale(count);
    showSaleSuccessOverlay(context, terminals: count, monthlyIncomePerTerminal: _monthlyIncomePerTerminal);
  }

  bool get _isPhoneValid => RegExp(r'^\+7 \d{3} \d{3} \d{2} \d{2}$').hasMatch(_phoneController.text);
  bool get _isEmailValid => RegExp(r'^[^@]+@[^@]+\.[^@]+$').hasMatch(_emailController.text);
  bool get _isCountValid {
    final count = int.tryParse(_countController.text) ?? 0;
    return count >= 1 && count <= 100;
  }
  void _validateInputs() {
    String? msg;
    if (!_isPhoneValid) {
      msg = 'Введите телефон в формате +7 7XX XXX XX XX';
    } else if (!_isEmailValid) {
      msg = 'Введите корректный email';
    } else if (!_isCountValid) {
      msg = 'Количество терминалов: 1–100';
    }
    setState(() => _errorMessage = msg);
    _errorTimer?.cancel();
    if (msg != null) {
      _errorTimer = Timer(const Duration(seconds: 2), () {
        if (mounted) {
          setState(() => _errorMessage = null);
        }
      });
    }
  }

  void _startPulse(int cycles) async {
    for (int i = 0; i < cycles; i++) {
      if (!mounted) break;
      setState(() => _scale = 1.02);
      await Future.delayed(const Duration(milliseconds: 120));
      if (!mounted) break;
      setState(() => _scale = 1.0);
      await Future.delayed(const Duration(milliseconds: 120));
    }
  }

  
  
  void _startNewSale() {
    ref.read(demoProvider.notifier).startNewSale();
  }
  
  void _goToRegistration(BuildContext context) {
    context.go(AppRoutes.register);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final demo = ref.watch(demoProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () => FocusScope.of(context).unfocus(),
        child: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                // HEADER
                Padding(padding: const EdgeInsets.only(top: 10, left: 16, right: 16, bottom: 10), child: const PreHomeHeader()),
                Padding(padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10), child: DemoTopNavBar(l10n: l10n)),
                
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        DemoModeBanner(l10n: l10n, onGoLearning: () => context.go(AppRoutes.preLearning), onGoRegister: () => context.go(AppRoutes.register)),
                        const SizedBox(height: 20),
                        
                        if (demo.isSelling)
                          SalesForm(
                            l10n: l10n,
                            fioController: _fioController,
                            companyController: _companyController,
                            phoneController: _phoneController,
                            emailController: _emailController,
                            cardController: _cardController,
                            countController: _countController,
                            errorMessage: _errorMessage,
                            scale: _scale,
                            onValidateInputs: _validateInputs,
                            onCompleteSale: _completeSale,
                            terminalPrice: _terminalPrice,
                            commissionRate: _commissionRate,
                            payoutPeriodMonths: _payoutPeriodMonths,
                          )
                        else
                          ProfileView(
                            l10n: l10n,
                            demo: demo,
                            totalExpectedIncome: _totalExpectedIncome,
                            monthlyIncomePerTerminal: _monthlyIncomePerTerminal,
                            payoutPeriodMonths: _payoutPeriodMonths,
                            onStartNewSale: _startNewSale,
                            onGoRegister: () => _goToRegistration(context),
                          ),
                          
                        const SizedBox(height: 80), // Отступ внизу
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Кнопка регистрации внизу (для состояния "Продажа")
          if (demo.isSelling)
            StickyRegisterButton(l10n: l10n, onPressed: () => _goToRegistration(context)),
          
          if (_errorMessage != null)
            Positioned(
              left: 16,
              right: 16,
              top: MediaQuery.of(context).padding.top + 12,
              child: GlassContainer(
                padding: const EdgeInsets.all(16),
                opacity: 0.15,
                borderRadius: BorderRadius.circular(12),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline, color: Colors.redAccent),
                    const SizedBox(width: 8),
                    Expanded(child: Text(_errorMessage!, style: const TextStyle(color: Colors.redAccent))),
                  ],
                ),
              ),
            ),
        ],
        ),
      ),
    );
  }

  // --- Вспомогательные методы UI ---
  

  @override
  void dispose() {
    _fioController.dispose();
    _companyController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _cardController.dispose();
    _countController.dispose();
    super.dispose();
  }
}
