import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/post_model.dart';
import '../../data/models/reaction_model.dart';
import '../../data/services/social_api_service.dart';

// --- Events ---
abstract class SocialFeedEvent {}
class LoadFeed extends SocialFeedEvent {
  final String? category;
  LoadFeed({this.category});
}
class RefreshFeed extends SocialFeedEvent {}
class FilterByCategory extends SocialFeedEvent {
  final String? category;
  FilterByCategory(this.category);
}
class PostCreated extends SocialFeedEvent {
  final PostModel post;
  PostCreated(this.post);
}
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
  final Map<int, List<ReactionModel>> postReactions; // postId -> reactions
  SocialFeedLoaded(this.posts, this.currentCategory, [this.postReactions = const {}]);
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
        final postReactions = await _fetchReactionsForPosts(posts.map((p) => p.id).toList());
        emit(SocialFeedLoaded(posts, _currentCategory, postReactions));
      } catch (e) {
        emit(SocialFeedError(e.toString()));
      }
    });

    on<RefreshFeed>((event, emit) async {
      if (state is SocialFeedLoaded) {
        try {
          final posts = await _apiService.getFeed(category: _currentCategory);
          final postReactions = await _fetchReactionsForPosts(posts.map((p) => p.id).toList());
          emit(SocialFeedLoaded(posts, _currentCategory, postReactions));
        } catch (e) {
          emit(SocialFeedError(e.toString()));
        }
      }
    });

    on<FilterByCategory>((event, emit) async {
      _currentCategory = event.category;
      emit(SocialFeedLoading());
      try {
        final posts = await _apiService.getFeed(category: _currentCategory);
        final postReactions = await _fetchReactionsForPosts(posts.map((p) => p.id).toList());
        emit(SocialFeedLoaded(posts, _currentCategory, postReactions));
      } catch (e) {
        emit(SocialFeedError(e.toString()));
      }
    });

    on<PostCreated>((event, emit) {
      if (state is SocialFeedLoaded) {
        final loaded = state as SocialFeedLoaded;
        // Only add if no filter or post matches current category
        if (_currentCategory == null || event.post.category == _currentCategory) {
          final updated = [event.post, ...loaded.posts];
          // New post has no reactions yet
          final updatedReactions = Map<int, List<ReactionModel>>.from(loaded.postReactions);
          emit(SocialFeedLoaded(updated, _currentCategory, updatedReactions));
        }
      }
    });

    on<ToggleReactionEvent>((event, emit) async {
      try {
        await _apiService.togglePostReaction(event.postId, event.reactionType);
        if (state is SocialFeedLoaded) {
          final loaded = state as SocialFeedLoaded;
          final reactions = await _apiService.getPostReactions(event.postId);
          final updatedReactions = Map<int, List<ReactionModel>>.from(loaded.postReactions)
            ..[event.postId] = reactions;
          emit(SocialFeedLoaded(loaded.posts, _currentCategory, updatedReactions));
        }
      } catch (e) {
        // Handle silently or show snackbar
      }
    });
  }

  Future<Map<int, List<ReactionModel>>> _fetchReactionsForPosts(List<int> postIds) async {
    final results = await Future.wait(
      postIds.map((id) => _apiService.getPostReactions(id).catchError((_) => <ReactionModel>[])),
    );
    return {for (var i = 0; i < postIds.length; i++) postIds[i]: results[i]};
  }
}
