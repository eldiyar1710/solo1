import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasource/payouts_local_datasource.dart';
import '../../data/models/payout_model.dart';

class PayoutsState {
  final List<PayoutModel> paid;
  final List<PayoutModel> pending;
  final String? card;
  final bool loading;
  const PayoutsState({this.paid = const [], this.pending = const [], this.card, this.loading = false});
  PayoutsState copyWith({List<PayoutModel>? paid, List<PayoutModel>? pending, String? card, bool? loading}) =>
      PayoutsState(paid: paid ?? this.paid, pending: pending ?? this.pending, card: card ?? this.card, loading: loading ?? this.loading);
}

class PayoutsController extends StateNotifier<PayoutsState> {
  final PayoutsLocalDataSource local;
  PayoutsController(this.local) : super(const PayoutsState());
  Future<void> load() async {
    state = state.copyWith(loading: true);
    final paid = await local.loadPaid();
    final pending = await local.loadPending();
    final card = local.getCardNumber();
    state = PayoutsState(paid: paid, pending: pending, card: card, loading: false);
  }
  Future<void> saveCard(String value) async {
    await local.setCardNumber(value);
    state = state.copyWith(card: value);
  }
}

final payoutsProvider = StateNotifierProvider<PayoutsController, PayoutsState>((ref) {
  return PayoutsController(PayoutsLocalDataSource());
});