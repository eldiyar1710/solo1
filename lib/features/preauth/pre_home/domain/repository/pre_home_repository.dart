import '../entities/monthly_income_params.dart';

abstract class PreHomeRepository {
  MonthlyIncomeParams? get lastParams;
  void saveParams(MonthlyIncomeParams params);
}