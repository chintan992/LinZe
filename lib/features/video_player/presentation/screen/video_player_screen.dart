import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:chewie/chewie.dart';
import 'package:video_player/video_player.dart';
import 'package:linze/core/models/streaming_models.dart';
import 'package:linze/core/services/anime_provider.dart';
import 'package:linze/core/api/api_service.dart';

class VideoPlayerScreen extends ConsumerStatefulWidget {
  final StreamingLink streamingLink;
  final String animeTitle;
  final String episodeTitle;
  final String episodeId;

  const VideoPlayerScreen({
    Key? key,
    required this.streamingLink,
    required this.animeTitle,
    required this.episodeTitle,
    required this.episodeId,
  }) : super(key: key);

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
        );

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
                  ? Chewie(controller: _chewieController!)
                  : const Center(
                      child: Text(
                        'Video player not initialized',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
    );
  }
}
