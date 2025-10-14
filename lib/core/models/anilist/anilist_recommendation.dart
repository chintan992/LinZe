import 'anilist_media.dart';
import 'anilist_auth.dart';

class AniListRecommendation {
  final int id;
  final int rating;
  final int? userRating;
  final AniListMedia media;
  final AniListMedia? mediaRecommendation;
  final AniListUser? user;

  const AniListRecommendation({
    required this.id,
    required this.rating,
    this.userRating,
    required this.media,
    this.mediaRecommendation,
    this.user,
  });

  factory AniListRecommendation.fromJson(Map<String, dynamic> json) {
    return AniListRecommendation(
      id: json['id'] as int,
      rating: json['rating'] as int,
      userRating: json['userRating'] as int?,
      media: AniListMedia.fromJson(json['media']),
      mediaRecommendation: json['mediaRecommendation'] != null 
          ? AniListMedia.fromJson(json['mediaRecommendation']) 
          : null,
      user: json['user'] != null 
          ? AniListUser.fromJson(json['user']) 
          : null,
    );
  }
}
