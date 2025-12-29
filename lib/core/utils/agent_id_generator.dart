import 'dart:math';

class AgentIdGenerator {
  static const _chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';

  static String generateUniqueId(int length) {
    final rand = Random.secure();
    final codeUnits = List.generate(length, (_) => _chars.codeUnitAt(rand.nextInt(_chars.length)));
    return String.fromCharCodes(codeUnits);
  }
}