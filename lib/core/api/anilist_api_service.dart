import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:linze/core/constants/constants.dart';
import 'package:linze/core/models/anilist/anilist_auth.dart';
import 'package:linze/core/models/anilist/anilist_media.dart';
import 'package:linze/core/models/anilist/anilist_media_list.dart';
import 'package:linze/core/models/anilist/anilist_recommendation.dart';

class AniListApiService {
  static const String _baseUrl = AniListConfig.baseUrl;
  final http.Client _client = http.Client();
  final String? _accessToken;

  AniListApiService({String? accessToken}) : _accessToken = accessToken;

  Future<T> _makeGraphQLRequest<T>(
    String query,
    Map<String, dynamic> variables, {
    Map<String, String>? headers,
    T Function(Map<String, dynamic>)? fromJson,
  }) async {
    final response = await _client.post(
      Uri.parse(_baseUrl),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (_accessToken != null) 'Authorization': 'Bearer $_accessToken',
        ...?headers,
      },
      body: jsonEncode({
        'query': query,
        'variables': variables,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      
      if (data['errors'] != null) {
        throw AniListApiException(
          'GraphQL errors: ${data['errors']}',
          response.statusCode,
        );
      }

      if (fromJson != null) {
        return fromJson(data['data'] as Map<String, dynamic>);
      }
      
      return data['data'] as T;
    } else {
      throw AniListApiException(
        'HTTP ${response.statusCode}: ${response.body}',
        response.statusCode,
      );
    }
  }

  // User Profile Queries
  Future<Map<String, dynamic>?> getAuthenticatedUser() async {
    final query = '''
      query {
        Viewer {
          id
          name
          avatar {
            large
          }
          bannerImage
          about
          unreadNotificationCount
          statistics {
            anime {
              count
              meanScore
              standardDeviation
              minutesWatched
              episodesWatched
            }
            manga {
              count
              meanScore
              standardDeviation
              chaptersRead
              volumesRead
            }
          }
        }
      }
    ''';

    final data = await _makeGraphQLRequest(
      query,
      {},
    );

    return data['Viewer'];
  }

  Future<AniListUser> getCurrentUser(String accessToken) async {
    const query = '''
      query {
        Viewer {
          id
          name
          avatar {
            large
          }
          bannerImage
          about
          unreadNotificationCount
          statistics {
            anime {
              count
              meanScore
              standardDeviation
              minutesWatched
              episodesWatched
            }
            manga {
              count
              meanScore
              standardDeviation
              chaptersRead
              volumesRead
            }
          }
        }
      }
    ''';

    return _makeGraphQLRequest(
      query,
      {},
      headers: {'Authorization': 'Bearer $accessToken'},
      fromJson: (data) => AniListUser.fromJson(data['Viewer']),
    );
  }

  // Media Queries
  Future<AniListMedia> getMedia(int mediaId, String? accessToken) async {
    const query = '''
      query (\$id: Int) {
        Media(id: \$id) {
          id
          title {
            romaji
            english
            native
          }
          description
          coverImage {
            extraLarge
            large
            medium
          }
          bannerImage
          type
          format
          status
          season
          seasonYear
          episodes
          chapters
          volumes
          duration
          genres
          tags {
            name
          }
          averageScore
          popularity
          favourites
          isFavourite
          trailer {
            id
            site
            thumbnail
          }
          relations {
            edges {
              relationType
              node {
                id
                title {
                  romaji
                  english
                  native
                }
                coverImage {
                  large
                  medium
                }
                type
                format
                status
              }
            }
          }
          characters {
            edges {
              role
              node {
                id
                name {
                  full
                  native
                  english
                }
                image {
                  large
                }
                description
              }
              voiceActors {
                id
                name {
                  full
                  native
                  english
                }
                language
                image {
                  large
                }
              }
            }
          }
          staff {
            edges {
              role
              node {
                id
                name {
                  full
                  native
                  english
                }
                image {
                  large
                }
                description
                primaryOccupations
              }
            }
          }
        }
      }
    ''';

    return _makeGraphQLRequest(
      query,
      {'id': mediaId},
      headers: accessToken != null ? {'Authorization': 'Bearer $accessToken'} : null,
      fromJson: (data) => AniListMedia.fromJson(data['Media']),
    );
  }

  // Search Media
  Future<List<AniListMedia>> searchMedia(
    String search, {
    int page = 1,
    int perPage = 20,
    AniListMediaType? type,
    AniListMediaFormat? format,
    AniListMediaStatus? status,
    String? season,
    int? seasonYear,
    List<String>? genres,
    String? sort,
    String? accessToken,
  }) async {
    const query = '''
      query (\$search: String, \$page: Int, \$perPage: Int, \$type: MediaType, \$format: MediaFormat, \$status: MediaStatus, \$season: MediaSeason, \$seasonYear: Int, \$genres: [String], \$sort: [MediaSort]) {
        Page(page: \$page, perPage: \$perPage) {
          pageInfo {
            total
            perPage
            currentPage
            lastPage
            hasNextPage
          }
          media(search: \$search, type: \$type, format: \$format, status: \$status, season: \$season, seasonYear: \$seasonYear, genre_in: \$genres, sort: \$sort) {
            id
            title {
              romaji
              english
              native
            }
            description
            coverImage {
              extraLarge
              large
              medium
            }
            bannerImage
            type
            format
            status
            season
            seasonYear
            episodes
            chapters
            volumes
            duration
            genres
            averageScore
            popularity
            favourites
            isFavourite
          }
        }
      }
    ''';

    final variables = <String, dynamic>{
      'search': search,
      'page': page,
      'perPage': perPage,
    };

    if (type != null) variables['type'] = type.name.toUpperCase();
    if (format != null) variables['format'] = format.name.toUpperCase();
    if (status != null) variables['status'] = status.name.toUpperCase();
    if (season != null) variables['season'] = season.toUpperCase();
    if (seasonYear != null) variables['seasonYear'] = seasonYear;
    if (genres != null && genres.isNotEmpty) variables['genres'] = genres;
    if (sort != null) variables['sort'] = [sort.toUpperCase()];

    final data = await _makeGraphQLRequest(
      query,
      variables,
      headers: accessToken != null ? {'Authorization': 'Bearer $accessToken'} : null,
    );

    final mediaList = (data['Page']['media'] as List<dynamic>)
        .map((item) => AniListMedia.fromJson(item))
        .toList();

    return mediaList;
  }

  // Trending Media
  Future<List<AniListMedia>> getTrendingMedia({
    int page = 1,
    int perPage = 20,
    AniListMediaType? type,
    String? accessToken,
  }) async {
    const query = '''
      query (\$page: Int, \$perPage: Int, \$type: MediaType, \$sort: [MediaSort]) {
        Page(page: \$page, perPage: \$perPage) {
          pageInfo {
            total
            perPage
            currentPage
            lastPage
            hasNextPage
          }
          media(type: \$type, sort: \$sort) {
            id
            title {
              romaji
              english
              native
            }
            description
            coverImage {
              extraLarge
              large
              medium
            }
            bannerImage
            type
            format
            status
            season
            seasonYear
            episodes
            chapters
            volumes
            duration
            genres
            averageScore
            popularity
            favourites
            isFavourite
          }
        }
      }
    ''';

    final variables = <String, dynamic>{
      'page': page,
      'perPage': perPage,
      'sort': ['TRENDING_DESC'],
    };

    if (type != null) variables['type'] = type.name.toUpperCase();

    final data = await _makeGraphQLRequest(
      query,
      variables,
      headers: accessToken != null ? {'Authorization': 'Bearer $accessToken'} : null,
    );

    final mediaList = (data['Page']['media'] as List<dynamic>)
        .map((item) => AniListMedia.fromJson(item))
        .toList();

    return mediaList;
  }

  // Popular Media
  Future<List<AniListMedia>> getPopularMedia({
    int page = 1,
    int perPage = 20,
    AniListMediaType? type,
    String? accessToken,
  }) async {
    const query = '''
      query (\$page: Int, \$perPage: Int, \$type: MediaType, \$sort: [MediaSort]) {
        Page(page: \$page, perPage: \$perPage) {
          pageInfo {
            total
            perPage
            currentPage
            lastPage
            hasNextPage
          }
          media(type: \$type, sort: \$sort) {
            id
            title {
              romaji
              english
              native
            }
            description
            coverImage {
              extraLarge
              large
              medium
            }
            bannerImage
            type
            format
            status
            season
            seasonYear
            episodes
            chapters
            volumes
            duration
            genres
            averageScore
            popularity
            favourites
            isFavourite
          }
        }
      }
    ''';

    final variables = <String, dynamic>{
      'page': page,
      'perPage': perPage,
      'sort': ['POPULARITY_DESC'],
    };

    if (type != null) variables['type'] = type.name.toUpperCase();

    final data = await _makeGraphQLRequest(
      query,
      variables,
      headers: accessToken != null ? {'Authorization': 'Bearer $accessToken'} : null,
    );

    final mediaList = (data['Page']['media'] as List<dynamic>)
        .map((item) => AniListMedia.fromJson(item))
        .toList();

    return mediaList;
  }

  // Seasonal Media
  Future<List<AniListMedia>> getSeasonalMedia({
    required AniListMediaSeason season,
    required int year,
    int page = 1,
    int perPage = 20,
    AniListMediaType? type,
    String? accessToken,
  }) async {
    const query = '''
      query (\$page: Int, \$perPage: Int, \$type: MediaType, \$season: MediaSeason, \$seasonYear: Int, \$sort: [MediaSort]) {
        Page(page: \$page, perPage: \$perPage) {
          pageInfo {
            total
            perPage
            currentPage
            lastPage
            hasNextPage
          }
          media(type: \$type, season: \$season, seasonYear: \$seasonYear, sort: \$sort) {
            id
            title {
              romaji
              english
              native
            }
            description
            coverImage {
              extraLarge
              large
              medium
            }
            bannerImage
            type
            format
            status
            season
            seasonYear
            episodes
            chapters
            volumes
            duration
            genres
            averageScore
            popularity
            favourites
            isFavourite
          }
        }
      }
    ''';

    final variables = <String, dynamic>{
      'page': page,
      'perPage': perPage,
      'season': season.name.toUpperCase(),
      'seasonYear': year,
      'sort': ['POPULARITY_DESC'],
    };

    if (type != null) variables['type'] = type.name.toUpperCase();

    final data = await _makeGraphQLRequest(
      query,
      variables,
      headers: accessToken != null ? {'Authorization': 'Bearer $accessToken'} : null,
    );

    final mediaList = (data['Page']['media'] as List<dynamic>)
        .map((item) => AniListMedia.fromJson(item))
        .toList();

    return mediaList;
  }

  // User Media List
  Future<AniListMediaListCollection> getUserMediaList({
    required int userId,
    AniListMediaType? type,
    AniListMediaListStatus? status,
    int page = 1,
    int perPage = 50,
    String? accessToken,
  }) async {
    const query = '''
      query (\$userId: Int, \$type: MediaType, \$status: MediaListStatus, \$page: Int, \$perPage: Int) {
        MediaListCollection(userId: \$userId, type: \$type, status: \$status, perPage: \$perPage, page: \$page) {
          lists {
            entries {
              id
              mediaId
              status
              score
              progress
              progressVolumes
              repeat
              priority
              private
              notes
              hiddenFromStatusLists
              customLists
              advancedScores
              advancedScoresFormatted
              startedAt
              completedAt
              updatedAt
              createdAt
              media {
                id
                title {
                  romaji
                  english
                  native
                }
                description
                coverImage {
                  extraLarge
                  large
                  medium
                }
                bannerImage
                type
                format
                status
                season
                seasonYear
                episodes
                chapters
                volumes
                duration
                genres
                averageScore
                popularity
                favourites
                isFavourite
              }
            }
          }
          hasNextChunk
          nextChunk
        }
      }
    ''';

    final variables = <String, dynamic>{
      'userId': userId,
      'page': page,
      'perPage': perPage,
    };

    if (type != null) variables['type'] = type.name.toUpperCase();
    if (status != null) variables['status'] = status.name.toUpperCase();

    return _makeGraphQLRequest(
      query,
      variables,
      headers: accessToken != null ? {'Authorization': 'Bearer $accessToken'} : null,
      fromJson: (data) => AniListMediaListCollection.fromJson(data['MediaListCollection']),
    );
  }

  // Save Media List Entry
  Future<AniListMediaList> saveMediaListEntry({
    required int mediaId,
    AniListMediaListStatus? status,
    int? score,
    int? progress,
    int? progressVolumes,
    int? repeat,
    int? priority,
    bool? private,
    String? notes,
    bool? hiddenFromStatusLists,
    String? accessToken,
  }) async {
    const query = '''
      mutation (\$mediaId: Int, \$status: MediaListStatus, \$score: Int, \$progress: Int, \$progressVolumes: Int, \$repeat: Int, \$priority: Int, \$private: Boolean, \$notes: String, \$hiddenFromStatusLists: Boolean) {
        SaveMediaListEntry(mediaId: \$mediaId, status: \$status, score: \$score, progress: \$progress, progressVolumes: \$progressVolumes, repeat: \$repeat, priority: \$priority, private: \$private, notes: \$notes, hiddenFromStatusLists: \$hiddenFromStatusLists) {
          id
          mediaId
          status
          score
          progress
          progressVolumes
          repeat
          priority
          private
          notes
          hiddenFromStatusLists
          customLists
          advancedScores
          advancedScoresFormatted
          startedAt
          completedAt
          updatedAt
          createdAt
        }
      }
    ''';

    final variables = <String, dynamic>{
      'mediaId': mediaId,
    };

    if (status != null) variables['status'] = status.name.toUpperCase();
    if (score != null) variables['score'] = score;
    if (progress != null) variables['progress'] = progress;
    if (progressVolumes != null) variables['progressVolumes'] = progressVolumes;
    if (repeat != null) variables['repeat'] = repeat;
    if (priority != null) variables['priority'] = priority;
    if (private != null) variables['private'] = private;
    if (notes != null) variables['notes'] = notes;
    if (hiddenFromStatusLists != null) variables['hiddenFromStatusLists'] = hiddenFromStatusLists;

    return _makeGraphQLRequest(
      query,
      variables,
      headers: {'Authorization': 'Bearer $accessToken'},
      fromJson: (data) => AniListMediaList.fromJson(data['SaveMediaListEntry']),
    );
  }

  // Delete Media List Entry
  Future<bool> deleteMediaListEntry({
    required int mediaId,
    required String accessToken,
  }) async {
    const query = '''
      mutation (\$mediaId: Int) {
        DeleteMediaListEntry(mediaId: \$mediaId) {
          deleted
        }
      }
    ''';

    final data = await _makeGraphQLRequest(
      query,
      {'mediaId': mediaId},
      headers: {'Authorization': 'Bearer $accessToken'},
    );

    return data['DeleteMediaListEntry']['deleted'] as bool;
  }

  // Recommendations
  Future<List<AniListRecommendation>> getRecommendations({
    int page = 1,
    int perPage = 20,
    AniListMediaType? type,
    String? accessToken,
  }) async {
    const query = '''
      query (\$page: Int, \$perPage: Int, \$type: MediaType) {
        Page(page: \$page, perPage: \$perPage) {
          recommendations(mediaType: \$type, sort: RATING_DESC) {
            id
            rating
            userRating
            media {
              id
              title {
                romaji
                english
                native
              }
              description
              coverImage {
                extraLarge
                large
                medium
              }
              bannerImage
              type
              format
              status
              season
              seasonYear
              episodes
              chapters
              volumes
              duration
              genres
              averageScore
              popularity
              favourites
              isFavourite
            }
            mediaRecommendation {
              id
              title {
                romaji
                english
                native
              }
              description
              coverImage {
                extraLarge
                large
                medium
              }
              bannerImage
              type
              format
              status
              season
              seasonYear
              episodes
              chapters
              volumes
              duration
              genres
              averageScore
              popularity
              favourites
              isFavourite
            }
            user {
              id
              name
              avatar {
                large
              }
            }
          }
        }
      }
    ''';

    final variables = <String, dynamic>{
      'page': page,
      'perPage': perPage,
    };

    if (type != null) variables['type'] = type.name.toUpperCase();

    final data = await _makeGraphQLRequest(
      query,
      variables,
      headers: accessToken != null ? {'Authorization': 'Bearer $accessToken'} : null,
    );

    final recommendations = (data['Page']['recommendations'] as List<dynamic>)
        .map((item) => AniListRecommendation.fromJson(item))
        .toList();

    return recommendations;
  }

  void dispose() {
    _client.close();
  }
  // Mutations
  Future<AniListMediaList?> saveMediaToList({
    required int mediaId,
    AniListMediaListStatus? status,
    int? score,
    int? progress,
  }) async {
    final mutation = '''
      mutation (\$mediaId: Int, \$status: MediaListStatus, \$score: Int, \$progress: Int) {
        SaveMediaListEntry(mediaId: \$mediaId, status: \$status, score: \$score, progress: \$progress) {
          id
          mediaId
          status
          score
          progress
        }
      }
    ''';

    final data = await _makeGraphQLRequest(
      mutation,
      {
        'mediaId': mediaId,
        'status': status?.name.toUpperCase(),
        'score': score,
        'progress': progress,
      },
    );

    if (data['SaveMediaListEntry'] != null) {
      return AniListMediaList.fromJson(data['SaveMediaListEntry']);
    }
    return null;
  }
}

class AniListApiException implements Exception {
  final String message;
  final int statusCode;

  const AniListApiException(this.message, this.statusCode);

  @override
  String toString() => 'AniListApiException: $message (Status: $statusCode)';
}
