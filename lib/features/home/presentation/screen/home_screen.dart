import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:linze/core/models/anime_model.dart';
import 'package:linze/core/models/home.dart' as home_models;
import 'package:linze/core/services/anime_provider.dart';
import 'package:linze/features/anime_detail/presentation/screen/anime_detail_screen.dart';
import 'package:linze/features/search_discovery/presentation/screen/search_discovery_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();

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
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: Consumer(
        builder: (context, ref, child) {
          final homeData = ref.watch(homePageProvider);
          
          return homeData.when(
            data: (data) {
              // Use data.spotlights, data.trending, data.latestEpisode, etc.
              final spotlights = data.spotlights ?? [];
              final trending = data.trending ?? [];
              final latestEpisodes = data.latestEpisode ?? [];
              
              return SafeArea(
                child: CustomScrollView(
                  slivers: [
                    // App Bar
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                        child: Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: const Color(0xFF5B13EC).withOpacity(0.2),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Icon(
                                Icons.live_tv,
                                color: const Color(0xFF5B13EC),
                                size: 24,
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
                              icon: Icon(
                                Icons.account_circle,
                                color: const Color(0xFFEAEAEA),
                                size: 28,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Search Bar
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                        child: Container(
                          height: 48,
                          decoration: BoxDecoration(
                            color: const Color(0xFF1F1F1F),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              const SizedBox(width: 16),
                              Icon(
                                Icons.search,
                                color: const Color(0xFFA9A9A9),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: TextField(
                                  controller: _searchController,
                                  style: GoogleFonts.plusJakartaSans(
                                    color: const Color(0xFFEAEAEA),
                                    fontSize: 16,
                                  ),
                                  decoration: InputDecoration(
                                    hintText: 'Search for anime...',
                                    hintStyle: GoogleFonts.plusJakartaSans(
                                      color: const Color(0xFFA9A9A9),
                                      fontSize: 16,
                                    ),
                                    border: InputBorder.none,
                                    contentPadding: EdgeInsets.zero,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    // Hero Carousel
                    SliverToBoxAdapter(
                      child: Container(
                        height: 200,
                        margin: const EdgeInsets.only(top: 8),
                        child: spotlights.isEmpty
                            ? Container(
                                width: double.infinity,
                                height: 200,
                                color: Colors.grey[800],
                                child: const Center(
                                  child: Text('No spotlight content available'),
                                ),
                              )
                            : ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: spotlights.length,
                                itemBuilder: (context, index) {
                                  final spotlight = spotlights[index];
                                  return GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => AnimeDetailScreen(anime: _convertSpotlightToAnime(spotlight)),
                                        ),
                                      );
                                    },
                                    child: Container(
                                      width: 300,
                                      margin: const EdgeInsets.symmetric(horizontal: 16),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(12),
                                        image: DecorationImage(
                                          image: CachedNetworkImageProvider(spotlight.poster),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(12),
                                          gradient: LinearGradient(
                                            begin: Alignment.bottomCenter,
                                            end: Alignment.topCenter,
                                            colors: [
                                              const Color(0xFF121212),
                                              Colors.transparent,
                                            ],
                                          ),
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.all(16.0),
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.end,
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                spotlight.title,
                                                style: GoogleFonts.plusJakartaSans(
                                                  color: Colors.white,
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.w700,
                                                ),
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              const SizedBox(height: 4),
                                              Flexible(
                                                child: Text(
                                                  spotlight.description ?? '',
                                                  style: GoogleFonts.plusJakartaSans(
                                                    color: const Color(0xFFEAEAEA),
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.normal,
                                                  ),
                                                  maxLines: 3,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                      ),
                    ),
                    // Trending Now Section
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.only(
                          top: 20,
                          left: 16,
                          right: 16,
                          bottom: 12,
                        ),
                        child: Text(
                          'Trending Now',
                          style: GoogleFonts.plusJakartaSans(
                            color: const Color(0xFFEAEAEA),
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: trending.isEmpty
                          ? Container()
                          : Container(
                              height: 200,
                              margin: const EdgeInsets.only(bottom: 12),
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: trending.length,
                                itemBuilder: (context, index) {
                                  final anime = trending[index];
                                  return GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => AnimeDetailScreen(anime: _convertTrendingToAnime(anime)),
                                        ),
                                      );
                                    },
                                    child: Container(
                                      width: 160,
                                      margin: const EdgeInsets.only(left: 16),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Expanded(
                                            child: ClipRRect(
                                              borderRadius: BorderRadius.circular(8),
                                              child: CachedNetworkImage(
                                                imageUrl: anime.poster,
                                                fit: BoxFit.cover,
                                                width: double.infinity,
                                                height: double.infinity,
                                                placeholder: (context, url) => Container(
                                                  color: Colors.grey[800],
                                                ),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            anime.title,
                                            style: GoogleFonts.plusJakartaSans(
                                              color: const Color(0xFFEAEAEA),
                                              fontSize: 16,
                                              fontWeight: FontWeight.w500,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          Text(
                                            'S1 E${index + 1}', // Example
                                            style: GoogleFonts.plusJakartaSans(
                                              color: const Color(0xFFA9A9A9),
                                              fontSize: 14,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                    ),
                    // New Releases Section
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.only(
                          top: 20,
                          left: 16,
                          right: 16,
                          bottom: 12,
                        ),
                        child: Text(
                          'New Episodes',
                          style: GoogleFonts.plusJakartaSans(
                            color: const Color(0xFFEAEAEA),
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: latestEpisodes.isEmpty
                          ? Container(
                              height: 200,
                              margin: const EdgeInsets.only(bottom: 20),
                              child: const Center(
                                child: Text('No new episodes available'),
                              ),
                            )
                          : Container(
                              height: 200,
                              margin: const EdgeInsets.only(bottom: 20),
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: latestEpisodes.length,
                                itemBuilder: (context, index) {
                                  final anime = latestEpisodes[index];
                                  return GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => AnimeDetailScreen(anime: _convertLatestEpisodeToAnime(anime)),
                                        ),
                                      );
                                    },
                                    child: Container(
                                      width: 160,
                                      margin: const EdgeInsets.only(left: 16),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Expanded(
                                            child: Stack(
                                              children: [
                                                ClipRRect(
                                                  borderRadius: BorderRadius.circular(8),
                                                  child: CachedNetworkImage(
                                                    imageUrl: anime.poster,
                                                    fit: BoxFit.cover,
                                                    width: double.infinity,
                                                    height: double.infinity,
                                                    placeholder: (context, url) => Container(
                                                      color: Colors.grey[800],
                                                    ),
                                                  ),
                                                ),
                                                // New/Dub badge
                                                Positioned(
                                                  top: 8,
                                                  right: 8,
                                                  child: Container(
                                                    padding: const EdgeInsets.symmetric(
                                                      horizontal: 8,
                                                      vertical: 4,
                                                    ),
                                                    decoration: BoxDecoration(
                                                      color: const Color(0xFF5B13EC),
                                                      borderRadius: BorderRadius.circular(12),
                                                    ),
                                                    child: Text(
                                                      'New',
                                                      style: GoogleFonts.plusJakartaSans(
                                                        color: Colors.white,
                                                        fontSize: 12,
                                                        fontWeight: FontWeight.w700,
                                                      ),
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
                                              fontSize: 16,
                                              fontWeight: FontWeight.w500,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          Text(
                                            'Episode ${index + 1}',
                                            style: GoogleFonts.plusJakartaSans(
                                              color: const Color(0xFFA9A9A9),
                                              fontSize: 14,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                    ),
                  ],
                ),
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
                    'Error loading data: $error',
                    style: GoogleFonts.plusJakartaSans(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      ref.refresh(homePageProvider);
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
}