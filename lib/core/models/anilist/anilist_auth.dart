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
    return AniListUser(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      avatar: json['avatar']?['large'] as String?,
      banner: json['bannerImage'] as String?,
      about: json['about'] as String?,
      unreadNotificationCount: (json['unreadNotificationCount'] as num?)?.toInt(),
      stats: json['statistics'] != null 
          ? AniListUserStats.fromJson(json['statistics']) 
          : null,
    );
  }
}

class AniListUserStats {
  final AniListAnimeStats? anime;
  final AniListMangaStats? manga;

  const AniListUserStats({
    this.anime,
    this.manga,
  });

  factory AniListUserStats.fromJson(Map<String, dynamic> json) {
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

  factory AniListAnimeStats.fromJson(Map<String, dynamic> json) {
    return AniListAnimeStats(
      count: (json['count'] as num?)?.toInt() ?? 0,
      meanScore: (json['meanScore'] as num?)?.toInt() ?? 0,
      standardDeviation: (json['standardDeviation'] as num?)?.toInt() ?? 0,
      minutesWatched: (json['minutesWatched'] as num?)?.toInt() ?? 0,
      episodesWatched: (json['episodesWatched'] as num?)?.toInt() ?? 0,
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

  factory AniListMangaStats.fromJson(Map<String, dynamic> json) {
    return AniListMangaStats(
      count: (json['count'] as num?)?.toInt() ?? 0,
      meanScore: (json['meanScore'] as num?)?.toInt() ?? 0,
      standardDeviation: (json['standardDeviation'] as num?)?.toInt() ?? 0,
      chaptersRead: (json['chaptersRead'] as num?)?.toInt() ?? 0,
      volumesRead: (json['volumesRead'] as num?)?.toInt() ?? 0,
    );
  }
}
