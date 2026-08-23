import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../entities/post_entity.dart';
import '../repositories/feed_repository.dart';

class GetFeedUseCase {
  final FeedRepository repository;

  GetFeedUseCase(this.repository);

  Future<Either<Failure, List<PostEntity>>> call({
    required int page,
    required int pageSize,
  }) {
    return repository.getPosts(page: page, pageSize: pageSize);
  }
}

class RefreshFeedUseCase {
  final FeedRepository repository;

  RefreshFeedUseCase(this.repository);

  Future<Either<Failure, List<PostEntity>>> call({required int pageSize}) {
    return repository.refreshPosts(pageSize: pageSize);
  }
}

