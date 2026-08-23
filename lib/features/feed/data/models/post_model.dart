import 'package:hive/hive.dart';
import '../../domain/entities/post_entity.dart';
import '../../../../core/constants/app_constants.dart';

part 'post_model.g.dart';

@HiveType(typeId: AppConstants.postUserModelTypeId)
class PostUserModel extends HiveObject {
  @HiveField(0)
  final int id;

  @HiveField(1)
  final String username;

  @HiveField(2)
  final String? profilePicture;

  @HiveField(3)
  final String? fullName;

  PostUserModel({
    required this.id,
    required this.username,
    this.profilePicture,
    this.fullName,
  });

  factory PostUserModel.fromJson(Map<String, dynamic> json) {
    return PostUserModel(
      id: json['id'] as int? ?? 0,
      username: json['username'] as String? ?? '',
      profilePicture: json['profile_picture'] as String?,
      fullName: json['full_name'] as String?,
    );
  }

  PostUserEntity toEntity() => PostUserEntity(
        id: id,
        username: username,
        profilePicture: profilePicture,
        fullName: fullName,
      );
}

@HiveType(typeId: AppConstants.postModelTypeId)
class PostModel extends HiveObject {
  @HiveField(0)
  final int id;

  @HiveField(1)
  final PostUserModel user;

  @HiveField(2)
  final String? caption;

  @HiveField(3)
  final String? image;

  @HiveField(4)
  final String? video;

  @HiveField(5)
  final int likesCount;

  @HiveField(6)
  final int commentsCount;

  @HiveField(7)
  final DateTime createdAt;

  PostModel({
    required this.id,
    required this.user,
    this.caption,
    this.image,
    this.video,
    required this.likesCount,
    required this.commentsCount,
    required this.createdAt,
  });

  factory PostModel.fromJson(Map<String, dynamic> json) {
    return PostModel(
      id: json['id'] as int? ?? 0,
      user: PostUserModel.fromJson(
        json['user'] as Map<String, dynamic>? ?? {},
      ),
      caption: json['caption'] as String?,
      image: json['image'] as String?,
      video: json['video'] as String?,
      likesCount: (json['likes_count'] as num?)?.toInt() ?? 0,
      commentsCount: (json['comments_count'] as num?)?.toInt() ?? 0,
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? '') ??
          DateTime.now(),
    );
  }

  PostEntity toEntity() => PostEntity(
        id: id,
        user: user.toEntity(),
        caption: caption,
        image: image,
        video: video,
        likesCount: likesCount,
        commentsCount: commentsCount,
        createdAt: createdAt,
      );
}

