import 'anilist_media.dart';

class AniListMediaList {
  final int id;
  final int mediaId;
  final AniListMediaListStatus? status;
  final int? score;
  final int? progress;
  final int? progressVolumes;
  final int? repeat;
  final int? priority;
  final bool? private;
  final String? notes;
  final bool? hiddenFromStatusLists;
  final String? customLists;
  final bool? advancedScores;
  final String? advancedScoresFormatted;
  final DateTime? startedAt;
  final DateTime? completedAt;
  final DateTime? updatedAt;
  final DateTime? createdAt;
  final AniListMedia? media;

  const AniListMediaList({
    required this.id,
    required this.mediaId,
    this.status,
    this.score,
    this.progress,
    this.progressVolumes,
    this.repeat,
    this.priority,
    this.private,
    this.notes,
    this.hiddenFromStatusLists,
    this.customLists,
    this.advancedScores,
    this.advancedScoresFormatted,
    this.startedAt,
    this.completedAt,
    this.updatedAt,
    this.createdAt,
    this.media,
  });

  factory AniListMediaList.fromJson(Map<String, dynamic> json) {
    return AniListMediaList(
      id: json['id'] as int,
      mediaId: json['mediaId'] as int,
      status: AniListMediaListStatus.fromString(json['status'] as String?),
      score: json['score'] as int?,
      progress: json['progress'] as int?,
      progressVolumes: json['progressVolumes'] as int?,
      repeat: json['repeat'] as int?,
      priority: json['priority'] as int?,
      private: json['private'] as bool?,
      notes: json['notes'] as String?,
      hiddenFromStatusLists: json['hiddenFromStatusLists'] as bool?,
      customLists: json['customLists'] as String?,
      advancedScores: json['advancedScores'] != null,
      advancedScoresFormatted: json['advancedScoresFormatted'] as String?,
      startedAt: json['startedAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(
              (json['startedAt'] as int) * 1000,
            )
          : null,
      completedAt: json['completedAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(
              (json['completedAt'] as int) * 1000,
            )
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(
              (json['updatedAt'] as int) * 1000,
            )
          : null,
      createdAt: json['createdAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(
              (json['createdAt'] as int) * 1000,
            )
          : null,
      media: json['media'] != null
          ? AniListMedia.fromJson(json['media'])
          : null,
    );
  }

  bool get isCompleted => status == AniListMediaListStatus.completed;
  bool get isWatching => status == AniListMediaListStatus.current;
  bool get isPlanning => status == AniListMediaListStatus.planning;
  bool get isPaused => status == AniListMediaListStatus.paused;
  bool get isDropped => status == AniListMediaListStatus.dropped;

  double get progressPercentage {
    if (media?.episodes == null || media!.episodes! <= 0) return 0.0;
    return (progress ?? 0) / media!.episodes! * 100;
  }
}

class AniListMediaListCollection {
  final List<AniListMediaList> lists;
  final bool hasNextChunk;
  final String? nextChunk;

  const AniListMediaListCollection({
    required this.lists,
    required this.hasNextChunk,
    this.nextChunk,
  });

  factory AniListMediaListCollection.fromJson(Map<String, dynamic> json) {
    final listsData = json['lists'] as List<dynamic>? ?? [];
    final allLists = <AniListMediaList>[];

    for (final listData in listsData) {
      if (listData['entries'] != null) {
        final entries = listData['entries'] as List<dynamic>;
        for (final entry in entries) {
          allLists.add(AniListMediaList.fromJson(entry));
        }
      }
    }

    return AniListMediaListCollection(
      lists: allLists,
      hasNextChunk: json['hasNextChunk'] as bool? ?? false,
      nextChunk: json['nextChunk'] as String?,
    );
  }

  List<AniListMediaList> get watching =>
      lists.where((item) => item.isWatching).toList();

  List<AniListMediaList> get completed =>
      lists.where((item) => item.isCompleted).toList();

  List<AniListMediaList> get planning =>
      lists.where((item) => item.isPlanning).toList();

  List<AniListMediaList> get paused =>
      lists.where((item) => item.isPaused).toList();

  List<AniListMediaList> get dropped =>
      lists.where((item) => item.isDropped).toList();
}

enum AniListMediaListStatus {
  current,
  planning,
  completed,
  dropped,
  paused,
  repeating;

  static AniListMediaListStatus? fromString(String? value) {
    switch (value?.toLowerCase()) {
      case 'current':
        return AniListMediaListStatus.current;
      case 'planning':
      case 'plan_to_watch':
      case 'plantowatch':
        return AniListMediaListStatus.planning;
      case 'completed':
        return AniListMediaListStatus.completed;
      case 'dropped':
        return AniListMediaListStatus.dropped;
      case 'paused':
        return AniListMediaListStatus.paused;
      case 'repeating':
      case 'repeat':
        return AniListMediaListStatus.repeating;
      default:
        return null;
    }
  }

  String get displayName {
    switch (this) {
      case AniListMediaListStatus.current:
        return 'Watching';
      case AniListMediaListStatus.planning:
        return 'Plan to Watch';
      case AniListMediaListStatus.completed:
        return 'Completed';
      case AniListMediaListStatus.dropped:
        return 'Dropped';
      case AniListMediaListStatus.paused:
        return 'Paused';
      case AniListMediaListStatus.repeating:
        return 'Repeating';
    }
  }
}
