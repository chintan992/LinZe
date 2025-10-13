import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:linze/core/models/anime_model.dart';
import 'package:linze/core/services/anime_provider.dart';
import 'package:linze/core/providers/user_preferences_provider.dart';
import 'package:linze/core/providers/watch_progress_provider.dart';
import 'package:linze/core/models/watch_progress.dart';
import 'package:linze/features/video_player/presentation/screen/video_player_screen.dart';
import 'package:linze/features/anime_detail/presentation/widgets/anime_hero_banner.dart';
import 'package:linze/features/anime_detail/presentation/widgets/stats_bar_widget.dart';
import 'package:linze/features/anime_detail/presentation/widgets/action_buttons_section.dart';
import 'package:linze/features/anime_detail/presentation/widgets/tabbed_content_widget.dart';

class AnimeDetailScreen extends ConsumerStatefulWidget {
  final Anime anime;
  
  const AnimeDetailScreen({super.key, required this.anime});

  @override
  ConsumerState<AnimeDetailScreen> createState() => _AnimeDetailScreenState();
}

class _AnimeDetailScreenState extends ConsumerState<AnimeDetailScreen> {
  bool _isFavorite = false;
  bool _isInWatchlist = false;
  double _scrollOffset = 0.0;
  
  
  Future<void> _playEpisode(Episode episode, int episodeIndex, List<Episode> episodes) async {
    try {
      // Get user preferences
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
          
          // Load watch progress for this anime
          ref.read(watchProgressNotifierProvider.notifier).loadAnimeProgress(widget.anime.id);
          
          return animeDetail.when(
            data: (detail) {
              final anime = detail.data ?? widget.anime;
              final totalEpisodes = episodes.hasValue ? (episodes.value?.totalEpisodes ?? 0) : 0;
              
              return Stack(
                children: [
                  // Main scrollable content
                  CustomScrollView(
                    physics: const BouncingScrollPhysics(),
                    slivers: [
                      // Custom App Bar
                      SliverToBoxAdapter(
                        child: _buildCustomAppBar(),
                      ),
                      
                      // Hero Banner
                      SliverToBoxAdapter(
                        child: AnimeHeroBanner(
                          anime: anime,
                          scrollOffset: _scrollOffset,
                          onPlayPressed: () => _playFirstEpisode(episodes),
                          onAddToListPressed: () {
                            setState(() {
                              _isInWatchlist = !_isInWatchlist;
                            });
                          },
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
                          onPlayPressed: () => _playFirstEpisode(episodes),
                          onAddToListPressed: () {
                            setState(() {
                              _isInWatchlist = !_isInWatchlist;
                            });
                          },
                          onSharePressed: () => _shareAnime(anime),
                          isInWatchlist: _isInWatchlist,
                          isFavorite: _isFavorite,
                          continueFromEpisode: _getContinueFromEpisode(episodes),
                        ),
                      ),
                      
                      // Tabbed Content
                      SliverFillRemaining(
                        child: TabbedContentWidget(
                          anime: anime,
                          animeDetail: animeDetail,
                          episodes: episodes,
                          characters: characters,
                          onEpisodeTap: _playEpisode,
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
                  const Icon(
                    Icons.error,
                    color: Colors.red,
                    size: 64,
                  ),
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
                    _isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                    color: _isFavorite ? Colors.red : Colors.white,
                    size: 24,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  onPressed: () {
                    setState(() {
                      _isInWatchlist = !_isInWatchlist;
                    });
                  },
                  icon: Icon(
                    _isInWatchlist ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                    color: _isInWatchlist ? const Color(0xFF5B13EC) : Colors.white,
                    size: 24,
                  ),
                ),
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
    final watchProgressNotifier = ref.read(watchProgressNotifierProvider.notifier);
    
    // Find the first episode that's not completed
    for (final episode in episodesList) {
      final status = watchProgressNotifier.getWatchStatus(episode.id);
      if (status == WatchStatus.inProgress) {
        return 'Episode ${episode.episodeNo}';
      }
    }
    
    return null;
  }

  void _playFirstEpisode(AsyncValue episodes) {
    if (episodes.hasValue && episodes.value?.episodes?.isNotEmpty == true) {
      final episodesList = episodes.value!.episodes!;
      _playEpisode(episodesList.first, 0, episodesList);
    }
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