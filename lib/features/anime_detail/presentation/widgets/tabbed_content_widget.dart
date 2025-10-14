import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:linze/core/models/anime_model.dart';
import 'package:linze/core/models/streaming_models.dart';
import 'package:linze/core/models/response_models.dart';
import 'package:linze/features/anime_detail/presentation/widgets/episode_card_widget.dart';
import 'package:linze/features/anime_detail/presentation/widgets/character_grid_widget.dart';

class _StickyTabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;
  
  _StickyTabBarDelegate(this.tabBar);
  
  @override
  double get minExtent => 64;
  
  @override
  double get maxExtent => 64;
  
  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF161022),
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFF2F2F2F),
            width: 1,
          ),
        ),
        child: tabBar,
      ),
    );
  }
  
  @override
  bool shouldRebuild(_StickyTabBarDelegate oldDelegate) => false;
}

class TabbedContentWidget extends ConsumerStatefulWidget {
  final Anime anime;
  final AsyncValue<AnimeDetailApiResponse> animeDetail;
  final AsyncValue<EpisodesResponse> episodes;
  final AsyncValue<CharacterListResponse> characters;
  final Function(Episode, int, List<Episode>) onEpisodeTap;

  const TabbedContentWidget({
    super.key,
    required this.anime,
    required this.animeDetail,
    required this.episodes,
    required this.characters,
    required this.onEpisodeTap,
  });

  @override
  ConsumerState<TabbedContentWidget> createState() => _TabbedContentWidgetState();
}

class TabbedContentSliverWidget extends ConsumerStatefulWidget {
  final Anime anime;
  final AsyncValue<AnimeDetailApiResponse> animeDetail;
  final AsyncValue<EpisodesResponse> episodes;
  final AsyncValue<CharacterListResponse> characters;
  final Function(Episode, int, List<Episode>) onEpisodeTap;

  const TabbedContentSliverWidget({
    super.key,
    required this.anime,
    required this.animeDetail,
    required this.episodes,
    required this.characters,
    required this.onEpisodeTap,
  });

  @override
  ConsumerState<TabbedContentSliverWidget> createState() => _TabbedContentSliverWidgetState();
}

class _TabbedContentSliverWidgetState extends ConsumerState<TabbedContentSliverWidget>
    with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Build sticky tab bar
  Widget buildStickyTabBar() {
    return SliverPersistentHeader(
      pinned: true,
      delegate: _StickyTabBarDelegate(
        TabBar(
          controller: _tabController,
          onTap: (index) {
            setState(() {});
          },
          indicator: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF5B13EC), Color(0xFF7B2CBF)],
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          indicatorPadding: const EdgeInsets.all(4),
          dividerColor: Colors.transparent,
          labelColor: Colors.white,
          unselectedLabelColor: const Color(0xFFA7A7A7),
          labelStyle: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
          unselectedLabelStyle: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
          tabs: const [
            Tab(text: 'Overview'),
            Tab(text: 'Episodes'),
            Tab(text: 'Characters'),
            Tab(text: 'Related'),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Sticky Tab Bar
        SliverPersistentHeader(
          pinned: true,
          delegate: _StickyTabBarDelegate(
            TabBar(
              controller: _tabController,
              onTap: (index) {
                setState(() {});
              },
              indicator: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF5B13EC), Color(0xFF7B2CBF)],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              indicatorPadding: const EdgeInsets.all(4),
              dividerColor: Colors.transparent,
              labelColor: Colors.white,
              unselectedLabelColor: const Color(0xFFA7A7A7),
              labelStyle: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
              unselectedLabelStyle: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              tabs: const [
                Tab(text: 'Overview'),
                Tab(text: 'Episodes'),
                Tab(text: 'Characters'),
                Tab(text: 'Related'),
              ],
            ),
          ),
        ),
        // Tab Content based on selected tab
        _buildSelectedTabContent(),
      ],
    );
  }

  Widget _buildSelectedTabContent() {
    switch (_tabController.index) {
      case 0:
        return _buildOverviewSliver();
      case 1:
        return _buildEpisodesSliver();
      case 2:
        return _buildCharactersSliver();
      case 3:
        return _buildRelatedSliver();
      default:
        return _buildOverviewSliver();
    }
  }

  // Build sliver content based on selected tab
  Widget buildSliverContent() {
    switch (_tabController.index) {
      case 0:
        return _buildOverviewSliver();
      case 1:
        return _buildEpisodesSliver();
      case 2:
        return _buildCharactersSliver();
      case 3:
        return _buildRelatedSliver();
      default:
        return _buildOverviewSliver();
    }
  }

  // Sliver implementations for the new sticky tab system
  Widget _buildOverviewSliver() {
    return widget.animeDetail.when(
      data: (detail) {
        final anime = detail.data ?? widget.anime;
        final relatedAnime = detail.relatedData ?? [];
        final recommendedAnime = detail.recommendedData ?? [];
        
        return SliverList(
          delegate: SliverChildListDelegate([
            // Description
            _buildDescriptionSection(anime),
            
            const SizedBox(height: 24),
            
            // Information
            _buildInformationSection(anime),
            
            const SizedBox(height: 24),
            
            // Related anime preview
            if (relatedAnime.isNotEmpty)
              _buildRelatedAnimePreview(relatedAnime, 'Related Anime'),
            
            if (relatedAnime.isNotEmpty)
              const SizedBox(height: 16),
            
            // Recommended anime preview
            if (recommendedAnime.isNotEmpty)
              _buildRelatedAnimePreview(recommendedAnime, 'Recommended'),
            
            const SizedBox(height: 24), // Extra padding at bottom
          ]),
        );
      },
      loading: () => SliverToBoxAdapter(
        child: Container(
          height: 200,
          child: const Center(child: CircularProgressIndicator()),
        ),
      ),
      error: (error, stack) => SliverToBoxAdapter(
        child: Container(
          height: 200,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline_rounded,
                  color: Colors.red,
                  size: 48,
                ),
                const SizedBox(height: 16),
                Text(
                  'Error loading anime details',
                  style: GoogleFonts.plusJakartaSans(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEpisodesSliver() {
    return widget.episodes.when(
      data: (episodesData) {
        final episodesList = episodesData.episodes ?? [];
        
        if (episodesList.isEmpty) {
          return SliverToBoxAdapter(
            child: Container(
              height: 200,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.playlist_play_outlined,
                      color: const Color(0xFF888888),
                      size: 48,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No episodes available',
                      style: GoogleFonts.plusJakartaSans(
                        color: const Color(0xFF888888),
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }
        
        return SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final episode = episodesList[index];
              return EpisodeCardWidget(
                episode: episode,
                anime: widget.anime,
                onTap: () => widget.onEpisodeTap(episode, index, episodesList),
              );
            },
            childCount: episodesList.length,
          ),
        );
      },
      loading: () => SliverToBoxAdapter(
        child: Container(
          height: 200,
          child: const Center(child: CircularProgressIndicator()),
        ),
      ),
      error: (error, stack) => SliverToBoxAdapter(
        child: Container(
          height: 200,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline_rounded,
                  color: Colors.red,
                  size: 48,
                ),
                const SizedBox(height: 16),
                Text(
                  'Error loading episodes',
                  style: GoogleFonts.plusJakartaSans(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCharactersSliver() {
    return SliverToBoxAdapter(
      child: widget.characters.when(
        data: (charactersData) {
          final charactersList = charactersData.data ?? [];
          return CharacterGridWidget(characters: charactersList);
        },
        loading: () => Container(
          height: 200,
          child: const Center(child: CircularProgressIndicator()),
        ),
        error: (error, stack) => Container(
          height: 200,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline_rounded,
                  color: Colors.red,
                  size: 48,
                ),
                const SizedBox(height: 16),
                Text(
                  'Error loading characters',
                  style: GoogleFonts.plusJakartaSans(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRelatedSliver() {
    return widget.animeDetail.when(
      data: (detail) {
        final relatedAnime = detail.relatedData ?? [];
        final recommendedAnime = detail.recommendedData ?? [];
        
        return SliverList(
          delegate: SliverChildListDelegate([
            if (relatedAnime.isNotEmpty)
              _buildRelatedAnimeSection(relatedAnime, 'Related Anime'),
            
            if (relatedAnime.isNotEmpty && recommendedAnime.isNotEmpty)
              const SizedBox(height: 24),
            
            if (recommendedAnime.isNotEmpty)
              _buildRelatedAnimeSection(recommendedAnime, 'Recommended'),
            
            const SizedBox(height: 24), // Extra padding at bottom
          ]),
        );
      },
      loading: () => SliverToBoxAdapter(
        child: Container(
          height: 200,
          child: const Center(child: CircularProgressIndicator()),
        ),
      ),
      error: (error, stack) => SliverToBoxAdapter(
        child: Container(
          height: 200,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline_rounded,
                  color: Colors.red,
                  size: 48,
                ),
                const SizedBox(height: 16),
                Text(
                  'Error loading related anime',
                  style: GoogleFonts.plusJakartaSans(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Helper methods for building content sections
  Widget _buildDescriptionSection(Anime anime) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF2F2F2F),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Description',
            style: GoogleFonts.plusJakartaSans(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            anime.animeInfo?.overview ?? 'No description available',
            style: GoogleFonts.plusJakartaSans(
              color: const Color(0xFFA7A7A7),
              fontSize: 16,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInformationSection(Anime anime) {
    if (anime.animeInfo == null) {
      return const SizedBox.shrink();
    }
    
    final info = anime.animeInfo!;
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF2F2F2F),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Information',
            style: GoogleFonts.plusJakartaSans(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          _buildInfoRow('Studios', info.studios),
          _buildInfoRow('Premiered', info.premiered),
          _buildInfoRow('Aired', info.aired),
          _buildInfoRow('Duration', info.duration),
          _buildInfoRow('Status', info.status),
          if (info.producers != null && info.producers!.isNotEmpty)
            _buildInfoRow('Producers', info.producers!.join(', ')),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String? value) {
    if (value == null || value.isEmpty) return const SizedBox.shrink();
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                color: const Color(0xFF888888),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.plusJakartaSans(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRelatedAnimePreview(List<Anime> animeList, String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.plusJakartaSans(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 160,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: animeList.take(5).length,
            itemBuilder: (context, index) {
              final anime = animeList[index];
              return Container(
                width: 120,
                margin: const EdgeInsets.only(right: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: SizedBox(
                        width: 120,
                        height: 120,
                        child: CachedNetworkImage(
                          imageUrl: anime.poster,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            color: const Color(0xFF2F2F2F),
                            child: const Center(
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ),
                          errorWidget: (context, url, error) => Container(
                            color: const Color(0xFF2F2F2F),
                            child: const Icon(
                              Icons.movie,
                              color: Colors.white30,
                              size: 32,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      anime.title,
                      style: GoogleFonts.plusJakartaSans(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildRelatedAnimeSection(List<Anime> animeList, String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.plusJakartaSans(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.7,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: animeList.length,
          itemBuilder: (context, index) {
            final anime = animeList[index];
            return Container(
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A1A),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFF2F2F2F),
                  width: 1,
                ),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () {
                    // Navigate to anime detail
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 3,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: SizedBox(
                              width: double.infinity,
                              child: CachedNetworkImage(
                                imageUrl: anime.poster,
                                fit: BoxFit.cover,
                                placeholder: (context, url) => Container(
                                  color: const Color(0xFF2F2F2F),
                                  child: const Center(
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  ),
                                ),
                                errorWidget: (context, url, error) => Container(
                                  color: const Color(0xFF2F2F2F),
                                  child: const Icon(
                                    Icons.movie,
                                    color: Colors.white30,
                                    size: 32,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Expanded(
                          flex: 2,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                anime.title,
                                style: GoogleFonts.plusJakartaSans(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              if (anime.animeInfo?.malScore != null)
                                Row(
                                  children: [
                                    Icon(
                                      Icons.star_rounded,
                                      color: Colors.amber,
                                      size: 14,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      anime.animeInfo!.malScore!,
                                      style: GoogleFonts.plusJakartaSans(
                                        color: const Color(0xFFA7A7A7),
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                            ],
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
      ],
    );
  }
}

class _TabbedContentWidgetState extends ConsumerState<TabbedContentWidget>
    with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF161022),
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          // Tab bar
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A1A),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFF2F2F2F),
                width: 1,
              ),
            ),
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF5B13EC), Color(0xFF7B2CBF)],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              indicatorPadding: const EdgeInsets.all(4),
              dividerColor: Colors.transparent,
              labelColor: Colors.white,
              unselectedLabelColor: const Color(0xFFA7A7A7),
              labelStyle: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
              unselectedLabelStyle: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              tabs: const [
                Tab(text: 'Overview'),
                Tab(text: 'Episodes'),
                Tab(text: 'Characters'),
                Tab(text: 'Related'),
              ],
            ),
          ),
          
          // Tab content
          Flexible(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildOverviewTab(),
                _buildEpisodesTab(),
                _buildCharactersTab(),
                _buildRelatedTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewTab() {
    return widget.animeDetail.when(
      data: (detail) {
        final anime = detail.data ?? widget.anime;
        final relatedAnime = detail.relatedData ?? [];
        final recommendedAnime = detail.recommendedData ?? [];
        
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Description
              _buildDescriptionSection(anime),
              
              const SizedBox(height: 24),
              
              // Information
              _buildInformationSection(anime),
              
              const SizedBox(height: 24),
              
              // Related anime preview
              if (relatedAnime.isNotEmpty)
                _buildRelatedAnimePreview(relatedAnime, 'Related Anime'),
              
              if (relatedAnime.isNotEmpty)
                const SizedBox(height: 16),
              
              // Recommended anime preview
              if (recommendedAnime.isNotEmpty)
                _buildRelatedAnimePreview(recommendedAnime, 'Recommended'),
            ],
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline_rounded,
              color: Colors.red,
              size: 48,
            ),
            const SizedBox(height: 16),
            Text(
              'Error loading anime details',
              style: GoogleFonts.plusJakartaSans(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEpisodesTab() {
    return widget.episodes.when(
      data: (episodesData) {
        final episodesList = episodesData.episodes ?? [];
        
        if (episodesList.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.playlist_play_outlined,
                  color: const Color(0xFF888888),
                  size: 48,
                ),
                const SizedBox(height: 16),
                Text(
                  'No episodes available',
                  style: GoogleFonts.plusJakartaSans(
                    color: const Color(0xFF888888),
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          );
        }
        
        return ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 16),
          itemCount: episodesList.length,
          itemBuilder: (context, index) {
            final episode = episodesList[index];
            return EpisodeCardWidget(
              episode: episode,
              anime: widget.anime,
              onTap: () => widget.onEpisodeTap(episode, index, episodesList),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline_rounded,
              color: Colors.red,
              size: 48,
            ),
            const SizedBox(height: 16),
            Text(
              'Error loading episodes',
              style: GoogleFonts.plusJakartaSans(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCharactersTab() {
    return widget.characters.when(
      data: (charactersData) {
        final charactersList = charactersData.data ?? [];
        return CharacterGridWidget(characters: charactersList);
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline_rounded,
              color: Colors.red,
              size: 48,
            ),
            const SizedBox(height: 16),
            Text(
              'Error loading characters',
              style: GoogleFonts.plusJakartaSans(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRelatedTab() {
    return widget.animeDetail.when(
      data: (detail) {
        final relatedAnime = detail.relatedData ?? [];
        final recommendedAnime = detail.recommendedData ?? [];
        
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (relatedAnime.isNotEmpty)
                _buildRelatedAnimeSection(relatedAnime, 'Related Anime'),
              
              if (relatedAnime.isNotEmpty && recommendedAnime.isNotEmpty)
                const SizedBox(height: 24),
              
              if (recommendedAnime.isNotEmpty)
                _buildRelatedAnimeSection(recommendedAnime, 'Recommended'),
            ],
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline_rounded,
              color: Colors.red,
              size: 48,
            ),
            const SizedBox(height: 16),
            Text(
              'Error loading related anime',
              style: GoogleFonts.plusJakartaSans(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDescriptionSection(Anime anime) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF2F2F2F),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Description',
            style: GoogleFonts.plusJakartaSans(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            anime.animeInfo?.overview ?? 'No description available',
            style: GoogleFonts.plusJakartaSans(
              color: const Color(0xFFA7A7A7),
              fontSize: 16,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInformationSection(Anime anime) {
    if (anime.animeInfo == null) {
      return const SizedBox.shrink();
    }
    
    final info = anime.animeInfo!;
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF2F2F2F),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Information',
            style: GoogleFonts.plusJakartaSans(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          _buildInfoRow('Studios', info.studios),
          _buildInfoRow('Premiered', info.premiered),
          _buildInfoRow('Aired', info.aired),
          _buildInfoRow('Duration', info.duration),
          _buildInfoRow('Status', info.status),
          if (info.producers != null && info.producers!.isNotEmpty)
            _buildInfoRow('Producers', info.producers!.join(', ')),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String? value) {
    if (value == null || value.isEmpty) return const SizedBox.shrink();
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                color: const Color(0xFF888888),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.plusJakartaSans(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRelatedAnimePreview(List<Anime> animeList, String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.plusJakartaSans(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 160,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: animeList.take(5).length,
            itemBuilder: (context, index) {
              final anime = animeList[index];
              return Container(
                width: 120,
                margin: const EdgeInsets.only(right: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: SizedBox(
                        width: 120,
                        height: 120,
                        child: CachedNetworkImage(
                          imageUrl: anime.poster,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            color: const Color(0xFF2F2F2F),
                            child: const Center(
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ),
                          errorWidget: (context, url, error) => Container(
                            color: const Color(0xFF2F2F2F),
                            child: const Icon(
                              Icons.movie,
                              color: Colors.white30,
                              size: 32,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      anime.title,
                      style: GoogleFonts.plusJakartaSans(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildRelatedAnimeSection(List<Anime> animeList, String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.plusJakartaSans(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.7,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: animeList.length,
          itemBuilder: (context, index) {
            final anime = animeList[index];
            return Container(
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A1A),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFF2F2F2F),
                  width: 1,
                ),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () {
                    // Navigate to anime detail
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 3,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: SizedBox(
                              width: double.infinity,
                              child: CachedNetworkImage(
                                imageUrl: anime.poster,
                                fit: BoxFit.cover,
                                placeholder: (context, url) => Container(
                                  color: const Color(0xFF2F2F2F),
                                  child: const Center(
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  ),
                                ),
                                errorWidget: (context, url, error) => Container(
                                  color: const Color(0xFF2F2F2F),
                                  child: const Icon(
                                    Icons.movie,
                                    color: Colors.white30,
                                    size: 32,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Expanded(
                          flex: 2,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                anime.title,
                                style: GoogleFonts.plusJakartaSans(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              if (anime.animeInfo?.malScore != null)
                                Row(
                                  children: [
                                    Icon(
                                      Icons.star_rounded,
                                      color: Colors.amber,
                                      size: 14,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      anime.animeInfo!.malScore!,
                                      style: GoogleFonts.plusJakartaSans(
                                        color: const Color(0xFFA7A7A7),
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                            ],
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
      ],
    );
  }
}
