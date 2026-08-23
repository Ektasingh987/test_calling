import 'package:equatable/equatable.dart';

class PostUserEntity extends Equatable {
  final int id;
  final String username;
  final String? profilePicture;
  final String? fullName;

  const PostUserEntity({
    required this.id,
    required this.username,
    this.profilePicture,
    this.fullName,
  });

  String get displayName =>
      (fullName != null && fullName!.isNotEmpty) ? fullName! : username;

  @override
  List<Object?> get props => [id, username, profilePicture, fullName];
}

class PostEntity extends Equatable {
  final int id;
  final PostUserEntity user;
  final String? caption;
  final String? image;
  final String? video;
  final int likesCount;
  final int commentsCount;
  final DateTime createdAt;

  const PostEntity({
    required this.id,
    required this.user,
    this.caption,
    this.image,
    this.video,
    required this.likesCount,
    required this.commentsCount,
    required this.createdAt,
  });

  bool get hasMedia => image != null || video != null;

  @override
  List<Object?> get props =>
      [id, user, caption, image, video, likesCount, commentsCount, createdAt];
}

