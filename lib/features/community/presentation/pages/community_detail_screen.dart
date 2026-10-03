import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:logger/logger.dart';
import 'package:intl/intl.dart';

import 'package:frontend/core/models/komunitas_model.dart';
import 'package:frontend/core/models/komentar_model.dart';
import 'package:frontend/features/community/presentation/bloc/community_bloc.dart';
import 'package:frontend/features/community/presentation/bloc/community_event.dart';
import 'package:frontend/features/community/presentation/bloc/community_state.dart';
import 'package:frontend/core/utils/snackbar_util.dart';

final logger = Logger();

class KomunitasDetailScreen extends StatefulWidget {
  final Komunitas post;

  const KomunitasDetailScreen({super.key, required this.post});

  @override
  State<KomunitasDetailScreen> createState() => _KomunitasDetailScreenState();
}

class _KomunitasDetailScreenState extends State<KomunitasDetailScreen> {
  final TextEditingController _commentController = TextEditingController();
  String? currentUserId;

  @override
  void initState() {
    super.initState();
    _loadUserId();
    context.read<CommunityBloc>().add(CommentsFetchRequested(widget.post.idKomunitas!));
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _loadUserId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final storedUserIdInt = prefs.getInt('idUser');
      if (storedUserIdInt != null) {
        if (mounted) {
          setState(() {
            currentUserId = storedUserIdInt.toString();
          });
        }
      }
    } catch (e) {
      logger.e('Error loading userId: $e');
    }
  }

  void _submitKomentar() {
    if (_commentController.text.trim().isEmpty) {
      SnackbarUtil.showError(context, 'Silakan masukkan komentar Anda');
      return;
    }
    context.read<CommunityBloc>().add(CommentAddRequested(widget.post.idKomunitas!, _commentController.text));
    _commentController.clear();
    FocusScope.of(context).unfocus();
  }

  void _updateKomentar(int komentarId, String newText) {
    if (newText.trim().isEmpty) {
      SnackbarUtil.showError(context, 'Komentar tidak boleh kosong');
      return;
    }
    context.read<CommunityBloc>().add(CommentUpdateRequested(komentarId, widget.post.idKomunitas!, newText));
  }

  void _deleteKomentar(int komentarId) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Hapus Komentar', style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text('Apakah Anda yakin ingin menghapus komentar ini?'),
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
              context.read<CommunityBloc>().add(CommentDeleteRequested(komentarId, widget.post.idKomunitas!));
            },
            child: const Text('Hapus', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showEditCommentDialog(Komentar komentar) {
    final editController = TextEditingController(text: komentar.isiKomentar);
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: const Text('Edit Jawaban', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
          content: TextField(
            controller: editController,
            autofocus: true,
            maxLines: 4,
            style: const TextStyle(color: Colors.black87, fontSize: 15),
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.grey.shade50,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.all(16),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text('Batal', style: TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.bold)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade600,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                elevation: 0,
              ),
              onPressed: () {
                Navigator.pop(dialogContext);
                if (komentar.idKomentar != null) {
                  _updateKomentar(komentar.idKomentar!, editController.text);
                }
              },
              child: const Text('Simpan', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Detail Keluhan', style: TextStyle(fontWeight: FontWeight.w700, color: Colors.black87)),
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
          } else if (state is CommunityError) {
            SnackbarUtil.showError(context, state.message);
          }
        },
        builder: (context, state) {
          return Column(
            children: [
              if (state is CommunityLoading) const LinearProgressIndicator(minHeight: 3, color: Colors.blue),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async {
                    context.read<CommunityBloc>().add(CommentsFetchRequested(widget.post.idKomunitas!));
                  },
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildPostDetails(),
                        _buildCommentSection(state),
                      ],
                    ),
                  ),
                ),
              ),
              _buildCommentInput(state is CommunityLoading),
            ],
          );
        },
      ),
    );
  }

  Widget _buildPostDetails() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: Colors.blue.shade50,
                child: Text(
                  (widget.post.username ?? 'A')[0].toUpperCase(),
                  style: TextStyle(color: Colors.blue.shade700, fontWeight: FontWeight.w800, fontSize: 20),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.post.username ?? 'Anonymous',
                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 17, color: Colors.black87),
                    ),
                    Text(
                      'Beberapa waktu lalu',
                      style: TextStyle(color: Colors.grey.shade500, fontSize: 13, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          if (widget.post.judul != null && widget.post.judul!.isNotEmpty)
            Text(
              widget.post.judul!,
              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 22, color: Colors.black87),
            ),
          const SizedBox(height: 12),
          Text(
            widget.post.isi,
            style: TextStyle(fontSize: 16, color: Colors.grey.shade800, height: 1.6),
          ),
          const SizedBox(height: 24),
          if (widget.post.image != null && widget.post.image!.isNotEmpty)
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.network(
                widget.post.image!,
                width: double.infinity,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, progress) => progress == null
                    ? child
                    : Container(
                        height: 250,
                        color: Colors.grey.shade50,
                        child: const Center(child: CircularProgressIndicator()),
                      ),
                errorBuilder: (context, error, stack) => Container(
                  height: 200,
                  color: Colors.grey.shade50,
                  child: Center(child: Icon(Icons.broken_image_rounded, size: 50, color: Colors.grey.shade400)),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCommentSection(CommunityState state) {
    List<Komentar> komentarList = [];
    if (state is CommentsLoaded) {
      komentarList = state.comments;
    }

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.forum_rounded, color: Colors.blue.shade700, size: 24),
              const SizedBox(width: 8),
              Text(
                '${komentarList.length} Jawaban',
                style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18, color: Colors.black87),
              ),
            ],
          ),
          const SizedBox(height: 20),
          if (state is CommunityLoading && komentarList.isEmpty)
            const Padding(
              padding: EdgeInsets.all(40.0),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (komentarList.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 40.0),
              child: Center(
                child: Column(
                  children: [
                    Icon(Icons.chat_bubble_outline_rounded, size: 64, color: Colors.grey.shade300),
                    const SizedBox(height: 16),
                    Text(
                      'Belum ada jawaban.\nJadilah yang pertama membantu!',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey.shade500, fontSize: 15, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: komentarList.length,
              separatorBuilder: (context, index) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final komentar = komentarList[index];
                final isOwner = currentUserId != null && currentUserId == komentar.userId?.toString();

                return Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.03),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                    border: Border.all(color: Colors.grey.shade100),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 18,
                                backgroundColor: Colors.green.shade50,
                                child: Text(
                                  (komentar.username ?? 'A')[0].toUpperCase(),
                                  style: TextStyle(color: Colors.green.shade700, fontWeight: FontWeight.w800, fontSize: 14),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    komentar.username ?? 'Anonymous',
                                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: Colors.black87),
                                  ),
                                  if (komentar.tanggalKomentar != null)
                                    Text(
                                      DateFormat('dd MMM yyyy, HH:mm').format(komentar.tanggalKomentar!),
                                      style: TextStyle(color: Colors.grey.shade500, fontSize: 12, fontWeight: FontWeight.w500),
                                    ),
                                ],
                              ),
                            ],
                          ),
                          if (isOwner)
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  constraints: const BoxConstraints(),
                                  padding: const EdgeInsets.all(8),
                                  icon: Icon(Icons.edit_rounded, color: Colors.blue.shade500, size: 20),
                                  onPressed: (state is CommunityLoading) ? null : () => _showEditCommentDialog(komentar),
                                ),
                                IconButton(
                                  constraints: const BoxConstraints(),
                                  padding: const EdgeInsets.all(8),
                                  icon: Icon(Icons.delete_outline_rounded, color: Colors.red.shade400, size: 20),
                                  onPressed: (state is CommunityLoading) ? null : () => _deleteKomentar(komentar.idKomentar!),
                                ),
                              ],
                            ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        komentar.isiKomentar,
                        style: TextStyle(fontSize: 15, color: Colors.grey.shade800, height: 1.5),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildCommentInput(bool isLoading) {
    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 16,
        bottom: MediaQuery.of(context).padding.bottom + 16,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: TextField(
              controller: _commentController,
              minLines: 1,
              maxLines: 4,
              style: const TextStyle(fontSize: 15),
              decoration: InputDecoration(
                hintText: 'Tulis jawaban Anda...',
                hintStyle: TextStyle(color: Colors.grey.shade400, fontWeight: FontWeight.w500),
                filled: true,
                fillColor: Colors.grey.shade50,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            margin: const EdgeInsets.only(bottom: 2),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.blue.shade600,
              boxShadow: [
                BoxShadow(
                  color: Colors.blue.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: IconButton(
              onPressed: isLoading ? null : _submitKomentar,
              icon: isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                    )
                  : const Icon(Icons.send_rounded, color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }
}
