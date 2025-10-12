import 'package:linze/core/models/anime_model.dart';
import 'package:linze/core/models/streaming_models.dart';

class ApiResponse<T> {
  final bool success;
  final T? data;
  final String? message;

  ApiResponse({
    required this.success,
    this.data,
    this.message,
  });

  factory ApiResponse.fromJson(Map<String, dynamic> json, T Function(Object?) fromJsonT) {
    return ApiResponse(
      success: json['success'] ?? false,
      data: json['results'] != null ? fromJsonT(json['results']) : null,
      message: json['message'],
    );
  }
}

class HomeResponse {
  final List<Anime>? spotlights;
  final List<Anime>? trending;
  final List<ScheduleItem>? todaySchedule;
  final List<Anime>? topAiring;
  final List<Anime>? mostPopular;
  final List<Anime>? mostFavorite;
  final List<Anime>? latestCompleted;
  final List<Anime>? latestEpisode;
  final List<String>? genres;

  HomeResponse({
    this.spotlights,
    this.trending,
    this.todaySchedule,
    this.topAiring,
    this.mostPopular,
    this.mostFavorite,
    this.latestCompleted,
    this.latestEpisode,
    this.genres,
  });

  factory HomeResponse.fromJson(Map<String, dynamic> json) {
    return HomeResponse(
      spotlights: json['spotlights'] != null
          ? (json['spotlights'] as List).map((e) => Anime.fromJson(e)).toList()
          : null,
      trending: json['trending'] != null
          ? (json['trending'] as List).map((e) => Anime.fromJson(e)).toList()
          : null,
      todaySchedule: json['today']?['schedule'] != null
          ? (json['today']['schedule'] as List)
              .map((e) => ScheduleItem.fromJson(e))
              .toList()
          : null,
      topAiring: json['topAiring'] != null
          ? (json['topAiring'] as List).map((e) => Anime.fromJson(e)).toList()
          : null,
      mostPopular: json['mostPopular'] != null
          ? (json['mostPopular'] as List).map((e) => Anime.fromJson(e)).toList()
          : null,
      mostFavorite: json['mostFavorite'] != null
          ? (json['mostFavorite'] as List).map((e) => Anime.fromJson(e)).toList()
          : null,
      latestCompleted: json['latestCompleted'] != null
          ? (json['latestCompleted'] as List).map((e) => Anime.fromJson(e)).toList()
          : null,
      latestEpisode: json['latestEpisode'] != null
          ? (json['latestEpisode'] as List).map((e) => Anime.fromJson(e)).toList()
          : null,
      genres: json['genres'] != null
          ? List<String>.from(json['genres'])
          : null,
    );
  }
}

class CategoryResponse {
  final int? totalPages;
  final List<Anime>? data;

  CategoryResponse({this.totalPages, this.data});

  factory CategoryResponse.fromJson(Map<String, dynamic> json) {
    return CategoryResponse(
      totalPages: json['totalPages'],
      data: json['data'] != null
          ? (json['data'] as List).map((e) => Anime.fromJson(e)).toList()
          : null,
    );
  }
}

class AnimeDetailApiResponse {
  final Anime? data;
  final List<Season>? seasons;
  final List<Anime>? relatedData;
  final List<Anime>? recommendedData;

  AnimeDetailApiResponse({
    this.data,
    this.seasons,
    this.relatedData,
    this.recommendedData,
  });

  factory AnimeDetailApiResponse.fromJson(Map<String, dynamic> json) {
    return AnimeDetailApiResponse(
      data: json['data'] != null ? Anime.fromJson(json['data']) : null,
      seasons: json['seasons'] != null
          ? (json['seasons'] as List).map((e) => Season.fromJson(e)).toList()
          : null,
      relatedData: json['related_data'] != null && json['related_data'].isNotEmpty
          ? (json['related_data'][0] as List).map((e) => Anime.fromJson(e)).toList()
          : null,
      recommendedData: json['recommended_data'] != null && json['recommended_data'].isNotEmpty
          ? (json['recommended_data'][0] as List).map((e) => Anime.fromJson(e)).toList()
          : null,
    );
  }
}

class SearchResponse {
  final String? title;
  final String? link;

  SearchResponse({this.title, this.link});

  factory SearchResponse.fromJson(Map<String, dynamic> json) {
    return SearchResponse(
      title: json['title'],
      link: json['link'],
    );
  }
}

class EpisodesResponse {
  final int? totalEpisodes;
  final List<Episode>? episodes;

  EpisodesResponse({this.totalEpisodes, this.episodes});

  factory EpisodesResponse.fromJson(Map<String, dynamic> json) {
    return EpisodesResponse(
      totalEpisodes: json['totalEpisodes'],
      episodes: json['episodes'] != null
          ? (json['episodes'] as List).map((e) => Episode.fromJson(e)).toList()
          : null,
    );
  }
}

class StreamingResponse {
  final StreamingLink? streamingLink;
  final List<Server>? servers;

  StreamingResponse({this.streamingLink, this.servers});

  factory StreamingResponse.fromJson(Map<String, dynamic> json) {
    return StreamingResponse(
      streamingLink: json['streamingLink'] != null
          ? StreamingLink.fromJson(json['streamingLink'])
          : null,
      servers: json['servers'] != null
          ? (json['servers'] as List).map((e) => Server.fromJson(e)).toList()
          : null,
    );
  }
}