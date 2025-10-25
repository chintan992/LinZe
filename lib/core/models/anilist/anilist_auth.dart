class AniListAuthTokens {
  final String accessToken;
  final String? refreshToken;
  final DateTime expiresAt;
  final String tokenType;

  const AniListAuthTokens({
    required this.accessToken,
    this.refreshToken,
    required this.expiresAt,
    this.tokenType = 'Bearer',
  });

  factory AniListAuthTokens.fromJson(Map<String, dynamic> json) {
    return AniListAuthTokens(
      accessToken: json['access_token'] as String,
      refreshToken: json['refresh_token'] as String?,
      expiresAt: DateTime.now().add(
        Duration(seconds: (json['expires_in'] as num?)?.toInt() ?? 3600),
      ),
      tokenType: json['token_type'] as String? ?? 'Bearer',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'access_token': accessToken,
      'refresh_token': refreshToken,
      'expires_at': expiresAt.toIso8601String(),
      'token_type': tokenType,
    };
  }

  bool get isExpired => DateTime.now().isAfter(expiresAt);

  bool get needsRefresh =>
      refreshToken != null &&
      DateTime.now().isAfter(expiresAt.subtract(const Duration(minutes: 5)));
}

class AniListUser {
  final int id;
  final String name;
  final String? avatar;
  final String? banner;
  final String? about;
  final int? unreadNotificationCount;
  final AniListUserStats? stats;

  const AniListUser({
    required this.id,
    required this.name,
    this.avatar,
    this.banner,
    this.about,
    this.unreadNotificationCount,
    this.stats,
  });

  factory AniListUser.fromJson(Map<String, dynamic> json) {
    // Safely extract avatar which may be a map or a string
    String? avatar;
    final avatarRaw = json['avatar'];
    if (avatarRaw is Map<String, dynamic>) {
      avatar = avatarRaw['large'] as String?;
    } else if (avatarRaw is String) {
      avatar = avatarRaw;
    } else {
      avatar = null;
    }

    final statsRaw = json['statistics'];

    return AniListUser(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      avatar: avatar,
      banner: json['bannerImage'] as String?,
      about: json['about'] as String?,
      unreadNotificationCount: (json['unreadNotificationCount'] as num?)
          ?.toInt(),
      stats: statsRaw is Map<String, dynamic>
          ? AniListUserStats.fromJson(statsRaw)
          : null,
    );
  }
}

class AniListUserStats {
  final AniListAnimeStats? anime;
  final AniListMangaStats? manga;

  const AniListUserStats({this.anime, this.manga});

  factory AniListUserStats.fromJson(dynamic json) {
    if (json is! Map<String, dynamic>) {
      return const AniListUserStats(anime: null, manga: null);
    }

    return AniListUserStats(
      anime: json['anime'] != null
          ? AniListAnimeStats.fromJson(json['anime'])
          : null,
      manga: json['manga'] != null
          ? AniListMangaStats.fromJson(json['manga'])
          : null,
    );
  }
}

class AniListAnimeStats {
  final int count;
  final int meanScore;
  final int standardDeviation;
  final int minutesWatched;
  final int episodesWatched;

  const AniListAnimeStats({
    required this.count,
    required this.meanScore,
    required this.standardDeviation,
    required this.minutesWatched,
    required this.episodesWatched,
  });

  factory AniListAnimeStats.fromJson(dynamic json) {
    if (json is Map<String, dynamic>) {
      return AniListAnimeStats(
        count: (json['count'] as num?)?.toInt() ?? 0,
        meanScore: (json['meanScore'] as num?)?.toInt() ?? 0,
        standardDeviation: (json['standardDeviation'] as num?)?.toInt() ?? 0,
        minutesWatched: (json['minutesWatched'] as num?)?.toInt() ?? 0,
        episodesWatched: (json['episodesWatched'] as num?)?.toInt() ?? 0,
      );
    }

    // If AniList returns a numeric value for this node, interpret it as count
    if (json is num) {
      return AniListAnimeStats(
        count: json.toInt(),
        meanScore: 0,
        standardDeviation: 0,
        minutesWatched: 0,
        episodesWatched: 0,
      );
    }

    return const AniListAnimeStats(
      count: 0,
      meanScore: 0,
      standardDeviation: 0,
      minutesWatched: 0,
      episodesWatched: 0,
    );
  }
}

class AniListMangaStats {
  final int count;
  final int meanScore;
  final int standardDeviation;
  final int chaptersRead;
  final int volumesRead;

  const AniListMangaStats({
    required this.count,
    required this.meanScore,
    required this.standardDeviation,
    required this.chaptersRead,
    required this.volumesRead,
  });

  factory AniListMangaStats.fromJson(dynamic json) {
    if (json is Map<String, dynamic>) {
      return AniListMangaStats(
        count: (json['count'] as num?)?.toInt() ?? 0,
        meanScore: (json['meanScore'] as num?)?.toInt() ?? 0,
        standardDeviation: (json['standardDeviation'] as num?)?.toInt() ?? 0,
        chaptersRead: (json['chaptersRead'] as num?)?.toInt() ?? 0,
        volumesRead: (json['volumesRead'] as num?)?.toInt() ?? 0,
      );
    }

    if (json is num) {
      return AniListMangaStats(
        count: json.toInt(),
        meanScore: 0,
        standardDeviation: 0,
        chaptersRead: 0,
        volumesRead: 0,
      );
    }

    return const AniListMangaStats(
      count: 0,
      meanScore: 0,
      standardDeviation: 0,
      chaptersRead: 0,
      volumesRead: 0,
    );
  }
}
