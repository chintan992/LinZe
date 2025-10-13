import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:linze/core/models/anime_model.dart';
import 'package:linze/core/services/anime_provider.dart';
import 'package:linze/core/widgets/anime_card.dart';
import 'package:linze/features/anime_detail/presentation/screen/anime_detail_screen.dart';
import 'package:linze/features/search_discovery/presentation/screen/search_discovery_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
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
      description: '', // Trending doesn't have description
      tvInfo: null, // Trending doesn't have tvInfo
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

  Widget _buildHeroCarousel(List spotlights) {
    return SizedBox(
      height: 280,
      child: PageView.builder(
        controller: PageController(viewportFraction: 0.85),
        itemCount: spotlights.length,
        itemBuilder: (context, index) {
          final spotlight = spotlights[index];
          return AnimeCard(
            anime: _convertSpotlightToAnime(spotlight),
            type: AnimeCardType.hero,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AnimeDetailScreen(
                    anime: _convertSpotlightToAnime(spotlight),
                  ),
                ),
              );
            },
            onAddToList: () {
              // TODO: Implement add to list functionality
            },
          );
        },
      ),
    );
  }

  Widget _buildAnimeCard(dynamic anime, {String? badge, bool isTrending = false}) {
    AnimeCardBadge? cardBadge;
    int? trendingRank;
    
    // Convert string badge to enum
    switch (badge?.toLowerCase()) {
      case 'new':
        cardBadge = AnimeCardBadge.new_;
        break;
      case 'dub':
        cardBadge = AnimeCardBadge.dub;
        break;
      case 'airing':
        cardBadge = AnimeCardBadge.airing;
        break;
      case 'popular':
        cardBadge = AnimeCardBadge.popular;
        break;
      case 'favorite':
        cardBadge = AnimeCardBadge.favorite;
        break;
      case 'completed':
        cardBadge = AnimeCardBadge.completed;
        break;
    }
    
    // Get trending rank if it's a trending item
    if (isTrending && anime.number != null) {
      trendingRank = anime.number;
    }
    
    return AnimeCard(
      anime: isTrending 
        ? _convertTrendingToAnime(anime)
        : _convertLatestEpisodeToAnime(anime),
      type: AnimeCardType.standard,
      badge: cardBadge,
      trendingRank: trendingRank,
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AnimeDetailScreen(
              anime: isTrending 
                ? _convertTrendingToAnime(anime)
                : _convertLatestEpisodeToAnime(anime),
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

  Widget _buildTrendingSection(List trending) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Trending Now'),
        SizedBox(
          height: 220,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.only(left: 16),
            itemCount: trending.length,
            itemBuilder: (context, index) {
              return _buildAnimeCard(trending[index], isTrending: true);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildNewEpisodesSection(List latestEpisodes) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('New Episodes'),
        SizedBox(
          height: 220,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.only(left: 16),
            itemCount: latestEpisodes.length,
            itemBuilder: (context, index) {
              return _buildAnimeCard(latestEpisodes[index], badge: 'New');
            },
          ),
        ),
      ],
    );
  }

  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: Consumer(
        builder: (context, ref, child) {
          final homeData = ref.watch(homePageProvider);
          
          return homeData.when(
            data: (data) {
              final spotlights = data.spotlights;
              final trending = data.trending;
              final latestEpisodes = data.latestEpisode;
              
              return CustomScrollView(
                  slivers: [
                    // App Bar
                  SliverAppBar(
                    backgroundColor: const Color(0xFF121212),
                    elevation: 0,
                    floating: true,
                    snap: true,
                    expandedHeight: 120,
                    flexibleSpace: FlexibleSpaceBar(
                      background: Padding(
                        padding: const EdgeInsets.only(top: 40, left: 16, right: 16),
                        child: Row(
                          children: [
                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Color(0xFF5B13EC), Color(0xFF8B5CF6)],
                                ),
                                borderRadius: BorderRadius.circular(18),
                              ),
                              child: const Icon(
                                Icons.live_tv,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Linze',
                              style: GoogleFonts.plusJakartaSans(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const Spacer(),
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
                                  color: const Color(0xFF1F1F1F),
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
                            IconButton(
                              onPressed: () {},
                              icon: Container(
                                padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1F1F1F),
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
                  ),
                  
                  // Hero Carousel
                  if (spotlights.isNotEmpty)
                    SliverToBoxAdapter(
                      child: _buildHeroCarousel(spotlights),
                    ),
                  
                  // Trending Section
                  if (trending.isNotEmpty)
                    SliverToBoxAdapter(
                      child: _buildTrendingSection(trending),
                    ),
                  
                        // New Episodes Section
                        if (latestEpisodes.isNotEmpty)
                          SliverToBoxAdapter(
                            child: _buildNewEpisodesSection(latestEpisodes),
                          ),

                        // Top Airing Section
                        if (data.topAiring.isNotEmpty)
                          SliverToBoxAdapter(
                            child: Column(
                              children: [
                                _buildSectionHeader(
                                  'Top Airing',
                                ),
                                SizedBox(
                                  height: 280,
                                  child: ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: data.topAiring.length,
                                    itemBuilder: (context, index) {
                                      final anime = data.topAiring[index];
                                      return Padding(
                                        padding: EdgeInsets.only(right: 16),
                                        child: _buildAnimeCard(
                                          anime,
                                          badge: 'Airing',
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                SizedBox(height: 24),
                              ],
                            ),
                          ),

                        // Most Popular Section
                        if (data.mostPopular.isNotEmpty)
                          SliverToBoxAdapter(
                            child: Column(
                              children: [
                                _buildSectionHeader(
                                  'Most Popular',
                                ),
                                SizedBox(
                                  height: 280,
                                  child: ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: data.mostPopular.length,
                                    itemBuilder: (context, index) {
                                      final anime = data.mostPopular[index];
                                      return Padding(
                                        padding: EdgeInsets.only(right: 16),
                                        child: _buildAnimeCard(
                                          anime,
                                          badge: 'Popular',
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                SizedBox(height: 24),
                              ],
                            ),
                          ),

                        // Most Favorite Section
                        if (data.mostFavorite.isNotEmpty)
                          SliverToBoxAdapter(
                            child: Column(
                              children: [
                                _buildSectionHeader(
                                  'Most Favorite',
                                ),
                                SizedBox(
                                  height: 280,
                                  child: ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: data.mostFavorite.length,
                                    itemBuilder: (context, index) {
                                      final anime = data.mostFavorite[index];
                                      return Padding(
                                        padding: EdgeInsets.only(right: 16),
                                        child: _buildAnimeCard(
                                          anime,
                                          badge: 'Favorite',
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                SizedBox(height: 24),
                              ],
                            ),
                          ),

                        // Latest Completed Section
                        if (data.latestCompleted.isNotEmpty)
                          SliverToBoxAdapter(
                            child: Column(
                              children: [
                                _buildSectionHeader(
                                  'Latest Completed',
                                ),
                                SizedBox(
                                  height: 280,
                                  child: ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: data.latestCompleted.length,
                                    itemBuilder: (context, index) {
                                      final anime = data.latestCompleted[index];
                                      return Padding(
                                        padding: EdgeInsets.only(right: 16),
                                        child: _buildAnimeCard(
                                          anime,
                                          badge: 'Completed',
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                SizedBox(height: 24),
                              ],
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
    );
  }
}