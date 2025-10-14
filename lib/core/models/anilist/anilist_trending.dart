import 'anilist_media.dart';

class AniListTrending {
  final AniListMedia media;
  final int trending;

  const AniListTrending({
    required this.media,
    required this.trending,
  });

  factory AniListTrending.fromJson(Map<String, dynamic> json) {
    return AniListTrending(
      media: AniListMedia.fromJson(json['media']),
      trending: json['trending'] as int,
    );
  }
}

class AniListSeasonal {
  final AniListMedia media;
  final int? trending;

  const AniListSeasonal({
    required this.media,
    this.trending,
  });

  factory AniListSeasonal.fromJson(Map<String, dynamic> json) {
    return AniListSeasonal(
      media: AniListMedia.fromJson(json['media']),
      trending: json['trending'] as int?,
    );
  }
}
