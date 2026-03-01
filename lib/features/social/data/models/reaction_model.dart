class ReactionModel {
  final String reactionType;
  final int count;
  final bool userReacted;

  ReactionModel({
    required this.reactionType,
    required this.count,
    required this.userReacted,
  });

  factory ReactionModel.fromJson(Map<String, dynamic> json) {
    return ReactionModel(
      reactionType: json['reactionType'],
      count: json['count'],
      userReacted: json['userReacted'] ?? false,
    );
  }
}
