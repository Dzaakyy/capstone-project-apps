import 'dart:io';
import 'package:equatable/equatable.dart';
import 'package:frontend/core/models/komunitas_model.dart';

abstract class CommunityEvent extends Equatable {
  const CommunityEvent();
  @override
  List<Object?> get props => [];
}

class PostsFetchRequested extends CommunityEvent {}

class PostsSearchRequested extends CommunityEvent {
  final String query;
  const PostsSearchRequested(this.query);
  @override
  List<Object?> get props => [query];
}

class UserPostsFetchRequested extends CommunityEvent {}

class PostCreateRequested extends CommunityEvent {
  final String judul;
  final String isi;
  final File? image;
  const PostCreateRequested(this.judul, this.isi, this.image);
  @override
  List<Object?> get props => [judul, isi];
}

class PostUpdateRequested extends CommunityEvent {
  final Komunitas post;
  final String judul;
  final String isi;
  final File? image;
  const PostUpdateRequested(this.post, this.judul, this.isi, this.image);
  @override
  List<Object?> get props => [post, judul, isi];
}

class PostDeleteRequested extends CommunityEvent {
  final int postId;
  const PostDeleteRequested(this.postId);
  @override
  List<Object?> get props => [postId];
}

class CommentsFetchRequested extends CommunityEvent {
  final int postId;
  const CommentsFetchRequested(this.postId);
  @override
  List<Object?> get props => [postId];
}

class CommentAddRequested extends CommunityEvent {
  final int postId;
  final String isi;
  const CommentAddRequested(this.postId, this.isi);
  @override
  List<Object?> get props => [postId, isi];
}

class CommentUpdateRequested extends CommunityEvent {
  final int komentarId;
  final int postId;
  final String isi;
  const CommentUpdateRequested(this.komentarId, this.postId, this.isi);
  @override
  List<Object?> get props => [komentarId, isi];
}

class CommentDeleteRequested extends CommunityEvent {
  final int komentarId;
  final int postId;
  const CommentDeleteRequested(this.komentarId, this.postId);
  @override
  List<Object?> get props => [komentarId];
}
