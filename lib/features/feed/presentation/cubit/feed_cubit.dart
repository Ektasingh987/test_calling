import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/error/failures.dart';
import '../../domain/usecases/get_feed_usecase.dart';
import 'feed_state.dart';

class FeedCubit extends Cubit<FeedState> {
  final GetFeedUseCase _getFeedUseCase;
  final RefreshFeedUseCase _refreshFeedUseCase;

  FeedCubit({
    required GetFeedUseCase getFeedUseCase,
    required RefreshFeedUseCase refreshFeedUseCase,
  })  : _getFeedUseCase = getFeedUseCase,
        _refreshFeedUseCase = refreshFeedUseCase,
        super(const FeedState());

  /// Load first page
  Future<void> loadFeed() async {
    if (state.status == FeedStatus.loading) return;

    if (state.posts.isEmpty) {
      emit(state.copyWith(
        status: FeedStatus.loading,
        posts: [],
        currentPage: 0,
        hasReachedMax: false,
        errorMessage: null,
      ));
    }

    final result = await _getFeedUseCase(
      page: 1,
      pageSize: AppConstants.pageSize,
    );

    result.fold(
      (failure) => emit(state.copyWith(
        status: FeedStatus.failure,
        errorMessage: _mapFailureMessage(failure),
        isOfflineData: failure is NetworkFailure,
      )),
      (posts) => emit(state.copyWith(
        status: FeedStatus.loaded,
        posts: posts,
        currentPage: 1,
        hasReachedMax: posts.length < AppConstants.pageSize,
        isOfflineData: false,
      )),
    );
  }

  /// Pull-to-refresh: always hit network
  Future<void> refreshFeed() async {
    emit(state.copyWith(status: FeedStatus.refreshing));

    final result = await _refreshFeedUseCase(
      pageSize: AppConstants.pageSize,
    );

    result.fold(
      (failure) => emit(state.copyWith(
        status: FeedStatus.failure,
        errorMessage: _mapFailureMessage(failure),
      )),
      (posts) => emit(state.copyWith(
        status: FeedStatus.loaded,
        posts: posts,
        currentPage: 1,
        hasReachedMax: posts.length < AppConstants.pageSize,
        isOfflineData: false,
      )),
    );
  }

  /// Load next page for infinite scroll
  Future<void> loadMorePosts() async {
    // Guard: don't load more if already at max or currently loading
    if (state.hasReachedMax ||
        state.status == FeedStatus.loadingMore ||
        state.status == FeedStatus.loading) {
      return;
    }

    final nextPage = state.currentPage + 1;
    emit(state.copyWith(status: FeedStatus.loadingMore));

    final result = await _getFeedUseCase(
      page: nextPage,
      pageSize: AppConstants.pageSize,
    );

    result.fold(
      (failure) => emit(state.copyWith(
        status: FeedStatus.loaded, // keep existing posts visible
        errorMessage: _mapFailureMessage(failure),
      )),
      (newPosts) {
        final existingIds = state.posts.map((p) => p.id).toSet();
        final uniqueNew = newPosts.where((p) => !existingIds.contains(p.id));
        final allPosts = [...state.posts, ...uniqueNew];

        emit(state.copyWith(
          status: FeedStatus.loaded,
          posts: allPosts,
          currentPage: nextPage,
          hasReachedMax: newPosts.length < AppConstants.pageSize,
        ));
      },
    );
  }

  String _mapFailureMessage(Failure failure) {
    if (failure is NetworkFailure) return 'You are offline';
    if (failure is ServerFailure) {
      if (failure.message.contains('401')) {
        return 'API Error: 401 Unauthorized.\nPlease configure AUTH_TOKEN in .env if required.';
      }
      return failure.message;
    }
    if (failure is CacheFailure) return 'Failed to load cached data.';
    return 'Something went wrong.';
  }
}

