import 'package:shared_preferences/shared_preferences.dart';
import '../models/demo_sale_model.dart';

class DemoLocalDataSource {
  static const _kTotalSold = 'demo_total_sold';
  final List<DemoSaleModel> _items = [];
  int _totalCache = 0;
  int get totalSold => _totalCache;
  Future<int> loadTotalSold() async {
    final prefs = await SharedPreferences.getInstance();
    _totalCache = prefs.getInt(_kTotalSold) ?? 0;
    return _totalCache;
  }
  void add(DemoSaleModel sale) {
    _items.add(sale);
    _totalCache += sale.count;
    SharedPreferences.getInstance().then((p) => p.setInt(_kTotalSold, _totalCache));
  }
}