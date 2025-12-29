import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasource/sales_local_datasource.dart';
import '../../data/repository/sales_repository_impl.dart';
import '../../domain/entities/sale.dart';
import '../../domain/usecases/add_sale.dart';
import 'package:solo1/core/sync/sync_service.dart';
import 'package:hive/hive.dart';
import 'package:flutter/foundation.dart';

final salesRepositoryProvider = Provider<SalesRepositoryImpl>((ref) => SalesRepositoryImpl(local: SalesLocalDataSource()));

class SalesState {
  final List<Sale> items;
  final bool loading;
  const SalesState({this.items = const [], this.loading = false});
  SalesState copyWith({List<Sale>? items, bool? loading}) => SalesState(items: items ?? this.items, loading: loading ?? this.loading);
}

class SalesController extends StateNotifier<SalesState> {
  final SalesRepositoryImpl repo;
  final AddSale add;
  final SyncService sync;
  SalesController(this.repo, this.add, this.sync) : super(const SalesState());
  Future<void> load() async {
    state = state.copyWith(loading: true);
    final list = await repo.getSales();
    state = SalesState(items: list, loading: false);
  }
  Future<void> createQuickSale() async {
    final now = DateTime.now().millisecondsSinceEpoch;
    final box = Hive.box('userBox');
    final raw = box.get('agent');
    final agentId = raw is Map ? (raw['agentId'] as String?) : null;
    final agentName = raw is Map ? ((raw['fullName'] as String?) ?? '') : '';
    final s = Sale(saleId: now.toString(), agentId: agentId, quantity: 1, monthlyPrice: 10000, version: 'v$now', updatedAt: now);
    await add(s);
    final isTest = raw is Map && ((raw['status'] as String?) == 'test' || (raw['email'] as String?)?.toLowerCase() == 'test@solo1.app');
    if (!kReleaseMode && isTest) {
      await load();
    } else {
      await sync.enqueueSale({
        'saleId': s.saleId,
        'agentId': agentId,
        'agentName': agentName,
        'quantity': s.quantity,
        'monthlyPrice': s.monthlyPrice,
        'version': s.version,
        'updatedAt': s.updatedAt,
      }, idempotencyKey: s.saleId);
      await sync.processQueue();
      await load();
    }
  }
}

final salesProvider = StateNotifierProvider<SalesController, SalesState>((ref) {
  final repo = ref.read(salesRepositoryProvider);
  return SalesController(repo, AddSale(repo), SyncService());
});