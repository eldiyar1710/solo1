import '../entities/sale.dart';
import '../repository/sales_repository.dart';

class AddSale {
  final SalesRepository repo;
  AddSale(this.repo);
  Future<void> call(Sale sale) => repo.addSale(sale);
}