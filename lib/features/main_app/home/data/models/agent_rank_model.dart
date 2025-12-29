class AgentRankModel {
  final String id;
  final String name;
  final int sales;
  final double bonusPercent;
  final int rank;
  const AgentRankModel({required this.id, required this.name, required this.sales, required this.bonusPercent, required this.rank});
  factory AgentRankModel.fromJson(Map<String, dynamic> j) => AgentRankModel(
        id: j['id'] as String,
        name: j['name'] as String,
        sales: j['sales'] as int,
        bonusPercent: (j['bonusPercent'] as num).toDouble(),
        rank: j['rank'] as int,
      );
  Map<String, dynamic> toJson() => {'id': id, 'name': name, 'sales': sales, 'bonusPercent': bonusPercent, 'rank': rank};
}