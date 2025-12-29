class Sale {
  final String saleId;
  final String? agentId;
  final int quantity;
  final int monthlyPrice;
  final String version;
  final int updatedAt;
  const Sale({required this.saleId, this.agentId, required this.quantity, required this.monthlyPrice, required this.version, required this.updatedAt});
}