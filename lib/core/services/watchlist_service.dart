import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:linze/core/models/anime_model.dart';
import 'package:linze/core/models/watchlist_item.dart';

class WatchlistService {
  static const String _watchlistKey = 'watchlist_items';
  
  static WatchlistService? _instance;
  static WatchlistService get instance {
    _instance ??= WatchlistService._();
    return _instance!;
  }
  
  WatchlistService._();

  /// Add anime to watchlist
  Future<void> addToWatchlist(Anime anime) async {
    try {
      final watchlistItems = await getWatchlist();
      
      // Check if anime is already in watchlist
      final existingIndex = watchlistItems.indexWhere((item) => item.animeId == anime.id);
      
      final watchlistItem = WatchlistItem(
        animeId: anime.id,
        title: anime.title,
        poster: anime.poster,
        dateAdded: DateTime.now(),
      );
      
      if (existingIndex != -1) {
        // Update existing item (replace with new date)
        watchlistItems[existingIndex] = watchlistItem;
      } else {
        // Add new item
        watchlistItems.add(watchlistItem);
      }
      
      await _saveWatchlist(watchlistItems);
    } catch (e) {
      debugPrint('Error adding to watchlist: $e');
    }
  }

  /// Remove anime from watchlist
  Future<void> removeFromWatchlist(String animeId) async {
    try {
      final watchlistItems = await getWatchlist();
      
      watchlistItems.removeWhere((item) => item.animeId == animeId);
      
      await _saveWatchlist(watchlistItems);
    } catch (e) {
      debugPrint('Error removing from watchlist: $e');
    }
  }

  /// Check if anime is in watchlist
  Future<bool> isInWatchlist(String animeId) async {
    try {
      final watchlistItems = await getWatchlist();
      return watchlistItems.any((item) => item.animeId == animeId);
    } catch (e) {
      debugPrint('Error checking watchlist status: $e');
      return false;
    }
  }

  /// Get all watchlist items
  Future<List<WatchlistItem>> getWatchlist() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final watchlistData = prefs.getString(_watchlistKey);
      
      if (watchlistData != null) {
        final List<dynamic> jsonList = jsonDecode(watchlistData);
        final watchlistItems = jsonList
            .map((json) => WatchlistItem.fromJson(json as Map<String, dynamic>))
            .toList();
        
        // Sort by date added (newest first)
        watchlistItems.sort((a, b) => b.dateAdded.compareTo(a.dateAdded));
        
        return watchlistItems;
      }
      
      return [];
    } catch (e) {
      debugPrint('Error getting watchlist: $e');
      return [];
    }
  }

  /// Clear entire watchlist
  Future<void> clearWatchlist() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_watchlistKey);
    } catch (e) {
      debugPrint('Error clearing watchlist: $e');
    }
  }

  /// Get watchlist count
  Future<int> getWatchlistCount() async {
    final watchlist = await getWatchlist();
    return watchlist.length;
  }

  /// Export watchlist data (for backup)
  Future<String> exportWatchlist() async {
    try {
      final watchlistItems = await getWatchlist();
      final jsonList = watchlistItems.map((item) => item.toJson()).toList();
      return jsonEncode(jsonList);
    } catch (e) {
      debugPrint('Error exporting watchlist: $e');
      return '[]';
    }
  }

  /// Import watchlist data (for restore)
  Future<void> importWatchlist(String watchlistData) async {
    try {
      final List<dynamic> jsonList = jsonDecode(watchlistData);
      final watchlistItems = jsonList
          .map((json) => WatchlistItem.fromJson(json as Map<String, dynamic>))
          .toList();
      
      await _saveWatchlist(watchlistItems);
    } catch (e) {
      debugPrint('Error importing watchlist: $e');
    }
  }

  /// Private method to save watchlist to SharedPreferences
  Future<void> _saveWatchlist(List<WatchlistItem> watchlistItems) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = watchlistItems.map((item) => item.toJson()).toList();
    await prefs.setString(_watchlistKey, jsonEncode(jsonList));
  }
}
