import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';

/// Enhanced video player controller with state management
class EnhancedVideoPlayerController extends StateNotifier<VideoPlayerState> {
  final VideoPlayerController _videoPlayerController;
  ChewieController? _chewieController;
  Timer? _progressTimer;
  Timer? _autoPlayTimer;

  // Callbacks
  final VoidCallback? onPositionChanged;
  final VoidCallback? onSkipIntro;
  final VoidCallback? onSkipOutro;
  final Function(Duration)? onProgressSaved;

  EnhancedVideoPlayerController({
    required VideoPlayerController videoPlayerController,
    this.onPositionChanged,
    this.onSkipIntro,
    this.onSkipOutro,
    this.onProgressSaved,
  }) : _videoPlayerController = videoPlayerController,
       super(VideoPlayerState.initial()) {
    _initialize();
  }

  void _initialize() {
    state = state.copyWith(isLoading: true);

    _videoPlayerController.addListener(_onVideoStateChanged);

    // Setup progress tracking
    _setupProgressTracking();
  }

  void _onVideoStateChanged() {
    if (!mounted) return;

    final newState = state.copyWith(
      isPlaying: _videoPlayerController.value.isPlaying,
      isInitialized: _videoPlayerController.value.isInitialized,
      position: _videoPlayerController.value.position,
      duration: _videoPlayerController.value.duration,
      buffered: _videoPlayerController.value.buffered,
      isBuffering: _videoPlayerController.value.isBuffering,
      volume: _videoPlayerController.value.volume,
      playbackSpeed: _videoPlayerController.value.playbackSpeed,
    );

    state = newState;
    onPositionChanged?.call();
  }

  void _setupProgressTracking() {
    _progressTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      if (state.isInitialized && state.isPlaying) {
        _saveProgress();
      }
    });
  }

  Future<void> _saveProgress() async {
    if (!state.isInitialized) return;

    final position = state.position;
    onProgressSaved?.call(position);
  }

  // Playback controls
  Future<void> play() async {
    await _videoPlayerController.play();
  }

  Future<void> pause() async {
    await _videoPlayerController.pause();
  }

  Future<void> seekTo(Duration position) async {
    await _videoPlayerController.seekTo(position);
  }

  Future<void> setPlaybackSpeed(double speed) async {
    await _videoPlayerController.setPlaybackSpeed(speed);
    state = state.copyWith(playbackSpeed: speed);
  }

  Future<void> setVolume(double volume) async {
    await _videoPlayerController.setVolume(volume);
    state = state.copyWith(volume: volume);
  }

  // Skip functionality
  void checkForAutoSkip(
    Map<String, dynamic>? intro,
    Map<String, dynamic>? outro,
  ) {
    if (!state.isInitialized) return;

    final currentPosition = state.position;

    // Auto-skip intro
    if (intro != null && !state.hasSkippedIntro) {
      final introStart = Duration(seconds: intro['start'] ?? 0);
      final introEnd = Duration(seconds: intro['end'] ?? 0);

      if (currentPosition >= introStart &&
          currentPosition <= introStart + const Duration(seconds: 5)) {
        seekTo(introEnd + const Duration(seconds: 2));
        state = state.copyWith(hasSkippedIntro: true);
        onSkipIntro?.call();
      }
    }

    // Auto-skip outro
    if (outro != null && !state.hasSkippedOutro) {
      final outroStart = Duration(seconds: outro['start'] ?? 0);
      final outroEnd = Duration(seconds: outro['end'] ?? 0);

      if (currentPosition >= outroStart &&
          currentPosition <= outroStart + const Duration(seconds: 5)) {
        seekTo(outroEnd + const Duration(seconds: 2));
        state = state.copyWith(hasSkippedOutro: true);
        onSkipOutro?.call();
      }
    }
  }

  // Episode navigation
  void setupAutoPlay(Duration remainingTime, VoidCallback onAutoPlay) {
    _autoPlayTimer?.cancel();
    if (remainingTime.inSeconds > 0 && remainingTime.inSeconds <= 30) {
      _autoPlayTimer = Timer(remainingTime, onAutoPlay);
    }
  }

  // Cleanup
  @override
  void dispose() {
    _progressTimer?.cancel();
    _autoPlayTimer?.cancel();
    _videoPlayerController.removeListener(_onVideoStateChanged);
    _videoPlayerController.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  @override
  bool get mounted => true; // Override in StateNotifier if needed
}

/// Video player state model
class VideoPlayerState {
  final bool isLoading;
  final bool isInitialized;
  final bool isPlaying;
  final bool isBuffering;
  final Duration position;
  final Duration duration;
  final List<DurationRange> buffered;
  final double volume;
  final double playbackSpeed;
  final bool hasSkippedIntro;
  final bool hasSkippedOutro;
  final String? errorMessage;

  const VideoPlayerState({
    required this.isLoading,
    required this.isInitialized,
    required this.isPlaying,
    required this.isBuffering,
    required this.position,
    required this.duration,
    required this.buffered,
    required this.volume,
    required this.playbackSpeed,
    required this.hasSkippedIntro,
    required this.hasSkippedOutro,
    this.errorMessage,
  });

  factory VideoPlayerState.initial() {
    return const VideoPlayerState(
      isLoading: true,
      isInitialized: false,
      isPlaying: false,
      isBuffering: false,
      position: Duration.zero,
      duration: Duration.zero,
      buffered: [],
      volume: 1.0,
      playbackSpeed: 1.0,
      hasSkippedIntro: false,
      hasSkippedOutro: false,
    );
  }

  VideoPlayerState copyWith({
    bool? isLoading,
    bool? isInitialized,
    bool? isPlaying,
    bool? isBuffering,
    Duration? position,
    Duration? duration,
    List<DurationRange>? buffered,
    double? volume,
    double? playbackSpeed,
    bool? hasSkippedIntro,
    bool? hasSkippedOutro,
    String? errorMessage,
  }) {
    return VideoPlayerState(
      isLoading: isLoading ?? this.isLoading,
      isInitialized: isInitialized ?? this.isInitialized,
      isPlaying: isPlaying ?? this.isPlaying,
      isBuffering: isBuffering ?? this.isBuffering,
      position: position ?? this.position,
      duration: duration ?? this.duration,
      buffered: buffered ?? this.buffered,
      volume: volume ?? this.volume,
      playbackSpeed: playbackSpeed ?? this.playbackSpeed,
      hasSkippedIntro: hasSkippedIntro ?? this.hasSkippedIntro,
      hasSkippedOutro: hasSkippedOutro ?? this.hasSkippedOutro,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
