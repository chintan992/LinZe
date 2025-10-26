import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:chewie/chewie.dart';
import 'package:video_player/video_player.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:linze/core/models/streaming_models.dart';
import 'package:linze/core/models/anime_model.dart';
import 'package:linze/core/services/anime_provider.dart';
import 'package:linze/core/providers/user_preferences_provider.dart';
import 'package:linze/features/video_player/controllers/video_player_controller.dart';
import 'package:linze/features/video_player/presentation/widgets/video_player_overlay.dart';
import 'package:linze/features/video_player/presentation/widgets/gesture_controls.dart';
import 'package:linze/features/video_player/presentation/widgets/settings_panel.dart';
import 'package:linze/features/video_player/presentation/widgets/chapter_selector.dart';
import 'package:linze/features/video_player/presentation/services/download_service.dart';
import 'package:linze/features/video_player/presentation/services/video_history_service.dart';

class VideoPlayerScreen extends ConsumerStatefulWidget {
  final StreamingLink streamingLink;
  final String animeTitle;
  final String episodeTitle;
  final String episodeId;
  final List<Episode>? episodes;
  final int currentEpisodeIndex;
  final String animeId;

  const VideoPlayerScreen({
    super.key,
    required this.streamingLink,
    required this.animeTitle,
    required this.episodeTitle,
    required this.episodeId,
    this.episodes,
    this.currentEpisodeIndex = 0,
    this.animeId = '',
  });

  @override
  ConsumerState<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends ConsumerState<VideoPlayerScreen> {
  late VideoPlayerController _videoPlayerController;
  ChewieController? _chewieController;
  EnhancedVideoPlayerController? _enhancedController;

  bool _isLoading = true;
  String? _errorMessage;
  List<Server> _availableServers = [];
  Server? _selectedServer;
  String _selectedType = 'sub';

  // Enhanced features - will be initialized from user preferences
  double _playbackSpeed = 1.0;
  bool _isAutoSkipIntro = true;
  bool _isAutoSkipOutro = true;
  Duration? _lastWatchedPosition;
  List<Track> _availableSubtitles = [];
  Track? _selectedSubtitle;

  // Skip tracking to prevent loops
  bool _hasSkippedIntro = false;
  bool _hasSkippedOutro = false;

  // Chapter/scene selection
  List<Map<String, dynamic>> _chapters = [];

  // UI state
  bool _showControls = true;
  bool _showSkipMessage = false;
  String _skipMessage = '';
  bool _isVideoInitialized = false;

  // Chapter selector state
  bool _showChapterSelector = false;

  // Episode navigation overlay state
  bool _showNextEpisodeOverlay = false;
  Timer? _autoPlayTimer;

  // Gesture controls state
  bool _showSeekPreview = false;
  Duration _seekPosition = Duration.zero;
  bool _showVolumePreview = false;
  double _volumeLevel = 1.0;
  bool _isControllingBrightness =
      false; // To track whether we're adjusting brightness or volume

  // Download state
  String? _downloadTaskId;
  DownloadTaskStatus _downloadStatus = DownloadTaskStatus.undefined;
  double _downloadProgress = 0;

  @override
  void initState() {
    super.initState();
    _initializeUserPreferences();
    _loadServersAndInitializePlayer();
  }

  @override
  void dispose() {
    // Reset system UI settings when disposing
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    
    _enhancedController?.dispose();
    _autoPlayTimer?.cancel();
    super.dispose();
  }

  void _initializeUserPreferences() {
    // Initialize settings from user preferences
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userPreferences = ref.read(userPreferencesProvider);
      setState(() {
        _playbackSpeed = userPreferences.defaultPlaybackSpeed;
        _isAutoSkipIntro = userPreferences.autoSkipIntro;
        _isAutoSkipOutro = userPreferences.autoSkipOutro;
      });
    });
  }

  Future<void> _loadServersAndInitializePlayer() async {
    try {
      // Get user preferences
      final userPreferences = ref.read(userPreferencesProvider);

      // Get servers from the streaming API response instead of separate endpoint
      final apiService = ref.read(apiServiceProvider);
      final streamingInfo = await apiService.getStreamingInfo(
        id: widget.episodeId,
        server: userPreferences.defaultServer, // Use user's preferred server
        type: userPreferences
            .preferredAudioType, // Use user's preferred audio type
      );

      setState(() {
        _availableServers = streamingInfo.servers ?? [];
        _selectedServer = _availableServers.isNotEmpty
            ? _availableServers.first
            : null;
        _selectedType = widget.streamingLink.type ?? 'sub';

        // Load subtitles from streaming link
        _availableSubtitles = widget.streamingLink.tracks ?? [];
        _selectedSubtitle = _availableSubtitles.isNotEmpty
            ? _availableSubtitles.firstWhere(
                (track) => track.isDefault == true,
                orElse: () => _availableSubtitles.first,
              )
            : null;
      });

      await _initializePlayer();
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load servers: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _initializePlayer() async {
    try {
      if (widget.streamingLink.link?.file != null) {
        final videoUrl = widget.streamingLink.link!.file!;

        _videoPlayerController = VideoPlayerController.networkUrl(
          Uri.parse(videoUrl),
          httpHeaders: {
            'User-Agent':
                'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36',
            'Referer': 'https://rapid-cloud.co/',
            'Accept': '*/*',
            'Accept-Language': 'en-US,en;q=0.9',
            'Accept-Encoding': 'gzip, deflate, br',
            'Connection': 'keep-alive',
          },
        );

        await _videoPlayerController.initialize();

        _chewieController = ChewieController(
          videoPlayerController: _videoPlayerController,
          showControls: false,
          autoPlay: true,
          looping: false,
          allowFullScreen: true,
          allowMuting: true,
          showOptions: true,
          showControlsOnInitialize: true,
          materialProgressColors: ChewieProgressColors(
            playedColor: const Color(0xFF5B13EC),
            handleColor: const Color(0xFF5B13EC),
            backgroundColor: const Color(0xFF444444),
            bufferedColor: const Color(0xFF888888),
          ),
          placeholder: Container(
            color: Colors.black,
            child: const Center(
              child: CircularProgressIndicator(color: Color(0xFF5B13EC)),
            ),
          ),
          autoInitialize: true,
          // Enhanced features
          allowPlaybackSpeedChanging: true,
          playbackSpeeds: const [0.5, 0.75, 1.0, 1.25, 1.5, 2.0],
        );

        // Setup auto-skip intro/outro
        _setupAutoSkip();

        // Restore playback position
        _restorePlaybackPosition();

        // Extract chapter information
        _extractChapterInfo();

        // Add listener to save position periodically
        _videoPlayerController.addListener(_onPositionChanged);

        setState(() {
          _isLoading = false;
          _isVideoInitialized = true; // Mark video as initialized
          // Ensure custom controls are visible after switching servers
          // so the user can interact with the paused/new video immediately.
          _showControls = true;
        });
      } else {
        setState(() {
          _errorMessage = 'No video source available';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load video: $e';
        _isLoading = false;
      });
    }
  }

  void _setupAutoSkip() {
    if (_videoPlayerController.value.isInitialized) {
      _videoPlayerController.addListener(_checkForSkipSegments);
    }
  }

  void _extractChapterInfo() {
    // Extract chapter info from streaming link (intro/outro)
    final chapters = <Map<String, dynamic>>[];

    if (widget.streamingLink.intro != null) {
      final introStart = widget.streamingLink.intro!['start'] as int? ?? 0;
      final introEnd = widget.streamingLink.intro!['end'] as int? ?? 0;

      if (introEnd > introStart) {
        chapters.add({
          'title': 'Intro',
          'start': Duration(seconds: introStart),
          'end': Duration(seconds: introEnd),
          'type': 'intro',
        });
      }
    }

    if (widget.streamingLink.outro != null) {
      final outroStart = widget.streamingLink.outro!['start'] as int? ?? 0;
      final outroEnd = widget.streamingLink.outro!['end'] as int? ?? 0;

      if (outroEnd > outroStart) {
        chapters.add({
          'title': 'Outro',
          'start': Duration(seconds: outroStart),
          'end': Duration(seconds: outroEnd),
          'type': 'outro',
        });
      }
    }

    setState(() {
      _chapters = chapters;
    });
  }

  void _checkForSkipSegments() {
    if (!_videoPlayerController.value.isInitialized) return;

    final currentPosition = _videoPlayerController.value.position;
    final intro = widget.streamingLink.intro;
    final outro = widget.streamingLink.outro;

    // Auto-skip intro
    if (_isAutoSkipIntro && intro != null && !_hasSkippedIntro) {
      final introStart = Duration(seconds: intro['start'] ?? 0);
      final introEnd = Duration(seconds: intro['end'] ?? 0);

      // Check if we're near the intro start (with a small buffer to avoid loops)
      if (currentPosition >= introStart &&
          currentPosition <= introStart + const Duration(seconds: 5)) {
        _videoPlayerController.seekTo(
          introEnd + const Duration(seconds: 2),
        ); // Add 2 seconds buffer
        _showSkipMessageOverlay('Skipping intro...');
        _hasSkippedIntro = true;
      }
    }

    // Auto-skip outro
    if (_isAutoSkipOutro && outro != null && !_hasSkippedOutro) {
      final outroStart = Duration(seconds: outro['start'] ?? 0);
      final outroEnd = Duration(seconds: outro['end'] ?? 0);

      // Check if we're near the outro start (with a small buffer to avoid loops)
      if (currentPosition >= outroStart &&
          currentPosition <= outroStart + const Duration(seconds: 5)) {
        _videoPlayerController.seekTo(
          outroEnd + const Duration(seconds: 2),
        ); // Add 2 seconds buffer
        _showSkipMessageOverlay('Skipping outro...');
        _hasSkippedOutro = true;
      }
    }
  }

  void _showSkipMessageOverlay(String message) {
    setState(() {
      _showSkipMessage = true;
      _skipMessage = message;
    });

    // Hide message after 2 seconds
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _showSkipMessage = false;
        });
      }
    });
  }

  void _jumpToChapter(int chapterIndex) {
    if (chapterIndex >= 0 && chapterIndex < _chapters.length) {
      final chapter = _chapters[chapterIndex];
      final startDuration = chapter['start'] as Duration;

      _videoPlayerController.seekTo(startDuration);
      _showSkipMessageOverlay('Jumped to ${chapter['title']}');
    }
  }

  void _skipForward() {
    if (_videoPlayerController.value.isInitialized) {
      final currentPosition = _videoPlayerController.value.position;
      final duration = _videoPlayerController.value.duration;
      final newPosition = currentPosition + const Duration(seconds: 10);

      if (newPosition < duration) {
        _videoPlayerController.seekTo(newPosition);
        _showSkipMessageOverlay('⏭️ +10s');
      }
    }
  }

  void _skipBackward() {
    if (_videoPlayerController.value.isInitialized) {
      final currentPosition = _videoPlayerController.value.position;
      final newPosition = currentPosition - const Duration(seconds: 10);

      if (newPosition > Duration.zero) {
        _videoPlayerController.seekTo(newPosition);
        _showSkipMessageOverlay('⏮️ -10s');
      }
    }
  }

  Future<void> _savePlaybackPosition() async {
    if (_videoPlayerController.value.isInitialized) {
      final position = _videoPlayerController.value.position;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(
        'playback_position_${widget.episodeId}',
        position.inSeconds,
      );

      // Also save to video history
      await VideoHistoryService.savePlaybackPosition(
        episodeId: widget.episodeId,
        position: position.inSeconds,
        animeTitle: widget.animeTitle,
        episodeTitle: widget.episodeTitle,
      );
    }
  }

  Future<void> _restorePlaybackPosition() async {
    final prefs = await SharedPreferences.getInstance();
    final savedPosition = prefs.getInt('playback_position_${widget.episodeId}');

    if (savedPosition != null && savedPosition > 0) {
      _lastWatchedPosition = Duration(seconds: savedPosition);

      // Show resume dialog if position is significant (more than 30 seconds)
      if (savedPosition > 30) {
        _showResumeDialog();
      }
    }
  }

  void _showResumeDialog() {
    if (!mounted || _lastWatchedPosition == null) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2C2C2E),
        title: Text(
          'Resume Playback',
          style: GoogleFonts.plusJakartaSans(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          'Continue from ${_formatDuration(_lastWatchedPosition!)}?',
          style: GoogleFonts.plusJakartaSans(
            color: Colors.white70,
            fontSize: 14,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text(
              'Start Over',
              style: GoogleFonts.plusJakartaSans(
                color: const Color(0xFF8E8E93),
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _videoPlayerController.seekTo(_lastWatchedPosition!);
            },
            child: Text(
              'Resume',
              style: GoogleFonts.plusJakartaSans(
                color: const Color(0xFF5B13EC),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));

    if (duration.inHours > 0) {
      return '$hours:$minutes:$seconds';
    } else {
      return '$minutes:$seconds';
    }
  }

  void _onPositionChanged() {
    // Save position every 10 seconds
    if (_videoPlayerController.value.isInitialized) {
      final position = _videoPlayerController.value.position;
      if (position.inSeconds % 10 == 0) {
        _savePlaybackPosition();
      }
    }
  }

  Future<void> _playNextEpisode() async {
    if (widget.episodes == null ||
        widget.currentEpisodeIndex >= widget.episodes!.length - 1) {
      _showEpisodeNavigationMessage('No next episode available');
      return;
    }

    final nextEpisode = widget.episodes![widget.currentEpisodeIndex + 1];
    await _loadAndPlayEpisode(nextEpisode, widget.currentEpisodeIndex + 1);
  }

  Future<void> _playPreviousEpisode() async {
    if (widget.episodes == null || widget.currentEpisodeIndex <= 0) {
      _showEpisodeNavigationMessage('No previous episode available');
      return;
    }

    final previousEpisode = widget.episodes![widget.currentEpisodeIndex - 1];
    await _loadAndPlayEpisode(previousEpisode, widget.currentEpisodeIndex - 1);
  }

  Future<void> _loadAndPlayEpisode(Episode episode, int episodeIndex) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Dispose current player
      _videoPlayerController.dispose();
      _chewieController?.dispose();

      // Get new streaming info
      final apiService = ref.read(apiServiceProvider);
      final streamingInfo = await apiService.getStreamingInfo(
        id: episode.id,
        server: _selectedServer?.serverName ?? 'HD-2',
        type: _selectedType,
      );

      if (streamingInfo.streamingLink?.link?.file != null) {
        final videoUrl = streamingInfo.streamingLink!.link!.file!;

        _videoPlayerController = VideoPlayerController.networkUrl(
          Uri.parse(videoUrl),
          httpHeaders: {
            'User-Agent':
                'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36',
            'Referer': 'https://rapid-cloud.co/',
            'Accept': '*/*',
            'Accept-Language': 'en-US,en;q=0.9',
            'Accept-Encoding': 'gzip, deflate, br',
            'Connection': 'keep-alive',
          },
        );

        await _videoPlayerController.initialize();

        _chewieController = ChewieController(
          videoPlayerController: _videoPlayerController,
          showControls: false,
          autoPlay: true,
          looping: false,
          allowFullScreen: true,
          allowMuting: true,
          showOptions: true,
          showControlsOnInitialize: true,
          materialProgressColors: ChewieProgressColors(
            playedColor: const Color(0xFF5B13EC),
            handleColor: const Color(0xFF5B13EC),
            backgroundColor: const Color(0xFF444444),
            bufferedColor: const Color(0xFF888888),
          ),
          placeholder: Container(
            color: Colors.black,
            child: const Center(
              child: CircularProgressIndicator(color: Color(0xFF5B13EC)),
            ),
          ),
          autoInitialize: true,
          allowPlaybackSpeedChanging: true,
          playbackSpeeds: const [0.5, 0.75, 1.0, 1.25, 1.5, 2.0],
        );

        // Setup auto-skip intro/outro
        _setupAutoSkip();

        // Add listener to save position periodically
        _videoPlayerController.addListener(_onPositionChanged);

        setState(() {
          _isLoading = false;
          _isVideoInitialized = true; // Mark video as initialized
          // Ensure custom controls are visible after switching servers
          // so the user can interact with the paused/new video immediately.
          _showControls = true;
        });

        // Show success message
        if (mounted) {
          _showEpisodeNavigationMessage('Playing Episode ${episode.episodeNo}');
        }
      } else {
        setState(() {
          _errorMessage = 'No video source available for this episode';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load episode: $e';
        _isLoading = false;
      });

      if (mounted) {
        _showEpisodeNavigationMessage('Failed to load episode: $e');
      }
    }
  }

  void _showEpisodeNavigationMessage(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          duration: const Duration(seconds: 2),
          backgroundColor: const Color(0xFF5B13EC),
        ),
      );
    }
  }

  void _toggleControlsVisibility() {
    setState(() {
      _showControls = !_showControls;
    });
  }

  // Fullscreen state management
  bool _isFullscreen = false;

  void _toggleFullscreen() {
    setState(() {
      _isFullscreen = !_isFullscreen;
    });

    if (_isFullscreen) {
      // Enter fullscreen mode
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
    } else {
      // Exit fullscreen mode
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);
    }
  }

  void _exitFullscreen() {
    if (_isFullscreen) {
      setState(() {
        _isFullscreen = false;
      });
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);
    }
  }

  void _toggleChapterSelector() {
    setState(() {
      _showChapterSelector = !_showChapterSelector;
    });
  }

  Future<void> _enterPipMode() async {
    // Show snackbar that PiP is not implemented yet
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Picture-in-Picture mode is coming soon!'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  Future<void> _cancelDownload(String taskId) async {
    try {
      await DownloadService.cancelDownload(taskId);
      setState(() {
        _downloadTaskId = null;
        _downloadStatus = DownloadTaskStatus.canceled;
        _downloadProgress = 0;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Download canceled'),
            backgroundColor: const Color(0xFF5B13EC),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to cancel download: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _downloadVideo() async {
    if (widget.streamingLink.link?.file == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('No video file available for download'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    // Show confirmation dialog
    bool confirmDownload =
        await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: const Color(0xFF2C2C2E),
            title: Text(
              'Download Episode',
              style: GoogleFonts.plusJakartaSans(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            content: Text(
              'Do you want to download "${widget.animeTitle} - ${widget.episodeTitle}" for offline viewing?',
              style: GoogleFonts.plusJakartaSans(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(
                  'Cancel',
                  style: GoogleFonts.plusJakartaSans(
                    color: const Color(0xFF8E8E93),
                  ),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text(
                  'Download',
                  style: GoogleFonts.plusJakartaSans(
                    color: const Color(0xFF5B13EC),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ) ??
        false;

    if (confirmDownload) {
      // Start download
      final taskId = await DownloadService.downloadVideo(
        url: widget.streamingLink.link!.file!,
        animeTitle: widget.animeTitle,
        episodeTitle: widget.episodeTitle,
      );

      if (taskId != null) {
        setState(() {
          _downloadTaskId = taskId;
          _downloadStatus = DownloadTaskStatus.enqueued;
          _downloadProgress = 0;
        });

        // Show download started snackbar
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Download started'),
              backgroundColor: const Color(0xFF5B13EC),
            ),
          );
        }

        // Listen to download progress
        _listenToDownloadProgress(taskId);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to start download'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  void _listenToDownloadProgress(String taskId) {
    Timer.periodic(Duration(seconds: 1), (timer) async {
      if (_downloadStatus == DownloadTaskStatus.complete ||
          _downloadStatus == DownloadTaskStatus.failed ||
          _downloadStatus == DownloadTaskStatus.canceled) {
        timer.cancel();
        return;
      }

      final tasks = await FlutterDownloader.loadTasks();
      final task = (tasks ?? []).firstWhere(
        (element) => element.taskId == taskId,
        orElse: () => DownloadTask(
          taskId: '',
          status: DownloadTaskStatus.undefined,
          progress: 0,
          url: '',
          filename: '',
          savedDir: '',
          timeCreated: DateTime.now().millisecondsSinceEpoch,
          allowCellular: false,
        ),
      );

      if (task.taskId == taskId) {
        setState(() {
          _downloadStatus = task.status;
          _downloadProgress = task.progress.toDouble();
        });

        if (task.status == DownloadTaskStatus.complete) {
          timer.cancel();
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Download completed'),
                backgroundColor: const Color(0xFF5B13EC),
              ),
            );
          }
        } else if (task.status == DownloadTaskStatus.failed) {
          timer.cancel();
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Download failed'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      }
    });
  }

  int _calculateCountdown() {
    if (!_videoPlayerController.value.isInitialized) return 0;

    final position = _videoPlayerController.value.position;
    final duration = _videoPlayerController.value.duration;
    final remainingTime = duration - position;

    return remainingTime.inSeconds > 30 ? 0 : remainingTime.inSeconds;
  }

  void _cancelAutoPlay() {
    _autoPlayTimer?.cancel();
    setState(() {
      _showNextEpisodeOverlay = false;
    });
  }

  void _onHorizontalDragUpdate(DragUpdateDetails details) {
    // Implement seek preview logic
    final screenWidth = MediaQuery.of(context).size.width;
    final dragPercentage = details.delta.dx / screenWidth;
    final duration = _videoPlayerController.value.duration;

    setState(() {
      _seekPosition += Duration(
        seconds: (dragPercentage * duration.inSeconds).round(),
      );
      _seekPosition = Duration(
        seconds: _seekPosition.inSeconds.clamp(0, duration.inSeconds),
      );
      _showSeekPreview = true;
    });
  }

  void _onVerticalDragUpdate(DragUpdateDetails details) {
    final screenW = MediaQuery.of(context).size.width;
    final dragStartX = details.globalPosition.dx;

    // Determine if dragging on left (brightness) or right (volume) side
    if (dragStartX < screenW / 2) {
      // Brightness control on left side
      _adjustBrightness(details.delta.dy);
    } else {
      // Volume control on right side
      _adjustVolume(details.delta.dy);
    }
  }

  void _adjustVolume(double delta) {
    // Implement volume control logic
    final screenHeight = MediaQuery.of(context).size.height;
    final dragPercentage = delta / screenHeight;

    setState(() {
      _volumeLevel = (_volumeLevel - dragPercentage * 3).clamp(
        0.0,
        1.0,
      ); // Multiplied by 3 for more sensitivity
      _showVolumePreview = true;
      _isControllingBrightness = false; // Volume control
    });

    _videoPlayerController.setVolume(_volumeLevel);
  }

  void _adjustBrightness(double delta) {
    // Implement brightness control logic (this is platform-specific and requires additional implementation)
    // For this example, we'll just show a preview
    final screenHeight = MediaQuery.of(context).size.height;
    final dragPercentage = delta / screenHeight;

    setState(() {
      _showVolumePreview = true;
      _isControllingBrightness = true; // Brightness control
      // Use the same variable for preview but with brightness indication
      _volumeLevel = (_volumeLevel - dragPercentage * 3).clamp(0.0, 1.0);
    });

    // On Android, we can use platform channels to adjust system brightness
    // This is just a demo - real implementation would require more complex code
  }

  // Adapter for the new PopScope API. The SDK expects a callback with the
  // signature (bool didPop, T result). Provide a matching handler that runs
  // cleanup when the system back invocation did not pop the route.
  void _onPopInvokedWithResult(bool didPop, dynamic result) {
    if (!didPop) {
      debugPrint(
        'VideoPlayerScreen: System back button pressed - pausing video and cleaning up',
      );
      Navigator.pop(context);
    }
  }

  void _showAdvancedSettings() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return VideoPlayerSettingsPanel(
          playbackSpeed: _playbackSpeed,
          autoSkipIntro: _isAutoSkipIntro,
          autoSkipOutro: _isAutoSkipOutro,
          availableSubtitles: _availableSubtitles,
          selectedSubtitle: _selectedSubtitle,
          availableServers: _availableServers,
          selectedServer: _selectedServer,
          selectedType: _selectedType,
          onPlaybackSpeedChanged: (speed) {
            setState(() {
              _playbackSpeed = speed;
            });
            _videoPlayerController.setPlaybackSpeed(speed);
          },
          onAutoSkipIntroChanged: (enabled) {
            setState(() {
              _isAutoSkipIntro = enabled;
              // Reset skip flag when toggling auto-skip intro
              _hasSkippedIntro = false;
            });
          },
          onAutoSkipOutroChanged: (enabled) {
            setState(() {
              _isAutoSkipOutro = enabled;
              // Reset skip flag when toggling auto-skip outro
              _hasSkippedOutro = false;
            });
          },
          onSubtitleChanged: (subtitle) {
            setState(() {
              _selectedSubtitle = subtitle;
            });
            // TODO: Implement actual subtitle switching when chewie supports it
            // Currently, subtitle switching is not working in this version of chewie
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Subtitle switching will be implemented in a future update',
                  ),
                  backgroundColor: Colors.orange,
                ),
              );
            }
          },
          onServerChanged: (server, type) {
            _switchServer(server, type);
          },
        );
      },
    );
  }

  void _showServerSelectionDialog() {
    String tempSelectedType = _selectedType;
    Server? tempSelectedServer = _selectedServer;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: const Color(0xFF2C2C2E),
              title: Text(
                'Select Server & Audio',
                style: GoogleFonts.plusJakartaSans(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              content: SizedBox(
                width: double.maxFinite,
                height: 400,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Audio Type Selection
                    Text(
                      'Audio Type',
                      style: GoogleFonts.plusJakartaSans(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: _buildAudioTypeButton(
                            'sub',
                            'Sub',
                            tempSelectedType,
                            (type) {
                              setDialogState(() {
                                tempSelectedType = type;
                                // Reset server selection when audio type changes
                                final availableServersForType =
                                    _availableServers
                                        .where(
                                          (server) =>
                                              server.type == tempSelectedType,
                                        )
                                        .toList();
                                tempSelectedServer =
                                    availableServersForType.isNotEmpty
                                    ? availableServersForType.first
                                    : null;
                              });
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildAudioTypeButton(
                            'dub',
                            'Dub',
                            tempSelectedType,
                            (type) {
                              setDialogState(() {
                                tempSelectedType = type;
                                // Reset server selection when audio type changes
                                final availableServersForType =
                                    _availableServers
                                        .where(
                                          (server) =>
                                              server.type == tempSelectedType,
                                        )
                                        .toList();
                                tempSelectedServer =
                                    availableServersForType.isNotEmpty
                                    ? availableServersForType.first
                                    : null;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Server Selection
                    Text(
                      'Available Servers (${tempSelectedType.toUpperCase()})',
                      style: GoogleFonts.plusJakartaSans(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          children: _availableServers
                              .where(
                                (server) => server.type == tempSelectedType,
                              )
                              .map(
                                (server) => _buildServerButton(
                                  server,
                                  tempSelectedServer?.serverName ==
                                      server.serverName,
                                  () {
                                    setDialogState(() {
                                      tempSelectedServer = server;
                                    });
                                  },
                                ),
                              )
                              .toList(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(
                    'Cancel',
                    style: GoogleFonts.plusJakartaSans(
                      color: const Color(0xFF8E8E93),
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    if (tempSelectedServer != null) {
                      _switchServer(tempSelectedServer!, tempSelectedType);
                    }
                  },
                  child: Text(
                    'Apply',
                    style: GoogleFonts.plusJakartaSans(
                      color: const Color(0xFF5B13EC),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildAudioTypeButton(
    String type,
    String label,
    String selectedType,
    Function(String) onTap,
  ) {
    final isSelected = selectedType == type;
    return GestureDetector(
      onTap: () => onTap(type),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF5B13EC) : const Color(0xFF3A3A3C),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildServerButton(
    Server server,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          decoration: BoxDecoration(
            color: isSelected
                ? const Color(0xFF5B13EC)
                : const Color(0xFF3A3A3C),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(Icons.dns, color: Colors.white, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  server.serverName ?? 'Unknown Server',
                  style: GoogleFonts.plusJakartaSans(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              if (isSelected) Icon(Icons.check, color: Colors.white, size: 20),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _switchServer(Server server, String type) async {
    setState(() {
      _isLoading = true;
      _selectedServer = server;
      _selectedType = type;
      _errorMessage = null;
    });

    try {
      // Dispose current player
      _videoPlayerController.dispose();
      _chewieController?.dispose();

      // Get new streaming info
      final apiService = ref.read(apiServiceProvider);
      final streamingInfo = await apiService.getStreamingInfo(
        id: widget.episodeId,
        server: server.serverName ?? 'HD-2',
        type: type,
      );

      if (streamingInfo.streamingLink?.link?.file != null) {
        final videoUrl = streamingInfo.streamingLink!.link!.file!;

        _videoPlayerController = VideoPlayerController.networkUrl(
          Uri.parse(videoUrl),
          httpHeaders: {
            'User-Agent':
                'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36',
            'Referer': 'https://rapid-cloud.co/',
            'Accept': '*/*',
            'Accept-Language': 'en-US,en;q=0.9',
            'Accept-Encoding': 'gzip, deflate, br',
            'Connection': 'keep-alive',
          },
        );

        await _videoPlayerController.initialize();

        // Update available subtitles with new stream data
        setState(() {
          _availableSubtitles = streamingInfo.streamingLink?.tracks ?? [];
          _selectedSubtitle = _availableSubtitles.isNotEmpty
              ? _availableSubtitles.firstWhere(
                  (track) => track.isDefault == true,
                  orElse: () => _availableSubtitles.first,
                )
              : null;
        });

        _chewieController = ChewieController(
          videoPlayerController: _videoPlayerController,
          showControls: false,
          autoPlay: false, // Don't auto-play when switching servers
          looping: false,
          allowFullScreen: true,
          allowMuting: true,
          showOptions: true,
          showControlsOnInitialize: true,
          materialProgressColors: ChewieProgressColors(
            playedColor: const Color(0xFF5B13EC),
            handleColor: const Color(0xFF5B13EC),
            backgroundColor: const Color(0xFF444444),
            bufferedColor: const Color(0xFF888888),
          ),
          placeholder: Container(
            color: Colors.black,
            child: const Center(
              child: CircularProgressIndicator(color: Color(0xFF5B13EC)),
            ),
          ),
          autoInitialize: true,
        );

        setState(() {
          _isLoading = false;
          _isVideoInitialized = true; // Mark video as initialized
          // Ensure custom controls are visible after switching servers
          // so the user can interact with the paused/new video immediately.
          _showControls = true;
        });

        // Show success message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Switched to ${server.serverName} (${type.toUpperCase()})',
              ),
              backgroundColor: const Color(0xFF5B13EC),
              duration: const Duration(seconds: 2),
            ),
          );
        }
      } else {
        setState(() {
          _errorMessage = 'No video source available for selected server';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to switch server: $e';
        _isLoading = false;
      });

      // Show error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to switch server: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }





  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: _onPopInvokedWithResult,
      child: _isFullscreen 
          ? _buildFullscreenPlayer()  // Fullscreen view
          : Scaffold(  // Normal view
              backgroundColor: Colors.black,
              appBar: AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () {
                    debugPrint(
                      'VideoPlayerScreen: Back button pressed - pausing video and cleaning up',
                    );
                    Navigator.pop(context);
                  },
                ),
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.animeTitle,
                      style: GoogleFonts.plusJakartaSans(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Row(
                      children: [
                        // Using Flexible instead of Expanded to allow row items to fit content
                        Flexible(
                          fit: FlexFit.loose,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.episodeTitle,
                                style: GoogleFonts.plusJakartaSans(
                                  color: const Color(0xFFA7A7A7),
                                  fontSize: 14,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              if (widget.episodes != null)
                                Text(
                                  'Episode ${widget.currentEpisodeIndex + 1} of ${widget.episodes!.length}',
                                  style: GoogleFonts.plusJakartaSans(
                                    color: const Color(0xFF888888),
                                    fontSize: 12,
                                  ),
                                ),
                            ],
                          ),
                        ),
                        if (_selectedServer != null) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF5B13EC),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '${_selectedServer!.serverName} (${_selectedType.toUpperCase()})',
                              style: GoogleFonts.plusJakartaSans(
                                color: Colors.white,
                                fontSize: 9,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
                actions: [
                  // Episode Navigation
                  if (widget.episodes != null) ...[
                    IconButton(
                      icon: Icon(
                        Icons.skip_previous,
                        color: widget.currentEpisodeIndex > 0
                            ? Colors.white
                            : Colors.grey,
                      ),
                      onPressed: widget.currentEpisodeIndex > 0
                          ? _playPreviousEpisode
                          : null,
                      tooltip: 'Previous Episode',
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.skip_next,
                        color:
                            widget.episodes != null &&
                                widget.currentEpisodeIndex <
                                    widget.episodes!.length - 1
                            ? Colors.white
                            : Colors.grey,
                      ),
                      onPressed:
                          widget.episodes != null &&
                              widget.currentEpisodeIndex < widget.episodes!.length - 1
                          ? _playNextEpisode
                          : null,
                      tooltip: 'Next Episode',
                    ),
                  ],
                  // Chapter Selection button
                  IconButton(
                    icon: const Icon(Icons.menu_book, color: Colors.white),
                    onPressed: _isVideoInitialized ? _toggleChapterSelector : null,
                    tooltip: 'Chapters',
                  ),
                  // Server Selection button
                  IconButton(
                    icon: const Icon(Icons.dns, color: Colors.white),
                    onPressed: _isVideoInitialized ? _showServerSelectionDialog : null,
                    tooltip: 'Select Server',
                  ),
                  // PiP button
                  IconButton(
                    icon: const Icon(Icons.picture_in_picture_alt_outlined, color: Colors.white),
                    onPressed: _isVideoInitialized ? _enterPipMode : null,
                    tooltip: 'Picture-in-Picture',
                  ),
                  // Settings button
                  IconButton(
                    icon: const Icon(Icons.tune, color: Colors.white),
                    onPressed: _isVideoInitialized ? _showAdvancedSettings : null,
                    tooltip: 'Settings',
                  ),
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      IconButton(
                        icon: Icon(
                          _downloadStatus == DownloadTaskStatus.running
                              ? Icons.downloading
                              : _downloadStatus == DownloadTaskStatus.complete
                              ? Icons.offline_pin
                              : Icons.download,
                          color: Colors.white,
                        ),
                        onPressed:
                            _downloadStatus == DownloadTaskStatus.running &&
                                _downloadTaskId != null
                            ? () => _cancelDownload(_downloadTaskId!)
                            : _downloadVideo,
                        tooltip: _downloadStatus == DownloadTaskStatus.running
                            ? 'Cancel Download'
                            : 'Download for offline viewing',
                      ),
                      if (_downloadStatus == DownloadTaskStatus.running)
                        CircularProgressIndicator(
                          value: _downloadProgress / 100,
                          strokeWidth: 2,
                          backgroundColor: Colors.white24,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      if (_downloadStatus == DownloadTaskStatus.running)
                        Positioned(
                          bottom: 8,
                          child: Text(
                            '${_downloadProgress.toInt()}%',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                  ),
                  IconButton(
                    icon: Icon(
                      _isFullscreen 
                          ? Icons.fullscreen_exit 
                          : Icons.fullscreen, 
                      color: Colors.white
                    ),
                    onPressed: _toggleFullscreen,
                  ),
                ],
              ),
        body: _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: Color(0xFF5B13EC)),
              )
            : _errorMessage != null
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: Colors.red,
                      size: 64,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _errorMessage!,
                      style: GoogleFonts.plusJakartaSans(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _isLoading = true;
                          _errorMessage = null;
                        });
                        _initializePlayer();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF5B13EC),
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              )
            : _chewieController != null
            ? Stack(
                children: [
                  // Enhanced gesture controls
                  VideoGestureControls(
                    onDoubleTapLeft: _skipBackward,
                    onDoubleTapRight: _skipForward,
                    onTap: _toggleControlsVisibility,
                    onHorizontalDragUpdate: _onHorizontalDragUpdate,
                    onVerticalDragUpdate: _onVerticalDragUpdate,
                    child: Chewie(controller: _chewieController!),
                  ),

                  // Center video controls overlay (when controls are visible)
                  if (_showControls)
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: IgnorePointer(
                        ignoring: !_showControls,
                        child: Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Skip backward button
                              Container(
                                width: 60,
                                height: 60,
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                child: IconButton(
                                  onPressed: _skipBackward,
                                  icon: const Icon(Icons.replay_10, color: Colors.white, size: 32),
                                ),
                              ),
                              const SizedBox(width: 40),
                              // Play/Pause button
                              Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(40),
                                  border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.3),
                                    width: 2,
                                  ),
                                ),
                                child: ValueListenableBuilder<VideoPlayerValue>(
                                  valueListenable: _videoPlayerController,
                                  builder: (context, value, child) {
                                    bool isPlaying = value.isPlaying;
                                    return IconButton(
                                      icon: Icon(
                                        isPlaying ? Icons.pause : Icons.play_arrow,
                                        color: Colors.white,
                                        size: 48,
                                      ),
                                      onPressed: () {
                                        if (isPlaying) {
                                          _videoPlayerController.pause();
                                        } else {
                                          _videoPlayerController.play();
                                        }
                                      },
                                      padding: EdgeInsets.zero,
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(width: 40),
                              // Skip forward button
                              Container(
                                width: 60,
                                height: 60,
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                child: IconButton(
                                  onPressed: _skipForward,
                                  icon: const Icon(Icons.forward_10, color: Colors.white, size: 32),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),


                  // Chapter selector overlay
                  ChapterSelector(
                    chapters: _chapters,
                    onChapterSelected: _jumpToChapter,
                    currentPosition: _videoPlayerController.value.position,
                    totalDuration: _videoPlayerController.value.duration,
                    isVisible: _showChapterSelector,
                    onVisibilityChanged: (visible) {
                      setState(() {
                        _showChapterSelector = visible;
                      });
                    },
                  ),

                  // Episode Navigation Overlay
                  if (widget.episodes != null)
                    VideoPlayerOverlay(
                      showOverlay: _showNextEpisodeOverlay,
                      nextEpisodeTitle:
                          widget.episodes!.length >
                              widget.currentEpisodeIndex + 1
                          ? widget
                                .episodes![widget.currentEpisodeIndex + 1]
                                .title
                          : null,
                      nextEpisodeNumber:
                          widget.episodes!.length >
                              widget.currentEpisodeIndex + 1
                          ? widget
                                .episodes![widget.currentEpisodeIndex + 1]
                                .episodeNo
                                .toString()
                          : null,
                      countdown: _calculateCountdown(),
                      onPlayNow: _playNextEpisode,
                      onCancel: _cancelAutoPlay,
                    ),

                  // Skip message overlay
                  SkipMessageOverlay(
                    message: _skipMessage,
                    show: _showSkipMessage,
                  ),

                  // Seek preview overlay
                  SeekPreview(
                    currentPosition: _seekPosition,
                    totalDuration: _videoPlayerController.value.duration,
                    seekPosition: _seekPosition,
                    show: _showSeekPreview,
                  ),

                  // Progress bar overlay (when controls are visible)
                  if (_showControls)
                    Positioned(
                      bottom: 80, // Position above other overlays
                      left: 20,
                      right: 20,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.6),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          children: [
                            // Progress bar
                            VideoProgressIndicator(
                              _videoPlayerController,
                              allowScrubbing: true,
                              colors: VideoProgressColors(
                                playedColor: const Color(0xFF5B13EC),
                                bufferedColor: Colors.white.withValues(alpha: 0.5),
                                backgroundColor: Colors.white.withValues(alpha: 0.3),
                              ),
                            ),
                            const SizedBox(height: 4),
                            // Time display
                            ValueListenableBuilder<VideoPlayerValue>(
                              valueListenable: _videoPlayerController,
                              builder: (context, value, child) {
                                final position = value.position;
                                final duration = value.duration;
                                return Text(
                                  '${_formatDuration(position)} / ${_formatDuration(duration)}',
                                  style: GoogleFonts.plusJakartaSans(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  
                  // Volume/Brightness control preview
                  ControlPreview(
                    icon: _isControllingBrightness ? '💡' : '🔊',
                    value: _volumeLevel,
                    show: _showVolumePreview,
                  ),
                ],
              )
            : const Center(
                child: Text(
                  'Video player not initialized',
                  style: TextStyle(color: Colors.white),
                ),
              ),
      ),
    );
  }

  /// Build fullscreen player view with custom controls
  Widget _buildFullscreenPlayer() {
    return Scaffold(
      backgroundColor: Colors.black,
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF5B13EC)),
            )
          : _errorMessage != null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    color: Colors.red,
                    size: 64,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _errorMessage!,
                    style: GoogleFonts.plusJakartaSans(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _isLoading = true;
                        _errorMessage = null;
                      });
                      _initializePlayer();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF5B13EC),
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            )
          : _chewieController != null
          ? Stack(
              children: [
                // Enhanced gesture controls
                VideoGestureControls(
                  onDoubleTapLeft: _skipBackward,
                  onDoubleTapRight: _skipForward,
                  onTap: _toggleControlsVisibility,
                  onHorizontalDragUpdate: _onHorizontalDragUpdate,
                  onVerticalDragUpdate: _onVerticalDragUpdate,
                  child: Chewie(controller: _chewieController!),
                ),

                // Center video controls overlay (when controls are visible)
                if (_showControls)
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: IgnorePointer(
                      ignoring: !_showControls,
                      child: Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Skip backward button
                            Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: IconButton(
                                onPressed: _skipBackward,
                                icon: const Icon(Icons.replay_10, color: Colors.white, size: 32),
                              ),
                            ),
                            const SizedBox(width: 40),
                            // Play/Pause button
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(40),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.3),
                                  width: 2,
                                ),
                              ),
                              child: ValueListenableBuilder<VideoPlayerValue>(
                                valueListenable: _videoPlayerController,
                                builder: (context, value, child) {
                                  bool isPlaying = value.isPlaying;
                                  return IconButton(
                                    icon: Icon(
                                      isPlaying ? Icons.pause : Icons.play_arrow,
                                      color: Colors.white,
                                      size: 48,
                                    ),
                                    onPressed: () {
                                      if (isPlaying) {
                                        _videoPlayerController.pause();
                                      } else {
                                        _videoPlayerController.play();
                                      }
                                    },
                                    padding: EdgeInsets.zero,
                                  );
                                },
                              ),
                            ),
                            const SizedBox(width: 40),
                            // Skip forward button
                            Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: IconButton(
                                onPressed: _skipForward,
                                icon: const Icon(Icons.forward_10, color: Colors.white, size: 32),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),


                // Chapter selector overlay
                ChapterSelector(
                  chapters: _chapters,
                  onChapterSelected: _jumpToChapter,
                  currentPosition: _videoPlayerController.value.position,
                  totalDuration: _videoPlayerController.value.duration,
                  isVisible: _showChapterSelector,
                  onVisibilityChanged: (visible) {
                    setState(() {
                      _showChapterSelector = visible;
                    });
                  },
                ),

                // Episode Navigation Overlay
                if (widget.episodes != null)
                  VideoPlayerOverlay(
                    showOverlay: _showNextEpisodeOverlay,
                    nextEpisodeTitle:
                        widget.episodes!.length >
                            widget.currentEpisodeIndex + 1
                        ? widget
                              .episodes![widget.currentEpisodeIndex + 1]
                              .title
                        : null,
                    nextEpisodeNumber:
                        widget.episodes!.length >
                            widget.currentEpisodeIndex + 1
                        ? widget
                              .episodes![widget.currentEpisodeIndex + 1]
                              .episodeNo
                              .toString()
                        : null,
                    countdown: _calculateCountdown(),
                    onPlayNow: _playNextEpisode,
                    onCancel: _cancelAutoPlay,
                  ),

                // Skip message overlay
                SkipMessageOverlay(
                  message: _skipMessage,
                  show: _showSkipMessage,
                ),

                // Seek preview overlay
                SeekPreview(
                  currentPosition: _seekPosition,
                  totalDuration: _videoPlayerController.value.duration,
                  seekPosition: _seekPosition,
                  show: _showSeekPreview,
                ),

                // Volume/Brightness control preview
                ControlPreview(
                  icon: _isControllingBrightness ? '💡' : '🔊',
                  value: _volumeLevel,
                  show: _showVolumePreview,
                ),
                
                // Progress bar overlay (when controls are visible)
                if (_showControls)
                  Positioned(
                    bottom: 80, // Position above other overlays
                    left: 20,
                    right: 20,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        children: [
                          // Progress bar
                          VideoProgressIndicator(
                            _videoPlayerController,
                            allowScrubbing: true,
                            colors: VideoProgressColors(
                              playedColor: const Color(0xFF5B13EC),
                              bufferedColor: Colors.white.withValues(alpha: 0.5),
                              backgroundColor: Colors.white.withValues(alpha: 0.3),
                            ),
                          ),
                          const SizedBox(height: 4),
                          // Time display
                          ValueListenableBuilder<VideoPlayerValue>(
                            valueListenable: _videoPlayerController,
                            builder: (context, value, child) {
                              final position = value.position;
                              final duration = value.duration;
                              return Text(
                                '${_formatDuration(position)} / ${_formatDuration(duration)}',
                                style: GoogleFonts.plusJakartaSans(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                
                // Exit fullscreen button (top right corner)
                Positioned(
                  top: 20,
                  right: 20,
                  child: IconButton(
                    icon: const Icon(Icons.fullscreen_exit, color: Colors.white, size: 32),
                    onPressed: _exitFullscreen,
                  ),
                ),
                
                // Title bar in fullscreen (showing anime title and episode)
                Positioned(
                  top: 20,
                  left: 20,
                  right: 80, // Make space for exit button
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.animeTitle,
                          style: GoogleFonts.plusJakartaSans(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          widget.episodeTitle,
                          style: GoogleFonts.plusJakartaSans(
                            color: const Color(0xFFA7A7A7),
                            fontSize: 14,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            )
          : const Center(
              child: Text(
                'Video player not initialized',
                style: TextStyle(color: Colors.white),
              ),
            ),
    );
  }
}
