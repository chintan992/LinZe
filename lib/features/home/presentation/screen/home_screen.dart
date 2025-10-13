import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:linze/core/models/anime_model.dart';
import 'package:linze/core/services/anime_provider.dart';
import 'package:linze/core/widgets/anime_card.dart';
import 'package:linze/core/widgets/app_logo.dart';
import 'package:linze/features/anime_detail/presentation/screen/anime_detail_screen.dart';
import 'package:linze/features/search_discovery/presentation/screen/search_discovery_screen.dart';
import 'package:linze/features/home/presentation/widgets/immersive_hero_section.dart';
import 'package:linze/features/home/presentation/widgets/continue_watching_card.dart';
import 'package:linze/features/home/presentation/widgets/trending_rank_card.dart';
import 'package:linze/features/home/presentation/widgets/new_release_card.dart';
import 'package:linze/features/home/presentation/widgets/genre_chip.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late ScrollController _scrollController;
  late AnimationController _appBarAnimationController;
  late Animation<double> _appBarOpacityAnimation;
  bool _isAppBarVisible = false;
  String? _selectedGenre;

  // Mock continue watching data - will be populated from actual API data
  List<Map<String, dynamic>> _getContinueWatchingData(List<Anime> availableAnime) {
    if (availableAnime.isEmpty) return [];
    
    return [
      {
        'anime': availableAnime[0],
        'progress': 0.75,
        'currentEpisode': 'S1 E8',
      },
      {
        'anime': availableAnime.length > 1 ? availableAnime[1] : availableAnime[0],
        'progress': 0.45,
        'currentEpisode': 'S2 E3',
      },
      {
        'anime': availableAnime.length > 2 ? availableAnime[2] : availableAnime[0],
        'progress': 0.90,
        'currentEpisode': 'S1 E11',
      },
    ];
  }

  final List<String> _genres = [
    'Action',
    'Adventure',
    'Comedy',
    'Drama',
    'Fantasy',
    'Romance',
    'Sci-Fi',
    'Thriller',
    'Horror',
    'Slice of Life',
  ];

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _appBarAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _appBarOpacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _appBarAnimationController, curve: Curves.easeInOut),
    );
    
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _appBarAnimationController.dispose();
    super.dispose();
  }

  void _onScroll() {
    const threshold = 100.0;
    final isVisible = _scrollController.offset > threshold;
    
    if (isVisible != _isAppBarVisible) {
      setState(() {
        _isAppBarVisible = isVisible;
      });
      
      if (_isAppBarVisible) {
        _appBarAnimationController.forward();
      } else {
        _appBarAnimationController.reverse();
      }
    }
  }

  Anime _convertSpotlightToAnime(dynamic spotlight) {
    return Anime(
      id: spotlight.id,
      dataId: spotlight.dataId,
      title: spotlight.title,
      japaneseTitle: spotlight.japaneseTitle,
      poster: spotlight.poster,
      description: spotlight.description,
      tvInfo: spotlight.tvInfo != null ? TvInfo(
        showType: spotlight.tvInfo.showType,
        duration: spotlight.tvInfo.duration,
        sub: spotlight.tvInfo.sub,
        dub: spotlight.tvInfo.dub,
        eps: spotlight.tvInfo.eps,
      ) : null,
    );
  }

  Anime _convertTrendingToAnime(dynamic trending) {
    return Anime(
      id: trending.id,
      dataId: trending.dataId,
      title: trending.title,
      japaneseTitle: trending.japaneseTitle,
      poster: trending.poster,
      description: '',
      tvInfo: null,
    );
  }

  Anime _convertLatestEpisodeToAnime(dynamic latestEpisode) {
    return Anime(
      id: latestEpisode.id,
      dataId: latestEpisode.dataId,
      title: latestEpisode.title,
      japaneseTitle: latestEpisode.japaneseTitle,
      poster: latestEpisode.poster,
      description: latestEpisode.description,
      tvInfo: latestEpisode.tvInfo != null ? TvInfo(
        showType: latestEpisode.tvInfo.showType,
        duration: latestEpisode.tvInfo.duration,
        sub: latestEpisode.tvInfo.sub,
        dub: latestEpisode.tvInfo.dub,
        eps: latestEpisode.tvInfo.eps,
      ) : null,
    );
  }

  Widget _buildTransparentAppBar() {
    return AnimatedBuilder(
      animation: _appBarOpacityAnimation,
      builder: (context, child) {
        return Container(
          height: kToolbarHeight + MediaQuery.of(context).padding.top,
          decoration: BoxDecoration(
            color: _isAppBarVisible 
                ? const Color(0xFF121212).withValues(alpha: _appBarOpacityAnimation.value)
                : Colors.transparent,
            border: _isAppBarVisible 
                ? Border(
                    bottom: BorderSide(
                      color: const Color(0xFF2A2A2A).withValues(alpha: _appBarOpacityAnimation.value),
                      width: 1,
                    ),
                  )
                : null,
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  // App Logo
                  const AppLogo(size: 28),
                  const SizedBox(width: 12),
                  
                  // App Name
                  if (_isAppBarVisible)
                    FadeTransition(
                      opacity: _appBarOpacityAnimation,
                      child: Text(
                        'Linze',
                        style: GoogleFonts.plusJakartaSans(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  
                  const Spacer(),
                  
                  // Search Button
                  IconButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SearchDiscoveryScreen(),
                        ),
                      );
                    },
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: _isAppBarVisible 
                            ? const Color(0xFF1F1F1F).withValues(alpha: _appBarOpacityAnimation.value)
                            : Colors.black.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.search,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                  
                  const SizedBox(width: 8),
                  
                  // Notifications Button
                  IconButton(
                    onPressed: () {},
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: _isAppBarVisible 
                            ? const Color(0xFF1F1F1F).withValues(alpha: _appBarOpacityAnimation.value)
                            : Colors.black.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.notifications_outlined,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSectionHeader(String title, {VoidCallback? onSeeAll}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: GoogleFonts.plusJakartaSans(
              color: const Color(0xFFEAEAEA),
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (onSeeAll != null)
            TextButton(
              onPressed: onSeeAll,
              child: Text(
                'See All',
                style: GoogleFonts.plusJakartaSans(
                  color: const Color(0xFF5B13EC),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildContinueWatchingSection(List<Map<String, dynamic>> continueWatching) {
    if (continueWatching.isEmpty) return const SizedBox.shrink();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Continue Watching'),
        SizedBox(
          height: 220,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.only(left: 16),
            itemCount: continueWatching.length,
            itemBuilder: (context, index) {
              final item = continueWatching[index];
              return ContinueWatchingCard(
                anime: item['anime'] as Anime,
                progress: item['progress'] as double,
                currentEpisode: item['currentEpisode'] as String,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AnimeDetailScreen(anime: item['anime'] as Anime),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTrendingSection(List trending) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Trending Now'),
        SizedBox(
          height: 280,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.only(left: 16),
            itemCount: trending.length,
            itemBuilder: (context, index) {
              final anime = _convertTrendingToAnime(trending[index]);
              return TrendingRankCard(
                anime: anime,
                rank: index + 1,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AnimeDetailScreen(anime: anime),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildNewReleasesSection(List latestEpisodes) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('New Releases'),
        SizedBox(
          height: 240,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.only(left: 16),
            itemCount: latestEpisodes.length,
            itemBuilder: (context, index) {
              final anime = _convertLatestEpisodeToAnime(latestEpisodes[index]);
              return NewReleaseCard(
                anime: anime,
                releaseDate: 'Today', // Mock date
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AnimeDetailScreen(anime: anime),
                    ),
                  );
                },
                onAddToList: () {
                  // Add to watchlist
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildGenreSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Browse by Genre'),
        GenreChipsList(
          genres: _genres,
          selectedGenre: _selectedGenre,
          onGenreSelected: (genre) {
            setState(() {
              _selectedGenre = _selectedGenre == genre ? null : genre;
            });
          },
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildAnimeSection(String title, List animeList, {String? badge}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(title),
        SizedBox(
          height: 280,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.only(left: 16),
            itemCount: animeList.length,
            itemBuilder: (context, index) {
              final anime = animeList[index];
              return AnimeCard(
                anime: anime,
                type: AnimeCardType.standard,
                badge: badge != null ? _getBadgeFromString(badge) : null,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AnimeDetailScreen(anime: anime),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  AnimeCardBadge? _getBadgeFromString(String badge) {
    switch (badge.toLowerCase()) {
      case 'new':
        return AnimeCardBadge.new_;
      case 'dub':
        return AnimeCardBadge.dub;
      case 'airing':
        return AnimeCardBadge.airing;
      case 'popular':
        return AnimeCardBadge.popular;
      case 'favorite':
        return AnimeCardBadge.favorite;
      case 'completed':
        return AnimeCardBadge.completed;
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: Stack(
        children: [
          Consumer(
            builder: (context, ref, child) {
              final homeData = ref.watch(homePageProvider);
              
              return homeData.when(
                data: (data) {
                  final spotlights = data.spotlights.map(_convertSpotlightToAnime).toList();
                  final trending = data.trending;
                  final latestEpisodes = data.latestEpisode;
                  final continueWatchingData = _getContinueWatchingData(spotlights);
                  
                  return CustomScrollView(
                    controller: _scrollController,
                    slivers: [
                      // Transparent App Bar
                      SliverAppBar(
                        backgroundColor: Colors.transparent,
                        elevation: 0,
                        floating: false,
                        pinned: false,
                        expandedHeight: 0,
                        toolbarHeight: 0,
                      ),
                      
                      // Immersive Hero Section
                      if (spotlights.isNotEmpty)
                        SliverToBoxAdapter(
                          child: ImmersiveHeroSection(
                            spotlights: spotlights,
                            onPlay: () {
                              // Play hero content
                            },
                            onAddToList: () {
                              // Add to watchlist
                            },
                            onInfo: () {
                              // Show info
                            },
                            onTap: (anime) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => AnimeDetailScreen(anime: anime),
                                ),
                              );
                            },
                          ),
                        ),
                      
                      // Continue Watching Section
                      SliverToBoxAdapter(
                        child: _buildContinueWatchingSection(continueWatchingData),
                      ),
                      
                      // Trending Section
                      if (trending.isNotEmpty)
                        SliverToBoxAdapter(
                          child: _buildTrendingSection(trending),
                        ),
                      
                      // New Releases Section
                      if (latestEpisodes.isNotEmpty)
                        SliverToBoxAdapter(
                          child: _buildNewReleasesSection(latestEpisodes),
                        ),
                      
                      // Genre Section
                      SliverToBoxAdapter(
                        child: _buildGenreSection(),
                      ),
                      
                      // Top Airing Section
                      if (data.topAiring.isNotEmpty)
                        SliverToBoxAdapter(
                          child: _buildAnimeSection(
                            'Top Airing This Season',
                            data.topAiring.map(_convertLatestEpisodeToAnime).toList(),
                            badge: 'Airing',
                          ),
                        ),
                      
                      // Most Popular Section
                      if (data.mostPopular.isNotEmpty)
                        SliverToBoxAdapter(
                          child: _buildAnimeSection(
                            'Popular This Week',
                            data.mostPopular.map(_convertLatestEpisodeToAnime).toList(),
                            badge: 'Popular',
                          ),
                        ),
                      
                      // Most Favorite Section
                      if (data.mostFavorite.isNotEmpty)
                        SliverToBoxAdapter(
                          child: _buildAnimeSection(
                            'Most Favorite',
                            data.mostFavorite.map(_convertLatestEpisodeToAnime).toList(),
                            badge: 'Favorite',
                          ),
                        ),
                      
                      // Latest Completed Section
                      if (data.latestCompleted.isNotEmpty)
                        SliverToBoxAdapter(
                          child: _buildAnimeSection(
                            'Latest Completed',
                            data.latestCompleted.map(_convertLatestEpisodeToAnime).toList(),
                            badge: 'Completed',
                          ),
                        ),
                      
                      // Bottom Spacing
                      const SliverToBoxAdapter(
                        child: SizedBox(height: 100),
                      ),
                    ],
                  );
                },
                loading: () => const Center(
                  child: CircularProgressIndicator(
                    color: Color(0xFF5B13EC),
                  ),
                ),
                error: (error, stack) => Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.red.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(50),
                        ),
                        child: const Icon(
                          Icons.error_outline,
                          color: Colors.red,
                          size: 48,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Oops! Something went wrong',
                        style: GoogleFonts.plusJakartaSans(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Please check your connection and try again',
                        style: GoogleFonts.plusJakartaSans(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: () {
                          ref.invalidate(homePageProvider);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF5B13EC),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                        ),
                        child: Text(
                          'Try Again',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          
          // Transparent App Bar Overlay
          _buildTransparentAppBar(),
        ],
      ),
    );
  }
}