class HomeBannerModel {
  final String id;
  final String title;
  final String imageUrl;
  final bool active;
  final int priority;
  final String linkUrl;
  final String type;
  final String description;
  const HomeBannerModel({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.active,
    required this.priority,
    this.linkUrl = '',
    this.type = 'banner',
    this.description = '',
  });
  factory HomeBannerModel.fromJson(Map<String, dynamic> j) => HomeBannerModel(
        id: j['id'] as String,
        title: j['title'] as String,
        imageUrl: (j['imageUrl'] as String?) ?? '',
        active: (j['active'] as bool?) ?? true,
        priority: (j['priority'] as int?) ?? 0,
        linkUrl: (j['linkUrl'] as String?) ?? '',
        type: (j['type'] as String?) ?? 'banner',
        description: (j['description'] as String?) ?? '',
      );
  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'imageUrl': imageUrl,
        'active': active,
        'priority': priority,
        'linkUrl': linkUrl,
        'type': type,
        'description': description,
      };
  factory HomeBannerModel.fromJsonString(String s) {
    final parts = s.split('|');
    return HomeBannerModel(
      id: parts[0],
      title: parts[1],
      imageUrl: parts.length > 2 ? parts[2] : '',
      active: parts.length > 3 ? parts[3] == '1' : true,
      priority: parts.length > 4 ? int.tryParse(parts[4]) ?? 0 : 0,
      linkUrl: parts.length > 5 ? parts[5] : '',
      type: parts.length > 6 ? parts[6] : 'banner',
      description: parts.length > 7 ? parts[7] : '',
    );
  }
  String toJsonString() => [id, title, imageUrl, active ? '1' : '0', priority.toString(), linkUrl, type, description].join('|');
}