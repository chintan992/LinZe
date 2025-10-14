import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:linze/core/models/watch_progress.dart';
import 'package:linze/core/services/anilist_sync_service.dart';
import 'package:linze/core/services/anime_id_mapper.dart';

class WatchProgressService {
  static const String _progressKey = 'watch_progress';
  static const String _statsKey = 'watch_stats';
  
  static WatchProgressService? _instance;
  static WatchProgressService get instance {
    _instance ??= WatchProgressService._();
    return _instance!;
  }
  
  WatchProgressService._();

  // AniList sync dependencies (will be injected)
  AniListSyncService? _anilistSyncService;
  AnimeIdMapper? _animeIdMapper;

  /// Initialize with AniList sync dependencies
  void initializeWithAniList({
    required AniListSyncService anilistSyncService,
    required AnimeIdMapper animeIdMapper,
  }) {
    _anilistSyncService = anilistSyncService;
    _animeIdMapper = animeIdMapper;
  }

  /// Save watch progress for an episode
  Future<void> saveProgress(WatchProgress progress) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final progressMap = await _getAllProgress();
      
      // Update or add progress
      progressMap[progress.episodeId] = progress.toJson();
      
      await prefs.setString(_progressKey, jsonEncode(progressMap));
      
      // Update stats for this anime
      await _updateAnimeStats(progress.animeId);
      
      // Sync with AniList if available
      await _syncProgressToAniList(progress);
    } catch (e) {
      debugPrint('Error saving watch progress: $e');
    }
  }

  /// Get watch progress for a specific episode
  Future<WatchProgress?> getProgress(String episodeId) async {
    try {
      final progressMap = await _getAllProgress();
      final progressData = progressMap[episodeId];
      
      if (progressData != null) {
        return WatchProgress.fromJson(progressData);
      }
      return null;
    } catch (e) {
      debugPrint('Error getting watch progress: $e');
      return null;
    }
  }

  /// Get all progress for an anime
  Future<List<WatchProgress>> getAnimeProgress(String animeId) async {
    try {
      final progressMap = await _getAllProgress();
      final progressList = <WatchProgress>[];
      
      for (final progressData in progressMap.values) {
        final progress = WatchProgress.fromJson(progressData);
        if (progress.animeId == animeId) {
          progressList.add(progress);
        }
      }
      
      // Sort by episode number (assuming episodeId contains episode number)
      progressList.sort((a, b) {
        final aNum = int.tryParse(a.episodeId.replaceAll(RegExp(r'[^\d]'), '')) ?? 0;
        final bNum = int.tryParse(b.episodeId.replaceAll(RegExp(r'[^\d]'), '')) ?? 0;
        return aNum.compareTo(bNum);
      });
      
      return progressList;
    } catch (e) {
      debugPrint('Error getting anime progress: $e');
      return [];
    }
  }

  /// Get watch status for an episode
  Future<WatchStatus> getWatchStatus(String episodeId) async {
    final progress = await getProgress(episodeId);
    if (progress == null) return WatchStatus.notWatched;
    if (progress.isCompleted) return WatchStatus.completed;
    return WatchStatus.inProgress;
  }

  /// Get watch progress stats for an anime
  Future<WatchProgressStats?> getAnimeStats(String animeId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final statsMap = prefs.getString(_statsKey);
      
      if (statsMap != null) {
        final statsData = jsonDecode(statsMap) as Map<String, dynamic>;
        final animeStats = statsData[animeId];
        
        if (animeStats != null) {
          return WatchProgressStats.fromJson(animeStats);
        }
      }
      
      // If no stats found, calculate from progress data
      final progressList = await getAnimeProgress(animeId);
      if (progressList.isNotEmpty) {
        // We need total episodes count - this should be passed from the anime data
        // For now, we'll estimate from progress list length
        final totalEpisodes = progressList.length;
        return WatchProgressStats.fromProgressList(animeId, progressList, totalEpisodes);
      }
      
      return null;
    } catch (e) {
      debugPrint('Error getting anime stats: $e');
      return null;
    }
  }

  /// Update progress from video player
  Future<void> updateProgressFromVideo({
    required String animeId,
    required String episodeId,
    required Duration currentPosition,
    required Duration episodeDuration,
    bool markAsCompleted = false,
  }) async {
    final progress = (currentPosition.inSeconds / episodeDuration.inSeconds).clamp(0.0, 1.0);
    final isCompleted = markAsCompleted || progress >= 0.9; // Consider 90% as completed
    
    final watchProgress = WatchProgress(
      animeId: animeId,
      episodeId: episodeId,
      progress: progress,
      lastWatched: DateTime.now(),
      totalWatchTime: currentPosition,
      isCompleted: isCompleted,
      episodeDuration: episodeDuration,
    );
    
    await saveProgress(watchProgress);
    
    // If episode is completed, sync milestone to AniList
    if (isCompleted) {
      await _syncEpisodeCompletionToAniList(animeId, episodeId);
    }
  }

  /// Mark episode as completed
  Future<void> markEpisodeCompleted(String animeId, String episodeId, Duration episodeDuration) async {
    final progress = WatchProgress(
      animeId: animeId,
      episodeId: episodeId,
      progress: 1.0,
      lastWatched: DateTime.now(),
      totalWatchTime: episodeDuration,
      isCompleted: true,
      episodeDuration: episodeDuration,
    );
    
    await saveProgress(progress);
    
    // Sync episode completion to AniList
    await _syncEpisodeCompletionToAniList(animeId, episodeId);
  }

  /// Mark episode as not watched (reset progress)
  Future<void> markEpisodeNotWatched(String episodeId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final progressMap = await _getAllProgress();
      
      progressMap.remove(episodeId);
      await prefs.setString(_progressKey, jsonEncode(progressMap));
    } catch (e) {
      debugPrint('Error marking episode as not watched: $e');
    }
  }

  /// Clear all progress for an anime
  Future<void> clearAnimeProgress(String animeId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final progressMap = await _getAllProgress();
      
      // Remove all episodes for this anime
      progressMap.removeWhere((key, value) {
        final progress = WatchProgress.fromJson(value);
        return progress.animeId == animeId;
      });
      
      await prefs.setString(_progressKey, jsonEncode(progressMap));
      
      // Remove stats
      final statsMap = prefs.getString(_statsKey);
      if (statsMap != null) {
        final statsData = jsonDecode(statsMap) as Map<String, dynamic>;
        statsData.remove(animeId);
        await prefs.setString(_statsKey, jsonEncode(statsData));
      }
    } catch (e) {
      debugPrint('Error clearing anime progress: $e');
    }
  }

  /// Get all progress data
  Future<Map<String, dynamic>> _getAllProgress() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final progressData = prefs.getString(_progressKey);
      
      if (progressData != null) {
        return jsonDecode(progressData) as Map<String, dynamic>;
      }
      return {};
    } catch (e) {
      debugPrint('Error getting all progress: $e');
      return {};
    }
  }

  /// Update stats for an anime
  Future<void> _updateAnimeStats(String animeId) async {
    try {
      final progressList = await getAnimeProgress(animeId);
      if (progressList.isEmpty) return;
      
      final stats = WatchProgressStats.fromProgressList(
        animeId,
        progressList,
        progressList.length, // This should ideally come from anime data
      );
      
      final prefs = await SharedPreferences.getInstance();
      final statsMap = prefs.getString(_statsKey);
      final statsData = statsMap != null 
          ? jsonDecode(statsMap) as Map<String, dynamic>
          : <String, dynamic>{};
      
      statsData[animeId] = stats.toJson();
      await prefs.setString(_statsKey, jsonEncode(statsData));
    } catch (e) {
      debugPrint('Error updating anime stats: $e');
    }
  }

  /// Get recently watched anime (for continue watching)
  Future<List<WatchProgress>> getRecentlyWatched({int limit = 10}) async {
    try {
      final progressMap = await _getAllProgress();
      final progressList = <WatchProgress>[];
      
      for (final progressData in progressMap.values) {
        progressList.add(WatchProgress.fromJson(progressData));
      }
      
      // Sort by last watched date
      progressList.sort((a, b) => b.lastWatched.compareTo(a.lastWatched));
      
      // Filter out completed episodes for "continue watching"
      final recentProgress = progressList
          .where((p) => !p.isCompleted)
          .take(limit)
          .toList();
      
      return recentProgress;
    } catch (e) {
      debugPrint('Error getting recently watched: $e');
      return [];
    }
  }

  /// Export progress data (for backup)
  Future<String> exportProgress() async {
    try {
      final progressMap = await _getAllProgress();
      return jsonEncode(progressMap);
    } catch (e) {
      debugPrint('Error exporting progress: $e');
      return '{}';
    }
  }

  /// Import progress data (for restore)
  Future<void> importProgress(String progressData) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final progressMap = jsonDecode(progressData) as Map<String, dynamic>;
      await prefs.setString(_progressKey, jsonEncode(progressMap));
    } catch (e) {
      debugPrint('Error importing progress: $e');
    }
  }

  /// Sync progress to AniList
  Future<void> _syncProgressToAniList(WatchProgress progress) async {
    if (_anilistSyncService == null || _animeIdMapper == null) return;

    try {
      // Find AniList media ID for this anime
      final anilistMediaId = await _findAniListMediaId(progress.animeId);
      if (anilistMediaId == null) return;

      // Calculate current episode number from progress
      final episodeNumber = _extractEpisodeNumber(progress.episodeId);
      if (episodeNumber == null) return;

      // Sync progress to AniList
      await _anilistSyncService!.syncLocalProgressToAniList(anilistMediaId, episodeNumber);
      
      debugPrint('Synced progress to AniList: Episode $episodeNumber for media $anilistMediaId');
    } catch (e) {
      debugPrint('Failed to sync progress to AniList: $e');
    }
  }

  /// Sync episode completion milestone to AniList
  Future<void> _syncEpisodeCompletionToAniList(String animeId, String episodeId) async {
    if (_anilistSyncService == null || _animeIdMapper == null) return;

    try {
      // Find AniList media ID for this anime
      final anilistMediaId = await _findAniListMediaId(animeId);
      if (anilistMediaId == null) return;

      // Calculate current episode number from progress
      final episodeNumber = _extractEpisodeNumber(episodeId);
      if (episodeNumber == null) return;

      // Sync progress to AniList
      await _anilistSyncService!.syncLocalProgressToAniList(anilistMediaId, episodeNumber);
      
      debugPrint('Synced episode completion to AniList: Episode $episodeNumber for media $anilistMediaId');
    } catch (e) {
      debugPrint('Failed to sync episode completion to AniList: $e');
    }
  }

  /// Find AniList media ID for a given anime ID
  Future<int?> _findAniListMediaId(String animeId) async {
    if (_animeIdMapper == null) return null;

    try {
      // First try to get existing mapping
      final anilistId = _animeIdMapper!.getStreamingId(int.tryParse(animeId) ?? 0);
      if (anilistId != null) {
        return int.tryParse(anilistId);
      }

      // If no mapping exists, we would need to search AniList
      // This is a simplified implementation - in practice, you'd want to
      // cache anime metadata or search by title
      return null;
    } catch (e) {
      debugPrint('Failed to find AniList media ID: $e');
      return null;
    }
  }

  /// Extract episode number from episode ID
  int? _extractEpisodeNumber(String episodeId) {
    try {
      // Try to extract episode number from episode ID
      // This is a simplified implementation - adjust based on your episode ID format
      final regex = RegExp(r'episode[_-]?(\d+)', caseSensitive: false);
      final match = regex.firstMatch(episodeId);
      if (match != null) {
        return int.tryParse(match.group(1) ?? '');
      }

      // Fallback: try to find any number in the episode ID
      final numbers = RegExp(r'\d+').allMatches(episodeId);
      if (numbers.isNotEmpty) {
        return int.tryParse(numbers.last.group(0) ?? '');
      }

      return null;
    } catch (e) {
      debugPrint('Failed to extract episode number: $e');
      return null;
    }
  }

  /// Sync all progress from AniList to local storage
  Future<void> syncFromAniList() async {
    if (_anilistSyncService == null) return;

    try {
      await _anilistSyncService!.syncAniListToLocal();
      debugPrint('Synced progress from AniList to local storage');
    } catch (e) {
      debugPrint('Failed to sync from AniList: $e');
    }
  }

  /// Get anime progress summary for AniList sync
  Future<Map<String, int>> getAnimeProgressSummary(String animeId) async {
    try {
      final progressList = await getAnimeProgress(animeId);
      final completedEpisodes = progressList.where((p) => p.isCompleted).length;
      final totalEpisodes = progressList.length;
      final lastWatchedEpisode = progressList
          .where((p) => !p.isCompleted && p.progress > 0)
          .isNotEmpty
          ? progressList
              .where((p) => !p.isCompleted && p.progress > 0)
              .map((p) => _extractEpisodeNumber(p.episodeId) ?? 0)
              .reduce((a, b) => a > b ? a : b)
          : 0;

      return {
        'completedEpisodes': completedEpisodes,
        'totalEpisodes': totalEpisodes,
        'lastWatchedEpisode': lastWatchedEpisode,
      };
    } catch (e) {
      debugPrint('Failed to get anime progress summary: $e');
      return {
        'completedEpisodes': 0,
        'totalEpisodes': 0,
        'lastWatchedEpisode': 0,
      };
    }
  }
}
