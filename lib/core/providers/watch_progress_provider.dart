import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:linze/core/models/watch_progress.dart';
import 'package:linze/core/services/watch_progress_service.dart';

// Service provider
final watchProgressServiceProvider = Provider<WatchProgressService>((ref) {
  return WatchProgressService.instance;
});

// Progress for specific episode
final episodeProgressProvider = FutureProvider.family<WatchProgress?, String>((ref, episodeId) async {
  final service = ref.read(watchProgressServiceProvider);
  return await service.getProgress(episodeId);
});

// Watch status for specific episode
final episodeWatchStatusProvider = FutureProvider.family<WatchStatus, String>((ref, episodeId) async {
  final service = ref.read(watchProgressServiceProvider);
  return await service.getWatchStatus(episodeId);
});

// All progress for an anime
final animeProgressProvider = FutureProvider.family<List<WatchProgress>, String>((ref, animeId) async {
  final service = ref.read(watchProgressServiceProvider);
  return await service.getAnimeProgress(animeId);
});

// Watch progress stats for an anime
final animeProgressStatsProvider = FutureProvider.family<WatchProgressStats?, String>((ref, animeId) async {
  final service = ref.read(watchProgressServiceProvider);
  return await service.getAnimeStats(animeId);
});

// Recently watched episodes (for continue watching)
final recentlyWatchedProvider = FutureProvider<List<WatchProgress>>((ref) async {
  final service = ref.read(watchProgressServiceProvider);
  return await service.getRecentlyWatched();
});

// Notifier for managing watch progress state
class WatchProgressNotifier extends StateNotifier<Map<String, WatchProgress>> {
  final WatchProgressService _service;

  WatchProgressNotifier(this._service) : super({});

  // Load progress for an anime
  Future<void> loadAnimeProgress(String animeId) async {
    try {
      final progressList = await _service.getAnimeProgress(animeId);
      final progressMap = <String, WatchProgress>{};
      
      for (final progress in progressList) {
        progressMap[progress.episodeId] = progress;
      }
      
      state = {...state, ...progressMap};
    } catch (e) {
      debugPrint('Error loading anime progress: $e');
    }
  }

  // Save progress for an episode
  Future<void> saveProgress(WatchProgress progress) async {
    try {
      await _service.saveProgress(progress);
      state = {...state, progress.episodeId: progress};
    } catch (e) {
      debugPrint('Error saving progress: $e');
    }
  }

  // Update progress from video player
  Future<void> updateProgressFromVideo({
    required String animeId,
    required String episodeId,
    required Duration currentPosition,
    required Duration episodeDuration,
    bool markAsCompleted = false,
  }) async {
    try {
      await _service.updateProgressFromVideo(
        animeId: animeId,
        episodeId: episodeId,
        currentPosition: currentPosition,
        episodeDuration: episodeDuration,
        markAsCompleted: markAsCompleted,
      );
      
      // Refresh the progress for this episode
      final updatedProgress = await _service.getProgress(episodeId);
      if (updatedProgress != null) {
        state = {...state, episodeId: updatedProgress};
      }
    } catch (e) {
      debugPrint('Error updating progress from video: $e');
    }
  }

  // Mark episode as completed
  Future<void> markEpisodeCompleted(String animeId, String episodeId, Duration episodeDuration) async {
    try {
      await _service.markEpisodeCompleted(animeId, episodeId, episodeDuration);
      
      // Update state
      final progress = WatchProgress(
        animeId: animeId,
        episodeId: episodeId,
        progress: 1.0,
        lastWatched: DateTime.now(),
        totalWatchTime: episodeDuration,
        isCompleted: true,
        episodeDuration: episodeDuration,
      );
      
      state = {...state, episodeId: progress};
    } catch (e) {
      debugPrint('Error marking episode as completed: $e');
    }
  }

  // Mark episode as not watched
  Future<void> markEpisodeNotWatched(String episodeId) async {
    try {
      await _service.markEpisodeNotWatched(episodeId);
      final newState = Map<String, WatchProgress>.from(state);
      newState.remove(episodeId);
      state = newState;
    } catch (e) {
      debugPrint('Error marking episode as not watched: $e');
    }
  }

  // Clear all progress for an anime
  Future<void> clearAnimeProgress(String animeId) async {
    try {
      await _service.clearAnimeProgress(animeId);
      
      // Remove all episodes for this anime from state
      final newState = <String, WatchProgress>{};
      for (final entry in state.entries) {
        if (entry.value.animeId != animeId) {
          newState[entry.key] = entry.value;
        }
      }
      state = newState;
    } catch (e) {
      debugPrint('Error clearing anime progress: $e');
    }
  }

  // Get progress for specific episode from state
  WatchProgress? getProgress(String episodeId) {
    return state[episodeId];
  }

  // Get watch status for specific episode from state
  WatchStatus getWatchStatus(String episodeId) {
    final progress = state[episodeId];
    if (progress == null) return WatchStatus.notWatched;
    if (progress.isCompleted) return WatchStatus.completed;
    return WatchStatus.inProgress;
  }

  // Get all progress for an anime from state
  List<WatchProgress> getAnimeProgress(String animeId) {
    return state.values
        .where((progress) => progress.animeId == animeId)
        .toList()
      ..sort((a, b) => a.episodeId.compareTo(b.episodeId));
  }

  // Calculate stats for an anime from state
  WatchProgressStats? calculateAnimeStats(String animeId, int totalEpisodes) {
    final progressList = getAnimeProgress(animeId);
    if (progressList.isEmpty) return null;
    
    return WatchProgressStats.fromProgressList(animeId, progressList, totalEpisodes);
  }
}

// State notifier provider
final watchProgressNotifierProvider = StateNotifierProvider<WatchProgressNotifier, Map<String, WatchProgress>>((ref) {
  final service = ref.read(watchProgressServiceProvider);
  return WatchProgressNotifier(service);
});

// Computed providers that use the state notifier
final computedEpisodeProgressProvider = Provider.family<WatchProgress?, String>((ref, episodeId) {
  final notifier = ref.read(watchProgressNotifierProvider.notifier);
  return notifier.getProgress(episodeId);
});

final computedEpisodeWatchStatusProvider = Provider.family<WatchStatus, String>((ref, episodeId) {
  final notifier = ref.read(watchProgressNotifierProvider.notifier);
  return notifier.getWatchStatus(episodeId);
});

final computedAnimeProgressProvider = Provider.family<List<WatchProgress>, String>((ref, animeId) {
  final notifier = ref.read(watchProgressNotifierProvider.notifier);
  return notifier.getAnimeProgress(animeId);
});

final computedAnimeProgressStatsProvider = Provider.family<WatchProgressStats?, (String, int)>((ref, params) {
  final animeId = params.$1;
  final totalEpisodes = params.$2;
  final notifier = ref.read(watchProgressNotifierProvider.notifier);
  return notifier.calculateAnimeStats(animeId, totalEpisodes);
});
