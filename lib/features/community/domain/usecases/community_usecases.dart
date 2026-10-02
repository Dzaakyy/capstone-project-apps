import 'dart:io';
import 'package:frontend/core/models/komunitas_model.dart';
import 'package:frontend/core/models/komentar_model.dart';
import 'package:frontend/features/community/domain/repositories/community_repository.dart';

class GetPostsUseCase {
  final CommunityRepository repo;
  GetPostsUseCase(this.repo);
  Future<List<Komunitas>> execute() => repo.getAllPosts();
}

class SearchPostsUseCase {
  final CommunityRepository repo;
  SearchPostsUseCase(this.repo);
  Future<List<Komunitas>> execute(String query) => repo.searchPosts(query);
}

class GetUserPostsUseCase {
  final CommunityRepository repo;
  GetUserPostsUseCase(this.repo);
  Future<List<Komunitas>> execute() => repo.getUserPosts();
}

class CreatePostUseCase {
  final CommunityRepository repo;
  CreatePostUseCase(this.repo);
  Future<void> execute(String judul, String isi, File? image) =>
      repo.createPost(judul, isi, image);
}

class UpdatePostUseCase {
  final CommunityRepository repo;
  UpdatePostUseCase(this.repo);
  Future<void> execute(int postId, String judul, String isi, File? image) =>
      repo.updatePost(postId, judul, isi, image);
}

class DeletePostUseCase {
  final CommunityRepository repo;
  DeletePostUseCase(this.repo);
  Future<void> execute(int postId) => repo.deletePost(postId);
}

class GetCommentsUseCase {
  final CommunityRepository repo;
  GetCommentsUseCase(this.repo);
  Future<List<Komentar>> execute(int postId) => repo.getComments(postId);
}

class AddCommentUseCase {
  final CommunityRepository repo;
  AddCommentUseCase(this.repo);
  Future<void> execute(int postId, String isi) => repo.addComment(postId, isi);
}

class UpdateCommentUseCase {
  final CommunityRepository repo;
  UpdateCommentUseCase(this.repo);
  Future<void> execute(int komentarId, String isi) =>
      repo.updateComment(komentarId, isi);
}

class DeleteCommentUseCase {
  final CommunityRepository repo;
  DeleteCommentUseCase(this.repo);
  Future<void> execute(int komentarId) => repo.deleteComment(komentarId);
}
