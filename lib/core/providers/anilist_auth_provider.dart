import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:linze/core/models/anilist/anilist_auth.dart';
import 'package:linze/core/services/anilist_auth_service.dart';

/// Provider for AniList authentication service
final anilistAuthServiceProvider = Provider<AniListAuthService>((ref) {
  final service = AniListAuthService();
  
  // Initialize service when provider is created
  service.initialize();
  
  // Dispose service when provider is disposed
  ref.onDispose(() {
    service.dispose();
  });
  
  return service;
});

/// Provider for current authentication state
final anilistAuthStateProvider = StreamProvider<AniListAuthState>((ref) {
  final authService = ref.watch(anilistAuthServiceProvider);
  
  return Stream.periodic(const Duration(seconds: 1), (_) {
    return AniListAuthState(
      isLoggedIn: authService.isLoggedIn,
      user: authService.currentUser,
      tokens: authService.currentTokens,
    );
  });
});

/// Provider for current user
final anilistCurrentUserProvider = Provider<AniListUser?>((ref) {
  final authState = ref.watch(anilistAuthStateProvider);
  return authState.when(
    data: (state) => state.user,
    loading: () => null,
    error: (_, __) => null,
  );
});

/// Provider for login status
final anilistLoginStatusProvider = Provider<bool>((ref) {
  final authState = ref.watch(anilistAuthStateProvider);
  return authState.when(
    data: (state) => state.isLoggedIn,
    loading: () => false,
    error: (_, __) => false,
  );
});

/// Provider for valid access token
final anilistAccessTokenProvider = FutureProvider<String?>((ref) async {
  final authService = ref.watch(anilistAuthServiceProvider);
  return await authService.getValidAccessToken();
});

/// Authentication state model
class AniListAuthState {
  final bool isLoggedIn;
  final AniListUser? user;
  final AniListAuthTokens? tokens;

  const AniListAuthState({
    required this.isLoggedIn,
    this.user,
    this.tokens,
  });

  bool get hasValidTokens => tokens != null && !tokens!.isExpired;
  bool get needsRefresh => tokens?.needsRefresh ?? false;
}
