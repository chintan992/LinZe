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

// Tab-specific providers
final forYouTabProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final homeData = await ref.watch(homePageProvider.future);
  final featuredSpotlight = homeData.spotlights.isNotEmpty ? homeData.spotlights.first : null;
  final featuredAnime = featuredSpotlight != null 
      ? Anime(
          id: featuredSpotlight.id,
          dataId: featuredSpotlight.dataId,
          poster: featuredSpotlight.poster,
          title: featuredSpotlight.title,
          japaneseTitle: featuredSpotlight.japaneseTitle,
          description: featuredSpotlight.description,
          tvInfo: TvInfo(
            showType: featuredSpotlight.tvInfo.showType,
            duration: featuredSpotlight.tvInfo.duration,
            sub: featuredSpotlight.tvInfo.sub,
            dub: featuredSpotlight.tvInfo.dub,
            eps: featuredSpotlight.tvInfo.eps,
          ),
        )
      : null;
  return {
    'featuredAnime': featuredAnime,
    'continueWatching': [], // Mock data for now, will be replaced with real data in future phases
    'recommended': homeData.mostPopular.take(10).toList(),
    'topAiring': homeData.topAiring.take(20).toList(),
    'genres': homeData.genres.take(5).toList(), // First 5 genres for "Your Genres" section
  };
});

final trendingTabProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final homeData = await ref.watch(homePageProvider.future);
  return {
    'topTrending': homeData.trending,
    'topAiring': homeData.topAiring,
    'mostPopular': homeData.mostPopular,
    'genres': homeData.genres,
  };
});

final newTabProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final homeData = await ref.watch(homePageProvider.future);
  return {
    'latestEpisodes': homeData.latestEpisode,
    'schedule': homeData.today, // Assuming today contains schedule info
    'latestCompleted': homeData.latestCompleted,
  };
});

final genresTabProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final homeData = await ref.watch(homePageProvider.future);
  // Combine lists for genre filtering
  final allAnime = [
    ...homeData.topAiring,
    ...homeData.mostPopular,
    ...homeData.mostFavorite,
  ];
  return {
    'genres': homeData.genres,
    'allAnime': allAnime,
  };
});

final myListTabProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  // For now, return empty/mock data structure
  // This will be enhanced in later phases to integrate with watchlist service
  return {
    'currentlyWatching': [],
    'planToWatch': [],
    'completed': [],
  };
});

// Forwarding providers with requested names to maintain compatibility
final forYouProvider = forYouTabProvider;
final trendingProvider = trendingTabProvider;
final newProvider = newTabProvider;
final genresProvider = genresTabProvider;
final myListProvider = myListTabProvider;