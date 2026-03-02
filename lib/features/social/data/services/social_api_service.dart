import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/constants/api_constants.dart';
import '../models/post_model.dart';
import '../models/comment_model.dart';
import '../models/reaction_model.dart';

class SocialApiService {
  Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken');
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // --- POSTS ---

  Future<List<PostModel>> getFeed({String? category, int page = 0, int size = 10}) async {
    final queryParams = {
      if (category != null) 'category': category,
      'page': page.toString(),
      'size': size.toString(),
    };
    
    final uri = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.socialPosts}').replace(queryParameters: queryParams);
    final response = await http.get(uri, headers: await _getHeaders());

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      final List<dynamic> content = data['content'];
      return content.map((json) => PostModel.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load feed: ${response.statusCode}');
    }
  }

  Future<PostModel> getPostById(int postId) async {
    final uri = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.socialPosts}/$postId');
    final response = await http.get(uri, headers: await _getHeaders());

    if (response.statusCode == 200) {
      return PostModel.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load post: ${response.statusCode}');
    }
  }

  Future<PostModel> createPost(String content, String category, String moodEmoji, {String? mediaUrl}) async {
    final uri = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.socialPosts}');
    final body = json.encode({
      'content': content,
      'category': category,
      'moodEmoji': moodEmoji,
      if (mediaUrl != null) 'mediaUrl': mediaUrl,
    });

    final response = await http.post(uri, headers: await _getHeaders(), body: body);

    if (response.statusCode == 200) {
      return PostModel.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to create post: ${response.statusCode}');
    }
  }

  Future<PostModel> editPost(int postId, String content, String category, String moodEmoji, {String? mediaUrl}) async {
    final uri = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.socialPosts}/$postId');
    final body = json.encode({
      'content': content,
      'category': category,
      'moodEmoji': moodEmoji,
      if (mediaUrl != null) 'mediaUrl': mediaUrl,
    });

    final response = await http.put(uri, headers: await _getHeaders(), body: body);

    if (response.statusCode == 200) {
      return PostModel.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to edit post: ${response.statusCode}');
    }
  }

  Future<void> deletePost(int postId) async {
    final uri = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.socialPosts}/$postId');
    final response = await http.delete(uri, headers: await _getHeaders());

    if (response.statusCode != 200) {
      throw Exception('Failed to delete post: ${response.statusCode}');
    }
  }

  // --- COMMENTS ---

  Future<List<CommentModel>> getComments(int postId, {int page = 0, int size = 20}) async {
    final uri = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.socialPosts}/$postId/comments?page=$page&size=$size');
    final response = await http.get(uri, headers: await _getHeaders());

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      final List<dynamic> content = data['content'];
      return content.map((json) => CommentModel.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load comments: ${response.statusCode}');
    }
  }

  Future<CommentModel> addComment(int postId, String content, {int? parentCommentId}) async {
    final uri = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.socialPosts}/$postId/comments');
    final body = json.encode({
      'content': content,
      if (parentCommentId != null) 'parentCommentId': parentCommentId,
    });

    final response = await http.post(uri, headers: await _getHeaders(), body: body);

    if (response.statusCode == 200) {
      return CommentModel.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to add comment: ${response.statusCode}');
    }
  }

  // --- REACTIONS ---

  Future<void> togglePostReaction(int postId, String reactionType) async {
    final uri = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.socialPosts}/$postId/reactions');
    final body = json.encode({'reactionType': reactionType});
    
    final response = await http.post(uri, headers: await _getHeaders(), body: body);
    if (response.statusCode != 200) throw Exception('Failed to toggle reaction');
  }

  Future<void> toggleCommentReaction(int commentId, String reactionType) async {
    final uri = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.socialCommentsBase}/$commentId/reactions');
    final body = json.encode({'reactionType': reactionType});
    
    final response = await http.post(uri, headers: await _getHeaders(), body: body);
    if (response.statusCode != 200) throw Exception('Failed to toggle reaction');
  }

  Future<List<ReactionModel>> getPostReactions(int postId) async {
    final uri = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.socialPosts}/$postId/reactions');
    final response = await http.get(uri, headers: await _getHeaders());

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => ReactionModel.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load reactions: ${response.statusCode}');
    }
  }
}
