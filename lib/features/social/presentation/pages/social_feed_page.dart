import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/social_feed_bloc.dart';
import '../../data/services/social_api_service.dart';
import '../widgets/reaction_widget.dart';
import '../../../../core/routes/app_routes.dart';

const Color _sapphire = Color(0xFF0D6078);
const Color _linen = Color(0xFFF2EBE1);
const Color _indigo = Color(0xFF022F40);

class SocialFeedPage extends StatelessWidget {
  const SocialFeedPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SocialFeedBloc(SocialApiService())..add(LoadFeed()),
      child: Scaffold(
        backgroundColor: _linen,
        appBar: AppBar(
          title: const Text('Recovery Network', style: TextStyle(fontWeight: FontWeight.bold)),
          backgroundColor: _linen,
          foregroundColor: _indigo,
          elevation: 0,
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.filter_list, color: _sapphire),
              onPressed: () {
                // Future: Filter bottom sheet based on PostCategory mapping
              },
            ),
          ],
        ),
        body: BlocBuilder<SocialFeedBloc, SocialFeedState>(
          builder: (context, state) {
            if (state is SocialFeedLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is SocialFeedError) {
              return Center(child: Text('Error: ${state.message}'));
            } else if (state is SocialFeedLoaded) {
              if (state.posts.isEmpty) {
                return const Center(child: Text('No posts yet. Be the first to share!'));
              }
              return RefreshIndicator(
                onRefresh: () async {
                  context.read<SocialFeedBloc>().add(RefreshFeed());
                },
                child: ListView.separated(
                  padding: const EdgeInsets.only(left: 16, right: 16, bottom: 80, top: 8),
                  itemCount: state.posts.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    final post = state.posts[index];
                    return Card(
                      elevation: 0,
                      color: Colors.white,
                      surfaceTintColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide(color: _sapphire.withOpacity(0.1), width: 1),
                      ),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(20),
                        onTap: () {
                          Navigator.pushNamed(
                            context, 
                            AppRoutes.postDetail,
                            arguments: post.id,
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(
                                    radius: 22,
                                    backgroundColor: _linen,
                                    child: Text(post.moodEmoji, style: const TextStyle(fontSize: 22)),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Text(post.pseudonym, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: _indigo)),
                                            const SizedBox(width: 8),
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                              decoration: BoxDecoration(
                                                color: _sapphire.withOpacity(0.1),
                                                borderRadius: BorderRadius.circular(12),
                                              ),
                                              child: Text(
                                                post.authorRole.toUpperCase(), 
                                                style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: _sapphire)
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 2),
                                        Text(post.category, style: TextStyle(color: Colors.grey[600], fontSize: 12, fontWeight: FontWeight.w500)),
                                      ],
                                    ),
                                  ),
                                  Text(
                                    "${post.createdAt.hour}:${post.createdAt.minute.toString().padLeft(2, '0')}", 
                                    style: TextStyle(color: Colors.grey[500], fontSize: 12, fontWeight: FontWeight.w500)
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Text(post.content, style: const TextStyle(fontSize: 15, color: _indigo, height: 1.4)),
                              if (post.mediaUrl != null) ...[
                                const SizedBox(height: 12),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.network(post.mediaUrl!),
                                ),
                              ],
                              const SizedBox(height: 16),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  ReactionWidget(
                                    reactions: {}, // Would come from PostModel if fetched
                                    onReact: (type) {
                                      context.read<SocialFeedBloc>().add(ToggleReactionEvent(post.id, type));
                                    },
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: _linen.withOpacity(0.5),
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(Icons.chat_bubble_outline, size: 18, color: _sapphire),
                                        const SizedBox(width: 6),
                                        const Text('Reply', style: TextStyle(color: _sapphire, fontWeight: FontWeight.w600, fontSize: 13)),
                                      ],
                                    ),
                                  )
                                ],
                              )
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              );
            }
            return const SizedBox();
          },
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            Navigator.pushNamed(context, AppRoutes.createPost).then((_) {
              // Refresh feed when popping back
              context.read<SocialFeedBloc>().add(RefreshFeed());
            });
          },
          backgroundColor: _sapphire,
          elevation: 4,
          icon: const Icon(Icons.edit, color: Colors.white),
          label: const Text('Share', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }
}
