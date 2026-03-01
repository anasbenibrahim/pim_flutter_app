import 'package:flutter/material.dart';

class ReactionWidget extends StatelessWidget {
  final Map<String, int> reactions; // e.g., {'💪': 5, '🤗': 2}
  final Function(String) onReact;
  final String? currentUserReaction;

  const ReactionWidget({
    Key? key,
    required this.reactions,
    required this.onReact,
    this.currentUserReaction,
  }) : super(key: key);

  static const Map<String, String> allowedReactions = {
    'STRENGTH': '💪',
    'SUPPORT': '🤗',
    'GRATITUDE': '🙏',
    'INSPIRATION': '✨',
    // Deferred: 'CONCERN': '🆘',
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: allowedReactions.entries.map((entry) {
          final type = entry.key;
          final emoji = entry.value;
          final count = reactions[type] ?? 0;
          final isReacted = currentUserReaction == type;

          return GestureDetector(
            onTap: () => onReact(type),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: Row(
                children: [
                  Text(
                    emoji,
                    style: TextStyle(
                      fontSize: 18,
                      // Subtle scale effect if user reacted
                      fontWeight: isReacted ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  if (count > 0) ...[
                    const SizedBox(width: 4),
                    Text(
                      '$count',
                      style: TextStyle(
                        fontSize: 12,
                        color: isReacted ? Colors.blue : Colors.grey[700],
                        fontWeight: isReacted ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                  ]
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
