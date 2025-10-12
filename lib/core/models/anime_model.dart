class Anime {
  final String id;
  final int dataId;
  final String poster;
  final String title;
  final String japaneseTitle;
  final String? description;
  final TvInfo? tvInfo;
  final bool? adultContent;
  final AnimeInfo? animeInfo;

  Anime({
    required this.id,
    required this.dataId,
    required this.poster,
    required this.title,
    required this.japaneseTitle,
    this.description,
    this.tvInfo,
    this.adultContent,
    this.animeInfo,
  });

  factory Anime.fromJson(Map<String, dynamic> json) {
    return Anime(
      id: json['id'] ?? '',
      dataId: int.tryParse(json['data_id']?.toString() ?? '0') ?? 0,
      poster: json['poster'] ?? '',
      title: json['title'] ?? '',
      japaneseTitle: json['japanese_title'] ?? '',
      description: json['description'],
      tvInfo: json['tvInfo'] != null ? TvInfo.fromJson(json['tvInfo']) : null,
      adultContent: json['adultContent'],
      animeInfo: json['animeInfo'] != null ? AnimeInfo.fromJson(json['animeInfo']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'data_id': dataId,
      'poster': poster,
      'title': title,
      'japanese_title': japaneseTitle,
      'description': description,
      'tvInfo': tvInfo?.toJson(),
      'adultContent': adultContent,
      'animeInfo': animeInfo?.toJson(),
    };
  }
}

class TvInfo {
  final String? showType;
  final String? duration;
  final String? sub;
  final String? dub;
  final String? eps;

  TvInfo({
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
      sub: json['sub']?.toString(),
      dub: json['dub']?.toString(),
      eps: json['eps']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'showType': showType,
      'duration': duration,
      'sub': sub,
      'dub': dub,
      'eps': eps,
    };
  }
}

class EpisodeInfo {
  final int? episodeNo;
  final String? id;
  final int? dataId;
  final String? title;
  final String? japaneseTitle;

  EpisodeInfo({
    this.episodeNo,
    this.id,
    this.dataId,
    this.title,
    this.japaneseTitle,
  });

  factory EpisodeInfo.fromJson(Map<String, dynamic> json) {
    return EpisodeInfo(
      episodeNo: json['episode_no'],
      id: json['id'],
      dataId: json['data_id'],
      title: json['title'],
      japaneseTitle: json['japanese_title'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'episode_no': episodeNo,
      'id': id,
      'data_id': dataId,
      'title': title,
      'japanese_title': japaneseTitle,
    };
  }
}

class AnimeInfo {
  final String? overview;
  final String? japanese;
  final String? synonyms;
  final String? aired;
  final String? premiered;
  final String? duration;
  final String? status;
  final String? malScore;
  final List<String>? genres;
  final String? studios;
  final List<String>? producers;

  AnimeInfo({
    this.overview,
    this.japanese,
    this.synonyms,
    this.aired,
    this.premiered,
    this.duration,
    this.status,
    this.malScore,
    this.genres,
    this.studios,
    this.producers,
  });

  factory AnimeInfo.fromJson(Map<String, dynamic> json) {
    return AnimeInfo(
      overview: json['Overview'],
      japanese: json['Japanese'],
      synonyms: json['Synonyms'],
      aired: json['Aired'],
      premiered: json['Premiered'],
      duration: json['Duration'],
      status: json['Status'],
      malScore: json['MAL Score'],
      genres: json['Genres'] != null
          ? List<String>.from(json['Genres'])
          : null,
      studios: json['Studios'],
      producers: json['Producers'] != null
          ? List<String>.from(json['Producers'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Overview': overview,
      'Japanese': japanese,
      'Synonyms': synonyms,
      'Aired': aired,
      'Premiered': premiered,
      'Duration': duration,
      'Status': status,
      'MAL Score': malScore,
      'Genres': genres,
      'Studios': studios,
      'Producers': producers,
    };
  }
}

class Season {
  final String id;
  final int dataNumber;
  final int dataId;
  final String season;
  final String title;
  final String japaneseTitle;
  final String seasonPoster;

  Season({
    required this.id,
    required this.dataNumber,
    required this.dataId,
    required this.season,
    required this.title,
    required this.japaneseTitle,
    required this.seasonPoster,
  });

  factory Season.fromJson(Map<String, dynamic> json) {
    return Season(
      id: json['id'] ?? '',
      dataNumber: json['data_number'] ?? 0,
      dataId: json['data_id'] ?? 0,
      season: json['season'] ?? '',
      title: json['title'] ?? '',
      japaneseTitle: json['japanese_title'] ?? '',
      seasonPoster: json['season_poster'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'data_number': dataNumber,
      'data_id': dataId,
      'season': season,
      'title': title,
      'japanese_title': japaneseTitle,
      'season_poster': seasonPoster,
    };
  }
}

class TopTenData {
  final List<TopAnime>? today;
  final List<TopAnime>? week;
  final List<TopAnime>? month;

  TopTenData({this.today, this.week, this.month});

  factory TopTenData.fromJson(Map<String, dynamic> json) {
    return TopTenData(
      today: json['today'] != null
          ? (json['today'] as List).map((e) => TopAnime.fromJson(e)).toList()
          : null,
      week: json['week'] != null
          ? (json['week'] as List).map((e) => TopAnime.fromJson(e)).toList()
          : null,
      month: json['month'] != null
          ? (json['month'] as List).map((e) => TopAnime.fromJson(e)).toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'today': today?.map((e) => e.toJson()).toList(),
      'week': week?.map((e) => e.toJson()).toList(),
      'month': month?.map((e) => e.toJson()).toList(),
    };
  }
}

class TopAnime {
  final String id;
  final int dataId;
  final int number;
  final String name;
  final String poster;
  final dynamic tvInfo;

  TopAnime({
    required this.id,
    required this.dataId,
    required this.number,
    required this.name,
    required this.poster,
    this.tvInfo,
  });

  factory TopAnime.fromJson(Map<String, dynamic> json) {
    return TopAnime(
      id: json['id'] ?? '',
      dataId: json['data_id'] ?? 0,
      number: json['number'] ?? 0,
      name: json['name'] ?? '',
      poster: json['poster'] ?? '',
      tvInfo: json['tvInfo'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'data_id': dataId,
      'number': number,
      'name': name,
      'poster': poster,
      'tvInfo': tvInfo,
    };
  }
}

class Episode {
  final int episodeNo;
  final String id;
  final String? title;
  final String? japaneseTitle;
  final bool? filler;

  Episode({
    required this.episodeNo,
    required this.id,
    this.title,
    this.japaneseTitle,
    this.filler,
  });

  factory Episode.fromJson(Map<String, dynamic> json) {
    return Episode(
      episodeNo: json['episode_no'] ?? 0,
      id: json['id'] ?? '',
      title: json['title'],
      japaneseTitle: json['japanese_title'],
      filler: json['filler'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'episode_no': episodeNo,
      'id': id,
      'title': title,
      'japanese_title': japaneseTitle,
      'filler': filler,
    };
  }
}