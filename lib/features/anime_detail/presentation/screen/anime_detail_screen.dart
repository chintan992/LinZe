import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:linze/core/models/anime_model.dart';
import 'package:linze/core/services/anime_provider.dart';
import 'package:linze/core/providers/user_preferences_provider.dart';
import 'package:linze/core/providers/watch_progress_provider.dart';
import 'package:linze/core/providers/watchlist_provider.dart';
import 'package:linze/core/models/watch_progress.dart';
import 'package:linze/features/video_player/presentation/screen/video_player_screen.dart';
import 'package:linze/features/anime_detail/presentation/widgets/anime_hero_banner.dart';
import 'package:linze/features/anime_detail/presentation/widgets/stats_bar_widget.dart';
import 'package:linze/features/anime_detail/presentation/widgets/action_buttons_section.dart';
import 'package:linze/features/anime_detail/presentation/widgets/tabbed_content_widget.dart';
import 'package:linze/core/models/anilist/anilist_media.dart';
import 'package:linze/core/models/anilist/anilist_media_list.dart';
import 'package:linze/core/providers/anilist_auth_provider.dart';
import 'package:linze/core/providers/anilist_data_providers.dart';
// removed unused imports

class AnimeDetailScreen extends ConsumerStatefulWidget {
  final Anime anime;

  const AnimeDetailScreen({super.key, required this.anime});

  @override
  ConsumerState<AnimeDetailScreen> createState() => _AnimeDetailScreenState();
}

class _AnimeDetailScreenState extends ConsumerState<AnimeDetailScreen> {
  bool _isFavorite = false;
  double _scrollOffset = 0.0;
  AniListMedia? _anilistMedia;
  AniListMediaList? _userMediaListEntry;

  @override
  void initState() {
    super.initState();
    _loadAniListData();
  }

  Future<void> _loadAniListData() async {
    final isLoggedIn = ref.read(anilistLoginStatusProvider);
    if (!isLoggedIn) return;

    try {
      final anilistApi = ref.read(anilistApiServiceProvider);

      // Try to find AniList media by searching with the anime title
      final searchResults = await anilistApi.searchMedia(widget.anime.title);
      if (searchResults.isNotEmpty) {
        _anilistMedia = searchResults.first;

        // Get user's media list entry for this anime
        final user = await anilistApi.getAuthenticatedUser();
        if (user != null) {
          final userMediaList = await anilistApi.getUserMediaList(
            userId: user['id'],
          );
          try {
            _userMediaListEntry = userMediaList.lists.firstWhere(
              (entry) => entry.mediaId == _anilistMedia!.id,
            );
          } catch (e) {
            _userMediaListEntry = null;
          }
        }
      }

      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      debugPrint('Failed to load AniList data: $e');
    }
  }

  Future<void> _updateAniListStatus(AniListMediaListStatus status) async {
    if (_anilistMedia == null) return;

    try {
      final anilistApi = ref.read(anilistApiServiceProvider);

      await anilistApi.saveMediaToList(
        mediaId: _anilistMedia!.id,
        status: status,
        progress: _userMediaListEntry?.progress,
        score: _userMediaListEntry?.score,
      );

      // Refresh user media list
      await _loadAniListData();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Updated status to ${status.name.toLowerCase()}'),
            backgroundColor: const Color(0xFF5B13EC),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update status: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showAniListStatusDialog() {
    if (_anilistMedia == null) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2C2C2E),
        title: Text(
          'Update Status',
          style: GoogleFonts.plusJakartaSans(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: AniListMediaListStatus.values.map((status) {
            final isSelected = _userMediaListEntry?.status == status;
            return ListTile(
              title: Text(
                status.name
                    .toLowerCase()
                    .replaceAll('_', ' ')
                    .split(' ')
                    .map(
                      (word) => word.isNotEmpty
                          ? word[0].toUpperCase() + word.substring(1)
                          : '',
                    )
                    .join(' '),
                style: GoogleFonts.plusJakartaSans(
                  color: Colors.white,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
              leading: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected ? const Color(0xFF02A9FF) : Colors.grey,
                    width: 2,
                  ),
                  color: isSelected
                      ? const Color(0xFF02A9FF)
                      : Colors.transparent,
                ),
                child: isSelected
                    ? const Icon(Icons.check, color: Colors.white, size: 16)
                    : null,
              ),
              onTap: () {
                Navigator.of(context).pop();
                _updateAniListStatus(status);
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  Future<void> _playEpisode(
    Episode episode,
    int episodeIndex,
    List<Episode> episodes,
    WidgetRef ref,
  ) async {
    try {
      // Get user preferences (current state)
      final userPreferences = ref.read(userPreferencesProvider);

      final apiService = ref.read(apiServiceProvider);
      final streamingInfo = await apiService.getStreamingInfo(
        id: episode.id,
        server: userPreferences.defaultServer,
        type: userPreferences.preferredAudioType,
      );

      if (!mounted) return;

      if (streamingInfo.streamingLink != null) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => VideoPlayerScreen(
              streamingLink: streamingInfo.streamingLink!,
              animeTitle: widget.anime.title,
              episodeTitle: episode.title ?? 'Episode ${episode.episodeNo}',
              episodeId: episode.id,
              episodes: episodes,
              currentEpisodeIndex: episodeIndex,
              animeId: widget.anime.id,
            ),
          ),
        );
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No streaming link available for this episode'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load episode: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF161022),
      body: Consumer(
        builder: (context, ref, child) {
          final animeDetail = ref.watch(animeDetailProvider(widget.anime.id));
          final episodes = ref.watch(episodesProvider(widget.anime.id));
          final characters = ref.watch(characterListProvider(widget.anime.id));
          final isInWatchlist = ref.watch(
            isAnimeInWatchlistProvider(widget.anime.id),
          );

          // Load watch progress for this anime
          ref
              .read(watchProgressNotifierProvider.notifier)
              .loadAnimeProgress(widget.anime.id);

          return animeDetail.when(
            data: (detail) {
              final anime = detail.data ?? widget.anime;
              final totalEpisodes = episodes.hasValue
                  ? (episodes.value?.totalEpisodes ?? 0)
                  : 0;

              return Stack(
                children: [
                  // Main scrollable content
                  CustomScrollView(
                    physics: const BouncingScrollPhysics(),
                    slivers: [
                      // Custom App Bar
                      SliverToBoxAdapter(child: _buildCustomAppBar()),

                      // Hero Banner
                      SliverToBoxAdapter(
                        child: AnimeHeroBanner(
                          anime: anime,
                          scrollOffset: _scrollOffset,
                          onPlayPressed: () => _playFirstEpisode(episodes, ref),
                          onAddToListPressed: () => _toggleWatchlist(anime),
                          onSharePressed: () => _shareAnime(anime),
                        ),
                      ),

                      // Stats Bar
                      SliverToBoxAdapter(
                        child: StatsBarWidget(
                          anime: anime,
                          totalEpisodes: totalEpisodes,
                        ),
                      ),

                      // Action Buttons
                      SliverToBoxAdapter(
                        child: ActionButtonsSection(
                          onPlayPressed: () => _playFirstEpisode(episodes, ref),
                          onAddToListPressed: () => _toggleWatchlist(anime),
                          onSharePressed: () => _shareAnime(anime),
                          isInWatchlist: isInWatchlist.value ?? false,
                          isFavorite: _isFavorite,
                          continueFromEpisode: _getContinueFromEpisode(
                            episodes,
                          ),
                          // AniList specific functionality will be added later
                        ),
                      ),

                      // Tabbed Content
                      SliverFillRemaining(
                        child: TabbedContentWidget(
                          anime: anime,
                          animeDetail: animeDetail,
                          episodes: episodes,
                          characters: characters,
                          onEpisodeTap: (episode, index, episodes) =>
                              _playEpisode(episode, index, episodes, ref),
                        ),
                      ),
                    ],
                  ),

                  // Scroll notification listener for parallax effects
                  Positioned.fill(
                    child: NotificationListener<ScrollNotification>(
                      onNotification: (notification) {
                        if (notification is ScrollUpdateNotification) {
                          setState(() {
                            _scrollOffset = notification.metrics.pixels;
                          });
                        }
                        return false;
                      },
                      child: const SizedBox.expand(),
                    ),
                  ),
                ],
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error, color: Colors.red, size: 64),
                  const SizedBox(height: 16),
                  Text(
                    'Error loading anime details: $error',
                    style: GoogleFonts.plusJakartaSans(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      ref.invalidate(animeDetailProvider(widget.anime.id));
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCustomAppBar() {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top,
        left: 16,
        right: 16,
        bottom: 8,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFF161022).withValues(alpha: 0.8),
            Colors.transparent,
          ],
        ),
      ),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(
                Icons.arrow_back_rounded,
                color: Colors.white,
                size: 24,
              ),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          const Spacer(),
          Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  onPressed: () {
                    setState(() {
                      _isFavorite = !_isFavorite;
                    });
                  },
                  icon: Icon(
                    _isFavorite
                        ? Icons.favorite_rounded
                        : Icons.favorite_border_rounded,
                    color: _isFavorite ? Colors.red : Colors.white,
                    size: 24,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Consumer(
                builder: (context, ref, child) {
                  final isInWatchlist = ref.watch(
                    isAnimeInWatchlistProvider(widget.anime.id),
                  );
                  return Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      onPressed: () => _toggleWatchlist(widget.anime),
                      icon: Icon(
                        (isInWatchlist.value ?? false)
                            ? Icons.bookmark_rounded
                            : Icons.bookmark_border_rounded,
                        color: (isInWatchlist.value ?? false)
                            ? const Color(0xFF5B13EC)
                            : Colors.white,
                        size: 24,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(width: 8),
              // AniList Status Button (only show if logged in and AniList data is available)
              Consumer(
                builder: (context, ref, child) {
                  final isLoggedIn = ref.watch(anilistLoginStatusProvider);
                  if (!isLoggedIn || _anilistMedia == null) {
                    return const SizedBox.shrink();
                  }

                  final status = _userMediaListEntry?.status;
                  IconData statusIcon;
                  Color statusColor;

                  switch (status) {
                    case AniListMediaListStatus.current:
                      statusIcon = Icons.play_circle_outline;
                      statusColor = const Color(0xFF02A9FF);
                      break;
                    case AniListMediaListStatus.completed:
                      statusIcon = Icons.check_circle_outline;
                      statusColor = const Color(0xFF00C851);
                      break;
                    case AniListMediaListStatus.planning:
                      statusIcon = Icons.schedule;
                      statusColor = const Color(0xFFFFB300);
                      break;
                    case AniListMediaListStatus.paused:
                      statusIcon = Icons.pause_circle_outline;
                      statusColor = const Color(0xFFFF6B00);
                      break;
                    case AniListMediaListStatus.dropped:
                      statusIcon = Icons.cancel_outlined;
                      statusColor = const Color(0xFFFF3B30);
                      break;
                    default:
                      statusIcon = Icons.add_circle_outline;
                      statusColor = Colors.white;
                  }

                  return Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      onPressed: _showAniListStatusDialog,
                      icon: Icon(statusIcon, color: statusColor, size: 24),
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  String? _getContinueFromEpisode(AsyncValue episodes) {
    if (!episodes.hasValue || episodes.value?.episodes?.isEmpty == true) {
      return null;
    }

    final episodesList = episodes.value!.episodes!;
    final watchProgressNotifier = ref.read(
      watchProgressNotifierProvider.notifier,
    );

    // Find the first episode that's not completed
    for (final episode in episodesList) {
      final status = watchProgressNotifier.getWatchStatus(episode.id);
      if (status == WatchStatus.inProgress) {
        return 'Episode ${episode.episodeNo}';
      }
    }

    return null;
  }

  void _playFirstEpisode(AsyncValue episodes, WidgetRef ref) {
    if (episodes.hasValue && episodes.value?.episodes?.isNotEmpty == true) {
      final episodesList = episodes.value!.episodes!;
      _playEpisode(episodesList.first, 0, episodesList, ref);
    }
  }

  void _toggleWatchlist(Anime anime) {
    final watchlistNotifier = ref.read(watchlistNotifierProvider.notifier);
    final isCurrentlyInWatchlist =
        ref.read(isAnimeInWatchlistProvider(anime.id)).value ?? false;

    watchlistNotifier.toggleWatchlist(anime);

    final message = isCurrentlyInWatchlist
        ? 'Removed from watchlist'
        : 'Added to watchlist';

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFF5B13EC),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  void _shareAnime(Anime anime) {
    // TODO: Implement share functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Share ${anime.title}'),
        backgroundColor: const Color(0xFF5B13EC),
      ),
    );
  }
}
