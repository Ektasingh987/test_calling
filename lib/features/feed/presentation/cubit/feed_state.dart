import 'package:equatable/equatable.dart';
import '../../domain/entities/post_entity.dart';

enum FeedStatus { initial, loading, refreshing, loadingMore, loaded, failure }

class FeedState extends Equatable {
  final FeedStatus status;
  final List<PostEntity> posts;
  final String? errorMessage;
  final bool hasReachedMax;
  final bool isOfflineData;
  final int currentPage;

  const FeedState({
    this.status = FeedStatus.initial,
    this.posts = const [],
    this.errorMessage,
    this.hasReachedMax = false,
    this.isOfflineData = false,
    this.currentPage = 0,
  });

  bool get isLoadingInitial => status == FeedStatus.loading && posts.isEmpty;
  bool get isLoadingMore => status == FeedStatus.loadingMore;
  bool get isRefreshing => status == FeedStatus.refreshing;

  FeedState copyWith({
    FeedStatus? status,
    List<PostEntity>? posts,
    String? errorMessage,
    bool? hasReachedMax,
    bool? isOfflineData,
    int? currentPage,
  }) {
    return FeedState(
      status: status ?? this.status,
      posts: posts ?? this.posts,
      errorMessage: errorMessage ?? this.errorMessage,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      isOfflineData: isOfflineData ?? this.isOfflineData,
      currentPage: currentPage ?? this.currentPage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        posts,
        errorMessage,
        hasReachedMax,
        isOfflineData,
        currentPage,
      ];
}

