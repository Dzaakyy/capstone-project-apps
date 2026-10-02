import 'dart:io';
import 'package:frontend/core/models/komunitas_model.dart';
import 'package:frontend/core/models/komentar_model.dart';
import 'package:frontend/features/community/data/datasources/community_remote_data_source.dart';
import 'package:frontend/features/community/domain/repositories/community_repository.dart';

class CommunityRepositoryImpl implements CommunityRepository {
  final CommunityRemoteDataSource remoteDataSource;
  CommunityRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<Komunitas>> getAllPosts() => remoteDataSource.getAllPosts();
  @override
  Future<List<Komunitas>> searchPosts(String query) => remoteDataSource.searchPosts(query);
  @override
  Future<List<Komunitas>> getUserPosts() => remoteDataSource.getUserPosts();
  @override
  Future<void> createPost(String judul, String isi, File? image) =>
      remoteDataSource.createPost(judul, isi, image);
  @override
  Future<void> updatePost(int postId, String judul, String isi, File? image) =>
      remoteDataSource.updatePost(postId, judul, isi, image);
  @override
  Future<void> deletePost(int postId) => remoteDataSource.deletePost(postId);
  @override
  Future<List<Komentar>> getComments(int postId) => remoteDataSource.getComments(postId);
  @override
  Future<void> addComment(int postId, String isi) => remoteDataSource.addComment(postId, isi);
  @override
  Future<void> updateComment(int komentarId, String isi) =>
      remoteDataSource.updateComment(komentarId, isi);
  @override
  Future<void> deleteComment(int komentarId) => remoteDataSource.deleteComment(komentarId);
}
