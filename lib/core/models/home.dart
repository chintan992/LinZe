class Spotlight {
  final String id;
  final int dataId;
  final String poster;
  final String title;
  final String japaneseTitle;
  final String description;
  final TvInfo tvInfo;

  Spotlight({
    required this.id,
    required this.dataId,
    required this.poster,
    required this.title,
    required this.japaneseTitle,
    required this.description,
    required this.tvInfo,
  });
}

class Trending {
  final String id;
  final int dataId;
  final int number;
  final String poster;
  final String title;
  final String japaneseTitle;

  Trending({
    required this.id,
    required this.dataId,
    required this.number,
    required this.poster,
    required this.title,
    required this.japaneseTitle,
  });
}

class Schedule {
  final String id;
  final int dataId;
  final String title;
  final String japaneseTitle;
  final String releaseDate;
  final String time;
  final int episodeNo;

  Schedule({
    required this.id,
    required this.dataId,
    required this.title,
    required this.japaneseTitle,
    required this.releaseDate,
    required this.time,
    required this.episodeNo,
  });

  factory Schedule.fromJson(Map<String, dynamic> json) {
    return Schedule(
      id: json['id'] ?? '',
      dataId: json['data_id'] ?? 0,
      title: json['title'] ?? '',
      japaneseTitle: json['japanese_title'] ?? '',
      releaseDate: json['releaseDate'] ?? '',
      time: json['time'] ?? '',
      episodeNo: json['episode_no'] ?? 0,
    );
  }
}

class TopAiring {
  final String id;
  final int dataId;
  final String poster;
  final String title;
  final String japaneseTitle;
  final String description;
  final TvInfo tvInfo;

  TopAiring({
    required this.id,
    required this.dataId,
    required this.poster,
    required this.title,
    required this.japaneseTitle,
    required this.description,
    required this.tvInfo,
  });
}

class MostPopular {
  final String id;
  final int dataId;
  final String poster;
  final String title;
  final String japaneseTitle;
  final String description;
  final TvInfo tvInfo;

  MostPopular({
    required this.id,
    required this.dataId,
    required this.poster,
    required this.title,
    required this.japaneseTitle,
    required this.description,
    required this.tvInfo,
  });
}

class MostFavorite {
  final String id;
  final int dataId;
  final String poster;
  final String title;
  final String japaneseTitle;
  final String description;
  final TvInfo tvInfo;

  MostFavorite({
    required this.id,
    required this.dataId,
    required this.poster,
    required this.title,
    required this.japaneseTitle,
    required this.description,
    required this.tvInfo,
  });
}

class LatestCompleted {
  final String id;
  final int dataId;
  final String poster;
  final String title;
  final String japaneseTitle;
  final String description;
  final TvInfo tvInfo;

  LatestCompleted({
    required this.id,
    required this.dataId,
    required this.poster,
    required this.title,
    required this.japaneseTitle,
    required this.description,
    required this.tvInfo,
  });
}

class LatestEpisode {
  final String id;
  final int dataId;
  final String poster;
  final String title;
  final String japaneseTitle;
  final String description;
  final TvInfo tvInfo;

  LatestEpisode({
    required this.id,
    required this.dataId,
    required this.poster,
    required this.title,
    required this.japaneseTitle,
    required this.description,
    required this.tvInfo,
  });
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
}

class Home {
  final List<Spotlight> spotlights;
  final List<Trending> trending;
  final List<Schedule> today;
  final List<TopAiring> topAiring;
  final List<MostPopular> mostPopular;
  final List<MostFavorite> mostFavorite;
  final List<LatestCompleted> latestCompleted;
  final List<LatestEpisode> latestEpisode;
  final List<String> genres;

  Home({
    required this.spotlights,
    required this.trending,
    required this.today,
    required this.topAiring,
    required this.mostPopular,
    required this.mostFavorite,
    required this.latestCompleted,
    required this.latestEpisode,
    required this.genres,
  });
}
