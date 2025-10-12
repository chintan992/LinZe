import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:linze/core/models/anime_model.dart';
import 'package:linze/core/services/anime_provider.dart';
import 'package:linze/core/api/api_service.dart';
import 'package:linze/features/video_player/presentation/screen/video_player_screen.dart';

class AnimeDetailScreen extends ConsumerStatefulWidget {
  final Anime anime;
  
  const AnimeDetailScreen({Key? key, required this.anime}) : super(key: key);

  @override
  ConsumerState<AnimeDetailScreen> createState() => _AnimeDetailScreenState();
}

class _AnimeDetailScreenState extends ConsumerState<AnimeDetailScreen> {
  Future<void> _playEpisode(Episode episode) async {
    try {
      final apiService = ref.read(apiServiceProvider);
      final streamingInfo = await apiService.getStreamingInfo(
        id: episode.id,
        server: 'HD-2',
        type: 'sub',
      );

      if (streamingInfo.streamingLink != null) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => VideoPlayerScreen(
              streamingLink: streamingInfo.streamingLink!,
              animeTitle: widget.anime.title,
              episodeTitle: episode.title ?? 'Episode ${episode.episodeNo}',
              episodeId: episode.id,
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No streaming link available for this episode'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
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
          
          return animeDetail.when(
            data: (detail) {
              final anime = detail.data ?? widget.anime;
              final genres = anime.animeInfo?.genres ?? [];
              
              return CustomScrollView(
                slivers: [
                  // App Bar
                  SliverAppBar(
                    backgroundColor: const Color(0xFF161022),
                    elevation: 0,
                    leading: IconButton(
                      icon: Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                        size: 24,
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                    actions: [
                      IconButton(
                        onPressed: () {},
                        icon: Icon(
                          Icons.search,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                    ],
                  ),
                  // Hero Banner
                  SliverToBoxAdapter(
                    child: Container(
                      height: 320, // 80 height units from the design
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: CachedNetworkImageProvider(anime.poster),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  // Content
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Title
                          Text(
                            anime.title,
                            style: GoogleFonts.plusJakartaSans(
                              color: Colors.white,
                              fontSize: 32,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 8),
                          // Rating and Genres
                          Row(
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.star,
                                    color: Colors.yellow[700],
                                    size: 20,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '4.9',
                                    style: GoogleFonts.plusJakartaSans(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '•',
                                style: GoogleFonts.plusJakartaSans(
                                  color: const Color(0xFF888888),
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Wrap(
                                spacing: 8,
                                children: genres.take(3).map((genre) {
                                  return Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF2F2F2F),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      genre,
                                      style: GoogleFonts.plusJakartaSans(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          // Action Buttons
                          Row(
                            children: [
                              Expanded(
                                child: Container(
                                  height: 48,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      // Play first episode if available
                                      if (episodes.hasValue && episodes.value?.episodes?.isNotEmpty == true) {
                                        _playEpisode(episodes.value!.episodes!.first);
                                      }
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF5B13EC),
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      padding: const EdgeInsets.symmetric(horizontal: 16),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.play_arrow,
                                          size: 20,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          'Play Episode',
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Container(
                                  height: 48,
                                  child: OutlinedButton(
                                    onPressed: () {},
                                    style: OutlinedButton.styleFrom(
                                      backgroundColor: const Color(0xFF5B13EC).withOpacity(0.2),
                                      foregroundColor: Colors.white,
                                      side: BorderSide.none,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      padding: const EdgeInsets.symmetric(horizontal: 16),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.add,
                                          size: 20,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          'Add to My List',
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          // Description
                          Text(
                            anime.animeInfo?.overview ?? 'No description available',
                            style: GoogleFonts.plusJakartaSans(
                              color: const Color(0xFFA7A7A7),
                              fontSize: 16,
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),
                  // Episodes Section
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.only(
                        left: 16,
                        right: 16,
                        bottom: 12,
                      ),
                      child: Text(
                        'Episodes',
                        style: GoogleFonts.plusJakartaSans(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  episodes.when(
                    data: (episodesData) {
                      final episodesList = episodesData.episodes ?? [];
                      if (episodesList.isEmpty) {
                        return SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              'No episodes available',
                              style: GoogleFonts.plusJakartaSans(
                                color: const Color(0xFFA7A7A7),
                              ),
                            ),
                          ),
                        );
                      }
                      
                      return SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final episode = episodesList[index];
                            return Container(
                              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color(0xFF2F2F2F),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Container(
                                      width: 128,
                                      height: 80,
                                      color: Colors.grey[800],
                                      child: Center(
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            const Icon(
                                              Icons.video_library,
                                              color: Colors.white30,
                                              size: 24,
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              'EP ${episode.episodeNo}',
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
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Episode ${episode.episodeNo}',
                                          style: GoogleFonts.plusJakartaSans(
                                            color: const Color(0xFF888888),
                                            fontSize: 14,
                                          ),
                                        ),
                                        Text(
                                          episode.title ?? 'Episode ${episode.episodeNo}',
                                          style: GoogleFonts.plusJakartaSans(
                                            color: Colors.white,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () => _playEpisode(episode),
                                    icon: Icon(
                                      Icons.play_circle,
                                      color: Colors.white,
                                      size: 32,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                          childCount: episodesList.length,
                        ),
                      );
                    },
                    loading: () => SliverToBoxAdapter(
                      child: const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Center(
                          child: CircularProgressIndicator(),
                        ),
                      ),
                    ),
                    error: (error, stack) => SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'Error loading episodes: $error',
                          style: GoogleFonts.plusJakartaSans(
                            color: Colors.red,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SliverToBoxAdapter(
                    child: SizedBox(height: 100), // Extra space
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
                      ref.refresh(animeDetailProvider(widget.anime.id));
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