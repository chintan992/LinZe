import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:linze/core/services/user_preferences_service.dart';
import 'package:linze/core/models/user_preferences.dart';

final userPreferencesServiceProvider = Provider(
  (ref) => UserPreferencesService.instance,
);

final userPreferencesProvider =
    StateNotifierProvider<UserPreferencesNotifier, UserPreferences>(
      (ref) => UserPreferencesNotifier(),
    );
