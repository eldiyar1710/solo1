import '../../domain/repository/pre_home_repository.dart';
import '../../domain/entities/monthly_income_params.dart';
import '../datasource/pre_home_local_datasource.dart';
import '../models/monthly_income_params_model.dart';

class PreHomeRepositoryImpl implements PreHomeRepository {
  final PreHomeLocalDataSource ds;
  PreHomeRepositoryImpl(this.ds);
  @override
  MonthlyIncomeParams? get lastParams => ds.last;
  @override
  void saveParams(MonthlyIncomeParams params) => ds.save(
        MonthlyIncomeParamsModel(
          connections: params.connections,
          payoutMonths: params.payoutMonths,
          appPrice: params.appPrice,
          commissionRate: params.commissionRate,
        ),
      );
}