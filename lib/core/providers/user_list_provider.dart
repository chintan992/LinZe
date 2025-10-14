import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:linze/core/services/anilist_sync_service.dart';
import 'package:linze/core/providers/anilist_data_providers.dart'
    show anilistApiServiceProvider, anilistCurrentUserProvider;
import 'package:linze/core/models/anilist/anilist_media_list.dart';

final anilistSyncServiceProvider = Provider((ref) {
  final anilistApi = ref.watch(anilistApiServiceProvider);
  return AniListSyncService(anilistApi);
});

// Example: Provider to fetch user's AniList watching list
final anilistWatchingListProvider = FutureProvider((ref) async {
  final syncService = ref.watch(anilistSyncServiceProvider);
  final user = await ref.watch(anilistCurrentUserProvider.future);

  if (user == null || user['id'] == null) {
    return [];
  }
  return syncService.getUserMediaList(
    user['id'],
    status: AniListMediaListStatus.current,
  );
});

// Provider for sync status
final syncStatusProvider = StateProvider<SyncStatus>((ref) {
  final syncService = ref.watch(anilistSyncServiceProvider);
  return syncService.getSyncStatus();
});

// Provider for manual sync trigger
final manualSyncProvider = FutureProvider<void>((ref) async {
  final syncService = ref.read(anilistSyncServiceProvider);
  await syncService.performManualSync();
  ref.invalidate(syncStatusProvider); // Refresh sync status after manual sync
});
