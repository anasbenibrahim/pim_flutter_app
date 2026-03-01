import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/post_detail_bloc.dart';
import '../../data/services/social_api_service.dart';

const Color _sapphire = Color(0xFF0D6078);
const Color _linen = Color(0xFFF2EBE1);
const Color _indigo = Color(0xFF022F40);

class PostDetailPage extends StatelessWidget {
  final int postId;
  const PostDetailPage({Key? key, required this.postId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => PostDetailBloc(SocialApiService())..add(LoadPostDetail(postId)),
      child: Scaffold(
        backgroundColor: _linen,
        appBar: AppBar(
          title: const Text('Post', style: TextStyle(fontWeight: FontWeight.bold)),
          backgroundColor: _linen,
          foregroundColor: _indigo,
          elevation: 0,
          centerTitle: true,
        ),
        body: Column(
          children: [
            Expanded(
              child: BlocBuilder<PostDetailBloc, PostDetailState>(
                builder: (context, state) {
                  if (state is PostDetailLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is PostDetailError) {
                    return Center(child: Text('Error: ${state.message}'));
                  } else if (state is PostDetailLoaded) {
                    return ListView(
                      padding: const EdgeInsets.all(16),
                      children: [
                        // Post Header Mock
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: _sapphire.withOpacity(0.1)),
                          ),
                          child: Text(
                            "Wait, post details should be passed or fetched. (Currently mocked in bloc)",
                            style: TextStyle(color: Colors.grey[400]),
                          ),
                        ),
                        const SizedBox(height: 24),
                        const Text('Comments', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: _indigo)),
                        const SizedBox(height: 16),
                        ...state.comments.map((c) => Padding(
                          padding: const EdgeInsets.only(bottom: 16.0),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: _sapphire.withOpacity(0.05)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 14, 
                                      backgroundColor: _linen,
                                      child: const Icon(Icons.person, size: 16, color: _sapphire),
                                    ),
                                    const SizedBox(width: 12),
                                    Text(c.pseudonym, style: const TextStyle(fontWeight: FontWeight.bold, color: _indigo, fontSize: 15)),
                                  ],
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(left: 40.0, top: 4),
                                  child: Text(c.content, style: const TextStyle(color: _indigo, height: 1.4)),
                                ),
                              ],
                            ),
                          ),
                        )).toList(),
                      ],
                    );
                  }
                  return const SizedBox();
                },
              ),
            ),
            // Comment Input Widget
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [BoxShadow(color: _sapphire.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))],
              ),
              child: Builder(
                builder: (context) {
                  final controller = TextEditingController();
                  return Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: controller,
                          style: const TextStyle(color: _indigo),
                          decoration: InputDecoration(
                            hintText: 'Write an anonymous reply...',
                            hintStyle: TextStyle(color: _indigo.withOpacity(0.5)),
                            filled: true,
                            fillColor: _linen.withOpacity(0.5),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(24),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12)
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        decoration: const BoxDecoration(
                          color: _sapphire,
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.send, color: Colors.white, size: 20),
                          onPressed: () {
                            if (controller.text.isNotEmpty) {
                              context.read<PostDetailBloc>().add(AddCommentEvent(controller.text));
                              controller.clear();
                            }
                          },
                        ),
                      )
                    ],
                  );
                }
              ),
            )
          ],
        ),
      ),
    );
  }
}
