import 'package:hive/hive.dart';
import '../models/sale_model.dart';

class SalesLocalDataSource {
  static const _box = 'sales';
  Future<List<SaleModel>> load() async {
    final box = Hive.box(_box);
    final raw = (box.get('items') as List?) ?? [];
    return raw.map((e) => SaleModel.fromJson(Map<String, dynamic>.from(e as Map))).toList();
  }
  Future<void> append(SaleModel m) async {
    final box = Hive.box(_box);
    final raw = (box.get('items') as List?)?.map((e) => Map<String, dynamic>.from(e as Map)).toList() ?? [];
    raw.add(m.toJson());
    await box.put('items', raw);
  }
}