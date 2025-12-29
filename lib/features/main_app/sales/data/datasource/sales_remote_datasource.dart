import 'package:solo1/core/data/remote/firebase_remote_datasource.dart';
import '../models/sale_model.dart';

class SalesRemoteDataSource {
  final FirebaseRemoteDataSource remote;
  SalesRemoteDataSource({FirebaseRemoteDataSource? remote}) : remote = remote ?? FirebaseRemoteDataSource();
  Future<List<SaleModel>> listByAgent(String agentId) async {
    final raw = await remote.salesByAgent(agentId);
    return raw.map((e) => SaleModel.fromJson(e)).toList();
  }
}