import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:linze/core/models/anime_model.dart';
import 'package:linze/core/models/watch_progress.dart';
import 'package:linze/core/providers/watch_progress_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class StatsBarWidget extends ConsumerWidget {
  final Anime anime;
  final int totalEpisodes;

  const StatsBarWidget({
    super.key,
    required this.anime,
    required this.totalEpisodes,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progressStats = ref.watch(
      computedAnimeProgressStatsProvider((anime.id, totalEpisodes)),
    );

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
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
      child: Row(
        children: [
          // Rating
          if (anime.animeInfo?.malScore != null) ...[
            _buildStatItem(
              icon: Icons.star_rounded,
              iconColor: Colors.amber,
              label: 'Rating',
              value: anime.animeInfo!.malScore!,
              onTap: () => _showRatingInfo(context),
            ),
            _buildDivider(),
          ],
          
          // Episodes
          _buildStatItem(
            icon: Icons.playlist_play_rounded,
            iconColor: const Color(0xFF5B13EC),
            label: 'Episodes',
            value: totalEpisodes > 0 ? '$totalEpisodes' : 'N/A',
          ),
          
          // Status
          if (anime.animeInfo?.status != null) ...[
            _buildDivider(),
            _buildStatItem(
              icon: _getStatusIcon(anime.animeInfo!.status!),
              iconColor: _getStatusColor(anime.animeInfo!.status!),
              label: 'Status',
              value: anime.animeInfo!.status!,
              onTap: () => _showStatusInfo(context, anime.animeInfo!.status!),
            ),
          ],
          
          // Duration
          if (anime.animeInfo?.duration != null) ...[
            _buildDivider(),
            _buildStatItem(
              icon: Icons.schedule_rounded,
              iconColor: const Color(0xFF10B981),
              label: 'Duration',
              value: anime.animeInfo!.duration!,
            ),
          ],
          
          // Watch Progress (if available)
          if (progressStats != null) ...[
            _buildDivider(),
            _buildProgressStat(progressStats),
          ],
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
    VoidCallback? onTap,
  }) {
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  color: iconColor,
                  size: 20,
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: GoogleFonts.plusJakartaSans(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                  textAlign: TextAlign.center,
                ),
                Text(
                  label,
                  style: GoogleFonts.plusJakartaSans(
                    color: const Color(0xFFA7A7A7),
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProgressStat(WatchProgressStats stats) {
    final progressPercentage = (stats.overallProgress * 100).round();
    
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.check_circle_rounded,
                color: const Color(0xFF10B981),
                size: 20,
              ),
              const SizedBox(width: 4),
              Text(
                '$progressPercentage%',
                style: GoogleFonts.plusJakartaSans(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Progress',
            style: GoogleFonts.plusJakartaSans(
              color: const Color(0xFFA7A7A7),
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 2),
          Container(
            height: 3,
            width: 40,
            decoration: BoxDecoration(
              color: const Color(0xFF2F2F2F),
              borderRadius: BorderRadius.circular(2),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: stats.overallProgress,
              child: Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF10B981), Color(0xFF059669)],
                  ),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 40,
      width: 1,
      color: const Color(0xFF2F2F2F),
    );
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'ongoing':
        return Icons.play_circle_rounded;
      case 'completed':
        return Icons.check_circle_rounded;
      case 'upcoming':
        return Icons.schedule_rounded;
      default:
        return Icons.help_rounded;
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'ongoing':
        return const Color(0xFF10B981);
      case 'completed':
        return const Color(0xFF3B82F6);
      case 'upcoming':
        return const Color(0xFFF59E0B);
      default:
        return const Color(0xFF888888);
    }
  }

  void _showRatingInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        title: Text(
          'Rating Information',
          style: GoogleFonts.plusJakartaSans(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
        content: Text(
          'This rating is based on MyAnimeList scores, which reflect community ratings for this anime.',
          style: GoogleFonts.plusJakartaSans(
            color: const Color(0xFFA7A7A7),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'OK',
              style: GoogleFonts.plusJakartaSans(
                color: const Color(0xFF5B13EC),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showStatusInfo(BuildContext context, String status) {
    String message;
    switch (status.toLowerCase()) {
      case 'ongoing':
        message = 'This anime is currently airing new episodes.';
        break;
      case 'completed':
        message = 'This anime has finished airing all episodes.';
        break;
      case 'upcoming':
        message = 'This anime is scheduled to air in the future.';
        break;
      default:
        message = 'Status information for this anime.';
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        title: Text(
          'Status Information',
          style: GoogleFonts.plusJakartaSans(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
        content: Text(
          message,
          style: GoogleFonts.plusJakartaSans(
            color: const Color(0xFFA7A7A7),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'OK',
              style: GoogleFonts.plusJakartaSans(
                color: const Color(0xFF5B13EC),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
