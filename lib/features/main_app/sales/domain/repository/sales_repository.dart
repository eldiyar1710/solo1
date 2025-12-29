import '../entities/sale.dart';

abstract class SalesRepository {
  Future<List<Sale>> getSales();
  Future<void> addSale(Sale sale);
}