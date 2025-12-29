import 'package:flutter/material.dart';
import 'package:solo1/l10n/l10n.dart';
import 'package:solo1/features/preauth/demo/presentation/providers/demo_provider.dart';
import 'package:solo1/features/preauth/demo/presentation/widgets/balance_card.dart';
import 'package:solo1/features/preauth/demo/presentation/widgets/income_bar.dart';
import 'package:solo1/features/preauth/demo/presentation/widgets/increase_income_block.dart';

class ProfileView extends StatelessWidget {
  final AppLocalizations l10n;
  final DemoState demo;
  final double totalExpectedIncome;
  final double monthlyIncomePerTerminal;
  final int payoutPeriodMonths;
  final VoidCallback onStartNewSale;
  final VoidCallback onGoRegister;
  const ProfileView({super.key, required this.l10n, required this.demo, required this.totalExpectedIncome, required this.monthlyIncomePerTerminal, required this.payoutPeriodMonths, required this.onStartNewSale, required this.onGoRegister});
  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(l10n.demo_profile_title, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
      Text(l10n.demo_profile_subtitle, style: const TextStyle(color: Colors.white70, fontSize: 14)),
      const SizedBox(height: 20),
      Row(children: [BalanceCard(title: l10n.demo_current_balance, value: '${demo.currentBalance.toInt()} ₸', bgColor: Colors.white, textColor: Colors.black), const SizedBox(width: 10), BalanceCard(title: l10n.demo_expected_balance, value: '${totalExpectedIncome.toInt()} ₸', bgColor: const Color(0xFF6A1B9A), textColor: Colors.white)]),
      const SizedBox(height: 20),
      _detailRow(l10n.demo_total_sales, '${demo.totalTerminalsSold} ${l10n.demo_terminal_unit}'),
      _detailRow(l10n.calculator_payout_period, '$payoutPeriodMonths ${l10n.calculator_months}'),
      _detailRow(l10n.demo_monthly_income, '${monthlyIncomePerTerminal.toInt() * demo.totalTerminalsSold} ₸'),
      const Divider(color: Colors.white12, height: 30),
      Text(l10n.demo_income_accumulation_title, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
      const SizedBox(height: 10),
      ...List.generate(6, (index) => IncomeBar(monthLabel: '${l10n.demo_month} ${index + 1}', income: (monthlyIncomePerTerminal * demo.totalTerminalsSold * (index + 1)), maxIncome: monthlyIncomePerTerminal * payoutPeriodMonths * 5)),
      const SizedBox(height: 30),
      IncreaseIncomeBlock(title: l10n.demo_increase_income_title, text: l10n.demo_increase_income_text),
      const SizedBox(height: 30),
      SizedBox(width: double.infinity, child: ElevatedButton(onPressed: onStartNewSale, style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF42A5F5), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 18), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))), child: Text(l10n.demo_new_sale_button, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)))),
      const SizedBox(height: 10),
      SizedBox(width: double.infinity, child: OutlinedButton(onPressed: onGoRegister, style: OutlinedButton.styleFrom(foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 18), side: const BorderSide(color: Color(0xFF6A1B9A), width: 2), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))), child: Text(l10n.demo_register_real_button, style: const TextStyle(fontSize: 18))))
    ]);
  }
  Widget _detailRow(String label, String value) {
    return Padding(padding: const EdgeInsets.symmetric(vertical: 8.0), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(label, style: const TextStyle(color: Colors.white70, fontSize: 16)), Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600))]));
  }
}