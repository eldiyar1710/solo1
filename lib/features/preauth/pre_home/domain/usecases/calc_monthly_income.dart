import 'dart:math' as math;
import '../entities/monthly_income_params.dart';
import '../entities/monthly_income_stats.dart';

class CalcMonthlyIncome {
  MonthlyIncomeStats call(MonthlyIncomeParams params) {
    final monthlyPerConnection = params.appPrice * params.commissionRate;
    final base = monthlyPerConnection * params.connections;
    final months = const ['Янв','Фев','Мар','Апр','Май','Июн'];
    final k = params.payoutMonths / 36.0;
    final factors = [0.6, 0.8, 1.0, 1.1, 1.2, 1.3].map((f) => f * k).toList();
    final values = List<double>.generate(months.length, (i) => base * factors[i]);
    final avgIncome = values.reduce((a,b)=>a+b) / values.length;
    final growthPercent = ((values.last - values.first) / values.first * 100).clamp(-999, 999).toDouble();
    final maxYear = values.reduce(math.max) * 12;
    return MonthlyIncomeStats(months: months, values: values, avgIncome: avgIncome, growthPercent: growthPercent, maxYear: maxYear);
  }
}