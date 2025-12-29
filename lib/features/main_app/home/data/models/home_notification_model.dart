class HomeNotificationModel {
  final String id;
  final String title;
  final String message;
  final int date;
  const HomeNotificationModel({required this.id, required this.title, required this.message, required this.date});
  factory HomeNotificationModel.fromJson(Map<String, dynamic> j) => HomeNotificationModel(id: j['id'] as String, title: j['title'] as String, message: j['message'] as String, date: j['date'] as int);
  Map<String, dynamic> toJson() => {'id': id, 'title': title, 'message': message, 'date': date};
}