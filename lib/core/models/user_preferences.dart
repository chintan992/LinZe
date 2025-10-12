class UserPreferences {
  final String preferredAudioType; // 'sub' or 'dub'
  final String defaultServer; // Server name like 'HD-2', 'HD-1', etc.
  final bool autoSkipIntro;
  final bool autoSkipOutro;
  final double defaultPlaybackSpeed;
  final bool notificationsEnabled;
  final bool dataSaverMode;
  final String streamingQuality; // 'auto', '1080p', '720p', '480p', '360p'

  const UserPreferences({
    this.preferredAudioType = 'sub',
    this.defaultServer = 'HD-2',
    this.autoSkipIntro = true,
    this.autoSkipOutro = true,
    this.defaultPlaybackSpeed = 1.0,
    this.notificationsEnabled = true,
    this.dataSaverMode = false,
    this.streamingQuality = 'auto',
  });

  UserPreferences copyWith({
    String? preferredAudioType,
    String? defaultServer,
    bool? autoSkipIntro,
    bool? autoSkipOutro,
    double? defaultPlaybackSpeed,
    bool? notificationsEnabled,
    bool? dataSaverMode,
    String? streamingQuality,
  }) {
    return UserPreferences(
      preferredAudioType: preferredAudioType ?? this.preferredAudioType,
      defaultServer: defaultServer ?? this.defaultServer,
      autoSkipIntro: autoSkipIntro ?? this.autoSkipIntro,
      autoSkipOutro: autoSkipOutro ?? this.autoSkipOutro,
      defaultPlaybackSpeed: defaultPlaybackSpeed ?? this.defaultPlaybackSpeed,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      dataSaverMode: dataSaverMode ?? this.dataSaverMode,
      streamingQuality: streamingQuality ?? this.streamingQuality,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'preferredAudioType': preferredAudioType,
      'defaultServer': defaultServer,
      'autoSkipIntro': autoSkipIntro,
      'autoSkipOutro': autoSkipOutro,
      'defaultPlaybackSpeed': defaultPlaybackSpeed,
      'notificationsEnabled': notificationsEnabled,
      'dataSaverMode': dataSaverMode,
      'streamingQuality': streamingQuality,
    };
  }

  factory UserPreferences.fromJson(Map<String, dynamic> json) {
    return UserPreferences(
      preferredAudioType: json['preferredAudioType'] ?? 'sub',
      defaultServer: json['defaultServer'] ?? 'HD-2',
      autoSkipIntro: json['autoSkipIntro'] ?? true,
      autoSkipOutro: json['autoSkipOutro'] ?? true,
      defaultPlaybackSpeed: (json['defaultPlaybackSpeed'] ?? 1.0).toDouble(),
      notificationsEnabled: json['notificationsEnabled'] ?? true,
      dataSaverMode: json['dataSaverMode'] ?? false,
      streamingQuality: json['streamingQuality'] ?? 'auto',
    );
  }
}
