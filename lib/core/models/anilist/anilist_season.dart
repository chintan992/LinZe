import 'anilist_media.dart';

class AniListSeason {
  final AniListMediaSeason season;
  final int year;
  final List<AniListMedia> media;

  const AniListSeason({
    required this.season,
    required this.year,
    required this.media,
  });

  factory AniListSeason.fromJson(Map<String, dynamic> json) {
    return AniListSeason(
      season: AniListMediaSeason.values.firstWhere(
        (s) =>
            s.name.toUpperCase() == (json['season'] as String?)?.toUpperCase(),
        orElse: () => AniListMediaSeason.winter,
      ),
      year: json['year'] as int,
      media: (json['media'] as List<dynamic>)
          .map((item) => AniListMedia.fromJson(item))
          .toList(),
    );
  }
}
