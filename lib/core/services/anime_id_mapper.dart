import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:linze/core/models/anilist/anilist_media.dart';
import 'package:linze/core/api/streaming_api_service.dart';

/// Service to map AniList anime IDs/titles to streaming API IDs
/// This is critical for linking AniList metadata to streaming sources
class AnimeIdMapper {
  static const String _mappingsKey = 'anime_id_mappings';
  static const String _lastSyncKey = 'anime_mappings_last_sync';

  final StreamingApiService _streamingApi = StreamingApiService();

  Map<String, String> _mappings = {};
  DateTime? _lastSync;

  /// Initialize the mapper and load cached mappings
  Future<void> initialize() async {
    await _loadCachedMappings();
  }

  /// Load cached mappings from local storage
  Future<void> _loadCachedMappings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final mappingsJson = prefs.getString(_mappingsKey);
      final lastSyncString = prefs.getString(_lastSyncKey);

      if (mappingsJson != null) {
        final mappingsData = jsonDecode(mappingsJson) as Map<String, dynamic>;
        _mappings = Map<String, String>.from(mappingsData);
      }

      if (lastSyncString != null) {
        _lastSync = DateTime.parse(lastSyncString);
      }
    } catch (e) {
      debugPrint('Error loading cached mappings: $e');
      _mappings = {};
    }
  }

  /// Save mappings to local storage
  Future<void> _saveMappings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_mappingsKey, jsonEncode(_mappings));
      await prefs.setString(_lastSyncKey, DateTime.now().toIso8601String());
      _lastSync = DateTime.now();
    } catch (e) {
      debugPrint('Error saving mappings: $e');
    }
  }

  /// Map AniList anime to streaming API ID
  /// Returns null if no mapping found
  Future<String?> mapToStreamingId(AniListMedia anilistAnime) async {
    // First check if we have a cached mapping
    final cachedId = _mappings[anilistAnime.id.toString()];
    if (cachedId != null) {
      return cachedId;
    }

    // Try to find a match by searching the streaming API
    final streamingId = await _findStreamingId(anilistAnime);

    if (streamingId != null) {
      // Cache the mapping
      _mappings[anilistAnime.id.toString()] = streamingId;
      await _saveMappings();
    }

    return streamingId;
  }

  /// Find streaming ID by searching the streaming API
  Future<String?> _findStreamingId(AniListMedia anilistAnime) async {
    try {
      // Try different title variations
      final searchTitles = _generateSearchTitles(anilistAnime);

      for (final title in searchTitles) {
        final results = await _streamingApi.searchAnimeForStreaming(title);

        for (final result in results) {
          if (_isMatch(anilistAnime, result)) {
            return result.id;
          }
        }
      }
    } catch (e) {
      debugPrint('Error finding streaming ID: $e');
    }

    return null;
  }

  /// Generate various title combinations for searching
  List<String> _generateSearchTitles(AniListMedia anilistAnime) {
    final titles = <String>{};

    // Add all available titles
    if (anilistAnime.title?.english != null) {
      titles.add(anilistAnime.title!.english!);
    }
    if (anilistAnime.title?.romaji != null) {
      titles.add(anilistAnime.title!.romaji!);
    }
    if (anilistAnime.title?.native != null) {
      titles.add(anilistAnime.title!.native!);
    }

    // Add variations without common suffixes
    final variations = <String>{};
    for (final title in titles) {
      variations.addAll(_generateTitleVariations(title));
    }

    return variations.toList();
  }

  /// Generate title variations (remove common suffixes, clean up)
  List<String> _generateTitleVariations(String title) {
    final variations = <String>{title};

    // Remove common suffixes
    final suffixesToRemove = [
      ' (TV)',
      ' (Movie)',
      ' (OVA)',
      ' (ONA)',
      ' (Special)',
      ' Season 1',
      ' Season 2',
      ' Season 3',
      ' Season 4',
      ' S1',
      ' S2',
      ' S3',
      ' S4',
    ];

    for (final suffix in suffixesToRemove) {
      if (title.endsWith(suffix)) {
        variations.add(title.substring(0, title.length - suffix.length));
      }
    }

    // Add version without punctuation
    variations.add(title.replaceAll(RegExp(r'[^\w\s]'), ''));

    return variations.toList();
  }

  /// Check if AniList anime matches streaming anime
  bool _isMatch(AniListMedia anilistAnime, StreamingAnime streamingAnime) {
    // Compare titles (case insensitive)
    final anilistTitle = anilistAnime.displayTitle.toLowerCase();
    final streamingTitle = streamingAnime.title.toLowerCase();
    final streamingJapaneseTitle = streamingAnime.japaneseTitle.toLowerCase();

    // Exact title match
    if (anilistTitle == streamingTitle ||
        anilistTitle == streamingJapaneseTitle) {
      return true;
    }

    // Check if titles are similar (fuzzy matching)
    if (_calculateSimilarity(anilistTitle, streamingTitle) > 0.8 ||
        _calculateSimilarity(anilistTitle, streamingJapaneseTitle) > 0.8) {
      return true;
    }

    // Compare episode count if available
    if (anilistAnime.episodes != null &&
        streamingAnime.tvInfo.eps != null &&
        anilistAnime.episodes == streamingAnime.tvInfo.eps) {
      return true;
    }

    return false;
  }

  /// Calculate string similarity (Levenshtein distance)
  double _calculateSimilarity(String s1, String s2) {
    if (s1 == s2) return 1.0;

    final distance = _levenshteinDistance(s1, s2);
    final maxLength = s1.length > s2.length ? s1.length : s2.length;

    if (maxLength == 0) return 1.0;

    return 1.0 - (distance / maxLength);
  }

  /// Calculate Levenshtein distance between two strings
  int _levenshteinDistance(String s1, String s2) {
    final matrix = List.generate(
      s1.length + 1,
      (i) => List.generate(s2.length + 1, (j) => 0),
    );

    for (int i = 0; i <= s1.length; i++) {
      matrix[i][0] = i;
    }

    for (int j = 0; j <= s2.length; j++) {
      matrix[0][j] = j;
    }

    for (int i = 1; i <= s1.length; i++) {
      for (int j = 1; j <= s2.length; j++) {
        final cost = s1[i - 1] == s2[j - 1] ? 0 : 1;
        matrix[i][j] = [
          matrix[i - 1][j] + 1,
          matrix[i][j - 1] + 1,
          matrix[i - 1][j - 1] + cost,
        ].reduce((a, b) => a < b ? a : b);
      }
    }

    return matrix[s1.length][s2.length];
  }

  /// Manually add a mapping (for user overrides)
  Future<void> addManualMapping({
    required int anilistId,
    required String streamingId,
  }) async {
    _mappings[anilistId.toString()] = streamingId;
    await _saveMappings();
  }

  /// Remove a mapping
  Future<void> removeMapping(int anilistId) async {
    _mappings.remove(anilistId.toString());
    await _saveMappings();
  }

  /// Get all cached mappings
  Map<String, String> getAllMappings() {
    return Map.from(_mappings);
  }

  /// Clear all mappings
  Future<void> clearAllMappings() async {
    _mappings.clear();
    await _saveMappings();
  }

  /// Check if mappings need refresh (older than 7 days)
  bool needsRefresh() {
    if (_lastSync == null) return true;
    return DateTime.now().difference(_lastSync!).inDays > 7;
  }

  /// Get mapping statistics
  Map<String, dynamic> getStats() {
    return {
      'totalMappings': _mappings.length,
      'lastSync': _lastSync?.toIso8601String(),
      'needsRefresh': needsRefresh(),
    };
  }

  /// Get streaming API ID for a given AniList Media ID
  String? getStreamingId(int anilistId) {
    return _mappings[anilistId.toString()];
  }
}
