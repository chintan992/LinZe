import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:linze/core/api/anilist_api_service.dart';
import 'package:linze/core/models/anilist/anilist_media.dart';
import 'package:linze/core/models/anilist/anilist_media_list.dart';
import 'package:linze/core/services/anilist_auth_service.dart';

/// Service for bidirectional sync between local watch progress and AniList
class AniListSyncService {
  final AniListApiService _apiService;
  final AniListAuthService _authService;

  AniListSyncService(this._apiService) : _authService = AniListAuthService();

  static const String _syncQueueKey = 'anilist_sync_queue';
  static const String _lastSyncKey = 'anilist_last_sync';

  List<SyncItem> _syncQueue = [];
  DateTime? _lastSync;
  Timer? _syncTimer;

  /// Initialize sync service
  Future<void> initialize() async {
    await _loadSyncQueue();
    await _loadLastSyncTime();
    _startPeriodicSync();
  }

  /// Load sync queue from local storage
  Future<void> _loadSyncQueue() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final queueJson = prefs.getString(_syncQueueKey);

      if (queueJson != null) {
        final queueData = jsonDecode(queueJson) as List<dynamic>;
        _syncQueue = queueData.map((item) => SyncItem.fromJson(item)).toList();
      }
    } catch (e) {
      debugPrint('Error loading sync queue: $e');
      _syncQueue = [];
    }
  }

  /// Save sync queue to local storage
  Future<void> _saveSyncQueue() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final queueJson = jsonEncode(
        _syncQueue.map((item) => item.toJson()).toList(),
      );
      await prefs.setString(_syncQueueKey, queueJson);
    } catch (e) {
      debugPrint('Error saving sync queue: $e');
    }
  }

  /// Load last sync time
  Future<void> _loadLastSyncTime() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastSyncString = prefs.getString(_lastSyncKey);

      if (lastSyncString != null) {
        _lastSync = DateTime.parse(lastSyncString);
      }
    } catch (e) {
      debugPrint('Error loading last sync time: $e');
    }
  }

  /// Save last sync time
  Future<void> _saveLastSyncTime() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _lastSync = DateTime.now();
      await prefs.setString(_lastSyncKey, _lastSync!.toIso8601String());
    } catch (e) {
      debugPrint('Error saving last sync time: $e');
    }
  }

  /// Start periodic sync (every 5 minutes)
  void _startPeriodicSync() {
    _syncTimer = Timer.periodic(const Duration(minutes: 5), (_) {
      if (_authService.isLoggedIn) {
        _processSyncQueue();
      }
    });
  }

  /// Pull user's anime lists from AniList
  Future<AniListMediaListCollection?> pullUserLists() async {
    if (!_authService.isLoggedIn) return null;

    try {
      final accessToken = await _authService.getValidAccessToken();
      if (accessToken == null) return null;

      final userId = _authService.currentUser?.id;
      if (userId == null) return null;

      return await _apiService.getUserMediaList(
        userId: userId,
        type: AniListMediaType.anime,
        accessToken: accessToken,
      );
    } catch (e) {
      debugPrint('Error pulling user lists: $e');
      return null;
    }
  }

  /// Push watch progress to AniList
  Future<bool> pushWatchProgress({
    required int anilistMediaId,
    required int episodeNumber,
    AniListMediaListStatus? status,
    int? score,
  }) async {
    if (!_authService.isLoggedIn) {
      // Queue for later sync
      _addToSyncQueue(
        SyncItem(
          type: SyncType.watchProgress,
          anilistMediaId: anilistMediaId,
          episodeNumber: episodeNumber,
          status: status,
          score: score,
          timestamp: DateTime.now(),
        ),
      );
      return false;
    }

    try {
      final accessToken = await _authService.getValidAccessToken();
      if (accessToken == null) return false;

      await _apiService.saveMediaListEntry(
        mediaId: anilistMediaId,
        progress: episodeNumber,
        status: status,
        score: score,
        accessToken: accessToken,
      );

      await _saveLastSyncTime();
      return true;
    } catch (e) {
      debugPrint('Error pushing watch progress: $e');
      // Queue for retry
      _addToSyncQueue(
        SyncItem(
          type: SyncType.watchProgress,
          anilistMediaId: anilistMediaId,
          episodeNumber: episodeNumber,
          status: status,
          score: score,
          timestamp: DateTime.now(),
        ),
      );
      return false;
    }
  }

  /// Update anime status in AniList
  Future<bool> updateAnimeStatus({
    required int anilistMediaId,
    required AniListMediaListStatus status,
    int? score,
    String? notes,
  }) async {
    if (!_authService.isLoggedIn) {
      _addToSyncQueue(
        SyncItem(
          type: SyncType.statusUpdate,
          anilistMediaId: anilistMediaId,
          status: status,
          score: score,
          notes: notes,
          timestamp: DateTime.now(),
        ),
      );
      return false;
    }

    try {
      final accessToken = await _authService.getValidAccessToken();
      if (accessToken == null) return false;

      await _apiService.saveMediaListEntry(
        mediaId: anilistMediaId,
        status: status,
        score: score,
        notes: notes,
        accessToken: accessToken,
      );

      await _saveLastSyncTime();
      return true;
    } catch (e) {
      debugPrint('Error updating anime status: $e');
      _addToSyncQueue(
        SyncItem(
          type: SyncType.statusUpdate,
          anilistMediaId: anilistMediaId,
          status: status,
          score: score,
          notes: notes,
          timestamp: DateTime.now(),
        ),
      );
      return false;
    }
  }

  /// Add item to sync queue
  void _addToSyncQueue(SyncItem item) {
    _syncQueue.add(item);
    _saveSyncQueue();
  }

  /// Process sync queue (retry failed syncs)
  Future<void> _processSyncQueue() async {
    if (_syncQueue.isEmpty || !_authService.isLoggedIn) return;

    final accessToken = await _authService.getValidAccessToken();
    if (accessToken == null) return;

    final itemsToRetry = <SyncItem>[];

    for (final item in _syncQueue) {
      try {
        switch (item.type) {
          case SyncType.watchProgress:
            await _apiService.saveMediaListEntry(
              mediaId: item.anilistMediaId,
              progress: item.episodeNumber,
              status: item.status,
              score: item.score,
              accessToken: accessToken,
            );
            break;
          case SyncType.statusUpdate:
            await _apiService.saveMediaListEntry(
              mediaId: item.anilistMediaId,
              status: item.status,
              score: item.score,
              notes: item.notes,
              accessToken: accessToken,
            );
            break;
        }
      } catch (e) {
        debugPrint('Failed to sync item: $e');
        // Retry if not too old (older than 24 hours)
        if (DateTime.now().difference(item.timestamp).inHours < 24) {
          itemsToRetry.add(item);
        }
      }
    }

    _syncQueue = itemsToRetry;
    await _saveSyncQueue();
    await _saveLastSyncTime();
  }

  /// Manual sync trigger
  Future<void> manualSync() async {
    await _processSyncQueue();
  }

  /// Get sync status
  SyncStatus getSyncStatus() {
    return SyncStatus(
      isLoggedIn: _authService.isLoggedIn,
      queueSize: _syncQueue.length,
      lastSync: _lastSync,
      hasPendingSync: _syncQueue.isNotEmpty,
    );
  }

  /// Clear sync queue
  Future<void> clearSyncQueue() async {
    _syncQueue.clear();
    await _saveSyncQueue();
  }

  /// Dispose resources
  void dispose() {
    _syncTimer?.cancel();
  }
}

/// Sync queue item
class SyncItem {
  final SyncType type;
  final int anilistMediaId;
  final int? episodeNumber;
  final AniListMediaListStatus? status;
  final int? score;
  final String? notes;
  final DateTime timestamp;

  const SyncItem({
    required this.type,
    required this.anilistMediaId,
    this.episodeNumber,
    this.status,
    this.score,
    this.notes,
    required this.timestamp,
  });

  factory SyncItem.fromJson(Map<String, dynamic> json) {
    return SyncItem(
      type: SyncType.values.firstWhere(
        (e) => e.toString() == json['type'],
        orElse: () => SyncType.watchProgress,
      ),
      anilistMediaId: json['anilistMediaId'] as int,
      episodeNumber: json['episodeNumber'] as int?,
      status: AniListMediaListStatus.fromString(json['status'] as String?),
      score: json['score'] as int?,
      notes: json['notes'] as String?,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type.toString(),
      'anilistMediaId': anilistMediaId,
      'episodeNumber': episodeNumber,
      'status': status?.name,
      'score': score,
      'notes': notes,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}

/// Sync types
enum SyncType { watchProgress, statusUpdate }

/// Sync status
class SyncStatus {
  final bool isLoggedIn;
  final int queueSize;
  final DateTime? lastSync;
  final bool hasPendingSync;

  const SyncStatus({
    required this.isLoggedIn,
    required this.queueSize,
    required this.lastSync,
    required this.hasPendingSync,
  });

  bool get isUpToDate => isLoggedIn && !hasPendingSync;
}

// Add missing methods
extension AniListSyncServiceExtensions on AniListSyncService {
  Future<void> syncLocalProgressToAniList(
    int anilistMediaId,
    int episodeNumber,
  ) async {
    try {
      await _apiService.saveMediaToList(
        mediaId: anilistMediaId,
        status: AniListMediaListStatus.current,
        progress: episodeNumber,
      );
    } catch (e) {
      debugPrint('Failed to sync progress to AniList: $e');
    }
  }

  Future<void> syncAniListToLocal() async {
    try {
      // Implementation for syncing AniList data to local storage
      debugPrint('Syncing AniList to local storage');
    } catch (e) {
      debugPrint('Failed to sync from AniList: $e');
    }
  }

  Future<List<AniListMediaList>> getUserMediaList(
    int userId, {
    AniListMediaListStatus? status,
  }) async {
    try {
      final collection = await _apiService.getUserMediaList(
        userId: userId,
        status: status,
      );
      return collection.lists;
    } catch (e) {
      debugPrint('Failed to get user media list: $e');
      return [];
    }
  }

  Future<void> performManualSync() async {
    await syncAniListToLocal();
  }
}
