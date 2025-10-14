import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:linze/core/constants/constants.dart';
import 'package:linze/core/models/streaming_models.dart';

/// Streaming API Service - handles only streaming-related endpoints
/// This service is used exclusively for getting video streaming links
class StreamingApiService {
  String get baseUrl => StreamingApiConfig.baseUrl;

  // Get streaming information for an episode
  Future<StreamingResponse> getStreamingInfo({
    required String id,
    required String server,
    required String type,
  }) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/stream?id=$id&server=$server&type=$type'),
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return StreamingResponse.fromJson(json['results']);
    } else {
      throw StreamingApiException(
        'Failed to load streaming info: ${response.statusCode}',
        response.statusCode,
      );
    }
  }

  // Get fallback streaming information
  Future<StreamingResponse> getFallbackStreamingInfo({
    required String id,
    required String server,
    required String type,
  }) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/stream/fallback?id=$id&server=$server&type=$type'),
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return StreamingResponse.fromJson(json['results']);
    } else {
      throw StreamingApiException(
        'Failed to load fallback streaming info: ${response.statusCode}',
        response.statusCode,
      );
    }
  }

  // Get available servers for an anime
  Future<List<Server>> getServers(String animeId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/servers/$animeId'),
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return (json['results'] as List)
          .map((item) => Server.fromJson(item))
          .toList();
    } else {
      throw StreamingApiException(
        'Failed to load servers: ${response.statusCode}',
        response.statusCode,
      );
    }
  }

  // Search for anime by title to find streaming ID
  Future<List<StreamingAnime>> searchAnimeForStreaming(String title) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/search?keyword=${Uri.encodeComponent(title)}'),
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      final results = json['results'];
      return (results['data'] as List)
          .map((item) => StreamingAnime.fromJson(item))
          .toList();
    } else {
      throw StreamingApiException(
        'Failed to search anime: ${response.statusCode}',
        response.statusCode,
      );
    }
  }

  // Get episodes for an anime (to map AniList anime to streaming episodes)
  Future<StreamingEpisodesResponse> getEpisodes(String animeId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/episodes/$animeId'),
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return StreamingEpisodesResponse.fromJson(json['results']);
    } else {
      throw StreamingApiException(
        'Failed to load episodes: ${response.statusCode}',
        response.statusCode,
      );
    }
  }
}

/// Models for streaming API responses
class StreamingAnime {
  final String id;
  final int dataId;
  final String poster;
  final String title;
  final String japaneseTitle;
  final TvInfo tvInfo;

  const StreamingAnime({
    required this.id,
    required this.dataId,
    required this.poster,
    required this.title,
    required this.japaneseTitle,
    required this.tvInfo,
  });

  factory StreamingAnime.fromJson(Map<String, dynamic> json) {
    return StreamingAnime(
      id: json['id'] ?? '',
      dataId: int.tryParse(json['data_id']?.toString() ?? '0') ?? 0,
      poster: json['poster'] ?? '',
      title: json['title'] ?? '',
      japaneseTitle: json['japanese_title'] ?? '',
      tvInfo: TvInfo.fromJson(json['tvInfo'] ?? {}),
    );
  }
}

class TvInfo {
  final String? showType;
  final String? duration;
  final int? sub;
  final int? dub;
  final int? eps;

  const TvInfo({
    this.showType,
    this.duration,
    this.sub,
    this.dub,
    this.eps,
  });

  factory TvInfo.fromJson(Map<String, dynamic> json) {
    return TvInfo(
      showType: json['showType'],
      duration: json['duration'],
      sub: json['sub'],
      dub: json['dub'],
      eps: json['eps'],
    );
  }
}

class StreamingApiException implements Exception {
  final String message;
  final int statusCode;

  const StreamingApiException(this.message, this.statusCode);

  @override
  String toString() => 'StreamingApiException: $message (Status: $statusCode)';
}
