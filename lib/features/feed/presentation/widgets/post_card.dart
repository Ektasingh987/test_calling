import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../calling/presentation/cubit/call_cubit.dart';
import '../../../calling/presentation/screens/active_call_screen.dart';
import '../../domain/entities/post_entity.dart';

class PostCard extends StatelessWidget {
  final PostEntity post;

  const PostCard({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.surfaceCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.divider, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context),
          if (post.caption != null && post.caption!.isNotEmpty)
            _buildCaption(),
          if (post.image != null) _buildImage(),
          _buildActions(),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Row(
        children: [
          _buildAvatar(),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  post.user.displayName,
                  style: AppTheme.titleMedium,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  DateFormatter.timeAgo(post.createdAt),
                  style: AppTheme.bodySmall,
                ),
              ],
            ),
          ),

          // Quick call action (Voice)
          IconButton(
            icon: const Icon(Icons.call_rounded, size: 20),
            color: AppTheme.callGreen,
            tooltip: 'Voice Call',
            onPressed: () => _startCall(context, isVideo: false),
          ),

          // Quick call action (Video)
          IconButton(
            icon: const Icon(Icons.videocam_rounded, size: 22),
            color: AppTheme.primary,
            tooltip: 'Video Call',
            onPressed: () => _startCall(context, isVideo: true),
          ),
        ],
      ),
    );
  }

  void _startCall(BuildContext context, {required bool isVideo}) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BlocProvider<ActiveCallCubit>(
          create: (_) => sl<ActiveCallCubit>()
            ..startCall(
              callerName: post.user.displayName,
              isVideo: isVideo,
            ),
          child: ActiveCallScreen(
            callerName: post.user.displayName,
            callerAvatar: post.user.profilePicture,
            isVideo: isVideo,
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    final url = post.user.profilePicture;
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: url == null ? AppTheme.primaryGradient : null,
        border: Border.all(color: AppTheme.primary.withValues(alpha: 0.4), width: 2),
      ),
      child: url != null
          ? ClipOval(
              child: CachedNetworkImage(
                imageUrl: url,
                fit: BoxFit.cover,
                placeholder: (_, __) => const _AvatarPlaceholder(),
                errorWidget: (_, __, ___) => const _AvatarPlaceholder(),
              ),
            )
          : Center(
              child: Text(
                post.user.displayName.isNotEmpty
                    ? post.user.displayName[0].toUpperCase()
                    : '?',
                style: const TextStyle(
                  fontFamily: 'Inter',
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ),
    );
  }

  Widget _buildCaption() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Text(
        post.caption!,
        style: AppTheme.bodyLarge.copyWith(height: 1.45),
      ),
    );
  }

  Widget _buildImage() {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: ClipRRect(
        child: CachedNetworkImage(
          imageUrl: post.image!,
          width: double.infinity,
          fit: BoxFit.cover,
          placeholder: (context, url) => Container(
            height: 220,
            color: AppTheme.surfaceElevated,
            child: const Center(
              child: CircularProgressIndicator(
                color: AppTheme.primary,
                strokeWidth: 2,
              ),
            ),
          ),
          errorWidget: (context, url, error) => Container(
            height: 180,
            color: AppTheme.surfaceElevated,
            child: const Center(
              child: Icon(
                Icons.broken_image_rounded,
                color: AppTheme.textSecondary,
                size: 36,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActions() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          // Likes
          _ActionButton(
            icon: Icons.favorite_border_rounded,
            label: '${post.likesCount}',
            onTap: () {},
          ),
          const SizedBox(width: 20),

          // Comments
          _ActionButton(
            icon: Icons.chat_bubble_outline_rounded,
            label: '${post.commentsCount}',
            onTap: () {},
          ),
          const Spacer(),

          // Share
          IconButton(
            icon: const Icon(
              Icons.share_outlined,
              color: AppTheme.textSecondary,
              size: 20,
            ),
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, color: AppTheme.textSecondary, size: 20),
          const SizedBox(width: 6),
          Text(label, style: AppTheme.labelMedium),
        ],
      ),
    );
  }
}

class _AvatarPlaceholder extends StatelessWidget {
  const _AvatarPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppTheme.surfaceElevated,
      child: const Icon(
        Icons.person_rounded,
        color: AppTheme.textSecondary,
        size: 24,
      ),
    );
  }
}
