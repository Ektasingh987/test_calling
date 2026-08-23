import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_theme.dart';
import '../cubit/feed_cubit.dart';
import '../cubit/feed_state.dart';
import '../widgets/offline_illustration.dart';
import '../widgets/post_card.dart';
import '../widgets/shimmer_post_card.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    context.read<FeedCubit>().loadFeed();
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  void _onScroll() {
    final threshold = _scrollController.position.maxScrollExtent - 200;
    if (_scrollController.position.pixels >= threshold) {
      context.read<FeedCubit>().loadMorePosts();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: NestedScrollView(
        headerSliverBuilder: (_, __) => [_buildAppBar()],
        body: BlocBuilder<FeedCubit, FeedState>(
          builder: (context, state) {
            return _buildBody(context, state);
          },
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      floating: true,
      snap: true,
      backgroundColor: AppTheme.background,
      expandedHeight: 70,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.only(left: 20, bottom: 14),
        title: ShaderMask(
          shaderCallback: (bounds) =>
              AppTheme.primaryGradient.createShader(bounds),
          child: const Text(
            'GaonGram',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ),
      ),
      actions: [
        IconButton(
          onPressed: () {},
          icon: const Icon(
            Icons.notifications_none_rounded,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(width: 4),
      ],
    );
  }

  Widget _buildBody(BuildContext context, FeedState state) {
    // Pure loading: show shimmer
    if (state.isLoadingInitial) {
      return ListView.builder(
        itemCount: 5,
        itemBuilder: (_, __) => const ShimmerPostCard(),
      );
    }

    // Offline with no cache
    if (state.status == FeedStatus.failure && state.posts.isEmpty) {
      if (state.isOfflineData || state.errorMessage == 'You are offline') {
        return OfflineIllustration(
          onRetry: () => context.read<FeedCubit>().loadFeed(),
        );
      }
      return ErrorIllustration(
        message: state.errorMessage ?? 'Unknown error',
        onRetry: () => context.read<FeedCubit>().loadFeed(),
      );
    }

    // Empty state
    if (state.status == FeedStatus.loaded && state.posts.isEmpty) {
      return Center(
        child: Text(
          'No posts yet 👋\nBe the first to post!',
          textAlign: TextAlign.center,
          style: AppTheme.bodyLarge,
        ),
      );
    }

    // Feed list
    return RefreshIndicator(
      onRefresh: () => context.read<FeedCubit>().refreshFeed(),
      color: AppTheme.primary,
      backgroundColor: AppTheme.surfaceCard,
      child: CustomScrollView(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          // Offline banner (serving cached data)
          if (state.isOfflineData)
            SliverToBoxAdapter(child: _buildOfflineBanner()),

          // Post list
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (_, index) {
                if (index < state.posts.length) {
                  return PostCard(post: state.posts[index]);
                }
                return null;
              },
              childCount: state.posts.length,
            ),
          ),

          // Load more indicator or end-of-feed
          SliverToBoxAdapter(child: _buildFooter(state)),
        ],
      ),
    );
  }

  Widget _buildOfflineBanner() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: AppTheme.warning.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.warning.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.wifi_off_rounded,
            color: AppTheme.warning,
            size: 18,
          ),
          const SizedBox(width: 10),
          const Expanded(
            child: Text(
              'Showing cached posts — you\'re offline',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 13,
                color: AppTheme.warning,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter(FeedState state) {
    if (state.isLoadingMore) {
      return const Padding(
        padding: EdgeInsets.all(24),
        child: Center(
          child: CircularProgressIndicator(
            color: AppTheme.primary,
            strokeWidth: 2,
          ),
        ),
      );
    }
    if (state.hasReachedMax && state.posts.isNotEmpty) {
      return Padding(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Text(
            '✨ You\'re all caught up',
            style: AppTheme.bodySmall.copyWith(
              color: AppTheme.textSecondary,
            ),
          ),
        ),
      );
    }
    return const SizedBox(height: 80);
  }
}

