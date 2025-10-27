import 'dart:math' show min;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:provider/provider.dart' as provider_package;
import 'package:google_fonts/google_fonts.dart';
import 'package:linze/core/services/anime_provider.dart';
import 'package:linze/core/models/anime_model.dart';
import 'package:linze/core/widgets/app_logo.dart';
import 'package:linze/features/anime_detail/presentation/screen/anime_detail_screen.dart';
import 'package:linze/features/search_discovery/presentation/screen/search_discovery_screen.dart';
import 'package:linze/core/widgets/minimal_tab_bar.dart';
import 'package:linze/core/constants/constants.dart';
import 'package:linze/core/providers/watch_progress_provider.dart';
import 'package:linze/core/models/watch_progress.dart';
import 'package:linze/core/widgets/section_card.dart';
import 'package:linze/features/home/presentation/widgets/minimal_hero_banner.dart';
import 'package:linze/features/home/presentation/widgets/minimal_continue_watching_card.dart';
import 'package:linze/core/widgets/anime_card.dart';
import 'package:linze/features/home/presentation/widgets/genre_chip.dart';
import 'package:linze/core/api/api_service.dart';
import 'package:linze/core/models/anime_model.dart';
import 'package:linze/core/models/home.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  final Map<int, ScrollController> _tabScrollControllers = {};
  final Set<int> _loadedTabs = {0};
  int _currentTabIndex = 0;
  late AnimationController _appBarAnimationController;
  late Animation<double> _appBarOpacityAnimation;
  bool _isAppBarVisible = false;
  
  // Cache for anime data to prevent repeated network calls
  final Map<String, Anime> _animeCache = {};
  final Map<String, Future<Anime?>> _animeFutureCache = {};

  // State variables for trending tab
  String _trendingSortType = 'rank';
  Set<String> _expandedGenres = {};

  // State variables for new tab
  String _newSortType = 'date';


  @override
  void initState() {
    super.initState();
    _appBarAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _appBarOpacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _appBarAnimationController, curve: Curves.easeInOut),
    );
    
    _tabController = TabController(length: 5, vsync: this, initialIndex: 0);
    _tabController.addListener(_onTabChanged);
    
    // Initialize scroll controllers for all 5 tabs
    for (int i = 0; i < 5; i++) {
      _tabScrollControllers[i] = ScrollController();
    }
    // Add scroll listener to tab 0's controller initially
    _tabScrollControllers[0]!.addListener(_onScroll);
  }

  @override
  void dispose() {
    _tabController.dispose();
    for (var controller in _tabScrollControllers.values) {
      controller.dispose();
    }
    _appBarAnimationController.dispose();
    super.dispose();
  }

  void _onTabChanged() {
    if (!_tabController.indexIsChanging) {
      int newTabIndex = _tabController.index;
      if (newTabIndex != _currentTabIndex) {
        // Remove scroll listener from previous tab's controller
        _tabScrollControllers[_currentTabIndex]?.removeListener(_onScroll);
        // Add scroll listener to new tab's controller
        _tabScrollControllers[newTabIndex]?.addListener(_onScroll);
        // Add new tab index to loaded tabs set
        _loadedTabs.add(newTabIndex);
        _currentTabIndex = newTabIndex;
        
        // Recalculate app bar visibility based on the new tab's scroll offset
        final newTabOffset = _tabScrollControllers[newTabIndex]?.offset ?? 0;
        final isVisible = newTabOffset > 100.0;
        if (isVisible != _isAppBarVisible) {
          setState(() {
            _isAppBarVisible = isVisible;
          });
          if (_isAppBarVisible) {
            _appBarAnimationController.forward();
          } else {
            _appBarAnimationController.reverse();
          }
        } else {
          setState(() {});
        }
      }
    }
  }

  void _onScroll() {
    const threshold = 100.0;
    final isVisible = (_tabScrollControllers[_currentTabIndex]?.offset ?? 0) > threshold;
    
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





  Widget _buildTransparentAppBar() {
    return AnimatedBuilder(
      animation: _appBarOpacityAnimation,
      builder: (context, child) {
        return Container(
          height: kToolbarHeight + MediaQuery.of(context).padding.top,
          decoration: BoxDecoration(
            color: _isAppBarVisible 
                ? surfaceColor.withValues(alpha: _appBarOpacityAnimation.value)
                : Colors.transparent,
            border: _isAppBarVisible 
                ? Border(
                    bottom: BorderSide(
                      color: dividerColor.withValues(alpha: _appBarOpacityAnimation.value),
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
                            ? surfaceElevatedColor.withValues(alpha: _appBarOpacityAnimation.value)
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
                ],
              ),
            ),
          ),
        );
      },
    );
  }






  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: Stack(
        children: [
          Column(
            children: [
              SizedBox(height: MediaQuery.of(context).padding.top + kToolbarHeight),
              MinimalTabBar(
                tabs: ['For You', 'Trending', 'New', 'Genres', 'My List'],
                selectedIndex: _currentTabIndex,
                onTabSelected: (index) {
                  _tabController.animateTo(index);
                },
              ),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildForYouTab(),
                    _buildTrendingTab(),
                    _buildNewTab(),
                    _buildGenresTab(),
                    _buildMyListTab(),
                  ],
                ),
              ),
            ],
          ),
          // Transparent App Bar Overlay
          _buildTransparentAppBar(),
        ],
      ),
    );
  }

  Widget _buildForYouTab() {
    if (!_loadedTabs.contains(0)) {
      return const Center(
        child: Text('For You Tab - Coming in next phase'),
      );
    }
    
    return Consumer(
      builder: (context, ref, child) {
        final forYouData = ref.watch(forYouTabProvider);
        final recentlyWatchedData = ref.watch(recentlyWatchedProvider);
        
        return forYouData.when(
          data: (forYouMap) {
            return recentlyWatchedData.when(
              data: (recentlyWatchedList) {
                return RefreshIndicator(
                  onRefresh: () async {
                    await Future.wait([
                      ref.refresh(forYouTabProvider.future),
                      ref.refresh(recentlyWatchedProvider.future)
                    ]);
                  },
                  color: primaryColor,
                  backgroundColor: surfaceColor,
                  child: CustomScrollView(
                    key: const PageStorageKey('forYouScroll'),
                    controller: _tabScrollControllers[0],
                    physics: const AlwaysScrollableScrollPhysics(),
                    slivers: [
                      // Hero Banner
                      if (forYouMap['featuredAnime'] != null)
                        SliverToBoxAdapter(
                          child: MinimalHeroBanner(
                            featuredAnime: forYouMap['featuredAnime'] as Anime,
                            onPlay: () {
                              _navigateToAnimeDetail((forYouMap['featuredAnime'] as Anime).id);
                            },
                            onAddToList: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Add to list functionality coming soon'),
                                  backgroundColor: primaryColor,
                                ),
                              );
                            },
                            onTap: (anime) {
                              _navigateToAnimeDetail(anime.id);
                            },
                          ),
                        ),
                      
                      const SliverToBoxAdapter(child: SizedBox(height: 24)),
                      
                      // Continue Watching Section
                      SliverToBoxAdapter(
                        child: SectionCard(
                          title: 'Jump Back In',
                          padding: EdgeInsets.zero,
                          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                          child: SizedBox(
                            height: 320,
                            child: recentlyWatchedList.isNotEmpty
                                ? ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    padding: const EdgeInsets.symmetric(horizontal: 16),
                                    itemCount: min(recentlyWatchedList.length, 10),
                                    itemBuilder: (context, index) {
                                      final watchProgress = recentlyWatchedList[index];
                                      return FutureBuilder<Anime?>(
                                        future: _getAnimeForWatchProgress(ref, watchProgress),
                                        builder: (context, snapshot) {
                                          if (snapshot.connectionState == ConnectionState.waiting) {
                                            return const SizedBox(
                                              width: 200, // Match the width of MinimalContinueWatchingCard
                                              child: Center(
                                                child: CircularProgressIndicator(color: primaryColor),
                                              ),
                                            );
                                          } else if (snapshot.hasData && snapshot.data != null) {
                                            final anime = snapshot.data!;
                                            return MinimalContinueWatchingCard(
                                              anime: anime,
                                              progress: watchProgress.progress,
                                              currentEpisode: _formatEpisodeNumber(watchProgress.episodeId),
                                              onTap: () {
                                                _navigateToAnimeDetail(anime.id);
                                              },
                                              onResume: () {
                                                _navigateToAnimeDetail(anime.id);
                                              },
                                            );
                                          } else {
                                            return const SizedBox.shrink();
                                          }
                                        },
                                      );
                                    },
                                  )
                                : Container(
                                    padding: const EdgeInsets.all(24),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.play_circle_outline,
                                          size: 64,
                                          color: textTertiaryColor,
                                        ),
                                        const SizedBox(height: 16),
                                        Text(
                                          'No watch history yet',
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.white,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          'Start watching anime to see your progress here',
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 14,
                                            color: textSecondaryColor,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ],
                                    ),
                                  ),
                          ),
                        ),
                      ),
                      
                      const SliverToBoxAdapter(child: SizedBox(height: 24)),
                      
                      // Recommended Section
                      if (forYouMap['recommended'] != null && (forYouMap['recommended'] as List).isNotEmpty)
                        SliverToBoxAdapter(
                          child: SectionCard(
                            title: 'Recommended for You',
                            padding: EdgeInsets.zero,
                            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                            child: SizedBox(
                              height: 280,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                itemCount: min((forYouMap['recommended'] as List).length, 10),
                                itemBuilder: (context, index) {
                                  final anime = _convertToAnime((forYouMap['recommended'] as List)[index]);
                                  return AnimeCard(
                                    anime: anime,
                                    type: AnimeCardType.minimal,
                                    onTap: () {
                                      _navigateToAnimeDetail(anime.id);
                                    },
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                      
                      const SliverToBoxAdapter(child: SizedBox(height: 24)),
                      
                      // Because You Watched Section
                      if (forYouMap['topAiring'] != null && (forYouMap['topAiring'] as List).isNotEmpty)
                        SliverToBoxAdapter(
                          child: SectionCard(
                            title: 'Because You Watched Action Anime',
                            padding: EdgeInsets.zero,
                            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                            child: SizedBox(
                              height: 280,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                itemCount: min((forYouMap['topAiring'] as List).length, 10),
                                itemBuilder: (context, index) {
                                  final anime = _convertToAnime((forYouMap['topAiring'] as List)[index]);
                                  return AnimeCard(
                                    anime: anime,
                                    type: AnimeCardType.minimal,
                                    onTap: () {
                                      _navigateToAnimeDetail(anime.id);
                                    },
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                      
                      const SliverToBoxAdapter(child: SizedBox(height: 24)),
                      
                      // Quick Picks Section
                      if (forYouMap['topAiring'] != null && (forYouMap['topAiring'] as List).length >= 14)
                        SliverToBoxAdapter(
                          child: SectionCard(
                            title: 'Quick Picks',
                            padding: const EdgeInsets.all(16),
                            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                            child: GridView.count(
                              crossAxisCount: 2,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                              childAspectRatio: 0.7,
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              children: List.generate(
                                4,
                                (index) {
                                  // Skip first 10 items and take the next 4 for variety
                                  final anime = _convertToAnime((forYouMap['topAiring'] as List)[index + 10]);
                                  return AnimeCard(
                                    anime: anime,
                                    type: AnimeCardType.minimal,
                                    onTap: () {
                                      _navigateToAnimeDetail(anime.id);
                                    },
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                      
                      const SliverToBoxAdapter(child: SizedBox(height: 24)),
                      
                      // Your Genres Section
                      if (forYouMap['genres'] != null && (forYouMap['genres'] as List).isNotEmpty)
                        SliverToBoxAdapter(
                          child: SectionCard(
                            title: 'Your Genres',
                            padding: const EdgeInsets.all(16),
                            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                            child: Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: List.generate(
                                min((forYouMap['genres'] as List).length, 5),
                                (index) {
                                  final genre = (forYouMap['genres'] as List)[index];
                                  return GenreChip(
                                    genre: genre,
                                    isSelected: false,
                                    onTap: () {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text('Filter by $genre coming soon'),
                                          backgroundColor: primaryColor,
                                        ),
                                      );
                                    },
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                      
                      const SliverToBoxAdapter(child: SizedBox(height: 40)),
                    ],
                  ),
                );
              },
              loading: () => const CustomScrollView(
                slivers: [
                  SliverFillRemaining(
                    child: Center(
                      child: CircularProgressIndicator(color: primaryColor),
                    ),
                  ),
                ],
              ),
              error: (error, stack) => CustomScrollView(
                slivers: [
                  SliverFillRemaining(
                    child: Center(
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
                            onPressed: () async {
                              await Future.wait([
                                ref.refresh(forYouTabProvider.future),
                                ref.refresh(recentlyWatchedProvider.future)
                              ]);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryColor,
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
                  ),
                ],
              ),
            );
          },
          loading: () => const CustomScrollView(
            slivers: [
              SliverFillRemaining(
                child: Center(
                  child: CircularProgressIndicator(color: primaryColor),
                ),
              ),
            ],
          ),
          error: (error, stack) => CustomScrollView(
            slivers: [
              SliverFillRemaining(
                child: Center(
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
                        onPressed: () async {
                          await Future.wait([
                            ref.refresh(forYouTabProvider.future),
                            ref.refresh(recentlyWatchedProvider.future)
                          ]);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
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
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTrendingTab() {
    if (!_loadedTabs.contains(1)) {
      return const Center(
        child: Text('Trending Tab - Coming in next phase'),
      );
    }
    return Consumer(
      builder: (context, ref, child) {
        final trendingData = ref.watch(trendingTabProvider);
        
        return trendingData.when(
          data: (trendingMap) {
            final topTrending = trendingMap['topTrending'] as List?;
            final topAiring = trendingMap['topAiring'] as List?;
            final mostPopular = trendingMap['mostPopular'] as List?;
            final genres = trendingMap['genres'] as List<String>?;
            
            // Apply sorting if needed
            List<dynamic>? sortedTopTrending = _applySorting<dynamic>(topTrending ?? [], _trendingSortType, 'trending');
            
            return RefreshIndicator(
              onRefresh: () async {
                await ref.refresh(trendingTabProvider.future);
              },
              color: primaryColor,
              backgroundColor: surfaceColor,
              child: CustomScrollView(
                key: PageStorageKey('trendingScroll'),
                controller: _tabScrollControllers[1],
                slivers: [
                  // Section 1: Top 10 This Week
                  SliverToBoxAdapter(
                    child: SectionCard(
                      title: 'Top 10 This Week',
                      trailing: IconButton(
                        icon: Icon(Icons.sort, color: textSecondaryColor),
                        onPressed: () => _showTrendingSortBottomSheet(context),
                      ),
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                      child: SizedBox(
                        height: 340,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: min(sortedTopTrending.length, 10),
                          itemBuilder: (context, index) {
                            final trending = sortedTopTrending[index];
                            final anime = _convertTrendingToAnime(trending);
                            return MinimalRankCard(
                              anime: anime,
                              rank: index + 1,
                              onTap: () => _navigateToAnimeDetail(anime.id),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                  
                  const SliverToBoxAdapter(child: SizedBox(height: 24)),
                  
                  // Section 2: Rising Stars
                  SliverToBoxAdapter(
                    child: SectionCard(
                      title: 'Rising Stars',
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                      child: GridView.count(
                        crossAxisCount: 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 0.7,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        children: List.generate(
                          min((topAiring?.length ?? 0), 10),
                          (index) {
                            final trending = topAiring![index];
                            final anime = _convertToAnime(trending);
                            return AnimeCard(
                              anime: anime,
                              type: AnimeCardType.minimal,
                              onTap: () => _navigateToAnimeDetail(anime.id),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                  
                  const SliverToBoxAdapter(child: SizedBox(height: 24)),
                  
                  // Section 3: Trending by Genre (Collapsible)
                  if (genres != null && genres.isNotEmpty)
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          if (index >= 5) return null; // Only show first 5 genres
                          final genre = genres[index];
                          return _buildCollapsibleGenreSection(
                            genre,
                            mostPopular ?? [],
                          );
                        },
                        childCount: min(genres.length, 5),
                      ),
                    ),
                  
                  const SliverToBoxAdapter(child: SizedBox(height: 40)),
                ],
              ),
            );
          },
          loading: () => const SliverFillRemaining(
            child: Center(
              child: CircularProgressIndicator(color: primaryColor),
            ),
          ),
          error: (error, stack) {
            return SliverFillRemaining(
              child: Center(
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
                      onPressed: () async {
                        await ref.refresh(trendingTabProvider.future);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
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
        );
      },
    );
  }

  Widget _buildNewTab() {
    if (!_loadedTabs.contains(2)) {
      return const Center(
        child: Text('New Tab - Coming in next phase'),
      );
    }
    return Consumer(
      builder: (context, ref, child) {
        final newData = ref.watch(newTabProvider);
        
        return newData.when(
          data: (newMap) {
            final latestEpisodes = newMap['latestEpisodes'] as List?;
            final schedule = newMap['schedule'] as List?;
            final latestCompleted = newMap['latestCompleted'] as List?;
            
            // Apply sorting if needed
            List<dynamic>? sortedLatestEpisodes = _applySorting<dynamic>(latestEpisodes ?? [], _newSortType, 'new');
            
            return RefreshIndicator(
              onRefresh: () async {
                await ref.refresh(newTabProvider.future);
              },
              color: primaryColor,
              backgroundColor: surfaceColor,
              child: CustomScrollView(
                key: PageStorageKey('newScroll'),
                controller: _tabScrollControllers[2],
                slivers: [
                  // Section 1: Latest Episodes
                  SliverToBoxAdapter(
                    child: SectionCard(
                      title: 'Latest Episodes',
                      trailing: IconButton(
                        icon: Icon(Icons.sort, color: textSecondaryColor),
                        onPressed: () => _showNewSortBottomSheet(context),
                      ),
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                      child: Column(
                        children: [
                          ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: min(sortedLatestEpisodes.length, 10),
                            separatorBuilder: (context, index) => Divider(color: dividerColor),
                            itemBuilder: (context, index) {
                              final episode = sortedLatestEpisodes[index];
                              final anime = _convertToAnime(episode);
                              return AnimeCard(
                                anime: anime,
                                type: AnimeCardType.horizontal,
                                onTap: () => _navigateToAnimeDetail(anime.id),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  const SliverToBoxAdapter(child: SizedBox(height: 24)),
                  
                  // Section 2: New Series
                  SliverToBoxAdapter(
                    child: SectionCard(
                      title: 'New Series',
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                      child: GridView.count(
                        crossAxisCount: 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 0.65,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        children: List.generate(
                          min((latestCompleted?.length ?? 0), 10),
                          (index) {
                            final animeModel = latestCompleted![index];
                            final anime = _convertToAnime(animeModel);
                            return MinimalNewCard(
                              anime: anime,
                              releaseDate: 'Recently Added', // Will extract from model or use default
                              onTap: () => _navigateToAnimeDetail(anime.id),
                              onAddToList: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Add to list functionality coming soon'),
                                    backgroundColor: primaryColor,
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                  
                  const SliverToBoxAdapter(child: SizedBox(height: 24)),
                  
                  // Section 3: Coming Soon (Schedule)
                  SliverToBoxAdapter(
                    child: SectionCard(
                      title: 'Coming Soon',
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                      child: SizedBox(
                        height: 280,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: min((schedule?.length ?? 0), 10),
                          itemBuilder: (context, index) {
                            final scheduleItem = schedule![index];
                            final anime = _convertScheduleToAnime(scheduleItem);
                            return AnimeCard(
                              anime: anime,
                              type: AnimeCardType.minimal,
                              onTap: () => _navigateToAnimeDetail(anime.id),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                  
                  const SliverToBoxAdapter(child: SizedBox(height: 40)),
                ],
              ),
            );
          },
          loading: () => const SliverFillRemaining(
            child: Center(
              child: CircularProgressIndicator(color: primaryColor),
            ),
          ),
          error: (error, stack) {
            return SliverFillRemaining(
              child: Center(
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
                      onPressed: () async {
                        await ref.refresh(newTabProvider.future);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
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
        );
      },
    );
  }

  Widget _buildGenresTab() {
    if (!_loadedTabs.contains(3)) {
      return const Center(
        child: Text('Genres Tab - Coming in next phase'),
      );
    }
    return CustomScrollView(
      key: const PageStorageKey('genresScroll'),
      controller: _tabScrollControllers[3],
      slivers: [
        const SliverFillRemaining(
          child: Center(
            child: Text('Genres Tab - Coming in next phase'),
          ),
        ),
      ],
    );
  }

  Widget _buildMyListTab() {
    if (!_loadedTabs.contains(4)) {
      return const Center(
        child: Text('My List Tab - Coming in next phase'),
      );
    }
    return CustomScrollView(
      key: const PageStorageKey('myListScroll'),
      controller: _tabScrollControllers[4],
      slivers: [
        const SliverFillRemaining(
          child: Center(
            child: Text('My List Tab - Coming in next phase'),
          ),
        ),
      ],
    );
  }

  Future<Anime?> _getAnimeForWatchProgress(WidgetRef ref, WatchProgress watchProgress) async {
    // First check if we have a cached Anime object
    if (_animeCache.containsKey(watchProgress.animeId)) {
      return _animeCache[watchProgress.animeId];
    }
    
    // Check if we have a cached future for this animeId to avoid duplicate requests
    if (_animeFutureCache.containsKey(watchProgress.animeId)) {
      return _animeFutureCache[watchProgress.animeId];
    }
    
    try {
      // Create a new future to fetch the anime data using Riverpod
      final future = ref.read(animeDetailProvider(watchProgress.animeId).future);
      _animeFutureCache[watchProgress.animeId] = future;
      
      final response = await future;
      final anime = Anime(
        id: response.id,
        dataId: response.dataId,
        poster: response.poster,
        title: response.title,
        japaneseTitle: response.japaneseTitle,
        description: response.description,
        tvInfo: response.tvInfo != null 
            ? TvInfo(
                showType: response.tvInfo!.showType,
                duration: response.tvInfo!.duration,
                sub: response.tvInfo!.sub,
                dub: response.tvInfo!.dub,
                eps: response.tvInfo!.eps,
              )
            : null,
      );
      
      // Cache the anime and remove the future from cache
      _animeCache[watchProgress.animeId] = anime;
      _animeFutureCache.remove(watchProgress.animeId);
      
      return anime;
    } catch (e) {
      // Remove the future from the future cache on error
      _animeFutureCache.remove(watchProgress.animeId);
      return null;
    }
  }

  Anime _convertToAnime(dynamic homeModel) {
    // Type-check against known home model types and map properties explicitly
    if (homeModel is Spotlight) {
      return Anime(
        id: homeModel.id,
        dataId: homeModel.dataId,
        poster: homeModel.poster,
        title: homeModel.title,
        japaneseTitle: homeModel.japaneseTitle,
        description: homeModel.description,
        tvInfo: TvInfo(
          showType: homeModel.tvInfo.showType,
          duration: homeModel.tvInfo.duration,
          sub: homeModel.tvInfo.sub,
          dub: homeModel.tvInfo.dub,
          eps: homeModel.tvInfo.eps,
        ),
      );
    } else if (homeModel is TopAiring) {
      return Anime(
        id: homeModel.id,
        dataId: homeModel.dataId,
        poster: homeModel.poster,
        title: homeModel.title,
        japaneseTitle: homeModel.japaneseTitle,
        description: homeModel.description,
        tvInfo: TvInfo(
          showType: homeModel.tvInfo.showType,
          duration: homeModel.tvInfo.duration,
          sub: homeModel.tvInfo.sub,
          dub: homeModel.tvInfo.dub,
          eps: homeModel.tvInfo.eps,
        ),
      );
    } else if (homeModel is MostPopular) {
      return Anime(
        id: homeModel.id,
        dataId: homeModel.dataId,
        poster: homeModel.poster,
        title: homeModel.title,
        japaneseTitle: homeModel.japaneseTitle,
        description: homeModel.description,
        tvInfo: TvInfo(
          showType: homeModel.tvInfo.showType,
          duration: homeModel.tvInfo.duration,
          sub: homeModel.tvInfo.sub,
          dub: homeModel.tvInfo.dub,
          eps: homeModel.tvInfo.eps,
        ),
      );
    } else if (homeModel is MostFavorite) {
      return Anime(
        id: homeModel.id,
        dataId: homeModel.dataId,
        poster: homeModel.poster,
        title: homeModel.title,
        japaneseTitle: homeModel.japaneseTitle,
        description: homeModel.description,
        tvInfo: TvInfo(
          showType: homeModel.tvInfo.showType,
          duration: homeModel.tvInfo.duration,
          sub: homeModel.tvInfo.sub,
          dub: homeModel.tvInfo.dub,
          eps: homeModel.tvInfo.eps,
        ),
      );
    } else if (homeModel is LatestCompleted) {
      return Anime(
        id: homeModel.id,
        dataId: homeModel.dataId,
        poster: homeModel.poster,
        title: homeModel.title,
        japaneseTitle: homeModel.japaneseTitle,
        description: homeModel.description,
        tvInfo: TvInfo(
          showType: homeModel.tvInfo.showType,
          duration: homeModel.tvInfo.duration,
          sub: homeModel.tvInfo.sub,
          dub: homeModel.tvInfo.dub,
          eps: homeModel.tvInfo.eps,
        ),
      );
    } else if (homeModel is LatestEpisode) {
      return Anime(
        id: homeModel.id,
        dataId: homeModel.dataId,
        poster: homeModel.poster,
        title: homeModel.title,
        japaneseTitle: homeModel.japaneseTitle,
        description: homeModel.description,
        tvInfo: TvInfo(
          showType: homeModel.tvInfo.showType,
          duration: homeModel.tvInfo.duration,
          sub: homeModel.tvInfo.sub,
          dub: homeModel.tvInfo.dub,
          eps: homeModel.tvInfo.eps,
        ),
      );
    }
    
    // Fallback for unknown types or dynamic objects
    return Anime(
      id: homeModel.id ?? '',
      dataId: homeModel.dataId ?? 0,
      poster: homeModel.poster ?? '',
      title: homeModel.title ?? 'Unknown Title',
      japaneseTitle: homeModel.japaneseTitle ?? '',
      description: homeModel.description ?? '',
      tvInfo: homeModel.tvInfo != null 
          ? TvInfo(
              showType: homeModel.tvInfo.showType ?? '',
              duration: homeModel.tvInfo.duration ?? '',
              sub: homeModel.tvInfo.sub ?? '',
              dub: homeModel.tvInfo.dub ?? '',
              eps: homeModel.tvInfo.eps ?? 0,
            )
          : null,
    );
  }

  String _formatEpisodeNumber(String episodeId) {
    // Extract episode number from episodeId (e.g., "episode-5" → "Episode 5")
    final RegExp regex = RegExp(r'\d+');
    final Match? match = regex.firstMatch(episodeId);
    if (match != null) {
      return 'Episode ${match.group(0)!}';
    }
    return 'Episode';
  }

  void _navigateToAnimeDetail(String animeId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AnimeDetailScreen(animeId: animeId),
      ),
    );
  }
  
  // Helper method to convert Trending model to Anime
  Anime _convertTrendingToAnime(Trending trending) {
    return Anime(
      id: trending.id,
      dataId: trending.dataId,
      poster: trending.poster,
      title: trending.title,
      japaneseTitle: trending.japaneseTitle,
      description: '', // Description not available in Trending model
      tvInfo: null, // tvInfo not available in Trending model
    );
  }
  
  // Helper method to convert Schedule model to Anime
  Anime _convertScheduleToAnime(Schedule schedule) {
    return Anime(
      id: schedule.id,
      dataId: schedule.dataId,
      poster: '', // Placeholder, schedule doesn't have poster
      title: schedule.title,
      japaneseTitle: schedule.japaneseTitle ?? '',
      description: 'Releasing on ${schedule.releaseDate} at ${schedule.time ?? 'TBA'}',
      tvInfo: TvInfo(
        showType: 'TV',
        duration: '',
        sub: '',
        dub: '',
        eps: 0,
      ),
    );
  }
  
  // Helper method to show trending sort options bottom sheet
  void _showTrendingSortBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: surfaceColor,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.4,
          minChildSize: 0.3,
          maxChildSize: 0.6,
          builder: (context, scrollController) {
            return Container(
              padding: EdgeInsets.all(20),
              child: Column(
                children: [
                  // Handle bar
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: dividerColor,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  SizedBox(height: 20),
                  // Title
                  Text(
                    'Sort Trending',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 20),
                  // Sort options
                  Expanded(
                    child: ListView(
                      controller: scrollController,
                      children: [
                        ListTile(
                          leading: Radio<String>(
                            value: 'rank',
                            groupValue: _trendingSortType,
                            onChanged: (value) {
                              setState(() {
                                _trendingSortType = value!;
                              });
                              Navigator.pop(context);
                            },
                            activeColor: primaryColor,
                          ),
                          title: Text(
                            'By Rank',
                            style: GoogleFonts.plusJakartaSans(
                              color: Colors.white,
                            ),
                          ),
                          onTap: () {
                            setState(() {
                              _trendingSortType = 'rank';
                            });
                            Navigator.pop(context);
                          },
                        ),
                        ListTile(
                          leading: Radio<String>(
                            value: 'popularity',
                            groupValue: _trendingSortType,
                            onChanged: (value) {
                              setState(() {
                                _trendingSortType = value!;
                              });
                              Navigator.pop(context);
                            },
                            activeColor: primaryColor,
                          ),
                          title: Text(
                            'By Popularity',
                            style: GoogleFonts.plusJakartaSans(
                              color: Colors.white,
                            ),
                          ),
                          onTap: () {
                            setState(() {
                              _trendingSortType = 'popularity';
                            });
                            Navigator.pop(context);
                          },
                        ),
                        ListTile(
                          leading: Radio<String>(
                            value: 'title',
                            groupValue: _trendingSortType,
                            onChanged: (value) {
                              setState(() {
                                _trendingSortType = value!;
                              });
                              Navigator.pop(context);
                            },
                            activeColor: primaryColor,
                          ),
                          title: Text(
                            'By Title (A-Z)',
                            style: GoogleFonts.plusJakartaSans(
                              color: Colors.white,
                            ),
                          ),
                          onTap: () {
                            setState(() {
                              _trendingSortType = 'title';
                            });
                            Navigator.pop(context);
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
  
  // Helper method to show new sort options bottom sheet
  void _showNewSortBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: surfaceColor,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.4,
          minChildSize: 0.3,
          maxChildSize: 0.6,
          builder: (context, scrollController) {
            return Container(
              padding: EdgeInsets.all(20),
              child: Column(
                children: [
                  // Handle bar
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: dividerColor,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  SizedBox(height: 20),
                  // Title
                  Text(
                    'Sort New Releases',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 20),
                  // Sort options
                  Expanded(
                    child: ListView(
                      controller: scrollController,
                      children: [
                        ListTile(
                          leading: Radio<String>(
                            value: 'date',
                            groupValue: _newSortType,
                            onChanged: (value) {
                              setState(() {
                                _newSortType = value!;
                              });
                              Navigator.pop(context);
                            },
                            activeColor: primaryColor,
                          ),
                          title: Text(
                            'By Release Date',
                            style: GoogleFonts.plusJakartaSans(
                              color: Colors.white,
                            ),
                          ),
                          onTap: () {
                            setState(() {
                              _newSortType = 'date';
                            });
                            Navigator.pop(context);
                          },
                        ),
                        ListTile(
                          leading: Radio<String>(
                            value: 'title',
                            groupValue: _newSortType,
                            onChanged: (value) {
                              setState(() {
                                _newSortType = value!;
                              });
                              Navigator.pop(context);
                            },
                            activeColor: primaryColor,
                          ),
                          title: Text(
                            'By Title (A-Z)',
                            style: GoogleFonts.plusJakartaSans(
                              color: Colors.white,
                            ),
                          ),
                          onTap: () {
                            setState(() {
                              _newSortType = 'title';
                            });
                            Navigator.pop(context);
                          },
                        ),
                        ListTile(
                          leading: Radio<String>(
                            value: 'episodes',
                            groupValue: _newSortType,
                            onChanged: (value) {
                              setState(() {
                                _newSortType = value!;
                              });
                              Navigator.pop(context);
                            },
                            activeColor: primaryColor,
                          ),
                          title: Text(
                            'By Episode Count',
                            style: GoogleFonts.plusJakartaSans(
                              color: Colors.white,
                            ),
                          ),
                          onTap: () {
                            setState(() {
                              _newSortType = 'episodes';
                            });
                            Navigator.pop(context);
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
  
  // Helper method to apply sorting to a list
  List<T> _applySorting<T>(List<T> items, String sortType, String tabType) {
    List<T> sortedItems = List.from(items); // Create a copy to avoid modifying original
    
    if (tabType == 'trending') {
      switch (sortType) {
        case 'rank':
          // Keep original order (already sorted by rank)
          break;
        case 'popularity':
          // Sort by some popularity metric if available
          sortedItems.sort((a, b) {
            // Compare based on a popularity field if available, otherwise keep original
            // For now, assume Trending model doesn't have a specific popularity field
            return 0; // Keep original order
          });
          break;
        case 'title':
          sortedItems.sort((a, b) {
            String titleA = (a as dynamic).title ?? '';
            String titleB = (b as dynamic).title ?? '';
            return titleA.toLowerCase().compareTo(titleB.toLowerCase());
          });
          break;
      }
    } else if (tabType == 'new') {
      switch (sortType) {
        case 'date':
          // Keep original order (already sorted by date)
          break;
        case 'title':
          sortedItems.sort((a, b) {
            String titleA = (a as dynamic).title ?? '';
            String titleB = (b as dynamic).title ?? '';
            return titleA.toLowerCase().compareTo(titleB.toLowerCase());
          });
          break;
        case 'episodes':
          sortedItems.sort((a, b) {
            int epsA = (a as dynamic).tvInfo?.eps ?? 0;
            int epsB = (b as dynamic).tvInfo?.eps ?? 0;
            return epsB.compareTo(epsA); // Descending order
          });
          break;
      }
    }
    
    return sortedItems;
  }
  
  // Helper method to build collapsible genre section
  Widget _buildCollapsibleGenreSection(String genre, List<dynamic> animeList) {
    bool isExpanded = _expandedGenres.contains(genre);
    
    return SectionCard(
      title: '',
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
      child: Column(
        children: [
          GestureDetector(
            onTap: () {
              setState(() {
                if (_expandedGenres.contains(genre)) {
                  _expandedGenres.remove(genre);
                } else {
                  _expandedGenres.add(genre);
                }
              });
            },
            child: Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: surfaceColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Text(
                    genre,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const Spacer(),
                  AnimatedBuilder(
                    animation: _expandedGenres.contains(genre) 
                        ? AlwaysStoppedAnimation(0.5) 
                        : AlwaysStoppedAnimation(0.0),
                    builder: (context, child) {
                      return Transform.rotate(
                        angle: _expandedGenres.contains(genre) ? 0.5 * 3.14159 : 0.0,
                        child: Icon(
                          Icons.expand_more,
                          color: textSecondaryColor,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            height: isExpanded ? 280 : 0,
            child: ClipRect(
              child: isExpanded
                  ? Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: SizedBox(
                        height: 280,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: min(animeList.length, 5),
                          itemBuilder: (context, index) {
                            final anime = _convertToAnime(animeList[index]);
                            return AnimeCard(
                              anime: anime,
                              type: AnimeCardType.minimal,
                              onTap: () => _navigateToAnimeDetail(anime.id),
                            );
                          },
                        ),
                      ),
                    )
                  : null,
            ),
          ),
        ],
      ),
    );
  }
}