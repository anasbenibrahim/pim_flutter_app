import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../bloc/social_feed_bloc.dart';
import '../../data/constants/post_categories.dart';
import '../../data/models/post_model.dart';
import '../../data/models/reaction_model.dart';
import '../../data/services/social_api_service.dart';
import '../widgets/reaction_widget.dart';
import '../../../../core/routes/app_routes.dart';

const Color _sapphire = Color(0xFF0D6078);
const Color _linen = Color(0xFFF2EBE1);
const Color _indigo = Color(0xFF022F40);

class SocialFeedPage extends StatelessWidget {
  const SocialFeedPage({Key? key}) : super(key: key);

  static Map<String, int> _reactionsMap(List<ReactionModel>? list) {
    if (list == null) return {};
    return {for (final r in list) r.reactionType: r.count};
  }

  static String? _userReaction(List<ReactionModel>? list) {
    if (list == null) return null;
    final reacted = list.where((r) => r.userReacted).toList();
    return reacted.isNotEmpty ? reacted.first.reactionType : null;
  }

  void _showFilterBottomSheet(BuildContext context) {
    final bloc = context.read<SocialFeedBloc>();
    final currentCategory = bloc.state is SocialFeedLoaded
        ? (bloc.state as SocialFeedLoaded).currentCategory
        : null;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Filter by category',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: _indigo,
              ),
            ),
            const SizedBox(height: 16),
            // All option
            _FilterChip(
              label: 'All',
              isSelected: currentCategory == null,
              onTap: () {
                bloc.add(FilterByCategory(null));
                Navigator.pop(ctx);
              },
            ),
            const SizedBox(height: 8),
            ...postCategories.map((cat) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _FilterChip(
                label: cat,
                isSelected: currentCategory == cat,
                onTap: () {
                  bloc.add(FilterByCategory(cat));
                  Navigator.pop(ctx);
                },
              ),
            )),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SocialFeedBloc(SocialApiService())..add(LoadFeed()),
      child: Builder(
        builder: (ctx) => Scaffold(
          backgroundColor: _linen,
          appBar: AppBar(
            title: const Text('Recovery Network', style: TextStyle(fontWeight: FontWeight.bold)),
            backgroundColor: _linen,
            foregroundColor: _indigo,
            elevation: 0,
            centerTitle: true,
            actions: [
              IconButton(
                icon: Icon(Icons.tune_rounded, color: _sapphire, size: 24.sp),
                onPressed: () => _showFilterBottomSheet(ctx),
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
                  padding: EdgeInsets.only(left: 16, right: 16, bottom: 120.h, top: 8),
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
                            arguments: post,
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
                                    backgroundImage: const AssetImage('assets/images/avatar.png'),
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
                                    reactions: _reactionsMap(state.postReactions[post.id]),
                                    currentUserReaction: _userReaction(state.postReactions[post.id]),
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
          onPressed: () async {
            final result = await Navigator.pushNamed(ctx, AppRoutes.createPost);
            if (!ctx.mounted) return;
            if (result is PostModel) {
              ctx.read<SocialFeedBloc>().add(PostCreated(result));
            } else if (result != null) {
              ctx.read<SocialFeedBloc>().add(RefreshFeed());
            }
          },
          backgroundColor: _sapphire,
          elevation: 4,
          icon: const Icon(Icons.edit, color: Colors.white),
          label: const Text('POST', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ),
        floatingActionButtonLocation: _FabAboveNavLocation(),
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: isSelected ? _sapphire : _sapphire.withOpacity(0.08),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              if (isSelected)
                Icon(Icons.check_rounded, color: Colors.white, size: 20.sp),
              if (isSelected) const SizedBox(width: 12),
              Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                  color: isSelected ? Colors.white : _indigo,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Positions the FAB above the bottom navigation bar with adequate spacing.
class _FabAboveNavLocation extends FloatingActionButtonLocation {
  @override
  Offset getOffset(ScaffoldPrelayoutGeometry geometry) {
    final bottom = 90.0 + 16.0; // Space for nav bar + padding
    final right = 16.0;
    return Offset(
      geometry.scaffoldSize.width - geometry.floatingActionButtonSize.width - right,
      geometry.scaffoldSize.height - geometry.floatingActionButtonSize.height - bottom,
    );
  }
}
