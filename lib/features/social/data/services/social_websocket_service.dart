import 'dart:convert';
import 'package:stomp_dart_client/stomp_dart_client.dart';
import '../../../../core/constants/api_constants.dart';
import '../models/comment_model.dart';
import 'package:flutter/foundation.dart';

class SocialWebSocketService {
  late StompClient stompClient;
  final Function(CommentModel) onCommentReceived;

  SocialWebSocketService({required this.onCommentReceived});

  void connect(int postId) {
    stompClient = StompClient(
      config: StompConfig(
        url: ApiConstants.wsUrl,
        onConnect: (StompFrame frame) {
          debugPrint('Connected to STOMP');
          stompClient.subscribe(
            destination: '/topic/posts/$postId/comments',
            callback: (frame) {
              if (frame.body != null) {
                final Map<String, dynamic> data = json.decode(frame.body!);
                final comment = CommentModel.fromJson(data);
                onCommentReceived(comment);
              }
            },
          );
        },
        onWebSocketError: (dynamic error) => debugPrint('STOMP Error: $error'),
      ),
    );

    stompClient.activate();
  }

  void disconnect() {
    stompClient.deactivate();
  }
}
