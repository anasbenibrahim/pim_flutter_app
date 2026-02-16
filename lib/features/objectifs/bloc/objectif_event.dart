import 'package:equatable/equatable.dart';
import '../../../core/models/mood_type.dart';

abstract class ObjectifEvent extends Equatable {
  const ObjectifEvent();
  @override
  List<Object?> get props => [];
}

class LoadObjectifsEvent extends ObjectifEvent {
  const LoadObjectifsEvent();
}

class CreateObjectifEvent extends ObjectifEvent {
  final DateTime objectifDate;
  final MoodType mood;
  final bool consumed;
  final String? notes;

  const CreateObjectifEvent({
    required this.objectifDate,
    required this.mood,
    required this.consumed,
    this.notes,
  });

  @override
  List<Object?> get props => [objectifDate, mood, consumed, notes];
}

class DeleteObjectifEvent extends ObjectifEvent {
  final int id;

  const DeleteObjectifEvent({required this.id});

  @override
  List<Object?> get props => [id];
}
