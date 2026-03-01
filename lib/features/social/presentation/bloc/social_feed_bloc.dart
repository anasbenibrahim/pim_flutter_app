import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/post_model.dart';
import '../../data/services/social_api_service.dart';

// --- Events ---
abstract class SocialFeedEvent {}
class LoadFeed extends SocialFeedEvent {
  final String? category;
  LoadFeed({this.category});
}
class RefreshFeed extends SocialFeedEvent {}
class ToggleReactionEvent extends SocialFeedEvent {
  final int postId;
  final String reactionType;
  ToggleReactionEvent(this.postId, this.reactionType);
}

// --- States ---
abstract class SocialFeedState {}
class SocialFeedLoading extends SocialFeedState {}
class SocialFeedLoaded extends SocialFeedState {
  final List<PostModel> posts;
  final String? currentCategory;
  SocialFeedLoaded(this.posts, this.currentCategory);
}
class SocialFeedError extends SocialFeedState {
  final String message;
  SocialFeedError(this.message);
}

// --- Bloc ---
class SocialFeedBloc extends Bloc<SocialFeedEvent, SocialFeedState> {
  final SocialApiService _apiService;
  String? _currentCategory;

  SocialFeedBloc(this._apiService) : super(SocialFeedLoading()) {
    on<LoadFeed>((event, emit) async {
      emit(SocialFeedLoading());
      try {
        _currentCategory = event.category;
        final posts = await _apiService.getFeed(category: _currentCategory);
        emit(SocialFeedLoaded(posts, _currentCategory));
      } catch (e) {
        emit(SocialFeedError(e.toString()));
      }
    });

    on<RefreshFeed>((event, emit) async {
      if (state is SocialFeedLoaded) {
        try {
          final posts = await _apiService.getFeed(category: _currentCategory);
          emit(SocialFeedLoaded(posts, _currentCategory));
        } catch (e) {
          emit(SocialFeedError(e.toString()));
        }
      }
    });

    on<ToggleReactionEvent>((event, emit) async {
      try {
        await _apiService.togglePostReaction(event.postId, event.reactionType);
        // Refresh feed to update reaction counts quietly
        // Note: For optimal UX, implement optimistic updates instead of full refresh
        if (state is SocialFeedLoaded) {
          final posts = await _apiService.getFeed(category: _currentCategory);
          emit(SocialFeedLoaded(posts, _currentCategory));
        }
      } catch (e) {
        // Handle silently or show snackbar
      }
    });
  }
}
