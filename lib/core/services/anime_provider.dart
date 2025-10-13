import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:linze/core/api/api_service.dart';
import 'package:linze/core/models/home.dart' as home_models;
import 'package:linze/core/models/response_models.dart' as response_models;
import 'package:linze/core/models/anime_model.dart';
import 'package:linze/core/models/streaming_models.dart';

final apiServiceProvider = Provider<ApiService>((ref) => ApiService());

final homePageProvider = FutureProvider<home_models.Home>((ref) async {
  final apiService = ref.read(apiServiceProvider);
  return await apiService.getHomeData();
});

final animeDetailProvider = FutureProvider.family<response_models.AnimeDetailApiResponse, String>((ref, animeId) async {
  final apiService = ref.read(apiServiceProvider);
  return await apiService.getAnimeInfo(animeId);
});

final episodesProvider = FutureProvider.family<response_models.EpisodesResponse, String>((ref, animeId) async {
  final apiService = ref.read(apiServiceProvider);
  return await apiService.getEpisodes(animeId);
});

final categoryProvider = FutureProvider.family<response_models.CategoryResponse, String>((ref, category) async {
  final apiService = ref.read(apiServiceProvider);
  return await apiService.getCategory(category);
});

final searchProvider = FutureProvider.family<List<Anime>, String>((ref, keyword) async {
  final apiService = ref.read(apiServiceProvider);
  return await apiService.searchAnime(keyword);
});

final searchSuggestionsProvider = FutureProvider.family<List<Anime>, String>((ref, keyword) async {
  final apiService = ref.read(apiServiceProvider);
  return await apiService.getSearchSuggestions(keyword);
});

final topTenProvider = FutureProvider<TopTenData>((ref) async {
  final apiService = ref.read(apiServiceProvider);
  return await apiService.getTopTen();
});

final topSearchProvider = FutureProvider<List<TopSearch>>((ref) async {
  final apiService = ref.read(apiServiceProvider);
  return await apiService.getTopSearch();
});

final randomAnimeProvider = FutureProvider<response_models.AnimeDetailApiResponse>((ref) async {
  final apiService = ref.read(apiServiceProvider);
  return await apiService.getRandomAnime();
});

final streamingInfoProvider = FutureProvider.family<response_models.StreamingResponse, Map<String, String>>((ref, params) async {
  final apiService = ref.read(apiServiceProvider);
  return await apiService.getStreamingInfo(
    id: params['id']!,
    server: params['server']!,
    type: params['type']!,
  );
});

final serversProvider = FutureProvider.family<List<Server>, String>((ref, animeId) async {
  final apiService = ref.read(apiServiceProvider);
  return await apiService.getServers(animeId);
});

final characterListProvider = FutureProvider.family<CharacterListResponse, String>((ref, animeId) async {
  final apiService = ref.read(apiServiceProvider);
  return await apiService.getCharacterList(animeId);
});

final characterDetailProvider = FutureProvider.family<CharacterDetail, String>((ref, characterId) async {
  final apiService = ref.read(apiServiceProvider);
  return await apiService.getCharacterDetail(characterId);
});

final voiceActorDetailProvider = FutureProvider.family<VoiceActorDetail, String>((ref, actorId) async {
  final apiService = ref.read(apiServiceProvider);
  return await apiService.getVoiceActorDetail(actorId);
});

final scheduleProvider = FutureProvider.family<List<home_models.Schedule>, String>((ref, date) async {
  final apiService = ref.read(apiServiceProvider);
  return await apiService.getSchedule(date);
});

final nextEpisodeScheduleProvider = FutureProvider.family<NextEpisodeSchedule, String>((ref, animeId) async {
  final apiService = ref.read(apiServiceProvider);
  return await apiService.getNextEpisodeSchedule(animeId);
});

final episodeThumbnailsProvider = FutureProvider.family<Map<String, String>, String>((ref, animeId) async {
  final apiService = ref.read(apiServiceProvider);
  return await apiService.getEpisodeThumbnails(animeId);
});