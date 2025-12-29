class MonthlyIncomeStats {
  final List<String> months;
  final List<double> values;
  final double avgIncome;
  final double growthPercent;
  final double maxYear;
  const MonthlyIncomeStats({
    required this.months,
    required this.values,
    required this.avgIncome,
    required this.growthPercent,
    required this.maxYear,
  });
}