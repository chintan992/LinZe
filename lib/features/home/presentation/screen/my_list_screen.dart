import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:linze/core/providers/watchlist_provider.dart';
import 'package:linze/features/home/presentation/widgets/watchlist_anime_card.dart';

class MyListScreen extends ConsumerStatefulWidget {
  const MyListScreen({super.key});

  @override
  ConsumerState<MyListScreen> createState() => _MyListScreenState();
}

class _MyListScreenState extends ConsumerState<MyListScreen> {
  @override
  void initState() {
    super.initState();
    // Load watchlist when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(watchlistNotifierProvider.notifier).loadWatchlist();
    });
  }

  @override
  Widget build(BuildContext context) {
    final watchlist = ref.watch(watchlistNotifierProvider);
    final watchlistNotifier = ref.read(watchlistNotifierProvider.notifier);

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Text(
                    'My Watchlist',
                    style: GoogleFonts.plusJakartaSans(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Spacer(),
                  if (watchlist.isNotEmpty)
                    Text(
                      '${watchlist.length} anime',
                      style: GoogleFonts.plusJakartaSans(
                        color: const Color(0xFFA9A9A9),
                        fontSize: 14,
                      ),
                    ),
                ],
              ),
            ),
            
            // Content
            Expanded(
              child: watchlist.isEmpty
                  ? _buildEmptyState()
                  : _buildWatchlistGrid(watchlist, watchlistNotifier),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.bookmark_border_rounded,
            color: const Color(0xFF5B13EC),
            size: 64,
          ),
          const SizedBox(height: 24),
          Text(
            'Your Watchlist is Empty',
            style: GoogleFonts.plusJakartaSans(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Add anime to your watchlist by tapping\nthe bookmark icon on any anime',
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              color: const Color(0xFFA9A9A9),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWatchlistGrid(List watchlist, watchlistNotifier) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.6, // Adjust for poster aspect ratio
          crossAxisSpacing: 12,
          mainAxisSpacing: 16,
        ),
        itemCount: watchlist.length,
        itemBuilder: (context, index) {
          final item = watchlist[index];
          return WatchlistAnimeCard(
            watchlistItem: item,
            onRemove: () => _removeFromWatchlist(item.animeId, watchlistNotifier),
          );
        },
      ),
    );
  }

  void _removeFromWatchlist(String animeId, watchlistNotifier) {
    watchlistNotifier.removeAnime(animeId);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Removed from watchlist',
          style: GoogleFonts.plusJakartaSans(
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
        backgroundColor: const Color(0xFF5B13EC),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}