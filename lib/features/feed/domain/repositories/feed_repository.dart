import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../entities/post_entity.dart';

abstract class FeedRepository {
  /// Fetch paginated posts. Returns offline-first data.
  Future<Either<Failure, List<PostEntity>>> getPosts({
    required int page,
    required int pageSize,
  });

  /// Force a fresh refresh from network.
  Future<Either<Failure, List<PostEntity>>> refreshPosts({
    required int pageSize,
  });
}

