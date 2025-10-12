import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:linze/core/models/anime_model.dart';
import 'package:linze/core/services/anime_provider.dart';
import 'package:linze/features/anime_detail/presentation/screen/anime_detail_screen.dart';
import 'package:linze/features/profile_settings/presentation/screen/profile_settings_screen.dart';
import 'package:linze/core/api/api_service.dart';

class SearchDiscoveryScreen extends StatefulWidget {
  const SearchDiscoveryScreen({Key? key}) : super(key: key);

  @override
  State<SearchDiscoveryScreen> createState() => _SearchDiscoveryScreenState();
}

class _SearchDiscoveryScreenState extends State<SearchDiscoveryScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _currentSearchQuery = '';
  
  final List<String> _genres = [
    'All', 'Top Airing', 'Most Popular', 'Most Favorite', 'Completed',
    'Action', 'Adventure', 'Comedy', 'Drama', 'Fantasy'
  ];
  
  final List<String> _popularSearches = [
    'Attack on Titan', 'New Releases', 'Isekai', 'One Piece', 'Movies'
  ];

  // Map display names to API category names
  String _getCategoryName(String displayName) {
    switch (displayName) {
      case 'All':
        return 'top-airing'; // Default category
      case 'Top Airing':
        return 'top-airing';
      case 'Most Popular':
        return 'most-popular';
      case 'Most Favorite':
        return 'most-favorite';
      case 'Completed':
        return 'completed';
      case 'Action':
        return 'genre/action';
      case 'Adventure':
        return 'genre/adventure';
      case 'Comedy':
        return 'genre/comedy';
      case 'Drama':
        return 'genre/drama';
      case 'Fantasy':
        return 'genre/fantasy';
      default:
        return 'top-airing';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      body: Consumer(
        builder: (context, ref, child) {
          final trendingData = ref.watch(categoryProvider('top-airing'));
          final searchData = _currentSearchQuery.isNotEmpty 
              ? ref.watch(searchProvider(_currentSearchQuery))
              : null;
          
          return SafeArea(
            child: CustomScrollView(
              slivers: [
                // App Bar
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: Row(
                      children: [
                        Text(
                          'Discover',
                          style: GoogleFonts.plusJakartaSans(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const ProfileSettingsScreen(),
                              ),
                            );
                          },
                          icon: Icon(
                            Icons.account_circle,
                            color: Colors.white,
                            size: 24,
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
                        color: const Color(0xFF2C2C2E),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const SizedBox(width: 16),
                          Icon(
                            Icons.search,
                            color: const Color(0xFF8E8E93),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextField(
                              controller: _searchController,
                              onSubmitted: (value) {
                                if (value.trim().isNotEmpty) {
                                  setState(() {
                                    _currentSearchQuery = value.trim();
                                  });
                                  ref.read(searchProvider(value.trim()));
                                }
                              },
                              style: GoogleFonts.plusJakartaSans(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                              decoration: InputDecoration(
                                hintText: 'Search for anime, characters, or genres',
                                hintStyle: GoogleFonts.plusJakartaSans(
                                  color: const Color(0xFF8E8E93),
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
                // Search Results Section
                if (_currentSearchQuery.isNotEmpty)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.only(
                        top: 20,
                        left: 16,
                        right: 16,
                        bottom: 12,
                      ),
                      child: Text(
                        'Search Results for "$_currentSearchQuery"',
                        style: GoogleFonts.plusJakartaSans(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                if (_currentSearchQuery.isNotEmpty)
                  searchData?.when(
                    data: (results) {
                      if (results.isEmpty) {
                        return const SliverToBoxAdapter(
                          child: Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Center(
                              child: Text(
                                'No results found',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                        );
                      }
                      return SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final anime = results[index];
                            return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => AnimeDetailScreen(anime: anime),
                                  ),
                                );
                              },
                              child: Container(
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                child: Row(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: CachedNetworkImage(
                                        imageUrl: anime.poster,
                                        width: 80,
                                        height: 120,
                                        fit: BoxFit.cover,
                                        placeholder: (context, url) => Container(
                                          width: 80,
                                          height: 120,
                                          color: Colors.grey[800],
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            anime.title,
                                            style: GoogleFonts.plusJakartaSans(
                                              color: Colors.white,
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          if (anime.japaneseTitle?.isNotEmpty == true)
                                            Text(
                                              anime.japaneseTitle!,
                                              style: GoogleFonts.plusJakartaSans(
                                                color: const Color(0xFF8E8E93),
                                                fontSize: 14,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          const SizedBox(height: 4),
                                          Text(
                                            anime.tvInfo?.showType ?? 'TV',
                                            style: GoogleFonts.plusJakartaSans(
                                              color: const Color(0xFF007AFF),
                                              fontSize: 12,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                          childCount: results.length,
                        ),
                      );
                    },
                    loading: () => const SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Center(
                          child: CircularProgressIndicator(),
                        ),
                      ),
                    ),
                    error: (error, stack) => SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Center(
                          child: Text(
                            'Error: $error',
                            style: const TextStyle(color: Colors.red),
                          ),
                        ),
                      ),
                    ),
                  ) ?? const SliverToBoxAdapter(child: SizedBox.shrink()),
                // Genre Chips
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.only(
                      top: 20,
                      left: 16,
                      right: 16,
                      bottom: 12,
                    ),
                    child: Text(
                      'Explore by Genre',
                      style: GoogleFonts.plusJakartaSans(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Container(
                      height: 40,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _genres.length,
                        itemBuilder: (context, index) {
                          final genre = _genres[index];
                          final isSelected = index == 0; // First (All) is selected by default
                          return GestureDetector(
                            onTap: () {
                              // Navigate to category screen
                              final categoryName = _getCategoryName(genre);
                              ref.read(categoryProvider(categoryName));
                            },
                            child: Container(
                              margin: const EdgeInsets.only(right: 12),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: isSelected 
                                      ? const Color(0xFF007AFF) 
                                      : const Color(0xFF2C2C2E),
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: Center(
                                  child: Text(
                                    genre,
                                    style: GoogleFonts.plusJakartaSans(
                                      color: isSelected ? Colors.white : Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
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
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Container(
                    height: 200,
                    margin: const EdgeInsets.only(bottom: 20),
                    child: trendingData.when(
                      data: (data) {
                        final trending = data?.data ?? [];
                        if (trending.isEmpty) {
                          return const Center(
                            child: Text('No trending anime available'),
                          );
                        }
                        return ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: trending.length,
                          itemBuilder: (context, index) {
                            final anime = trending[index];
                            return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => AnimeDetailScreen(anime: anime),
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
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Text(
                                      anime.tvInfo?.showType ?? 'TV',
                                      style: GoogleFonts.plusJakartaSans(
                                        color: const Color(0xFF8E8E93),
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      },
                      loading: () => const Center(child: CircularProgressIndicator()),
                      error: (error, stack) => Center(
                        child: Text('Error: $error'),
                      ),
                    ),
                  ),
                ),
                // Popular Searches Section
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.only(
                      top: 32,
                      left: 16,
                      right: 16,
                      bottom: 12,
                    ),
                    child: Text(
                      'Popular Searches',
                      style: GoogleFonts.plusJakartaSans(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: _popularSearches.map((search) {
                        return GestureDetector(
                          onTap: () {
                            _searchController.text = search;
                            setState(() {
                              _currentSearchQuery = search;
                            });
                            ref.read(searchProvider(search));
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF2C2C2E),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              search,
                              style: GoogleFonts.plusJakartaSans(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
                // Spacer
                const SliverToBoxAdapter(
                  child: SizedBox(height: 40),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}