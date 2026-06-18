class ChatMessage {
  final String role; // "user" | "ai"
  final String content;
  final DateTime timestamp;

  const ChatMessage({
    required this.role,
    required this.content,
    required this.timestamp,
  });

  bool get isUser => role == 'user';

  Map<String, dynamic> toJson() => {
        'role': role,
        'content': content,
        'timestamp': timestamp.toIso8601String(),
      };

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    DateTime ts;
    try {
      ts = DateTime.parse(json['timestamp'] as String);
    } catch (_) {
      ts = DateTime.now();
    }
    return ChatMessage(
      role: json['role'] as String? ?? 'user',
      content: json['content'] as String? ?? '',
      timestamp: ts,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is ChatMessage &&
      other.role == role &&
      other.content == content &&
      other.timestamp == timestamp;

  @override
  int get hashCode => Object.hash(role, content, timestamp);
}
