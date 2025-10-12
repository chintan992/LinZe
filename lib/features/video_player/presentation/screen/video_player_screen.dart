import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:chewie/chewie.dart';
import 'package:video_player/video_player.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:linze/core/models/streaming_models.dart';
import 'package:linze/core/services/anime_provider.dart';

class VideoPlayerScreen extends ConsumerStatefulWidget {
  final StreamingLink streamingLink;
  final String animeTitle;
  final String episodeTitle;
  final String episodeId;

  const VideoPlayerScreen({
    super.key,
    required this.streamingLink,
    required this.animeTitle,
    required this.episodeTitle,
    required this.episodeId,
  });

  @override
  ConsumerState<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends ConsumerState<VideoPlayerScreen> {
  late VideoPlayerController _videoPlayerController;
  ChewieController? _chewieController;
  bool _isLoading = true;
  String? _errorMessage;
  List<Server> _availableServers = [];
  Server? _selectedServer;
  String _selectedType = 'sub';
  
  // Enhanced features
  double _playbackSpeed = 1.0;
  bool _isAutoSkipIntro = true;
  bool _isAutoSkipOutro = true;
  Duration? _lastWatchedPosition;
  List<Track> _availableSubtitles = [];
  Track? _selectedSubtitle;
  
  // Skip tracking to prevent loops
  bool _hasSkippedIntro = false;
  bool _hasSkippedOutro = false;

  @override
  void initState() {
    super.initState();
    _loadServersAndInitializePlayer();
  }

  Future<void> _loadServersAndInitializePlayer() async {
    try {
      // Get servers from the streaming API response instead of separate endpoint
      final apiService = ref.read(apiServiceProvider);
      final streamingInfo = await apiService.getStreamingInfo(
        id: widget.episodeId,
        server: 'HD-2', // Use HD-2 as default
        type: widget.streamingLink.type ?? 'sub',
      );
      
      setState(() {
        _availableServers = streamingInfo.servers ?? [];
        _selectedServer = _availableServers.isNotEmpty ? _availableServers.first : null;
        _selectedType = widget.streamingLink.type ?? 'sub';
        
        // Load subtitles from streaming link
        _availableSubtitles = widget.streamingLink.tracks ?? [];
        _selectedSubtitle = _availableSubtitles.isNotEmpty 
            ? _availableSubtitles.firstWhere((track) => track.isDefault == true, orElse: () => _availableSubtitles.first)
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
            'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36',
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
              child: CircularProgressIndicator(
                color: Color(0xFF5B13EC),
              ),
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
        
        // Add listener to save position periodically
        _videoPlayerController.addListener(_onPositionChanged);

        setState(() {
          _isLoading = false;
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
      if (currentPosition >= introStart && currentPosition <= introStart + const Duration(seconds: 5)) {
        _videoPlayerController.seekTo(introEnd + const Duration(seconds: 2)); // Add 2 seconds buffer
        _showSkipMessage('Skipping intro...');
        _hasSkippedIntro = true;
      }
    }
    
    // Auto-skip outro
    if (_isAutoSkipOutro && outro != null && !_hasSkippedOutro) {
      final outroStart = Duration(seconds: outro['start'] ?? 0);
      final outroEnd = Duration(seconds: outro['end'] ?? 0);
      
      // Check if we're near the outro start (with a small buffer to avoid loops)
      if (currentPosition >= outroStart && currentPosition <= outroStart + const Duration(seconds: 5)) {
        _videoPlayerController.seekTo(outroEnd + const Duration(seconds: 2)); // Add 2 seconds buffer
        _showSkipMessage('Skipping outro...');
        _hasSkippedOutro = true;
      }
    }
  }

  void _showSkipMessage(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          duration: const Duration(seconds: 1),
          backgroundColor: const Color(0xFF5B13EC),
        ),
      );
    }
  }

  void _skipForward() {
    if (_videoPlayerController.value.isInitialized) {
      final currentPosition = _videoPlayerController.value.position;
      final duration = _videoPlayerController.value.duration;
      final newPosition = currentPosition + const Duration(seconds: 10);
      
      if (newPosition < duration) {
        _videoPlayerController.seekTo(newPosition);
        _showSkipMessage('⏭️ +10s');
      }
    }
  }

  void _skipBackward() {
    if (_videoPlayerController.value.isInitialized) {
      final currentPosition = _videoPlayerController.value.position;
      final newPosition = currentPosition - const Duration(seconds: 10);
      
      if (newPosition > Duration.zero) {
        _videoPlayerController.seekTo(newPosition);
        _showSkipMessage('⏮️ -10s');
      }
    }
  }

  Future<void> _savePlaybackPosition() async {
    if (_videoPlayerController.value.isInitialized) {
      final position = _videoPlayerController.value.position;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('playback_position_${widget.episodeId}', position.inSeconds);
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

  void _showAdvancedSettings() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: const Color(0xFF2C2C2E),
              title: Text(
                'Advanced Settings',
                style: GoogleFonts.plusJakartaSans(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              content: SizedBox(
                width: double.maxFinite,
                height: 300,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Playback Speed
                    Text(
                      'Playback Speed',
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
                          child: DropdownButton<double>(
                            value: _playbackSpeed,
                            dropdownColor: const Color(0xFF3A3A3C),
                            style: GoogleFonts.plusJakartaSans(color: Colors.white),
                            items: const [
                              DropdownMenuItem(value: 0.5, child: Text('0.5x')),
                              DropdownMenuItem(value: 0.75, child: Text('0.75x')),
                              DropdownMenuItem(value: 1.0, child: Text('1x')),
                              DropdownMenuItem(value: 1.25, child: Text('1.25x')),
                              DropdownMenuItem(value: 1.5, child: Text('1.5x')),
                              DropdownMenuItem(value: 2.0, child: Text('2x')),
                            ],
                            onChanged: (value) {
                              setDialogState(() {
                                _playbackSpeed = value!;
                              });
                              _videoPlayerController.setPlaybackSpeed(_playbackSpeed);
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    // Auto-skip settings
                    Text(
                      'Auto-Skip Settings',
                      style: GoogleFonts.plusJakartaSans(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    SwitchListTile(
                      title: Text(
                        'Skip Intro',
                        style: GoogleFonts.plusJakartaSans(color: Colors.white),
                      ),
                      value: _isAutoSkipIntro,
                      onChanged: (value) {
                        setDialogState(() {
                          _isAutoSkipIntro = value;
                          // Reset skip flag when toggling auto-skip intro
                          _hasSkippedIntro = false;
                        });
                      },
                            activeThumbColor: const Color(0xFF5B13EC),
                    ),
                    SwitchListTile(
                      title: Text(
                        'Skip Outro',
                        style: GoogleFonts.plusJakartaSans(color: Colors.white),
                      ),
                      value: _isAutoSkipOutro,
                      onChanged: (value) {
                        setDialogState(() {
                          _isAutoSkipOutro = value;
                          // Reset skip flag when toggling auto-skip outro
                          _hasSkippedOutro = false;
                        });
                      },
                            activeThumbColor: const Color(0xFF5B13EC),
                    ),
                    
                    // Subtitle selection
                    if (_availableSubtitles.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      Text(
                        'Subtitles',
                        style: GoogleFonts.plusJakartaSans(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      DropdownButton<Track>(
                        value: _selectedSubtitle,
                        dropdownColor: const Color(0xFF3A3A3C),
                        style: GoogleFonts.plusJakartaSans(color: Colors.white),
                        hint: Text(
                          'Select Subtitle',
                          style: GoogleFonts.plusJakartaSans(color: Colors.white70),
                        ),
                        items: _availableSubtitles.map((track) {
                          return DropdownMenuItem<Track>(
                            value: track,
                            child: Text(track.label ?? 'Unknown'),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setDialogState(() {
                            _selectedSubtitle = value;
                          });
                          // TODO: Implement subtitle switching
                        },
                      ),
                    ],
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(
                    'Done',
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

  Future<void> _switchServer(Server server, String type) async {
    setState(() {
      _isLoading = true;
      _selectedServer = server;
      _selectedType = type;
      _errorMessage = null;
      // Reset skip flags when switching servers
      _hasSkippedIntro = false;
      _hasSkippedOutro = false;
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
            'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36',
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
              child: CircularProgressIndicator(
                color: Color(0xFF5B13EC),
              ),
            ),
          ),
          autoInitialize: true,
        );

        setState(() {
          _isLoading = false;
        });

        // Show success message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Switched to ${server.serverName} (${type.toUpperCase()})'),
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
                          child: _buildAudioTypeButton('sub', 'Sub', tempSelectedType, (type) {
                            setDialogState(() {
                              tempSelectedType = type;
                              // Reset server selection when audio type changes
                              final availableServersForType = _availableServers
                                  .where((server) => server.type == tempSelectedType)
                                  .toList();
                              tempSelectedServer = availableServersForType.isNotEmpty 
                                  ? availableServersForType.first 
                                  : null;
                            });
                          }),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildAudioTypeButton('dub', 'Dub', tempSelectedType, (type) {
                            setDialogState(() {
                              tempSelectedType = type;
                              // Reset server selection when audio type changes
                              final availableServersForType = _availableServers
                                  .where((server) => server.type == tempSelectedType)
                                  .toList();
                              tempSelectedServer = availableServersForType.isNotEmpty 
                                  ? availableServersForType.first 
                                  : null;
                            });
                          }),
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
                              .where((server) => server.type == tempSelectedType)
                              .map((server) => _buildServerButton(
                                server, 
                                tempSelectedServer?.serverName == server.serverName,
                                () {
                                  setDialogState(() {
                                    tempSelectedServer = server;
                                  });
                                },
                              ))
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

  Widget _buildAudioTypeButton(String type, String label, String selectedType, Function(String) onTap) {
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

  Widget _buildServerButton(Server server, bool isSelected, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF5B13EC) : const Color(0xFF3A3A3C),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(
                Icons.dns,
                color: Colors.white,
                size: 20,
              ),
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
              if (isSelected)
                Icon(
                  Icons.check,
                  color: Colors.white,
                  size: 20,
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _videoPlayerController.removeListener(_checkForSkipSegments);
    _videoPlayerController.removeListener(_onPositionChanged);
    // Save final position before disposing
    _savePlaybackPosition();
    _videoPlayerController.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
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
                Expanded(
                  child: Text(
                    widget.episodeTitle,
                    style: GoogleFonts.plusJakartaSans(
                      color: const Color(0xFFA7A7A7),
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (_selectedServer != null) ...[
                  Container(
                    margin: const EdgeInsets.only(left: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFF5B13EC),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${_selectedServer!.serverName} (${_selectedType.toUpperCase()})',
                      style: GoogleFonts.plusJakartaSans(
                        color: Colors.white,
                        fontSize: 10,
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
          IconButton(
            icon: const Icon(Icons.tune, color: Colors.white),
            onPressed: () {
              _showAdvancedSettings();
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white),
            onPressed: () {
              _showServerSelectionDialog();
            },
          ),
          IconButton(
            icon: const Icon(Icons.fullscreen, color: Colors.white),
            onPressed: () {
              if (_chewieController != null) {
                _chewieController!.enterFullScreen();
              }
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF5B13EC),
              ),
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
                  ? GestureDetector(
                      onDoubleTapDown: (details) {
                        final screenWidth = MediaQuery.of(context).size.width;
                        final tapPosition = details.globalPosition.dx;
                        
                        if (tapPosition < screenWidth / 2) {
                          // Double tap left side - skip backward 10 seconds
                          _skipBackward();
                        } else {
                          // Double tap right side - skip forward 10 seconds
                          _skipForward();
                        }
                      },
                      child: Chewie(controller: _chewieController!),
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
