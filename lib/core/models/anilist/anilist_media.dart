class AniListMedia {
  final int id;
  final AniListMediaTitle? title;
  final String? description;
  final AniListMediaCoverImage? coverImage;
  final String? bannerImage;
  final AniListMediaType? type;
  final AniListMediaFormat? format;
  final AniListMediaStatus? status;
  final AniListMediaSeason? season;
  final int? seasonYear;
  final int? episodes;
  final int? chapters;
  final int? volumes;
  final int? duration;
  final List<String>? genres;
  final List<String>? tags;
  final AniListMediaScore? averageScore;
  final int? popularity;
  final int? favourites;
  final bool? isFavourite;
  final AniListMediaTrailer? trailer;
  final List<AniListMediaRelation>? relations;
  // Characters and staff are loaded separately to avoid circular dependencies

  const AniListMedia({
    required this.id,
    this.title,
    this.description,
    this.coverImage,
    this.bannerImage,
    this.type,
    this.format,
    this.status,
    this.season,
    this.seasonYear,
    this.episodes,
    this.chapters,
    this.volumes,
    this.duration,
    this.genres,
    this.tags,
    this.averageScore,
    this.popularity,
    this.favourites,
    this.isFavourite,
    this.trailer,
    this.relations,
  });

  factory AniListMedia.fromJson(Map<String, dynamic> json) {
    return AniListMedia(
      id: json['id'] as int,
      title: json['title'] != null
          ? AniListMediaTitle.fromJson(json['title'])
          : null,
      description: json['description'] as String?,
      coverImage: json['coverImage'] != null
          ? AniListMediaCoverImage.fromJson(json['coverImage'])
          : null,
      bannerImage: json['bannerImage'] as String?,
      type: AniListMediaType.fromString(json['type'] as String?),
      format: AniListMediaFormat.fromString(json['format'] as String?),
      status: AniListMediaStatus.fromString(json['status'] as String?),
      season: AniListMediaSeason.fromString(json['season'] as String?),
      seasonYear: json['seasonYear'] as int?,
      episodes: json['episodes'] as int?,
      chapters: json['chapters'] as int?,
      volumes: json['volumes'] as int?,
      duration: json['duration'] as int?,
      genres: (json['genres'] as List<dynamic>?)?.cast<String>(),
      tags: (json['tags'] as List<dynamic>?)
          ?.map(
            (tag) => tag is Map<String, dynamic>
                ? tag['name'] as String
                : tag.toString(),
          )
          .toList(),
      averageScore: json['averageScore'] != null
          ? AniListMediaScore.fromJson(json['averageScore'])
          : null,
      popularity: json['popularity'] as int?,
      favourites: json['favourites'] as int?,
      isFavourite: json['isFavourite'] as bool?,
      trailer: json['trailer'] != null
          ? AniListMediaTrailer.fromJson(json['trailer'])
          : null,
      relations: json['relations']?['edges'] != null
          ? (json['relations']['edges'] as List<dynamic>)
                .map((edge) => AniListMediaRelation.fromJson(edge))
                .toList()
          : null,
    );
  }

  String get displayTitle =>
      title?.english ?? title?.romaji ?? title?.native ?? 'Unknown';
  String? get coverUrl => coverImage?.large ?? coverImage?.medium;
  String? get thumbnailUrl => coverImage?.medium ?? coverImage?.large;
}

class AniListMediaTitle {
  final String? romaji;
  final String? english;
  final String? native;

  const AniListMediaTitle({this.romaji, this.english, this.native});

  factory AniListMediaTitle.fromJson(Map<String, dynamic> json) {
    return AniListMediaTitle(
      romaji: json['romaji'] as String?,
      english: json['english'] as String?,
      native: json['native'] as String?,
    );
  }
}

class AniListMediaCoverImage {
  final String? extraLarge;
  final String? large;
  final String? medium;

  const AniListMediaCoverImage({this.extraLarge, this.large, this.medium});

  factory AniListMediaCoverImage.fromJson(Map<String, dynamic> json) {
    return AniListMediaCoverImage(
      extraLarge: json['extraLarge'] as String?,
      large: json['large'] as String?,
      medium: json['medium'] as String?,
    );
  }
}

class AniListMediaTrailer {
  final String? id;
  final String? site;
  final String? thumbnail;

  const AniListMediaTrailer({this.id, this.site, this.thumbnail});

  factory AniListMediaTrailer.fromJson(Map<String, dynamic> json) {
    return AniListMediaTrailer(
      id: json['id'] as String?,
      site: json['site'] as String?,
      thumbnail: json['thumbnail'] as String?,
    );
  }
}

class AniListMediaRelation {
  final AniListMediaRelationType relationType;
  final AniListMedia node;

  const AniListMediaRelation({required this.relationType, required this.node});

  factory AniListMediaRelation.fromJson(Map<String, dynamic> json) {
    return AniListMediaRelation(
      relationType: AniListMediaRelationType.fromString(
        json['relationType'] as String?,
      ),
      node: AniListMedia.fromJson(json['node']),
    );
  }
}

class AniListMediaScore {
  final int? score;
  final int? amount;

  const AniListMediaScore({this.score, this.amount});

  factory AniListMediaScore.fromJson(Map<String, dynamic> json) {
    return AniListMediaScore(
      score: json['score'] as int?,
      amount: json['amount'] as int?,
    );
  }
}

// Enums
enum AniListMediaType {
  anime,
  manga;

  static AniListMediaType? fromString(String? value) {
    switch (value?.toLowerCase()) {
      case 'anime':
        return AniListMediaType.anime;
      case 'manga':
        return AniListMediaType.manga;
      default:
        return null;
    }
  }
}

enum AniListMediaFormat {
  tv,
  tvShort,
  movie,
  special,
  ova,
  ona,
  music,
  manga,
  novel,
  oneShot,
  manhwa,
  manhua,
  lightNovel;

  static AniListMediaFormat? fromString(String? value) {
    switch (value?.toLowerCase()) {
      case 'tv':
        return AniListMediaFormat.tv;
      case 'tv_short':
      case 'tvshort':
        return AniListMediaFormat.tvShort;
      case 'movie':
        return AniListMediaFormat.movie;
      case 'special':
        return AniListMediaFormat.special;
      case 'ova':
        return AniListMediaFormat.ova;
      case 'ona':
        return AniListMediaFormat.ona;
      case 'music':
        return AniListMediaFormat.music;
      case 'manga':
        return AniListMediaFormat.manga;
      case 'novel':
        return AniListMediaFormat.novel;
      case 'one_shot':
      case 'oneshot':
        return AniListMediaFormat.oneShot;
      case 'manhwa':
        return AniListMediaFormat.manhwa;
      case 'manhua':
        return AniListMediaFormat.manhua;
      case 'light_novel':
      case 'lightnovel':
        return AniListMediaFormat.lightNovel;
      default:
        return null;
    }
  }
}

enum AniListMediaStatus {
  finished,
  releasing,
  notYetReleased,
  cancelled,
  hiatus;

  static AniListMediaStatus? fromString(String? value) {
    switch (value?.toLowerCase()) {
      case 'finished':
        return AniListMediaStatus.finished;
      case 'releasing':
        return AniListMediaStatus.releasing;
      case 'not_yet_released':
      case 'notyetreleased':
        return AniListMediaStatus.notYetReleased;
      case 'cancelled':
        return AniListMediaStatus.cancelled;
      case 'hiatus':
        return AniListMediaStatus.hiatus;
      default:
        return null;
    }
  }
}

enum AniListMediaSeason {
  winter,
  spring,
  summer,
  fall;

  static AniListMediaSeason? fromString(String? value) {
    switch (value?.toLowerCase()) {
      case 'winter':
        return AniListMediaSeason.winter;
      case 'spring':
        return AniListMediaSeason.spring;
      case 'summer':
        return AniListMediaSeason.summer;
      case 'fall':
      case 'autumn':
        return AniListMediaSeason.fall;
      default:
        return null;
    }
  }
}

enum AniListMediaRelationType {
  adaptation,
  prequel,
  sequel,
  parent,
  sideStory,
  character,
  summary,
  alternative,
  spinOff,
  other,
  source,
  compilation,
  contains;

  static AniListMediaRelationType fromString(String? value) {
    switch (value?.toLowerCase()) {
      case 'adaptation':
        return AniListMediaRelationType.adaptation;
      case 'prequel':
        return AniListMediaRelationType.prequel;
      case 'sequel':
        return AniListMediaRelationType.sequel;
      case 'parent':
        return AniListMediaRelationType.parent;
      case 'side_story':
      case 'sidestory':
        return AniListMediaRelationType.sideStory;
      case 'character':
        return AniListMediaRelationType.character;
      case 'summary':
        return AniListMediaRelationType.summary;
      case 'alternative':
        return AniListMediaRelationType.alternative;
      case 'spin_off':
      case 'spinoff':
        return AniListMediaRelationType.spinOff;
      case 'other':
        return AniListMediaRelationType.other;
      case 'source':
        return AniListMediaRelationType.source;
      case 'compilation':
        return AniListMediaRelationType.compilation;
      case 'contains':
        return AniListMediaRelationType.contains;
      default:
        return AniListMediaRelationType.other;
    }
  }
}
