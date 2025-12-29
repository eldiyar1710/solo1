import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:solo1/features/preauth/pre_home/data/datasource/pre_home_local_datasource.dart';
import 'package:solo1/features/preauth/pre_home/data/repository/pre_home_repository_impl.dart';
import 'package:solo1/features/preauth/pre_home/domain/entities/monthly_income_params.dart';
import 'package:solo1/features/preauth/pre_home/domain/repository/pre_home_repository.dart';

class PreHomeState {
  final int connections;
  final int payoutMonths;
  const PreHomeState({this.connections = 12, this.payoutMonths = 36});

  PreHomeState copyWith({int? connections, int? payoutMonths}) => PreHomeState(
        connections: connections ?? this.connections,
        payoutMonths: payoutMonths ?? this.payoutMonths,
      );
}

class PreHomeController extends StateNotifier<PreHomeState> {
  final PreHomeRepository repo;
  final PreHomeLocalDataSource ds;
  PreHomeController(this.repo, this.ds) : super(const PreHomeState()) {
    Future(() async {
      await ds.load();
      final last = repo.lastParams;
      if (last != null) {
        state = PreHomeState(connections: last.connections, payoutMonths: last.payoutMonths);
      }
    });
  }

  void incConnections() {
    final v = (state.connections + 1).clamp(1, 100);
    state = state.copyWith(connections: v);
    repo.saveParams(MonthlyIncomeParams(connections: v, payoutMonths: state.payoutMonths));
  }
  void decConnections() {
    final v = (state.connections - 1).clamp(1, 100);
    state = state.copyWith(connections: v);
    repo.saveParams(MonthlyIncomeParams(connections: v, payoutMonths: state.payoutMonths));
  }

  void incPayoutMonths() {
    final v = (state.payoutMonths + 6).clamp(12, 60);
    state = state.copyWith(payoutMonths: v);
    repo.saveParams(MonthlyIncomeParams(connections: state.connections, payoutMonths: v));
  }
  void decPayoutMonths() {
    final v = (state.payoutMonths - 6).clamp(12, 60);
    state = state.copyWith(payoutMonths: v);
    repo.saveParams(MonthlyIncomeParams(connections: state.connections, payoutMonths: v));
  }
}

final preHomeProvider = StateNotifierProvider<PreHomeController, PreHomeState>((ref) {
  final ds = PreHomeLocalDataSource();
  final repo = PreHomeRepositoryImpl(ds);
  return PreHomeController(repo, ds);
});