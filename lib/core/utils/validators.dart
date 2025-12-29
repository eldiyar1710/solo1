class Validators {
  static bool isEmail(String value) {
    return RegExp(r'^[^@]+@[^@]+\.[^@]+$').hasMatch(value.trim());
  }

  static bool isKzPhoneFormatted(String value) {
    return RegExp(r'^\+7 \d{3} \d{3} \d{2} \d{2}$').hasMatch(value.trim());
  }

  static bool isIntInRange(String value, int min, int max) {
    final n = int.tryParse(value);
    if (n == null) return false;
    return n >= min && n <= max;
  }
}