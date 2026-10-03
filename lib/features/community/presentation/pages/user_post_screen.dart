import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:logger/logger.dart';

import 'package:frontend/features/community/presentation/pages/community_detail_screen.dart';
import 'package:frontend/features/community/presentation/pages/edit_post_screen.dart';
import 'package:frontend/features/community/presentation/bloc/community_bloc.dart';
import 'package:frontend/features/community/presentation/bloc/community_event.dart';
import 'package:frontend/features/community/presentation/bloc/community_state.dart';
import 'package:frontend/core/utils/snackbar_util.dart';

final logger = Logger();

class UserPostsScreen extends StatefulWidget {
  const UserPostsScreen({super.key});

  @override
  State<UserPostsScreen> createState() => _UserPostsScreenState();
}

class _UserPostsScreenState extends State<UserPostsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<CommunityBloc>().add(UserPostsFetchRequested());
  }

  void _deletePost(int id) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Hapus Postingan', style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text('Apakah Anda yakin ingin menghapus postingan ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text('Batal', style: TextStyle(color: Colors.grey.shade700, fontWeight: FontWeight.bold)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade600,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<CommunityBloc>().add(PostDeleteRequested(id));
            },
            child: const Text('Hapus', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text(
          'Postingan Saya',
          style: TextStyle(fontWeight: FontWeight.w700, color: Colors.black87),
        ),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: BlocConsumer<CommunityBloc, CommunityState>(
        listener: (context, state) {
          if (state is CommunityActionSuccess) {
            SnackbarUtil.showSuccess(context, state.message);
            context.read<CommunityBloc>().add(UserPostsFetchRequested());
          } else if (state is CommunityError) {
            SnackbarUtil.showError(context, state.message);
          }
        },
        builder: (context, state) {
          if (state is CommunityLoading) {
            return const Center(child: CircularProgressIndicator(color: Colors.blue));
          }

          if (state is UserPostsLoaded) {
            final userPosts = state.posts;

            if (userPosts.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 10))
                        ],
                      ),
                      child: Icon(Icons.article_outlined, size: 60, color: Colors.grey.shade300),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Belum ada postingan',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Mulai berbagi pengalaman bertani Anda!',
                      style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
                    ),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () async {
                context.read<CommunityBloc>().add(UserPostsFetchRequested());
              },
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                itemCount: userPosts.length,
                itemBuilder: (context, index) {
                  final post = userPosts[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(20),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(20),
                        onTap: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => KomunitasDetailScreen(post: post)),
                          );
                          if (context.mounted) {
                            context.read<CommunityBloc>().add(UserPostsFetchRequested());
                          }
                        },
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (post.image != null && post.image!.isNotEmpty)
                              ClipRRect(
                                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                                child: CachedNetworkImage(
                                  imageUrl: post.image!,
                                  placeholder: (context, url) => Container(
                                    height: 160,
                                    color: Colors.grey.shade50,
                                    child: const Center(child: CircularProgressIndicator()),
                                  ),
                                  errorWidget: (context, url, error) {
                                    logger.e('Image load error: $url, $error');
                                    return Container(
                                      height: 160,
                                      color: Colors.grey.shade50,
                                      child: Icon(Icons.broken_image_rounded, size: 40, color: Colors.grey.shade400),
                                    );
                                  },
                                  width: double.infinity,
                                  height: 160,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            Padding(
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (post.judul != null && post.judul!.isNotEmpty)
                                    Text(
                                      post.judul!,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w800,
                                        fontSize: 18,
                                        color: Colors.black87,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  const SizedBox(height: 8),
                                  Text(
                                    post.isi,
                                    style: TextStyle(fontSize: 14, color: Colors.grey.shade700, height: 1.5),
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                              decoration: BoxDecoration(
                                border: Border(top: BorderSide(color: Colors.grey.shade100)),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  // Action buttons
                                  Row(
                                    children: [
                                      _buildActionButton(
                                        icon: Icons.edit_rounded,
                                        color: Colors.blue.shade600,
                                        bgColor: Colors.blue.shade50,
                                        onTap: () async {
                                          final bool? postWasUpdated = await Navigator.push<bool>(
                                            context,
                                            MaterialPageRoute(builder: (context) => EditPostScreen(post: post)),
                                          );
                                          if (postWasUpdated == true && context.mounted) {
                                            context.read<CommunityBloc>().add(UserPostsFetchRequested());
                                          }
                                        },
                                      ),
                                      const SizedBox(width: 10),
                                      _buildActionButton(
                                        icon: Icons.delete_outline_rounded,
                                        color: Colors.red.shade600,
                                        bgColor: Colors.red.shade50,
                                        onTap: () {
                                          if (post.idKomunitas != null) _deletePost(post.idKomunitas!);
                                        },
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Icon(Icons.chat_bubble_outline_rounded, size: 16, color: Colors.blue.shade600),
                                      const SizedBox(width: 6),
                                      Text(
                                        'Lihat Jawaban',
                                        style: TextStyle(
                                          color: Colors.blue.shade600,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            );
          }

          return const Center(child: Text('Tidak ada data'));
        },
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required Color bgColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: color, size: 20),
      ),
    );
  }
}
