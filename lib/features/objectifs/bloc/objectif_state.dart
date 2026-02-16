import 'package:equatable/equatable.dart';
import '../../../core/models/objectif_model.dart';

abstract class ObjectifState extends Equatable {
  const ObjectifState();
  @override
  List<Object?> get props => [];
}

class ObjectifInitial extends ObjectifState {
  const ObjectifInitial();
}

class ObjectifLoading extends ObjectifState {
  const ObjectifLoading();
}

class ObjectifLoaded extends ObjectifState {
  final List<ObjectifModel> objectifs;

  const ObjectifLoaded({required this.objectifs});

  @override
  List<Object?> get props => [objectifs];
}

class ObjectifError extends ObjectifState {
  final String message;

  const ObjectifError({required this.message});

  @override
  List<Object?> get props => [message];
}

class ObjectifCreating extends ObjectifState {
  const ObjectifCreating();
}
