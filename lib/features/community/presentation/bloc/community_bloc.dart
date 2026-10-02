import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/features/community/domain/usecases/community_usecases.dart';
import 'community_event.dart';
import 'community_state.dart';

class CommunityBloc extends Bloc<CommunityEvent, CommunityState> {
  final GetPostsUseCase getPostsUseCase;
  final SearchPostsUseCase searchPostsUseCase;
  final GetUserPostsUseCase getUserPostsUseCase;
  final CreatePostUseCase createPostUseCase;
  final UpdatePostUseCase updatePostUseCase;
  final DeletePostUseCase deletePostUseCase;
  final GetCommentsUseCase getCommentsUseCase;
  final AddCommentUseCase addCommentUseCase;
  final UpdateCommentUseCase updateCommentUseCase;
  final DeleteCommentUseCase deleteCommentUseCase;

  CommunityBloc({
    required this.getPostsUseCase,
    required this.searchPostsUseCase,
    required this.getUserPostsUseCase,
    required this.createPostUseCase,
    required this.updatePostUseCase,
    required this.deletePostUseCase,
    required this.getCommentsUseCase,
    required this.addCommentUseCase,
    required this.updateCommentUseCase,
    required this.deleteCommentUseCase,
  }) : super(CommunityInitial()) {
    on<PostsFetchRequested>(_onFetchPosts);
    on<PostsSearchRequested>(_onSearchPosts);
    on<UserPostsFetchRequested>(_onFetchUserPosts);
    on<PostCreateRequested>(_onCreatePost);
    on<PostUpdateRequested>(_onUpdatePost);
    on<PostDeleteRequested>(_onDeletePost);
    on<CommentsFetchRequested>(_onFetchComments);
    on<CommentAddRequested>(_onAddComment);
    on<CommentUpdateRequested>(_onUpdateComment);
    on<CommentDeleteRequested>(_onDeleteComment);
  }

  Future<void> _onFetchPosts(PostsFetchRequested event, Emitter<CommunityState> emit) async {
    emit(CommunityLoading());
    try {
      final posts = await getPostsUseCase.execute();
      emit(PostsLoaded(posts));
    } catch (e) {
      emit(CommunityError(e.toString().replaceFirst('Exception: ', '')));
    }
  }

  Future<void> _onSearchPosts(PostsSearchRequested event, Emitter<CommunityState> emit) async {
    emit(CommunityLoading());
    try {
      final posts = await searchPostsUseCase.execute(event.query);
      emit(PostsLoaded(posts));
    } catch (e) {
      emit(CommunityError(e.toString().replaceFirst('Exception: ', '')));
    }
  }

  Future<void> _onFetchUserPosts(UserPostsFetchRequested event, Emitter<CommunityState> emit) async {
    emit(CommunityLoading());
    try {
      final posts = await getUserPostsUseCase.execute();
      emit(UserPostsLoaded(posts));
    } catch (e) {
      emit(CommunityError(e.toString().replaceFirst('Exception: ', '')));
    }
  }

  Future<void> _onCreatePost(PostCreateRequested event, Emitter<CommunityState> emit) async {
    emit(CommunityLoading());
    try {
      await createPostUseCase.execute(event.judul, event.isi, event.image);
      emit(const CommunityActionSuccess('Postingan berhasil dibuat!'));
    } catch (e) {
      emit(CommunityError(e.toString().replaceFirst('Exception: ', '')));
    }
  }

  Future<void> _onUpdatePost(PostUpdateRequested event, Emitter<CommunityState> emit) async {
    emit(CommunityLoading());
    try {
      await updatePostUseCase.execute(event.post.idKomunitas!, event.judul, event.isi, event.image);
      emit(const CommunityActionSuccess('Postingan berhasil diperbarui!'));
    } catch (e) {
      emit(CommunityError(e.toString().replaceFirst('Exception: ', '')));
    }
  }

  Future<void> _onDeletePost(PostDeleteRequested event, Emitter<CommunityState> emit) async {
    emit(CommunityLoading());
    try {
      await deletePostUseCase.execute(event.postId);
      emit(const CommunityActionSuccess('Postingan berhasil dihapus!'));
    } catch (e) {
      emit(CommunityError(e.toString().replaceFirst('Exception: ', '')));
    }
  }

  Future<void> _onFetchComments(CommentsFetchRequested event, Emitter<CommunityState> emit) async {
    emit(CommunityLoading());
    try {
      final comments = await getCommentsUseCase.execute(event.postId);
      emit(CommentsLoaded(comments));
    } catch (e) {
      emit(CommunityError(e.toString().replaceFirst('Exception: ', '')));
    }
  }

  Future<void> _onAddComment(CommentAddRequested event, Emitter<CommunityState> emit) async {
    try {
      await addCommentUseCase.execute(event.postId, event.isi);
      final comments = await getCommentsUseCase.execute(event.postId);
      emit(CommentsLoaded(comments));
    } catch (e) {
      emit(CommunityError(e.toString().replaceFirst('Exception: ', '')));
    }
  }

  Future<void> _onUpdateComment(CommentUpdateRequested event, Emitter<CommunityState> emit) async {
    try {
      await updateCommentUseCase.execute(event.komentarId, event.isi);
      final comments = await getCommentsUseCase.execute(event.postId);
      emit(CommentsLoaded(comments));
    } catch (e) {
      emit(CommunityError(e.toString().replaceFirst('Exception: ', '')));
    }
  }

  Future<void> _onDeleteComment(CommentDeleteRequested event, Emitter<CommunityState> emit) async {
    try {
      await deleteCommentUseCase.execute(event.komentarId);
      final comments = await getCommentsUseCase.execute(event.postId);
      emit(CommentsLoaded(comments));
    } catch (e) {
      emit(CommunityError(e.toString().replaceFirst('Exception: ', '')));
    }
  }
}
