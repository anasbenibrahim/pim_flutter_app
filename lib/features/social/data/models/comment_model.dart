class CommentModel {
  final int id;
  final String content;
  final String pseudonym;
  final int postId;
  final int? parentCommentId;
  final DateTime createdAt;
  final List<CommentModel> replies;

  CommentModel({
    required this.id,
    required this.content,
    required this.pseudonym,
    required this.postId,
    this.parentCommentId,
    required this.createdAt,
    this.replies = const [],
  });

  factory CommentModel.fromJson(Map<String, dynamic> json) {
    return CommentModel(
      id: json['id'],
      content: json['content'],
      pseudonym: json['pseudonym'],
      postId: json['postId'],
      parentCommentId: json['parentCommentId'],
      createdAt: DateTime.parse(json['createdAt']),
      replies: json['replies'] != null
          ? List<CommentModel>.from(
              json['replies'].map((x) => CommentModel.fromJson(x)))
          : [],
    );
  }
}
