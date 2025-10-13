import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:linze/core/models/home.dart' as home_models;
import 'package:linze/core/models/anime_model.dart';
import 'package:linze/core/models/streaming_models.dart';
import 'package:linze/core/models/response_models.dart' as response_models;

class ApiService {
  final String baseUrl = 'https://anime-api-test-one.vercel.app';

  // Home endpoint
  Future<home_models.Home> getHomeData() async {
    final response = await http.get(Uri.parse('$baseUrl/api/'));

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      final results = json['results'];

      return home_models.Home(
        spotlights: (results['spotlights'] as List)
            .map(
              (spotlight) => home_models.Spotlight(
                id: spotlight['id'] ?? '',
                dataId: int.tryParse(spotlight['data_id']?.toString() ?? '0') ?? 0,
                poster: spotlight['poster'] ?? '',
                title: spotlight['title'] ?? '',
                japaneseTitle: spotlight['japanese_title'] ?? '',
                description: spotlight['description'] ?? '',
                tvInfo: home_models.TvInfo(
                  showType: spotlight['tvInfo']?['showType'],
                  duration: spotlight['tvInfo']?['duration'],
                  sub: spotlight['tvInfo']?['sub'],
                  dub: spotlight['tvInfo']?['dub'],
                  eps: spotlight['tvInfo']?['eps'],
                ),
              ),
            )
            .toList(),
        trending: (results['trending'] as List)
            .map(
              (trending) => home_models.Trending(
                id: trending['id'] ?? '',
                dataId: int.tryParse(trending['data_id']?.toString() ?? '0') ?? 0,
                number: int.tryParse(trending['number']?.toString() ?? '0') ?? 0,
                poster: trending['poster'] ?? '',
                title: trending['title'] ?? '',
                japaneseTitle: trending['japanese_title'] ?? '',
              ),
            )
            .toList(),
        today: (results['today']['schedule'] as List)
            .map(
              (schedule) => home_models.Schedule(
                id: schedule['id'] ?? '',
                dataId: int.tryParse(schedule['data_id']?.toString() ?? '0') ?? 0,
                title: schedule['title'] ?? '',
                japaneseTitle: schedule['japanese_title'] ?? '',
                releaseDate: schedule['releaseDate'] ?? '',
                time: schedule['time'] ?? '',
                episodeNo: int.tryParse(schedule['episode_no']?.toString() ?? '0') ?? 0,
              ),
            )
            .toList(),
        topAiring: (results['topAiring'] as List)
            .map(
              (topAiring) => home_models.TopAiring(
                id: topAiring['id'] ?? '',
                dataId: int.tryParse(topAiring['data_id']?.toString() ?? '0') ?? 0,
                poster: topAiring['poster'] ?? '',
                title: topAiring['title'] ?? '',
                japaneseTitle: topAiring['japanese_title'] ?? '',
                description: topAiring['description'] ?? '',
                tvInfo: home_models.TvInfo(
                  showType: topAiring['tvInfo']?['showType'],
                  duration: topAiring['tvInfo']?['duration'],
                  sub: topAiring['tvInfo']?['sub'],
                  dub: topAiring['tvInfo']?['dub'],
                  eps: topAiring['tvInfo']?['eps'],
                ),
              ),
            )
            .toList(),
        mostPopular: (results['mostPopular'] as List)
            .map(
              (mostPopular) => home_models.MostPopular(
                id: mostPopular['id'] ?? '',
                dataId: int.tryParse(mostPopular['data_id']?.toString() ?? '0') ?? 0,
                poster: mostPopular['poster'] ?? '',
                title: mostPopular['title'] ?? '',
                japaneseTitle: mostPopular['japanese_title'] ?? '',
                description: mostPopular['description'] ?? '',
                tvInfo: home_models.TvInfo(
                  showType: mostPopular['tvInfo']?['showType'],
                  duration: mostPopular['tvInfo']?['duration'],
                  sub: mostPopular['tvInfo']?['sub'],
                  dub: mostPopular['tvInfo']?['dub'],
                  eps: mostPopular['tvInfo']?['eps'],
                ),
              ),
            )
            .toList(),
        mostFavorite: (results['mostFavorite'] as List)
            .map(
              (mostFavorite) => home_models.MostFavorite(
                id: mostFavorite['id'] ?? '',
                dataId: int.tryParse(mostFavorite['data_id']?.toString() ?? '0') ?? 0,
                poster: mostFavorite['poster'] ?? '',
                title: mostFavorite['title'] ?? '',
                japaneseTitle: mostFavorite['japanese_title'] ?? '',
                description: mostFavorite['description'] ?? '',
                tvInfo: home_models.TvInfo(
                  showType: mostFavorite['tvInfo']?['showType'],
                  duration: mostFavorite['tvInfo']?['duration'],
                  sub: mostFavorite['tvInfo']?['sub'],
                  dub: mostFavorite['tvInfo']?['dub'],
                  eps: mostFavorite['tvInfo']?['eps'],
                ),
              ),
            )
            .toList(),
        latestCompleted: (results['latestCompleted'] as List)
            .map(
              (latestCompleted) => home_models.LatestCompleted(
                id: latestCompleted['id'] ?? '',
                dataId: int.tryParse(latestCompleted['data_id']?.toString() ?? '0') ?? 0,
                poster: latestCompleted['poster'] ?? '',
                title: latestCompleted['title'] ?? '',
                japaneseTitle: latestCompleted['japanese_title'] ?? '',
                description: latestCompleted['description'] ?? '',
                tvInfo: home_models.TvInfo(
                  showType: latestCompleted['tvInfo']?['showType'],
                  duration: latestCompleted['tvInfo']?['duration'],
                  sub: latestCompleted['tvInfo']?['sub'],
                  dub: latestCompleted['tvInfo']?['dub'],
                  eps: latestCompleted['tvInfo']?['eps'],
                ),
              ),
            )
            .toList(),
        latestEpisode: (results['latestEpisode'] as List)
            .map(
              (latestEpisode) => home_models.LatestEpisode(
                id: latestEpisode['id'] ?? '',
                dataId: int.tryParse(latestEpisode['data_id']?.toString() ?? '0') ?? 0,
                poster: latestEpisode['poster'] ?? '',
                title: latestEpisode['title'] ?? '',
                japaneseTitle: latestEpisode['japanese_title'] ?? '',
                description: latestEpisode['description'] ?? '',
                tvInfo: home_models.TvInfo(
                  showType: latestEpisode['tvInfo']?['showType'],
                  duration: latestEpisode['tvInfo']?['duration'],
                  sub: latestEpisode['tvInfo']?['sub'],
                  dub: latestEpisode['tvInfo']?['dub'],
                  eps: latestEpisode['tvInfo']?['eps'],
                ),
              ),
            )
            .toList(),
        genres: (results['genres'] as List)
            .map((genre) => genre as String)
            .toList(),
      );
    } else {
      throw Exception('Failed to load home data');
    }
  }

  // Top 10 anime endpoint
  Future<TopTenData> getTopTen() async {
    final response = await http.get(Uri.parse('$baseUrl/api/top-ten'));

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return TopTenData.fromJson(json['results']);
    } else {
      throw Exception('Failed to load top ten data');
    }
  }

  // Top search endpoint
  Future<List<TopSearch>> getTopSearch() async {
    final response = await http.get(Uri.parse('$baseUrl/api/top-search'));

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return (json['results'] as List)
          .map((item) => TopSearch.fromJson(item))
          .toList();
    } else {
      throw Exception('Failed to load top search data');
    }
  }

  // Anime info endpoint
  Future<response_models.AnimeDetailApiResponse> getAnimeInfo(String id) async {
    final response = await http.get(Uri.parse('$baseUrl/api/info?id=$id'));

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return response_models.AnimeDetailApiResponse.fromJson(json['results']);
    } else {
      throw Exception('Failed to load anime info');
    }
  }

  // Random anime endpoint
  Future<response_models.AnimeDetailApiResponse> getRandomAnime() async {
    final response = await http.get(Uri.parse('$baseUrl/api/random'));

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return response_models.AnimeDetailApiResponse.fromJson(json['results']);
    } else {
      throw Exception('Failed to load random anime');
    }
  }

  // Categories endpoint
  Future<response_models.CategoryResponse> getCategory(
    String category, {
    int page = 1,
  }) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/$category?page=$page'),
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return response_models.CategoryResponse.fromJson(json['results']);
    } else {
      throw Exception('Failed to load category data');
    }
  }

  // Producer endpoint
  Future<response_models.CategoryResponse> getProducer(
    String producer, {
    int page = 1,
  }) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/producer/$producer?page=$page'),
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return response_models.CategoryResponse.fromJson(json['results']);
    } else {
      throw Exception('Failed to load producer data');
    }
  }

  // Search endpoint
  Future<List<Anime>> searchAnime(String keyword) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/search?keyword=${Uri.encodeComponent(keyword)}'),
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      final results = json['results'];
      return (results['data'] as List)
          .map((item) => Anime.fromJson(item))
          .toList();
    } else {
      throw Exception('Failed to search anime');
    }
  }

  // Search suggestions endpoint
  Future<List<Anime>> getSearchSuggestions(String keyword) async {
    final response = await http.get(
      Uri.parse(
        '$baseUrl/api/search/suggest?keyword=${Uri.encodeComponent(keyword)}',
      ),
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return (json['results'] as List)
          .map((item) => Anime.fromJson(item))
          .toList();
    } else {
      throw Exception('Failed to get search suggestions');
    }
  }

  // Filter endpoint
  Future<response_models.CategoryResponse> filterAnime({
    String? type,
    String? status,
    String? rated,
    String? score,
    String? season,
    String? language,
    String? genres,
    String? sort,
    int page = 1,
    int? startYear,
    int? startMonth,
    int? startDay,
    int? endYear,
    int? endMonth,
    int? endDay,
    String? keyword,
  }) async {
    final uri = Uri.parse('$baseUrl/api/filter').replace(
      queryParameters: {
        if (type != null) 'type': type,
        if (status != null) 'status': status,
        if (rated != null) 'rated': rated,
        if (score != null) 'score': score,
        if (season != null) 'season': season,
        if (language != null) 'language': language,
        if (genres != null) 'genres': genres,
        if (sort != null) 'sort': sort,
        'page': page.toString(),
        if (startYear != null) 'sy': startYear.toString(),
        if (startMonth != null) 'sm': startMonth.toString(),
        if (startDay != null) 'sd': startDay.toString(),
        if (endYear != null) 'ey': endYear.toString(),
        if (endMonth != null) 'em': endMonth.toString(),
        if (endDay != null) 'ed': endDay.toString(),
        if (keyword != null) 'keyword': keyword,
      },
    );

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return response_models.CategoryResponse.fromJson(json['results']);
    } else {
      throw Exception('Failed to filter anime');
    }
  }

  // Episodes endpoint
  Future<response_models.EpisodesResponse> getEpisodes(String animeId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/episodes/$animeId'),
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return response_models.EpisodesResponse.fromJson(json['results']);
    } else {
      throw Exception('Failed to load episodes');
    }
  }

  // Schedule endpoint
  Future<List<home_models.Schedule>> getSchedule(String date) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/schedule?date=$date'),
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return (json['results'] as List)
          .map(
            (item) =>
                home_models.Schedule.fromJson(item as Map<String, dynamic>),
          )
          .toList();
    } else {
      throw Exception('Failed to load schedule');
    }
  }

  // Next episode schedule endpoint
  Future<NextEpisodeSchedule> getNextEpisodeSchedule(String animeId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/schedule/$animeId'),
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return NextEpisodeSchedule.fromJson(json['results']);
    } else {
      throw Exception('Failed to load next episode schedule');
    }
  }

  // Qtip endpoint
  Future<QtipInfo> getQtipInfo(int id) async {
    final response = await http.get(Uri.parse('$baseUrl/api/qtip/$id'));

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return QtipInfo.fromJson(json['results']);
    } else {
      throw Exception('Failed to load qtip info');
    }
  }

  // Characters endpoint
  Future<CharacterListResponse> getCharacterList(String animeId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/character/list/$animeId'),
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return CharacterListResponse.fromJson(json['results']);
    } else {
      throw Exception('Failed to load character list');
    }
  }

  // Streaming endpoint
  Future<response_models.StreamingResponse> getStreamingInfo({
    required String id,
    required String server,
    required String type,
  }) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/stream?id=$id&server=$server&type=$type'),
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return response_models.StreamingResponse.fromJson(json['results']);
    } else {
      throw Exception('Failed to load streaming info');
    }
  }

  // Fallback streaming endpoint
  Future<response_models.StreamingResponse> getFallbackStreamingInfo({
    required String id,
    required String server,
    required String type,
  }) async {
    final response = await http.get(
      Uri.parse(
        '$baseUrl/api/stream/fallback?id=$id&server=$server&type=$type',
      ),
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return response_models.StreamingResponse.fromJson(json['results']);
    } else {
      throw Exception('Failed to load fallback streaming info');
    }
  }

  // Servers endpoint
  Future<List<Server>> getServers(String animeId) async {
    final response = await http.get(Uri.parse('$baseUrl/api/servers/$animeId'));

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return (json['results'] as List)
          .map((item) => Server.fromJson(item))
          .toList();
    } else {
      throw Exception('Failed to load servers');
    }
  }

  // Character details endpoint
  Future<CharacterDetail> getCharacterDetail(String characterId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/character/$characterId'),
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return CharacterDetail.fromJson(json['results']['data'][0]);
    } else {
      throw Exception('Failed to load character details');
    }
  }

  // Voice actor details endpoint
  Future<VoiceActorDetail> getVoiceActorDetail(String actorId) async {
    final response = await http.get(Uri.parse('$baseUrl/api/actors/$actorId'));

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return VoiceActorDetail.fromJson(json['results']['data'][0]);
    } else {
      throw Exception('Failed to load voice actor details');
    }
  }

  // Episode thumbnails endpoint (if supported by the API)
  Future<Map<String, String>> getEpisodeThumbnails(String animeId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/episodes/$animeId/thumbnails'),
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        return Map<String, String>.from(json['results'] ?? {});
      } else {
        // If the endpoint doesn't exist, return empty map
        return {};
      }
    } catch (e) {
      // If there's an error, return empty map
      return {};
    }
  }
}
