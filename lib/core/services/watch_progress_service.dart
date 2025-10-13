import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:linze/core/models/watch_progress.dart';

class WatchProgressService {
  static const String _progressKey = 'watch_progress';
  static const String _statsKey = 'watch_stats';
  
  static WatchProgressService? _instance;
  static WatchProgressService get instance {
    _instance ??= WatchProgressService._();
    return _instance!;
  }
  
  WatchProgressService._();

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
    
    final watchProgress = WatchProgress(
      animeId: animeId,
      episodeId: episodeId,
      progress: progress,
      lastWatched: DateTime.now(),
      totalWatchTime: currentPosition,
      isCompleted: markAsCompleted || progress >= 0.9, // Consider 90% as completed
      episodeDuration: episodeDuration,
    );
    
    await saveProgress(watchProgress);
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
}
