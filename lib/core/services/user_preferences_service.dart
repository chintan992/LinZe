import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:linze/core/models/user_preferences.dart';

class UserPreferencesService {
  static const String _preferencesKey = 'user_preferences';

  // Default preferences
  static const UserPreferences _defaultPreferences = UserPreferences();

  static UserPreferencesService? _instance;
  static UserPreferencesService get instance {
    _instance ??= UserPreferencesService._();
    return _instance!;
  }

  UserPreferencesService._();

  /// Get user preferences from SharedPreferences
  static Future<UserPreferences> getPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final preferencesJson = prefs.getString(_preferencesKey);

    if (preferencesJson != null) {
      try {
        // For now, we'll store preferences as individual keys
        // This is more reliable than JSON serialization
        return UserPreferences(
          preferredAudioType:
              prefs.getString('preferred_audio_type') ??
              _defaultPreferences.preferredAudioType,
          defaultServer:
              prefs.getString('default_server') ??
              _defaultPreferences.defaultServer,
          autoSkipIntro:
              prefs.getBool('auto_skip_intro') ??
              _defaultPreferences.autoSkipIntro,
          autoSkipOutro:
              prefs.getBool('auto_skip_outro') ??
              _defaultPreferences.autoSkipOutro,
          defaultPlaybackSpeed:
              prefs.getDouble('default_playback_speed') ??
              _defaultPreferences.defaultPlaybackSpeed,
          notificationsEnabled:
              prefs.getBool('notifications_enabled') ??
              _defaultPreferences.notificationsEnabled,
          dataSaverMode:
              prefs.getBool('data_saver_mode') ??
              _defaultPreferences.dataSaverMode,
          streamingQuality:
              prefs.getString('streaming_quality') ??
              _defaultPreferences.streamingQuality,
        );
      } catch (e) {
        return _defaultPreferences;
      }
    }

    return _defaultPreferences;
  }

  /// Save user preferences to SharedPreferences
  static Future<void> savePreferences(UserPreferences preferences) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(
      'preferred_audio_type',
      preferences.preferredAudioType,
    );
    await prefs.setString('default_server', preferences.defaultServer);
    await prefs.setBool('auto_skip_intro', preferences.autoSkipIntro);
    await prefs.setBool('auto_skip_outro', preferences.autoSkipOutro);
    await prefs.setDouble(
      'default_playback_speed',
      preferences.defaultPlaybackSpeed,
    );
    await prefs.setBool(
      'notifications_enabled',
      preferences.notificationsEnabled,
    );
    await prefs.setBool('data_saver_mode', preferences.dataSaverMode);
    await prefs.setString('streaming_quality', preferences.streamingQuality);
  }

  /// Update a specific preference
  static Future<void> updatePreference<T>(String key, T value) async {
    final prefs = await SharedPreferences.getInstance();

    switch (key) {
      case 'preferredAudioType':
        await prefs.setString('preferred_audio_type', value as String);
        break;
      case 'defaultServer':
        await prefs.setString('default_server', value as String);
        break;
      case 'autoSkipIntro':
        await prefs.setBool('auto_skip_intro', value as bool);
        break;
      case 'autoSkipOutro':
        await prefs.setBool('auto_skip_outro', value as bool);
        break;
      case 'defaultPlaybackSpeed':
        await prefs.setDouble('default_playback_speed', value as double);
        break;
      case 'notificationsEnabled':
        await prefs.setBool('notifications_enabled', value as bool);
        break;
      case 'dataSaverMode':
        await prefs.setBool('data_saver_mode', value as bool);
        break;
      case 'streamingQuality':
        await prefs.setString('streaming_quality', value as String);
        break;
    }
  }

  /// Reset all preferences to default
  static Future<void> resetToDefault() async {
    await savePreferences(_defaultPreferences);
  }

  /// Get available audio types
  static List<String> getAudioTypes() {
    return ['sub', 'dub'];
  }

  /// Get available servers
  static List<String> getAvailableServers() {
    return ['HD-1', 'HD-2', 'HD-3', 'Multi Quality'];
  }

  /// Get available streaming qualities
  static List<String> getStreamingQualities() {
    return ['auto', '1080p', '720p', '480p', '360p'];
  }

  /// Get available playback speeds
  static List<double> getPlaybackSpeeds() {
    return [0.5, 0.75, 1.0, 1.25, 1.5, 2.0];
  }
}

class UserPreferencesNotifier extends StateNotifier<UserPreferences> {
  UserPreferencesNotifier() : super(const UserPreferences()) {
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final preferences = await UserPreferencesService.getPreferences();
    state = preferences;
  }

  Future<void> updatePreference(String key, dynamic value) async {
    await UserPreferencesService.updatePreference(key, value);
    await _loadPreferences();
  }

  // Convenience methods --------------------------------------------------
  Future<void> updateAutoSkipIntro(bool value) async {
    await updatePreference('autoSkipIntro', value);
  }

  Future<void> updateAutoSkipOutro(bool value) async {
    await updatePreference('autoSkipOutro', value);
  }

  Future<void> updatePreferredAudioType(String audioType) async {
    await updatePreference('preferredAudioType', audioType);
  }

  Future<void> updateDefaultServer(String server) async {
    await updatePreference('defaultServer', server);
  }

  Future<void> updateStreamingQuality(String quality) async {
    await updatePreference('streamingQuality', quality);
  }

  Future<void> updateDefaultPlaybackSpeed(double speed) async {
    await updatePreference('defaultPlaybackSpeed', speed);
  }

  Future<void> resetToDefault() async {
    await UserPreferencesService.resetToDefault();
    await _loadPreferences();
  }
}
