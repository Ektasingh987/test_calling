import 'package:hive_flutter/hive_flutter.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/error/exceptions.dart';
import '../models/post_model.dart';

abstract class FeedLocalDataSource {
  Future<List<PostModel>> getCachedPosts();
  Future<void> cachePosts(List<PostModel> posts);
  Future<void> appendPosts(List<PostModel> posts);
  Future<void> clearCache();
}

class FeedLocalDataSourceImpl implements FeedLocalDataSource {
  Box<PostModel> get _box => Hive.box<PostModel>(AppConstants.postsBox);

  @override
  Future<List<PostModel>> getCachedPosts() async {
    try {
      return _box.values.toList();
    } catch (e) {
      throw CacheException(message: 'Failed to read cached posts: $e');
    }
  }

  @override
  Future<void> cachePosts(List<PostModel> posts) async {
    try {
      await _box.clear();
      final map = {for (final p in posts) p.id.toString(): p};
      await _box.putAll(map);
    } catch (e) {
      throw CacheException(message: 'Failed to cache posts: $e');
    }
  }

  @override
  Future<void> appendPosts(List<PostModel> posts) async {
    try {
      // Avoid duplicates by using post ID as key
      final map = {for (final p in posts) p.id.toString(): p};
      await _box.putAll(map);
    } catch (e) {
      throw CacheException(message: 'Failed to append posts: $e');
    }
  }

  @override
  Future<void> clearCache() async {
    try {
      await _box.clear();
    } catch (e) {
      throw CacheException(message: 'Failed to clear cache: $e');
    }
  }
}

