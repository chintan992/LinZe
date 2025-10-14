class WatchlistItem {
  final String animeId;
  final String title;
  final String poster;
  final DateTime dateAdded;

  const WatchlistItem({
    required this.animeId,
    required this.title,
    required this.poster,
    required this.dateAdded,
  });

  factory WatchlistItem.fromJson(Map<String, dynamic> json) {
    return WatchlistItem(
      animeId: json['animeId'] ?? '',
      title: json['title'] ?? '',
      poster: json['poster'] ?? '',
      dateAdded: DateTime.parse(json['dateAdded'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'animeId': animeId,
      'title': title,
      'poster': poster,
      'dateAdded': dateAdded.toIso8601String(),
    };
  }

  WatchlistItem copyWith({
    String? animeId,
    String? title,
    String? poster,
    DateTime? dateAdded,
  }) {
    return WatchlistItem(
      animeId: animeId ?? this.animeId,
      title: title ?? this.title,
      poster: poster ?? this.poster,
      dateAdded: dateAdded ?? this.dateAdded,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is WatchlistItem && other.animeId == animeId;
  }

  @override
  int get hashCode => animeId.hashCode;

  @override
  String toString() {
    return 'WatchlistItem(animeId: $animeId, title: $title, dateAdded: $dateAdded)';
  }
}
