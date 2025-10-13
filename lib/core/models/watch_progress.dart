class WatchProgress {
  final String animeId;
  final String episodeId;
  final double progress; // 0.0 to 1.0 (percentage)
  final DateTime lastWatched;
  final Duration totalWatchTime;
  final bool isCompleted;
  final Duration episodeDuration;

  const WatchProgress({
    required this.animeId,
    required this.episodeId,
    required this.progress,
    required this.lastWatched,
    required this.totalWatchTime,
    required this.isCompleted,
    required this.episodeDuration,
  });

  factory WatchProgress.fromJson(Map<String, dynamic> json) {
    return WatchProgress(
      animeId: json['animeId'] ?? '',
      episodeId: json['episodeId'] ?? '',
      progress: (json['progress'] ?? 0.0).toDouble(),
      lastWatched: DateTime.parse(json['lastWatched'] ?? DateTime.now().toIso8601String()),
      totalWatchTime: Duration(seconds: json['totalWatchTime'] ?? 0),
      isCompleted: json['isCompleted'] ?? false,
      episodeDuration: Duration(seconds: json['episodeDuration'] ?? 0),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'animeId': animeId,
      'episodeId': episodeId,
      'progress': progress,
      'lastWatched': lastWatched.toIso8601String(),
      'totalWatchTime': totalWatchTime.inSeconds,
      'isCompleted': isCompleted,
      'episodeDuration': episodeDuration.inSeconds,
    };
  }

  WatchProgress copyWith({
    String? animeId,
    String? episodeId,
    double? progress,
    DateTime? lastWatched,
    Duration? totalWatchTime,
    bool? isCompleted,
    Duration? episodeDuration,
  }) {
    return WatchProgress(
      animeId: animeId ?? this.animeId,
      episodeId: episodeId ?? this.episodeId,
      progress: progress ?? this.progress,
      lastWatched: lastWatched ?? this.lastWatched,
      totalWatchTime: totalWatchTime ?? this.totalWatchTime,
      isCompleted: isCompleted ?? this.isCompleted,
      episodeDuration: episodeDuration ?? this.episodeDuration,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is WatchProgress &&
        other.animeId == animeId &&
        other.episodeId == episodeId;
  }

  @override
  int get hashCode => animeId.hashCode ^ episodeId.hashCode;
}

class WatchProgressStats {
  final String animeId;
  final int totalEpisodes;
  final int watchedEpisodes;
  final int completedEpisodes;
  final Duration totalWatchTime;
  final DateTime lastWatched;
  final double overallProgress; // 0.0 to 1.0

  const WatchProgressStats({
    required this.animeId,
    required this.totalEpisodes,
    required this.watchedEpisodes,
    required this.completedEpisodes,
    required this.totalWatchTime,
    required this.lastWatched,
    required this.overallProgress,
  });

  factory WatchProgressStats.fromProgressList(
    String animeId,
    List<WatchProgress> progressList,
    int totalEpisodes,
  ) {
    final watchedEpisodes = progressList.length;
    final completedEpisodes = progressList.where((p) => p.isCompleted).length;
    final totalWatchTime = progressList.fold<Duration>(
      Duration.zero,
      (total, progress) => total + progress.totalWatchTime,
    );
    final lastWatched = progressList.isNotEmpty
        ? progressList
            .reduce((a, b) => a.lastWatched.isAfter(b.lastWatched) ? a : b)
            .lastWatched
        : DateTime.now();
    final overallProgress = totalEpisodes > 0 ? completedEpisodes / totalEpisodes : 0.0;

    return WatchProgressStats(
      animeId: animeId,
      totalEpisodes: totalEpisodes,
      watchedEpisodes: watchedEpisodes,
      completedEpisodes: completedEpisodes,
      totalWatchTime: totalWatchTime,
      lastWatched: lastWatched,
      overallProgress: overallProgress,
    );
  }

  factory WatchProgressStats.fromJson(Map<String, dynamic> json) {
    return WatchProgressStats(
      animeId: json['animeId'] ?? '',
      totalEpisodes: json['totalEpisodes'] ?? 0,
      watchedEpisodes: json['watchedEpisodes'] ?? 0,
      completedEpisodes: json['completedEpisodes'] ?? 0,
      totalWatchTime: Duration(seconds: json['totalWatchTime'] ?? 0),
      lastWatched: DateTime.parse(json['lastWatched'] ?? DateTime.now().toIso8601String()),
      overallProgress: (json['overallProgress'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'animeId': animeId,
      'totalEpisodes': totalEpisodes,
      'watchedEpisodes': watchedEpisodes,
      'completedEpisodes': completedEpisodes,
      'totalWatchTime': totalWatchTime.inSeconds,
      'lastWatched': lastWatched.toIso8601String(),
      'overallProgress': overallProgress,
    };
  }
}

enum WatchStatus {
  notWatched,
  inProgress,
  completed,
}

extension WatchStatusExtension on WatchStatus {
  String get displayName {
    switch (this) {
      case WatchStatus.notWatched:
        return 'Not Watched';
      case WatchStatus.inProgress:
        return 'In Progress';
      case WatchStatus.completed:
        return 'Completed';
    }
  }
}
