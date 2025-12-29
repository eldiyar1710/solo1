import '../../data/datasource/sales_local_datasource.dart';
import '../../data/datasource/sales_remote_datasource.dart';
import '../../data/models/sale_model.dart';
import '../../domain/entities/sale.dart';
import '../../domain/repository/sales_repository.dart';

class SalesRepositoryImpl implements SalesRepository {
  final SalesLocalDataSource local;
  final SalesRemoteDataSource remote;
  SalesRepositoryImpl({required this.local, SalesRemoteDataSource? remote}) : remote = remote ?? SalesRemoteDataSource();
  @override
  Future<List<Sale>> getSales() async {
    final m = await local.load();
    return m.map((e) => Sale(saleId: e.saleId, agentId: e.agentId, quantity: e.quantity, monthlyPrice: e.monthlyPrice, version: e.version, updatedAt: e.updatedAt)).toList();
  }
  @override
  Future<void> addSale(Sale sale) {
    return local.append(SaleModel(saleId: sale.saleId, agentId: sale.agentId, quantity: sale.quantity, monthlyPrice: sale.monthlyPrice, version: sale.version, updatedAt: sale.updatedAt));
  }
  Future<List<Sale>> getRemoteSalesByAgent(String agentId) async {
    final list = await remote.listByAgent(agentId);
    return list.map((e) => Sale(saleId: e.saleId, agentId: e.agentId, quantity: e.quantity, monthlyPrice: e.monthlyPrice, version: e.version, updatedAt: e.updatedAt)).toList();
  }
}