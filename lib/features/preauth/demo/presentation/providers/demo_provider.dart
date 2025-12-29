import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:solo1/features/preauth/demo/data/datasource/demo_local_datasource.dart';
import 'package:solo1/features/preauth/demo/data/repository/demo_repository_impl.dart';
import 'package:solo1/features/preauth/demo/domain/repository/demo_repository.dart';
import 'package:solo1/features/preauth/demo/domain/usecases/add_demo_sale.dart';

class DemoState {
  final bool isSelling;
  final int totalTerminalsSold;
  final double currentBalance;
  const DemoState({this.isSelling = true, this.totalTerminalsSold = 0, this.currentBalance = 0.0});

  DemoState copyWith({bool? isSelling, int? totalTerminalsSold, double? currentBalance}) => DemoState(
        isSelling: isSelling ?? this.isSelling,
        totalTerminalsSold: totalTerminalsSold ?? this.totalTerminalsSold,
        currentBalance: currentBalance ?? this.currentBalance,
      );
}

class DemoController extends StateNotifier<DemoState> {
  static const double monthlyIncomePerTerminal = 2000.0;
  final AddDemoSale addDemoSale;
  final DemoRepository repo;
  DemoController(this.addDemoSale, this.repo) : super(const DemoState()) {
    Future(() async {
      final total = await repo.loadTotalSold();
      final balance = monthlyIncomePerTerminal * total;
      state = DemoState(isSelling: true, totalTerminalsSold: total, currentBalance: balance);
    });
  }

  void startNewSale() => state = state.copyWith(isSelling: true);

  void completeSale(int terminalsSold) {
    final total = addDemoSale(terminalsSold);
    final balance = monthlyIncomePerTerminal * total;
    state = DemoState(isSelling: false, totalTerminalsSold: total, currentBalance: balance);
  }
}

final demoProvider = StateNotifierProvider<DemoController, DemoState>((ref) {
  final repo = DemoRepositoryImpl(DemoLocalDataSource());
  final usecase = AddDemoSale(repo);
  return DemoController(usecase, repo);
});
