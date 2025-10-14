import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:linze/core/models/anime_model.dart';
import 'package:linze/core/models/watchlist_item.dart';
import 'package:linze/features/anime_detail/presentation/screen/anime_detail_screen.dart';

class WatchlistAnimeCard extends StatelessWidget {
  final WatchlistItem watchlistItem;
  final VoidCallback? onRemove;

  const WatchlistAnimeCard({
    super.key,
    required this.watchlistItem,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _navigateToAnimeDetail(context),
      onLongPress: onRemove != null ? () => _showRemoveDialog(context) : null,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: const Color(0xFF1E1E1E),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Poster Image
            Expanded(
              flex: 4,
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                child: CachedNetworkImage(
                  imageUrl: watchlistItem.poster,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  placeholder: (context, url) => Container(
                    color: const Color(0xFF2A2A2A),
                    child: const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF5B13EC),
                        strokeWidth: 2,
                      ),
                    ),
                  ),
                  errorWidget: (context, url, error) => Container(
                    color: const Color(0xFF2A2A2A),
                    child: const Icon(
                      Icons.broken_image,
                      color: Color(0xFF666666),
                      size: 32,
                    ),
                  ),
                ),
              ),
            ),
            
            // Title Section
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      watchlistItem.title,
                      style: GoogleFonts.plusJakartaSans(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        height: 1.2,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),
                    Text(
                      _formatDateAdded(watchlistItem.dateAdded),
                      style: GoogleFonts.plusJakartaSans(
                        color: const Color(0xFFA9A9A9),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToAnimeDetail(BuildContext context) {
    // Create a minimal Anime object for navigation
    final anime = Anime(
      id: watchlistItem.animeId,
      dataId: 0, // This would need to be stored if needed for API calls
      poster: watchlistItem.poster,
      title: watchlistItem.title,
      japaneseTitle: '', // Not stored in watchlist item
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AnimeDetailScreen(anime: anime),
      ),
    );
  }

  void _showRemoveDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Remove from Watchlist',
          style: GoogleFonts.plusJakartaSans(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          'Are you sure you want to remove "${watchlistItem.title}" from your watchlist?',
          style: GoogleFonts.plusJakartaSans(
            color: const Color(0xFFA9A9A9),
            fontSize: 14,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: GoogleFonts.plusJakartaSans(
                color: const Color(0xFFA9A9A9),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              onRemove?.call();
            },
            child: Text(
              'Remove',
              style: GoogleFonts.plusJakartaSans(
                color: Colors.red,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDateAdded(DateTime dateAdded) {
    final now = DateTime.now();
    final difference = now.difference(dateAdded);

    if (difference.inDays == 0) {
      return 'Added today';
    } else if (difference.inDays == 1) {
      return 'Added yesterday';
    } else if (difference.inDays < 7) {
      return 'Added ${difference.inDays} days ago';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return 'Added $weeks week${weeks == 1 ? '' : 's'} ago';
    } else {
      final months = (difference.inDays / 30).floor();
      return 'Added $months month${months == 1 ? '' : 's'} ago';
    }
  }
}
