import 'mood_type.dart' show MoodType, moodTypeFromString;

class ObjectifModel {
  final int id;
  final DateTime objectifDate;
  final MoodType mood;
  final bool consumed;
  final String? notes;
  final DateTime? createdAt;

  ObjectifModel({
    required this.id,
    required this.objectifDate,
    required this.mood,
    required this.consumed,
    this.notes,
    this.createdAt,
  });

  factory ObjectifModel.fromJson(Map<String, dynamic> json) {
    return ObjectifModel(
      id: json['id'] as int,
      objectifDate: DateTime.parse(json['objectifDate'] as String),
      mood: moodTypeFromString(json['mood'] as String),
      consumed: json['consumed'] as bool,
      notes: json['notes'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'objectifDate': objectifDate.toIso8601String().split('T')[0],
      'mood': mood.name.toUpperCase(),
      'consumed': consumed,
      'notes': notes,
      'createdAt': createdAt?.toIso8601String(),
    };
  }
}
