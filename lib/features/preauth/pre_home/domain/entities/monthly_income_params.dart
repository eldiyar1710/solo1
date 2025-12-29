class MonthlyIncomeParams {
  final int connections;
  final int payoutMonths;
  final double appPrice;
  final double commissionRate;
  const MonthlyIncomeParams({
    required this.connections,
    required this.payoutMonths,
    this.appPrice = 20000.0,
    this.commissionRate = 0.10,
  });
}