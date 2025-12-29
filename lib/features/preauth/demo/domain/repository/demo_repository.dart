abstract class DemoRepository {
  int get totalSold;
  void addSale(int count);
  Future<int> loadTotalSold();
}