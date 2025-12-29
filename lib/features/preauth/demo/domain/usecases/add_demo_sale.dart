import '../repository/demo_repository.dart';

class AddDemoSale {
  final DemoRepository repo;
  AddDemoSale(this.repo);
  int call(int count) {
    repo.addSale(count);
    return repo.totalSold;
  }
}