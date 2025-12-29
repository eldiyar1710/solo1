class ChatMessage {
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
  const ChatMessage({required this.id, required this.from, required this.text, required this.at, this.kind = 'text', this.url, this.path, this.name, this.mime, this.size});
}