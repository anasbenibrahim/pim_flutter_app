class PostModel {
  final int id;
  final String content;
  final String? mediaUrl;
  final String category;
  final String moodEmoji;
  final String pseudonym;
  final String status;
  final String authorRole;
  final DateTime createdAt;

  PostModel({
    required this.id,
    required this.content,
    this.mediaUrl,
    required this.category,
    required this.moodEmoji,
    required this.pseudonym,
    required this.status,
    required this.authorRole,
    required this.createdAt,
  });

  factory PostModel.fromJson(Map<String, dynamic> json) {
    return PostModel(
      id: json['id'],
      content: json['content'],
      mediaUrl: json['mediaUrl'],
      category: json['category'],
      moodEmoji: json['moodEmoji'],
      pseudonym: json['pseudonym'],
      status: json['status'],
      authorRole: json['authorRole'] ?? 'USER',
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'mediaUrl': mediaUrl,
      'category': category,
      'moodEmoji': moodEmoji,
      'pseudonym': pseudonym,
      'status': status,
      'authorRole': authorRole,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
