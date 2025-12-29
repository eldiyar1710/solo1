import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:solo1/l10n/l10n.dart';
import 'package:solo1/features/preauth/demo/presentation/widgets/demo_text_field.dart';
import 'package:solo1/features/preauth/demo/presentation/widgets/kz_phone_formatter.dart';

class SalesForm extends StatelessWidget {
  final AppLocalizations l10n;
  final TextEditingController fioController;
  final TextEditingController companyController;
  final TextEditingController phoneController;
  final TextEditingController emailController;
  final TextEditingController cardController;
  final TextEditingController countController;
  final String? errorMessage;
  final double scale;
  final VoidCallback onValidateInputs;
  final VoidCallback onCompleteSale;
  final double terminalPrice;
  final double commissionRate;
  final int payoutPeriodMonths;
  const SalesForm({super.key, required this.l10n, required this.fioController, required this.companyController, required this.phoneController, required this.emailController, required this.cardController, required this.countController, required this.errorMessage, required this.scale, required this.onValidateInputs, required this.onCompleteSale, required this.terminalPrice, required this.commissionRate, required this.payoutPeriodMonths});
  @override
  Widget build(BuildContext context) {
    final count = int.tryParse(countController.text) ?? 1;
    final totalExpected = (terminalPrice * commissionRate * payoutPeriodMonths * count).toInt();
    final monthlyIncome = (terminalPrice * commissionRate * count).toInt();
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [const Icon(Icons.shopping_cart, color: Colors.blueAccent), const SizedBox(width: 8), Text(l10n.demo_client_data_title, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold))]),
      const SizedBox(height: 15),
      DemoTextField(controller: fioController, label: l10n.demo_fio_label),
      DemoTextField(controller: companyController, label: l10n.demo_company_label),
      DemoTextField(controller: phoneController, label: l10n.demo_phone_label, keyboardType: TextInputType.phone, onChanged: (_) => onValidateInputs(), inputFormatters: [KzPhoneFormatter()]),
      DemoTextField(controller: emailController, label: l10n.demo_email_label, keyboardType: TextInputType.emailAddress, onChanged: (_) => onValidateInputs()),
      DemoTextField(controller: cardController, label: l10n.demo_card_label, keyboardType: TextInputType.number, inputFormatters: [FilteringTextInputFormatter.digitsOnly]),
      DemoTextField(controller: countController, label: l10n.demo_terminal_count_label, keyboardType: TextInputType.number, onChanged: (_) => onValidateInputs(), inputFormatters: [FilteringTextInputFormatter.digitsOnly]),
      const SizedBox(height: 20),
      _detailRow(l10n.calculator_terminal_price, '${terminalPrice.toInt()} ₸'),
      _detailRow(l10n.calculator_commission, '${(commissionRate * 100).toInt()}%', isCommission: true),
      _detailRow(l10n.calculator_payout_period, '$payoutPeriodMonths ${l10n.calculator_months}'),
      const Divider(color: Colors.white12, height: 30),
      _detailRow(l10n.demo_monthly_income, '$monthlyIncome ₸', isMain: true),
      _detailRow(l10n.demo_total_for_period, '$totalExpected ₸', isMain: true),
      const SizedBox(height: 30),
      AnimatedScale(scale: scale, duration: const Duration(milliseconds: 200), curve: Curves.easeInOut, child: AnimatedContainer(duration: const Duration(milliseconds: 200), decoration: BoxDecoration(border: Border.all(color: errorMessage != null ? Colors.redAccent : Colors.transparent, width: 1.5), borderRadius: BorderRadius.circular(12), boxShadow: errorMessage != null ? [BoxShadow(color: const Color(0xFFFF5252).withValues(alpha: 0.25), blurRadius: 10, spreadRadius: 0.5)] : const []), child: SizedBox(width: double.infinity, child: ElevatedButton(onPressed: onCompleteSale, style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF6A1B9A), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 18), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))), child: Text(l10n.demo_sell_terminal_button, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold))))))
    ]);
  }
  Widget _detailRow(String label, String value, {bool isCommission = false, bool isMain = false}) {
    return Padding(padding: const EdgeInsets.symmetric(vertical: 8.0), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(label, style: TextStyle(color: isMain ? Colors.white : Colors.white70, fontSize: 16)), isCommission ? Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5), decoration: BoxDecoration(color: Colors.blueAccent, borderRadius: BorderRadius.circular(8)), child: Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))) : Text(value, style: TextStyle(color: isMain ? Colors.lightGreenAccent : Colors.white, fontWeight: isMain ? FontWeight.w900 : FontWeight.w600))]));
  }
}