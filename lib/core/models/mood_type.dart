enum MoodType {
  happy,   // 😊
  calm,    // 🙂
  anxious, // 😟
  sad,     // 😢
}

extension MoodTypeExtension on MoodType {
  String get emoji {
    switch (this) {
      case MoodType.happy:
        return '😊';
      case MoodType.calm:
        return '🙂';
      case MoodType.anxious:
        return '😟';
      case MoodType.sad:
        return '😢';
    }
  }
  
  String get label {
    switch (this) {
      case MoodType.happy:
        return 'Happy';
      case MoodType.calm:
        return 'Calm';
      case MoodType.anxious:
        return 'Anxious';
      case MoodType.sad:
        return 'Sad';
    }
  }
}

MoodType moodTypeFromString(String value) {
  return MoodType.values.firstWhere(
    (e) => e.name.toLowerCase() == value.toLowerCase(),
    orElse: () => MoodType.calm,
  );
}
