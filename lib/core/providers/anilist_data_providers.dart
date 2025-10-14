import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:linze/core/api/anilist_api_service.dart';
import 'package:linze/core/services/anime_id_mapper.dart';
import 'package:linze/core/providers/anilist_auth_provider.dart';

final anilistApiServiceProvider = Provider((ref) {
  final accessTokenAsync = ref.watch(anilistAccessTokenProvider);
  final accessToken = accessTokenAsync.when(
    data: (token) => token,
    loading: () => null,
    error: (_, __) => null,
  );
  return AniListApiService(accessToken: accessToken);
});

final animeIdMapperProvider = Provider((ref) {
  return AnimeIdMapper();
});

// Provider for authenticated AniList user data
final anilistCurrentUserProvider = FutureProvider((ref) async {
  final authService = ref.watch(anilistAuthServiceProvider);
  if (!authService.isLoggedIn) {
    return null;
  }
  final anilistApi = ref.watch(anilistApiServiceProvider);
  return anilistApi.getAuthenticatedUser();
});

// Provider for user anime statistics
final userAnimeStatsProvider = FutureProvider((ref) async {
  final user = await ref.watch(anilistCurrentUserProvider.future);
  if (user == null) {
    return UserAnimeStats.empty();
  }
  return UserAnimeStats.fromAniListUser(user);
});

// Provider for sync status
final syncStatusProvider = StateProvider((ref) => SyncStatus.empty());

// Provider for manual sync
final manualSyncProvider = FutureProvider((ref) async {
  // Manual sync implementation would go here
  // For now, just return void
  return;
});

class UserAnimeStats {
  final int totalWatched;
  final int totalEpisodes;
  final int watchingCount;
  final int completedCount;
  final int planningCount;
  final double averageScore;

  const UserAnimeStats({
    required this.totalWatched,
    required this.totalEpisodes,
    required this.watchingCount,
    required this.completedCount,
    required this.planningCount,
    required this.averageScore,
  });

  factory UserAnimeStats.empty() {
    return const UserAnimeStats(
      totalWatched: 0,
      totalEpisodes: 0,
      watchingCount: 0,
      completedCount: 0,
      planningCount: 0,
      averageScore: 0.0,
    );
  }

  factory UserAnimeStats.fromAniListUser(Map<String, dynamic> user) {
    final animeStats = user['statistics']?['anime'];
    return UserAnimeStats(
      totalWatched: animeStats?['count'] ?? 0,
      totalEpisodes: animeStats?['episodesWatched'] ?? 0,
      watchingCount: 0, // Would need to fetch from user's list
      completedCount: 0, // Would need to fetch from user's list
      planningCount: 0, // Would need to fetch from user's list
      averageScore: (animeStats?['meanScore'] ?? 0).toDouble(),
    );
  }
}

class SyncStatus {
  final bool isUpToDate;
  final int queueSize;
  final bool hasPendingSync;

  const SyncStatus({
    required this.isUpToDate,
    required this.queueSize,
    required this.hasPendingSync,
  });

  factory SyncStatus.empty() {
    return const SyncStatus(
      isUpToDate: true,
      queueSize: 0,
      hasPendingSync: false,
    );
  }
}