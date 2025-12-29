import 'package:flutter/services.dart';

class KzPhoneFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final digitsOnly = newValue.text.replaceAll(RegExp(r'\D'), '');
    String d = digitsOnly;
    if (d.isEmpty) {
      const t = '+7 ';
      return TextEditingValue(text: t, selection: const TextSelection.collapsed(offset: 3));
    }
    if (d.startsWith('8')) d = '7${d.substring(1)}';
    if (!d.startsWith('7')) d = '7$d';
    d = d.substring(1);
    final parts = <String>[];
    if (d.isNotEmpty) parts.add(d.substring(0, d.length >= 3 ? 3 : d.length));
    if (d.length > 3) parts.add(d.substring(3, d.length >= 6 ? 6 : d.length));
    if (d.length > 6) parts.add(d.substring(6, d.length >= 8 ? 8 : d.length));
    if (d.length > 8) parts.add(d.substring(8, d.length >= 10 ? 10 : d.length));
    final formatted = '+7 ${parts.join(' ')}';
    return TextEditingValue(text: formatted, selection: TextSelection.collapsed(offset: formatted.length));
  }
}