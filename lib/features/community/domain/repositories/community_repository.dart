import 'dart:io';
import 'package:frontend/core/models/komunitas_model.dart';
import 'package:frontend/core/models/komentar_model.dart';

abstract class CommunityRepository {
  Future<List<Komunitas>> getAllPosts();
  Future<List<Komunitas>> searchPosts(String query);
  Future<List<Komunitas>> getUserPosts();
  Future<void> createPost(String judul, String isi, File? image);
  Future<void> updatePost(int postId, String judul, String isi, File? image);
  Future<void> deletePost(int postId);
  Future<List<Komentar>> getComments(int postId);
  Future<void> addComment(int postId, String isi);
  Future<void> updateComment(int komentarId, String isi);
  Future<void> deleteComment(int komentarId);
}
