class QuoteModel {
  final int id;
  final String content;
  final String author;
  final String? category;

  QuoteModel({
    required this.id,
    required this.content,
    required this.author,
    this.category,
  });

  factory QuoteModel.fromJson(Map<String, dynamic> json) {
    return QuoteModel(
      id: json['id'] as int,
      content: json['content'] as String,
      author: (json['author'] as String?) ?? 'Unknown',
      category: json['category'] as String?,
    );
  }
}
