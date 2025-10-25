import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Overlay widget for episode navigation and auto-play countdown
class VideoPlayerOverlay extends StatelessWidget {
  final bool showOverlay;
  final String? nextEpisodeTitle;
  final String? nextEpisodeNumber;
  final int countdown;
  final VoidCallback? onPlayNow;
  final VoidCallback? onCancel;

  const VideoPlayerOverlay({
    super.key,
    required this.showOverlay,
    this.nextEpisodeTitle,
    this.nextEpisodeNumber,
    this.countdown = 0,
    this.onPlayNow,
    this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    if (!showOverlay) return const SizedBox.shrink();

    return Positioned(
      bottom: 80,
      right: 16,
      child: AnimatedOpacity(
        opacity: showOverlay ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 300),
        child: Container(
          width: 280,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF5B13EC), width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.play_circle_outline,
                    color: const Color(0xFF5B13EC),
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Next Episode',
                    style: GoogleFonts.plusJakartaSans(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Episode info
              if (nextEpisodeNumber != null) ...[
                Text(
                  'Episode $nextEpisodeNumber',
                  style: GoogleFonts.plusJakartaSans(
                    color: const Color(0xFF5B13EC),
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
              ],

              if (nextEpisodeTitle != null) ...[
                Text(
                  nextEpisodeTitle!,
                  style: GoogleFonts.plusJakartaSans(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
              ],

              // Countdown timer
              if (countdown > 0 && countdown <= 30)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF5B13EC).withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Auto-play in ${countdown}s',
                    style: GoogleFonts.plusJakartaSans(
                      color: const Color(0xFF5B13EC),
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),

              const SizedBox(height: 12),

              // Action buttons
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ElevatedButton(
                    onPressed: onPlayNow,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF5B13EC),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.play_arrow, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          'Play Now',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  TextButton(
                    onPressed: onCancel,
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.grey,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                    child: Text(
                      'Cancel',
                      style: GoogleFonts.plusJakartaSans(fontSize: 12),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Skip message overlay widget
class SkipMessageOverlay extends StatelessWidget {
  final String message;
  final bool show;

  const SkipMessageOverlay({
    super.key,
    required this.message,
    required this.show,
  });

  @override
  Widget build(BuildContext context) {
    if (!show) return const SizedBox.shrink();

    return Positioned(
      top: 100,
      left: 16,
      right: 16,
      child: AnimatedOpacity(
        opacity: show ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 300),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFF5B13EC).withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            message,
            style: GoogleFonts.plusJakartaSans(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
