import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/post_model.dart';
import '../../data/models/comment_model.dart';
import '../../data/services/social_api_service.dart';
import '../../data/services/social_websocket_service.dart';

// --- Events ---
abstract class PostDetailEvent {}
class LoadPostDetail extends PostDetailEvent {
  final int postId;
  LoadPostDetail(this.postId);
}
class AddCommentEvent extends PostDetailEvent {
  final String content;
  final int? parentId;
  AddCommentEvent(this.content, {this.parentId});
}
class NewCommentReceived extends PostDetailEvent {
  final CommentModel comment;
  NewCommentReceived(this.comment);
}

// --- States ---
abstract class PostDetailState {}
class PostDetailLoading extends PostDetailState {}
class PostDetailLoaded extends PostDetailState {
  final PostModel post;
  final List<CommentModel> comments;
  PostDetailLoaded(this.post, this.comments);
}
class PostDetailError extends PostDetailState {
  final String message;
  PostDetailError(this.message);
}

// --- Bloc ---
class PostDetailBloc extends Bloc<PostDetailEvent, PostDetailState> {
  final SocialApiService _apiService;
  late final SocialWebSocketService _wsService;
  int? _currentPostId;
  PostModel? _currentPost;

  PostDetailBloc(this._apiService) : super(PostDetailLoading()) {
    _wsService = SocialWebSocketService(
      onCommentReceived: (comment) => add(NewCommentReceived(comment)),
    );

    on<LoadPostDetail>((event, emit) async {
      emit(PostDetailLoading());
      try {
        _currentPostId = event.postId;
        
        // Note: In real app, you might want to fetch single post + comments.
        // Assuming post is passed via router or we just fetch comments.
        // To keep it simple, we'll just use a mock post or fetch from feed if needed,
        // but let's assume we just fetch comments for the post ID here.
        final comments = await _apiService.getComments(event.postId);
        
        // Mock post just for structure. If API had getPostById, we'd call it.
        // For now, assume it's loaded from UI. We will only manage comments mostly.
        _currentPost = PostModel(
            id: event.postId, content: "Loading from feed...", category: "VICTORY", moodEmoji: "HAPPY", pseudonym: "User", status: "APPROVED", authorRole: "USER", createdAt: DateTime.now()
        );

        _wsService.connect(event.postId);
        emit(PostDetailLoaded(_currentPost!, comments));
      } catch (e) {
        emit(PostDetailError(e.toString()));
      }
    });

    on<AddCommentEvent>((event, emit) async {
      if (state is PostDetailLoaded && _currentPostId != null) {
        try {
          await _apiService.addComment(_currentPostId!, event.content, parentCommentId: event.parentId);
          // Backend broadcasts via WebSocket, we catch it in NewCommentReceived
        } catch (e) {
          // handle error
        }
      }
    });

    on<NewCommentReceived>((event, emit) {
      if (state is PostDetailLoaded) {
        final currentState = state as PostDetailLoaded;
        final updatedComments = List<CommentModel>.from(currentState.comments);
        
        // Logic to insert at top level or as reply
        if (event.comment.parentCommentId == null) {
          updatedComments.add(event.comment);
        } else {
          // It's a reply, find parent and append
          for (int i = 0; i < updatedComments.length; i++) {
            if (updatedComments[i].id == event.comment.parentCommentId) {
              final newReplies = List<CommentModel>.from(updatedComments[i].replies)..add(event.comment);
              updatedComments[i] = CommentModel(
                id: updatedComments[i].id, 
                content: updatedComments[i].content, 
                pseudonym: updatedComments[i].pseudonym, 
                postId: updatedComments[i].postId, 
                createdAt: updatedComments[i].createdAt,
                replies: newReplies
              );
              break;
            }
          }
        }
        
        emit(PostDetailLoaded(currentState.post, updatedComments));
      }
    });
  }

  @override
  Future<void> close() {
    _wsService.disconnect();
    return super.close();
  }
}
