import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class VideoHistoryService {
  static const String _historyKey = 'video_history';

  // Save playback position for an episode
  static Future<void> savePlaybackPosition({
    required String episodeId,
    required int position,
    required String animeTitle,
    required String episodeTitle,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final history = await getHistory();

    // Add or update the episode in history
    history[episodeId] = {
      'position': position,
      'animeTitle': animeTitle,
      'episodeTitle': episodeTitle,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    };

    await prefs.setString(_historyKey, jsonEncode(history));
  }

  // Get playback position for an episode
  static Future<int> getPlaybackPosition(String episodeId) async {
    final history = await getHistory();

    final episodeData = history[episodeId];
    if (episodeData != null) {
      return episodeData['position'] ?? 0;
    }
    return 0;
  }

  // Get all video history
  static Future<Map<String, dynamic>> getHistory() async {
    final historyString = (await SharedPreferences.getInstance()).getString(
      _historyKey,
    );

    if (historyString != null) {
      final decoded = jsonDecode(historyString);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
    }
    return <String, dynamic>{};
  }

  // Remove an episode from history
  static Future<void> removeFromHistory(String episodeId) async {
    final prefs = await SharedPreferences.getInstance();
    final history = await getHistory();

    history.remove(episodeId);
    await prefs.setString(_historyKey, jsonEncode(history));
  }

  // Clear all history
  static Future<void> clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_historyKey);
  }

  // Get recently watched episodes
  static Future<List<Map<String, dynamic>>> getRecentEpisodes({
    int limit = 10,
  }) async {
    final history = await getHistory();

    // Convert to list and sort by timestamp (most recent first)
    final recentList =
        history.entries
            .map(
              (entry) => {
                'episodeId': entry.key,
                'position': entry.value['position'],
                'animeTitle': entry.value['animeTitle'],
                'episodeTitle': entry.value['episodeTitle'],
                'timestamp': entry.value['timestamp'],
              },
            )
            .toList()
          ..sort(
            (a, b) => (b['timestamp'] as int).compareTo(a['timestamp'] as int),
          );

    // Return only the specified limit
    return recentList.length > limit
        ? recentList.take(limit).toList()
        : recentList;
  }
}
