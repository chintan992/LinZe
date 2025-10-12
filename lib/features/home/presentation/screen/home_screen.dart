import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:linze/core/models/anime_model.dart';
import 'package:linze/core/services/anime_provider.dart';
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

  Widget _buildHeroBanner(dynamic spotlight) {
    return Container(
      height: 280,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        image: DecorationImage(
          image: CachedNetworkImageProvider(spotlight.poster),
          fit: BoxFit.cover,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.transparent,
                        Colors.black.withValues(alpha: 0.3),
              Colors.black.withValues(alpha: 0.8),
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF5B13EC),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'FEATURED',
                  style: GoogleFonts.plusJakartaSans(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                spotlight.title,
                style: GoogleFonts.plusJakartaSans(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  height: 1.2,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Text(
                spotlight.description ?? '',
                style: GoogleFonts.plusJakartaSans(
                  color: Colors.white.withValues(alpha: 0.9),
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  height: 1.4,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.play_arrow,
                          color: const Color(0xFF5B13EC),
                          size: 20,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Watch Now',
                          style: GoogleFonts.plusJakartaSans(
                            color: const Color(0xFF5B13EC),
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
                    ),
                    child: Icon(
                      Icons.add,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnimeCard(dynamic anime, {String? badge, bool isTrending = false}) {
    return GestureDetector(
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
      child: Container(
        width: 140,
        margin: const EdgeInsets.only(right: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: CachedNetworkImage(
                      imageUrl: anime.poster,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                      placeholder: (context, url) => Container(
                        color: Colors.grey[800],
                        child: const Center(
                          child: CircularProgressIndicator(
                            color: Color(0xFF5B13EC),
                          ),
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: Colors.grey[800],
                        child: const Icon(
                          Icons.error,
                          color: Colors.white54,
                        ),
                      ),
                    ),
                  ),
                  if (badge != null)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: badge == 'New' ? const Color(0xFF5B13EC) : Colors.red,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          badge,
                          style: GoogleFonts.plusJakartaSans(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  if (isTrending)
                    Positioned(
                      bottom: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.7),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.trending_up,
                              color: Colors.white,
                              size: 12,
                            ),
                            const SizedBox(width: 2),
                            Text(
                              '${(anime as dynamic).number ?? '1'}',
                              style: GoogleFonts.plusJakartaSans(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              anime.title,
              style: GoogleFonts.plusJakartaSans(
                color: const Color(0xFFEAEAEA),
                fontSize: 14,
                fontWeight: FontWeight.w600,
                height: 1.2,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              isTrending ? 'Trending' : 'New Episode',
              style: GoogleFonts.plusJakartaSans(
                color: const Color(0xFFA9A9A9),
                fontSize: 12,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
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

  Widget _buildQuickAccessGrid() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Access',
            style: GoogleFonts.plusJakartaSans(
              color: const Color(0xFFEAEAEA),
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildQuickAccessCard(
                  'Continue Watching',
                  Icons.history,
                  const Color(0xFF5B13EC),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildQuickAccessCard(
                  'My List',
                  Icons.bookmark,
                  Colors.orange,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildQuickAccessCard(
                  'Simulcast',
                  Icons.live_tv,
                  Colors.red,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildQuickAccessCard(
                  'Browse',
                  Icons.explore,
                  Colors.green,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAccessCard(String title, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1F1F1F),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: color,
              size: 24,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: GoogleFonts.plusJakartaSans(
              color: const Color(0xFFEAEAEA),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
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
                  
                  // Hero Banner
                  if (spotlights.isNotEmpty)
                    SliverToBoxAdapter(
                      child: GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                              builder: (context) => AnimeDetailScreen(
                                anime: _convertSpotlightToAnime(spotlights[0]),
                                      ),
                                    ),
                                  );
                                },
                        child: _buildHeroBanner(spotlights[0]),
                      ),
                    ),
                  
                  // Quick Access
                    SliverToBoxAdapter(
                    child: _buildQuickAccessGrid(),
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