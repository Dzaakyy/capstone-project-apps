import 'package:equatable/equatable.dart';
import 'package:frontend/core/models/komunitas_model.dart';
import 'package:frontend/core/models/komentar_model.dart';

abstract class CommunityState extends Equatable {
  const CommunityState();
  @override
  List<Object?> get props => [];
}

class CommunityInitial extends CommunityState {}

class CommunityLoading extends CommunityState {}

class PostsLoaded extends CommunityState {
  final List<Komunitas> posts;
  const PostsLoaded(this.posts);
  @override
  List<Object?> get props => [posts];
}

class UserPostsLoaded extends CommunityState {
  final List<Komunitas> posts;
  const UserPostsLoaded(this.posts);
  @override
  List<Object?> get props => [posts];
}

class CommentsLoaded extends CommunityState {
  final List<Komentar> comments;
  const CommentsLoaded(this.comments);
  @override
  List<Object?> get props => [comments];
}

class CommunityActionSuccess extends CommunityState {
  final String message;
  const CommunityActionSuccess(this.message);
  @override
  List<Object?> get props => [message];
}

class CommunityError extends CommunityState {
  final String message;
  const CommunityError(this.message);
  @override
  List<Object?> get props => [message];
}
