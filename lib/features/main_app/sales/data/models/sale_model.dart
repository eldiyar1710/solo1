class SaleModel {
  final String saleId;
  final String? agentId;
  final int quantity;
  final int monthlyPrice;
  final String version;
  final int updatedAt;
  const SaleModel({required this.saleId, this.agentId, required this.quantity, required this.monthlyPrice, required this.version, required this.updatedAt});
  factory SaleModel.fromJson(Map<String, dynamic> j) => SaleModel(saleId: j['saleId'] as String, agentId: j['agentId'] as String?, quantity: j['quantity'] as int, monthlyPrice: j['monthlyPrice'] as int, version: j['version'] as String? ?? '', updatedAt: j['updatedAt'] as int? ?? 0);
  Map<String, dynamic> toJson() => {'saleId': saleId, 'agentId': agentId, 'quantity': quantity, 'monthlyPrice': monthlyPrice, 'version': version, 'updatedAt': updatedAt};
}