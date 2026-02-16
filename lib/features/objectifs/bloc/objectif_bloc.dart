import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/services/api_service.dart';
import 'objectif_event.dart';
import 'objectif_state.dart';

class ObjectifBloc extends Bloc<ObjectifEvent, ObjectifState> {
  final ApiService apiService;

  ObjectifBloc({required this.apiService}) : super(const ObjectifInitial()) {
    on<LoadObjectifsEvent>(_onLoadObjectifs);
    on<CreateObjectifEvent>(_onCreateObjectif);
    on<DeleteObjectifEvent>(_onDeleteObjectif);
  }

  Future<void> _onLoadObjectifs(LoadObjectifsEvent event, Emitter<ObjectifState> emit) async {
    emit(const ObjectifLoading());
    try {
      final objectifs = await apiService.getObjectifs();
      emit(ObjectifLoaded(objectifs: objectifs));
    } catch (e) {
      emit(ObjectifError(message: e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onCreateObjectif(CreateObjectifEvent event, Emitter<ObjectifState> emit) async {
    emit(const ObjectifCreating());
    try {
      await apiService.createObjectif(
        objectifDate: event.objectifDate,
        mood: event.mood,
        consumed: event.consumed,
        notes: event.notes,
      );
      final objectifs = await apiService.getObjectifs();
      emit(ObjectifLoaded(objectifs: objectifs));
    } catch (e) {
      emit(ObjectifError(message: e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onDeleteObjectif(DeleteObjectifEvent event, Emitter<ObjectifState> emit) async {
    try {
      await apiService.deleteObjectif(event.id);
      final objectifs = await apiService.getObjectifs();
      emit(ObjectifLoaded(objectifs: objectifs));
    } catch (e) {
      emit(ObjectifError(message: e.toString().replaceAll('Exception: ', '')));
    }
  }
}
