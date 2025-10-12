import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:linze/core/models/user_preferences.dart';
import 'package:linze/core/services/user_preferences_service.dart';

// Provider for user preferences
final userPreferencesProvider = StateNotifierProvider<UserPreferencesNotifier, UserPreferences>((ref) {
  return UserPreferencesNotifier();
});

// Notifier class for managing user preferences
class UserPreferencesNotifier extends StateNotifier<UserPreferences> {
  UserPreferencesNotifier() : super(const UserPreferences()) {
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final preferences = await UserPreferencesService.getPreferences();
    state = preferences;
  }

  Future<void> updatePreferences(UserPreferences preferences) async {
    await UserPreferencesService.savePreferences(preferences);
    state = preferences;
  }

  Future<void> updatePreferredAudioType(String audioType) async {
    final updatedPreferences = state.copyWith(preferredAudioType: audioType);
    await updatePreferences(updatedPreferences);
  }

  Future<void> updateDefaultServer(String server) async {
    final updatedPreferences = state.copyWith(defaultServer: server);
    await updatePreferences(updatedPreferences);
  }

  Future<void> updateAutoSkipIntro(bool value) async {
    final updatedPreferences = state.copyWith(autoSkipIntro: value);
    await updatePreferences(updatedPreferences);
  }

  Future<void> updateAutoSkipOutro(bool value) async {
    final updatedPreferences = state.copyWith(autoSkipOutro: value);
    await updatePreferences(updatedPreferences);
  }

  Future<void> updateDefaultPlaybackSpeed(double speed) async {
    final updatedPreferences = state.copyWith(defaultPlaybackSpeed: speed);
    await updatePreferences(updatedPreferences);
  }

  Future<void> updateNotificationsEnabled(bool value) async {
    final updatedPreferences = state.copyWith(notificationsEnabled: value);
    await updatePreferences(updatedPreferences);
  }

  Future<void> updateDataSaverMode(bool value) async {
    final updatedPreferences = state.copyWith(dataSaverMode: value);
    await updatePreferences(updatedPreferences);
  }

  Future<void> updateStreamingQuality(String quality) async {
    final updatedPreferences = state.copyWith(streamingQuality: quality);
    await updatePreferences(updatedPreferences);
  }

  Future<void> resetToDefault() async {
    await UserPreferencesService.resetToDefault();
    state = const UserPreferences();
  }
}
