import 'package:flutter/material.dart';
import 'package:chewie/chewie.dart';
import 'package:video_player/video_player.dart';
import 'package:google_fonts/google_fonts.dart';

/// Custom video controls with modern design
class CustomVideoControls extends StatefulWidget {
  final ChewieController chewieController;
  final VoidCallback onSettingsPressed;
  final VoidCallback onFullscreenPressed;
  final VoidCallback onSkipBackward;
  final VoidCallback onSkipForward;
  final VoidCallback onPipPressed;
  final VoidCallback onChapterPressed;

  const CustomVideoControls({
    super.key,
    required this.chewieController,
    required this.onSettingsPressed,
    required this.onFullscreenPressed,
    required this.onSkipBackward,
    required this.onSkipForward,
    required this.onPipPressed,
    required this.onChapterPressed,
  });

  @override
  State<CustomVideoControls> createState() => _CustomVideoControlsState();
}

class _CustomVideoControlsState extends State<CustomVideoControls>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black.withValues(alpha: 0.7),
              Colors.black.withValues(alpha: 0.3),
              Colors.transparent,
              Colors.black.withValues(alpha: 0.3),
              Colors.black.withValues(alpha: 0.7),
            ],
          ),
        ),
        child: Column(
          children: [
            // Top controls
            _buildTopControls(),

            // Center play/pause and skip buttons
            Expanded(child: _buildCenterControls()),

            // Bottom controls
            _buildBottomControls(),
          ],
        ),
      ),
    );
  }

  Widget _buildTopControls() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          // Back button
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
          ),
          const Spacer(),
          // Chapter button
          IconButton(
            onPressed: widget.onChapterPressed,
            icon: const Icon(Icons.menu_book, color: Colors.white, size: 28),
          ),
          // PiP button
          IconButton(
            onPressed: widget.onPipPressed,
            icon: const Icon(Icons.picture_in_picture_alt_outlined, color: Colors.white, size: 28),
          ),
          // Settings button
          IconButton(
            onPressed: widget.onSettingsPressed,
            icon: const Icon(Icons.settings, color: Colors.white, size: 28),
          ),
        ],
      ),
    );
  }

  Widget _buildCenterControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Skip backward
        _buildControlButton(
          icon: Icons.replay_10,
          onPressed: widget.onSkipBackward,
          label: '10s',
        ),

        const SizedBox(width: 40),

        // Play/Pause
        _buildPlayPauseButton(),

        const SizedBox(width: 40),

        // Skip forward
        _buildControlButton(
          icon: Icons.forward_10,
          onPressed: widget.onSkipForward,
          label: '10s',
        ),
      ],
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required VoidCallback onPressed,
    required String label,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(30),
          ),
          child: IconButton(
            onPressed: onPressed,
            icon: Icon(icon, color: Colors.white, size: 32),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildPlayPauseButton() {
    final isPlaying =
        widget.chewieController.videoPlayerController.value.isPlaying;

    return Container(
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
      child: IconButton(
        onPressed: () {
          if (isPlaying) {
            widget.chewieController.pause();
          } else {
            widget.chewieController.play();
          }
        },
        icon: Icon(
          isPlaying ? Icons.pause : Icons.play_arrow,
          color: Colors.white,
          size: 48,
        ),
      ),
    );
  }

  Widget _buildBottomControls() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Column(
        children: [
          // Progress bar
          _buildProgressBar(),

          const SizedBox(height: 12),

          // Time and fullscreen
          Row(
            children: [
              // Current time
              _buildTimeDisplay(),

              const Spacer(),

              // Fullscreen button
              IconButton(
                onPressed: widget.onFullscreenPressed,
                icon: const Icon(
                  Icons.fullscreen,
                  color: Colors.white,
                  size: 28,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar() {
    return VideoProgressIndicator(
      widget.chewieController.videoPlayerController,
      allowScrubbing: true,
      colors: VideoProgressColors(
        playedColor: const Color(0xFF5B13EC),
        bufferedColor: Colors.white.withValues(alpha: 0.5),
        backgroundColor: Colors.white.withValues(alpha: 0.3),
      ),
    );
  }

  Widget _buildTimeDisplay() {
    return ValueListenableBuilder<VideoPlayerValue>(
      valueListenable: widget.chewieController.videoPlayerController,
      builder: (context, value, child) {
        final position = value.position;
        final duration = value.duration;

        return Text(
          '${_formatDuration(position)} / ${_formatDuration(duration)}',
          style: GoogleFonts.plusJakartaSans(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        );
      },
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
}
