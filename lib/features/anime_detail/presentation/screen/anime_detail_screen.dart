import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:linze/core/models/anime_model.dart';
import 'package:linze/core/services/anime_provider.dart';
import 'package:linze/features/video_player/presentation/screen/video_player_screen.dart';
import 'package:linze/core/providers/user_preferences_provider.dart';

class AnimeDetailScreen extends ConsumerStatefulWidget {
  final Anime anime;
  
  const AnimeDetailScreen({super.key, required this.anime});

  @override
  ConsumerState<AnimeDetailScreen> createState() => _AnimeDetailScreenState();
}

class _AnimeDetailScreenState extends ConsumerState<AnimeDetailScreen> {
  bool _isFavorite = false;
  bool _isInWatchlist = false;
  
  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'ongoing':
        return Colors.green;
      case 'completed':
        return Colors.blue;
      case 'upcoming':
        return Colors.orange;
      default:
        return const Color(0xFF2F2F2F);
    }
  }
  
  Widget _buildInfoRow(String label, String? value) {
    if (value == null || value.isEmpty) return const SizedBox.shrink();
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                color: const Color(0xFF888888),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.plusJakartaSans(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
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
          
          return animeDetail.when(
            data: (detail) {
              final anime = detail.data ?? widget.anime;
              final genres = anime.animeInfo?.genres ?? [];
              final relatedAnime = detail.relatedData ?? [];
              final recommendedAnime = detail.recommendedData ?? [];
              
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
                        onPressed: () {
                          setState(() {
                            _isFavorite = !_isFavorite;
                          });
                        },
                        icon: Icon(
                          _isFavorite ? Icons.favorite : Icons.favorite_border,
                          color: _isFavorite ? Colors.red : Colors.white,
                          size: 24,
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          setState(() {
                            _isInWatchlist = !_isInWatchlist;
                          });
                        },
                        icon: Icon(
                          _isInWatchlist ? Icons.bookmark : Icons.bookmark_border,
                          color: _isInWatchlist ? Colors.blue : Colors.white,
                          size: 24,
                        ),
                      ),
                      IconButton(
                        onPressed: () {},
                        icon: Icon(
                          Icons.share,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                    ],
                  ),
                  // Hero Banner
                  SliverToBoxAdapter(
                    child: Container(
                      height: 400,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: CachedNetworkImageProvider(anime.poster),
                          fit: BoxFit.cover,
                        ),
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              const Color(0xFF161022).withValues(alpha: 0.7),
                              const Color(0xFF161022),
                            ],
                          ),
                        ),
                        child: Stack(
                          children: [
                            Positioned(
                              bottom: 20,
                              left: 20,
                              right: 20,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    anime.title,
                                    style: GoogleFonts.plusJakartaSans(
                                      color: Colors.white,
                                      fontSize: 28,
                                      fontWeight: FontWeight.w800,
                                      shadows: [
                                        Shadow(
                                          offset: const Offset(0, 2),
                                          blurRadius: 4,
                                          color: Colors.black.withValues(alpha: 0.8),
                                        ),
                                      ],
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 8),
                                  if (anime.animeInfo?.japanese != null)
                                    Text(
                                      anime.animeInfo!.japanese!,
                                      style: GoogleFonts.plusJakartaSans(
                                        color: Colors.white70,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                        shadows: [
                                          Shadow(
                                            offset: const Offset(0, 1),
                                            blurRadius: 2,
                                            color: Colors.black.withValues(alpha: 0.8),
                                          ),
                                        ],
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ],
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
                          // Rating and Basic Info
                          Row(
                            children: [
                              if (anime.animeInfo?.malScore != null)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF2F2F2F),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.star,
                                    color: Colors.yellow[700],
                                        size: 16,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                        anime.animeInfo!.malScore!,
                                    style: GoogleFonts.plusJakartaSans(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                                ),
                              const SizedBox(width: 12),
                              if (anime.animeInfo?.status != null)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: _getStatusColor(anime.animeInfo!.status!),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    anime.animeInfo!.status!,
                                    style: GoogleFonts.plusJakartaSans(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              const Spacer(),
                              if (anime.animeInfo?.duration != null)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF2F2F2F),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    anime.animeInfo!.duration!,
                                style: GoogleFonts.plusJakartaSans(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          // Genres
                          if (genres.isNotEmpty)
                              Wrap(
                                spacing: 8,
                              runSpacing: 8,
                              children: genres.map((genre) {
                                  return Container(
                                    padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        const Color(0xFF5B13EC).withValues(alpha: 0.8),
                                        const Color(0xFF5B13EC).withValues(alpha: 0.6),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(16),
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
                          const SizedBox(height: 20),
                          // Action Buttons
                          Row(
                            children: [
                              Expanded(
                                child: Container(
                                  height: 52,
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [Color(0xFF5B13EC), Color(0xFF7B2CBF)],
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFF5B13EC).withValues(alpha: 0.3),
                                        blurRadius: 8,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: ElevatedButton(
                                    onPressed: () {
                                      // Play first episode if available
                                      if (episodes.hasValue && episodes.value?.episodes?.isNotEmpty == true) {
                                        final episodesList = episodes.value!.episodes!;
                                        _playEpisode(episodesList.first, 0, episodesList);
                                      }
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.transparent,
                                      shadowColor: Colors.transparent,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.play_arrow_rounded,
                                          size: 24,
                                          color: Colors.white,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          'Play Episode',
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w700,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Container(
                                height: 52,
                                width: 52,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF2F2F2F),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: const Color(0xFF5B13EC).withValues(alpha: 0.3),
                                    width: 1,
                                  ),
                                ),
                                child: IconButton(
                                  onPressed: () {
                                    setState(() {
                                      _isInWatchlist = !_isInWatchlist;
                                    });
                                  },
                                  icon: Icon(
                                    _isInWatchlist ? Icons.bookmark : Icons.bookmark_border,
                                    color: _isInWatchlist ? const Color(0xFF5B13EC) : Colors.white,
                                    size: 24,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          // Description Section
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1A1A1A),
                              borderRadius: BorderRadius.circular(12),
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
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 12),
                          Text(
                            anime.animeInfo?.overview ?? 'No description available',
                            style: GoogleFonts.plusJakartaSans(
                              color: const Color(0xFFA7A7A7),
                                    fontSize: 14,
                                    height: 1.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                          // Additional Info
                          if (anime.animeInfo != null)
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: const Color(0xFF1A1A1A),
                                borderRadius: BorderRadius.circular(12),
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
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  _buildInfoRow('Studios', anime.animeInfo!.studios),
                                  _buildInfoRow('Premiered', anime.animeInfo!.premiered),
                                  _buildInfoRow('Aired', anime.animeInfo!.aired),
                                  if (anime.animeInfo!.producers != null && anime.animeInfo!.producers!.isNotEmpty)
                                    _buildInfoRow('Producers', anime.animeInfo!.producers!.join(', ')),
                                ],
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
                      child: Row(
                        children: [
                          Text(
                        'Episodes',
                        style: GoogleFonts.plusJakartaSans(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                          ),
                          const Spacer(),
                          if (episodes.hasValue && episodes.value?.totalEpisodes != null)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFF2F2F2F),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '${episodes.value!.totalEpisodes} episodes',
                                style: GoogleFonts.plusJakartaSans(
                                  color: const Color(0xFF888888),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                        ],
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
                              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
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
                                  onTap: () => _playEpisode(episode, index, episodesList),
                                  child: Padding(
                                    padding: const EdgeInsets.all(12),
                                    child: Row(
                                      children: [
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(8),
                                          child: Container(
                                            width: 60,
                                            height: 60,
                                            decoration: BoxDecoration(
                                              color: const Color(0xFF2F2F2F),
                                            ),
                                            child: episode.thumbnail != null || episode.poster != null
                                                ? Stack(
                                                    children: [
                                                      CachedNetworkImage(
                                                        imageUrl: episode.thumbnail ?? episode.poster ?? anime.poster,
                                                        width: 60,
                                                        height: 60,
                                                        fit: BoxFit.cover,
                                                        placeholder: (context, url) => Container(
                                                          color: const Color(0xFF2F2F2F),
                                                          child: const Center(
                                                            child: CircularProgressIndicator(
                                                              strokeWidth: 2,
                                                              color: Color(0xFF5B13EC),
                                                            ),
                                                          ),
                                                        ),
                                                        errorWidget: (context, url, error) => Container(
                                                          color: const Color(0xFF2F2F2F),
                                                          child: const Icon(
                                                            Icons.play_arrow_rounded,
                                                            color: Color(0xFF5B13EC),
                                                            size: 20,
                                                          ),
                                                        ),
                                                      ),
                                                      Container(
                                                        decoration: BoxDecoration(
                                                          gradient: LinearGradient(
                                                            begin: Alignment.topCenter,
                                                            end: Alignment.bottomCenter,
                                                            colors: [
                                                              Colors.transparent,
                                                              Colors.black.withValues(alpha: 0.7),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                      Center(
                                                        child: Container(
                                                          padding: const EdgeInsets.all(4),
                                                          decoration: BoxDecoration(
                                                            color: Colors.black.withValues(alpha: 0.6),
                                                            borderRadius: BorderRadius.circular(4),
                                                          ),
                                                          child: Row(
                                                            mainAxisSize: MainAxisSize.min,
                                                            children: [
                                                              const Icon(
                                                                Icons.play_arrow_rounded,
                                                                color: Color(0xFF5B13EC),
                                                                size: 16,
                                                              ),
                                                              const SizedBox(width: 2),
                                                              Text(
                                                                '${episode.episodeNo}',
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
                                                  )
                                                : Center(
                                                    child: Column(
                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                      children: [
                                                        const Icon(
                                                          Icons.play_arrow_rounded,
                                                          color: Color(0xFF5B13EC),
                                                          size: 20,
                                                        ),
                                                        const SizedBox(height: 2),
                                                        Text(
                                                          '${episode.episodeNo}',
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
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                episode.title ?? 'Episode ${episode.episodeNo}',
                                                style: GoogleFonts.plusJakartaSans(
                                                  color: Colors.white,
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              if (episode.filler == true)
                                                Container(
                                                  margin: const EdgeInsets.only(top: 4),
                                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                  decoration: BoxDecoration(
                                                    color: Colors.orange.withValues(alpha: 0.2),
                                                    borderRadius: BorderRadius.circular(8),
                                                  ),
                                                  child: Text(
                                                    'Filler',
                                                    style: GoogleFonts.plusJakartaSans(
                                                      color: Colors.orange,
                                                      fontSize: 10,
                                                      fontWeight: FontWeight.w500,
                                                    ),
                                                  ),
                                                ),
                                            ],
                                          ),
                                        ),
                                        Icon(
                                          Icons.chevron_right,
                                          color: const Color(0xFF888888),
                                          size: 20,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
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
                  // Characters Section
                  characters.when(
                    data: (charactersData) {
                      final charactersList = charactersData.data ?? [];
                      if (charactersList.isEmpty) {
                        return const SliverToBoxAdapter(child: SizedBox.shrink());
                      }
                      
                      return SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Characters',
                                style: GoogleFonts.plusJakartaSans(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 12),
                              SizedBox(
                                height: 120,
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: charactersList.take(10).length,
                                  itemBuilder: (context, index) {
                                    final characterItem = charactersList[index];
                                    final character = characterItem.character;
                                    if (character == null) return const SizedBox.shrink();
                                    
                                    return Container(
                                      width: 80,
                                      margin: const EdgeInsets.only(right: 12),
                                      child: Column(
                                        children: [
                                          ClipRRect(
                                            borderRadius: BorderRadius.circular(8),
                                            child: Container(
                                              width: 80,
                                              height: 80,
                                              decoration: BoxDecoration(
                                                color: const Color(0xFF2F2F2F),
                                              ),
                                              child: character.profile != null
                                                  ? CachedNetworkImage(
                                                      imageUrl: character.profile!,
                                                      fit: BoxFit.cover,
                                                      placeholder: (context, url) => const Center(
                                                        child: CircularProgressIndicator(strokeWidth: 2),
                                                      ),
                                                      errorWidget: (context, url, error) => const Icon(
                                                        Icons.person,
                                                        color: Colors.white30,
                                                        size: 32,
                                                      ),
                                                    )
                                                  : const Icon(
                                                      Icons.person,
                                                      color: Colors.white30,
                                                      size: 32,
                                                    ),
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            character.name ?? 'Unknown',
                                            style: GoogleFonts.plusJakartaSans(
                                              color: Colors.white,
                                              fontSize: 11,
                                              fontWeight: FontWeight.w600,
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            textAlign: TextAlign.center,
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                    loading: () => const SliverToBoxAdapter(child: SizedBox.shrink()),
                    error: (error, stack) => const SliverToBoxAdapter(child: SizedBox.shrink()),
                  ),
                  // Related Anime Section
                  if (relatedAnime.isNotEmpty)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Related Anime',
                              style: GoogleFonts.plusJakartaSans(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 12),
                            SizedBox(
                              height: 200,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: relatedAnime.length,
                                itemBuilder: (context, index) {
                                  final related = relatedAnime[index];
                                  return Container(
                                    width: 140,
                                    margin: const EdgeInsets.only(right: 12),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(8),
                                          child: SizedBox(
                                            width: 140,
                                            height: 180,
                                            child: CachedNetworkImage(
                                              imageUrl: related.poster,
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
                                                  size: 40,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  // Recommended Anime Section
                  if (recommendedAnime.isNotEmpty)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Recommended',
                              style: GoogleFonts.plusJakartaSans(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 12),
                            SizedBox(
                              height: 200,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: recommendedAnime.length,
                                itemBuilder: (context, index) {
                                  final recommended = recommendedAnime[index];
                                  return Container(
                                    width: 140,
                                    margin: const EdgeInsets.only(right: 12),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(8),
                                          child: SizedBox(
                                            width: 140,
                                            height: 180,
                                            child: CachedNetworkImage(
                                              imageUrl: recommended.poster,
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
                                                  size: 40,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
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
}