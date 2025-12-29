class ChatMessageModel {
  final String id;
  final String from;
  final String text;
  final int at;
  final String kind;
  final String? url;
  final String? path;
  final String? name;
  final String? mime;
  final int? size;
  const ChatMessageModel({required this.id, required this.from, required this.text, required this.at, this.kind = 'text', this.url, this.path, this.name, this.mime, this.size});
  factory ChatMessageModel.fromMap(String id, Map<String, dynamic> m) {
    return ChatMessageModel(
      id: id,
      from: (m['from'] as String?) ?? '',
      text: (m['text'] as String?) ?? '',
      at: (m['at'] as int?) ?? 0,
      kind: (m['kind'] as String?) ?? 'text',
      url: m['url'] as String?,
      path: m['path'] as String?,
      name: m['name'] as String?,
      mime: m['mime'] as String?,
      size: m['size'] as int?,
    );
  }
  Map<String, dynamic> toJson() => {
        'id': id,
        'from': from,
        'text': text,
        'at': at,
        'kind': kind,
        if (url != null) 'url': url,
        if (path != null) 'path': path,
        if (name != null) 'name': name,
        if (mime != null) 'mime': mime,
        if (size != null) 'size': size,
      };
}