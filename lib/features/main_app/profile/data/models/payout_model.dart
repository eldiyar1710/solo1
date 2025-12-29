class PayoutModel {
  final String client;
  final int amount;
  final int date;
  final String status;
  const PayoutModel({required this.client, required this.amount, required this.date, required this.status});
  factory PayoutModel.fromJson(Map<String, dynamic> j) => PayoutModel(client: j['client'] as String, amount: j['amount'] as int, date: j['date'] as int, status: j['status'] as String);
  Map<String, dynamic> toJson() => {'client': client, 'amount': amount, 'date': date, 'status': status};
}