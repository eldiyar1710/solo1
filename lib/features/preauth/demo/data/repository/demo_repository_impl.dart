import '../../domain/repository/demo_repository.dart';
import '../datasource/demo_local_datasource.dart';
import '../models/demo_sale_model.dart';

class DemoRepositoryImpl implements DemoRepository {
  final DemoLocalDataSource ds;
  DemoRepositoryImpl(this.ds);
  @override
  int get totalSold => ds.totalSold;
  @override
  void addSale(int count) => ds.add(DemoSaleModel(count: count, at: DateTime.now()));
  @override
  Future<int> loadTotalSold() => ds.loadTotalSold();
}