class HomeBanner {
  final String id;
  final String title;
  final String imageUrl;
  final bool active;
  final int priority;
  final String linkUrl;
  final String type;
  final String description;
  const HomeBanner({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.active,
    required this.priority,
    this.linkUrl = '',
    this.type = 'banner',
    this.description = '',
  });
}