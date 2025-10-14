import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:linze/core/models/anime_model.dart';
import 'package:linze/core/models/watchlist_item.dart';
import 'package:linze/core/services/watchlist_service.dart';

// Service provider
final watchlistServiceProvider = Provider<WatchlistService>((ref) {
  return WatchlistService.instance;
});

// Notifier for managing watchlist state
class WatchlistNotifier extends StateNotifier<List<WatchlistItem>> {
  final WatchlistService _service;

  WatchlistNotifier(this._service) : super([]);

  /// Load watchlist from storage
  Future<void> loadWatchlist() async {
    try {
      final watchlistItems = await _service.getWatchlist();
      state = watchlistItems;
    } catch (e) {
      debugPrint('Error loading watchlist: $e');
    }
  }

  /// Add anime to watchlist
  Future<void> addAnime(Anime anime) async {
    try {
      await _service.addToWatchlist(anime);
      await loadWatchlist(); // Refresh state
    } catch (e) {
      debugPrint('Error adding anime to watchlist: $e');
    }
  }

  /// Remove anime from watchlist
  Future<void> removeAnime(String animeId) async {
    try {
      await _service.removeFromWatchlist(animeId);
      await loadWatchlist(); // Refresh state
    } catch (e) {
      debugPrint('Error removing anime from watchlist: $e');
    }
  }

  /// Toggle anime in watchlist (add if not present, remove if present)
  Future<void> toggleWatchlist(Anime anime) async {
    try {
      final isInWatchlist = await _service.isInWatchlist(anime.id);
      if (isInWatchlist) {
        await removeAnime(anime.id);
      } else {
        await addAnime(anime);
      }
    } catch (e) {
      debugPrint('Error toggling watchlist: $e');
    }
  }

  /// Check if anime is in watchlist
  Future<bool> isInWatchlist(String animeId) async {
    return await _service.isInWatchlist(animeId);
  }

  /// Get watchlist count
  Future<int> getWatchlistCount() async {
    return await _service.getWatchlistCount();
  }

  /// Clear entire watchlist
  Future<void> clearWatchlist() async {
    try {
      await _service.clearWatchlist();
      state = [];
    } catch (e) {
      debugPrint('Error clearing watchlist: $e');
    }
  }

  /// Export watchlist
  Future<String> exportWatchlist() async {
    return await _service.exportWatchlist();
  }

  /// Import watchlist
  Future<void> importWatchlist(String watchlistData) async {
    try {
      await _service.importWatchlist(watchlistData);
      await loadWatchlist(); // Refresh state
    } catch (e) {
      debugPrint('Error importing watchlist: $e');
    }
  }
}

// State notifier provider
final watchlistNotifierProvider = StateNotifierProvider<WatchlistNotifier, List<WatchlistItem>>((ref) {
  final service = ref.read(watchlistServiceProvider);
  return WatchlistNotifier(service);
});

// Computed providers
final watchlistCountProvider = Provider<int>((ref) {
  final watchlist = ref.watch(watchlistNotifierProvider);
  return watchlist.length;
});

final isAnimeInWatchlistProvider = FutureProvider.family<bool, String>((ref, animeId) async {
  final notifier = ref.read(watchlistNotifierProvider.notifier);
  return await notifier.isInWatchlist(animeId);
});

final watchlistEmptyProvider = Provider<bool>((ref) {
  final watchlist = ref.watch(watchlistNotifierProvider);
  return watchlist.isEmpty;
});
