class ChatMessage {
  final String content;
  final bool isUser;
  final String? emotion;
  final DateTime timestamp;

  ChatMessage({
    required this.content,
    required this.isUser,
    this.emotion,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();
}
