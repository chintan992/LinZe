import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:linze/core/models/anime_model.dart';
import 'package:linze/core/models/watch_progress.dart';
import 'package:linze/core/providers/watch_progress_provider.dart';

class EpisodeCardWidget extends ConsumerWidget {
  final Episode episode;
  final Anime anime;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  const EpisodeCardWidget({
    super.key,
    required this.episode,
    required this.anime,
    this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final watchStatus = ref.watch(
      computedEpisodeWatchStatusProvider(episode.id),
    );
    final watchProgress = ref.watch(
      computedEpisodeProgressProvider(episode.id),
    );

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF2F2F2F),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          onLongPress: onLongPress,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Episode thumbnail with progress overlay
                _buildThumbnail(watchProgress, watchStatus),
                const SizedBox(width: 16),
                
                // Episode info
                Expanded(
                  child: _buildEpisodeInfo(watchProgress, watchStatus),
                ),
                
                // Action button
                _buildActionButton(watchStatus),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildThumbnail(WatchProgress? progress, WatchStatus status) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: const Color(0xFF2F2F2F),
            ),
            child: (episode.thumbnail != null || episode.poster != null)
                ? CachedNetworkImage(
                    imageUrl: episode.thumbnail ?? episode.poster ?? anime.poster,
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
                        size: 24,
                      ),
                    ),
                  )
                : Container(
                    color: const Color(0xFF2F2F2F),
                    child: const Icon(
                      Icons.play_arrow_rounded,
                      color: Color(0xFF5B13EC),
                      size: 24,
                    ),
                  ),
          ),
        ),
        
        // Progress overlay
        if (progress != null && progress.progress > 0)
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: LinearProgressIndicator(
                value: progress.progress,
                backgroundColor: Colors.transparent,
                valueColor: AlwaysStoppedAnimation<Color>(
                  const Color(0xFF5B13EC).withValues(alpha: 0.8),
                ),
              ),
            ),
          ),
        
        // Status indicator
        Positioned(
          top: 4,
          right: 4,
          child: _buildStatusIndicator(status),
        ),
        
        // Episode number overlay
        Positioned(
          bottom: 4,
          left: 4,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.7),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              '${episode.episodeNo}',
              style: GoogleFonts.plusJakartaSans(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusIndicator(WatchStatus status) {
    IconData icon;
    Color color;
    
    switch (status) {
      case WatchStatus.completed:
        icon = Icons.check_circle_rounded;
        color = const Color(0xFF10B981);
        break;
      case WatchStatus.inProgress:
        icon = Icons.play_circle_rounded;
        color = const Color(0xFFF59E0B);
        break;
      case WatchStatus.notWatched:
        icon = Icons.play_circle_outline_rounded;
        color = Colors.white70;
        break;
    }
    
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Icon(
        icon,
        color: color,
        size: 16,
      ),
    );
  }

  Widget _buildEpisodeInfo(WatchProgress? progress, WatchStatus status) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Episode number and title
        Text(
          'Episode ${episode.episodeNo}',
          style: GoogleFonts.plusJakartaSans(
            color: const Color(0xFF888888),
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        
        // Episode title
        Text(
          episode.title ?? 'Episode ${episode.episodeNo}',
          style: GoogleFonts.plusJakartaSans(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
            height: 1.2,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        
        const SizedBox(height: 8),
        
        // Status and progress info
        Row(
          children: [
            _buildStatusChip(status),
            if (episode.filler == true) ...[
              const SizedBox(width: 8),
              _buildFillerChip(),
            ],
            if (progress != null && progress.progress > 0) ...[
              const SizedBox(width: 8),
              _buildProgressChip(progress),
            ],
          ],
        ),
        
        // Continue watching indicator
        if (status == WatchStatus.inProgress && progress != null)
          Container(
            margin: const EdgeInsets.only(top: 8),
            child: Row(
              children: [
                Icon(
                  Icons.schedule_rounded,
                  color: const Color(0xFFF59E0B),
                  size: 14,
                ),
                const SizedBox(width: 4),
                Text(
                  'Continue from ${_formatDuration(progress.totalWatchTime)}',
                  style: GoogleFonts.plusJakartaSans(
                    color: const Color(0xFFF59E0B),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildStatusChip(WatchStatus status) {
    String label;
    Color color;
    
    switch (status) {
      case WatchStatus.completed:
        label = 'Watched';
        color = const Color(0xFF10B981);
        break;
      case WatchStatus.inProgress:
        label = 'In Progress';
        color = const Color(0xFFF59E0B);
        break;
      case WatchStatus.notWatched:
        label = 'Not Watched';
        color = const Color(0xFF888888);
        break;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Text(
        label,
        style: GoogleFonts.plusJakartaSans(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildFillerChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF59E0B).withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: const Color(0xFFF59E0B).withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Text(
        'Filler',
        style: GoogleFonts.plusJakartaSans(
          color: const Color(0xFFF59E0B),
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildProgressChip(WatchProgress progress) {
    final percentage = (progress.progress * 100).round();
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF5B13EC).withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: const Color(0xFF5B13EC).withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Text(
        '$percentage%',
        style: GoogleFonts.plusJakartaSans(
          color: const Color(0xFF5B13EC),
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildActionButton(WatchStatus status) {
    IconData icon;
    Color color;
    
    switch (status) {
      case WatchStatus.completed:
        icon = Icons.replay_rounded;
        color = const Color(0xFF10B981);
        break;
      case WatchStatus.inProgress:
        icon = Icons.play_arrow_rounded;
        color = const Color(0xFFF59E0B);
        break;
      case WatchStatus.notWatched:
        icon = Icons.play_arrow_rounded;
        color = const Color(0xFF5B13EC);
        break;
    }
    
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Icon(
        icon,
        color: color,
        size: 20,
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else {
      return '${minutes}m';
    }
  }
}
