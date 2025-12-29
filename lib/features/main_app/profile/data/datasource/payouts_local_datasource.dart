import 'package:hive/hive.dart';
import '../models/payout_model.dart';

class PayoutsLocalDataSource {
  static const _box = 'users';
  Future<List<PayoutModel>> loadPaid() async {
    final box = Hive.box(_box);
    final raw = (box.get('payouts_paid') as List?) ?? [];
    if (raw.isEmpty) {
      final now = DateTime.now();
      final demo = [
        PayoutModel(client: 'Клиент: Магазин №5', amount: 15000, date: DateTime(now.year, now.month, now.day - 2).millisecondsSinceEpoch, status: 'paid'),
        PayoutModel(client: 'Клиент: TOO Рога и копыта', amount: 20000, date: DateTime(now.year, now.month, now.day - 7).millisecondsSinceEpoch, status: 'paid'),
        PayoutModel(client: 'Клиент: Кофейня Coffee', amount: 12000, date: DateTime(now.year, now.month, now.day - 12).millisecondsSinceEpoch, status: 'paid'),
      ];
      return demo;
    }
    return raw.map((e) => PayoutModel.fromJson(Map<String, dynamic>.from(e as Map))).toList();
  }
  Future<List<PayoutModel>> loadPending() async {
    final box = Hive.box(_box);
    final raw = (box.get('payouts_pending') as List?) ?? [];
    if (raw.isEmpty) {
      final now = DateTime.now();
      final demo = [
        PayoutModel(client: 'Клиент: Ресторан Вкус', amount: 25000, date: now.add(const Duration(days: 8)).millisecondsSinceEpoch, status: 'pending'),
        PayoutModel(client: 'Клиент: Салон красоты', amount: 18000, date: now.add(const Duration(days: 5)).millisecondsSinceEpoch, status: 'pending'),
        PayoutModel(client: 'Клиент: Фитнес-центр', amount: 35000, date: now.add(const Duration(days: 12)).millisecondsSinceEpoch, status: 'pending'),
      ];
      return demo;
    }
    return raw.map((e) => PayoutModel.fromJson(Map<String, dynamic>.from(e as Map))).toList();
  }
  Future<void> savePaid(List<PayoutModel> items) async {
    final box = Hive.box(_box);
    await box.put('payouts_paid', items.map((e) => e.toJson()).toList());
  }
  Future<void> savePending(List<PayoutModel> items) async {
    final box = Hive.box(_box);
    await box.put('payouts_pending', items.map((e) => e.toJson()).toList());
  }
  String? getCardNumber() {
    final box = Hive.box(_box);
    return box.get('card_number') as String?;
  }
  Future<void> setCardNumber(String value) async {
    final box = Hive.box(_box);
    await box.put('card_number', value);
  }
}