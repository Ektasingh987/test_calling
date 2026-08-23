import 'package:fpdart/fpdart.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/post_entity.dart';
import '../../domain/repositories/feed_repository.dart';
import '../datasources/feed_local_datasource.dart';
import '../datasources/feed_remote_datasource.dart';

class FeedRepositoryImpl implements FeedRepository {
  final FeedRemoteDataSource remoteDataSource;
  final FeedLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  FeedRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, List<PostEntity>>> getPosts({
    required int page,
    required int pageSize,
  }) async {
    final isOnline = await networkInfo.isConnected;

    if (isOnline) {
      try {
        final models = await remoteDataSource.getPosts(
          page: page,
          pageSize: pageSize,
        );

        if (page == 1) {
          // First page: replace cache
          await localDataSource.cachePosts(models);
        } else {
          // Subsequent pages: append (dedup by key in Hive)
          await localDataSource.appendPosts(models);
        }

        return Right(models.map((m) => m.toEntity()).toList());
      } on ServerException catch (e) {
        // Network failed or API error — fall through to cache
        return _serveCachedOrFailure(
          e.message,
          isServerFailure: true,
        );
      }
    } else {
      // Offline: always serve from Hive cache
      return _serveCachedOrFailure('No internet connection');
    }
  }

  @override
  Future<Either<Failure, List<PostEntity>>> refreshPosts({
    required int pageSize,
  }) async {
    final isOnline = await networkInfo.isConnected;

    if (!isOnline) {
      return _serveCachedOrFailure('No internet connection');
    }

    try {
      final models = await remoteDataSource.getPosts(
        page: 1,
        pageSize: pageSize,
      );
      await localDataSource.cachePosts(models);
      return Right(models.map((m) => m.toEntity()).toList());
    } on ServerException catch (e) {
      return _serveCachedOrFailure(
        e.message,
        isServerFailure: true,
      );
    }
  }

  Future<Either<Failure, List<PostEntity>>> _serveCachedOrFailure(
    String errorMessage, {
    bool isServerFailure = false,
  }) async {
    try {
      final cached = await localDataSource.getCachedPosts();
      if (cached.isEmpty) {
        if (isServerFailure) {
          return Left(ServerFailure(message: errorMessage));
        }
        return Left(NetworkFailure(message: errorMessage));
      }
      return Right(cached.map((m) => m.toEntity()).toList());
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    }
  }
}
