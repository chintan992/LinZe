import 'package:flutter/material.dart';

/// Enhanced gesture controls for video player
class VideoGestureControls extends StatefulWidget {
  final Widget child;
  final VoidCallback onDoubleTapLeft;
  final VoidCallback onDoubleTapRight;
  final VoidCallback onTap;
  final Function(DragUpdateDetails)? onVerticalDragUpdate;
  final Function(DragUpdateDetails)? onHorizontalDragUpdate;

  const VideoGestureControls({
    super.key,
    required this.child,
    required this.onDoubleTapLeft,
    required this.onDoubleTapRight,
    required this.onTap,
    this.onVerticalDragUpdate,
    this.onHorizontalDragUpdate,
  });

  @override
  State<VideoGestureControls> createState() => _VideoGestureControlsState();
}

class _VideoGestureControlsState extends State<VideoGestureControls> {
  Offset? _dragStartPosition;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      onDoubleTapDown: (details) {
        final screenWidth = MediaQuery.of(context).size.width;
        final tapPosition = details.globalPosition.dx;

        if (tapPosition < screenWidth / 2) {
          widget.onDoubleTapLeft();
        } else {
          widget.onDoubleTapRight();
        }
      },
      onHorizontalDragStart: (details) {
        _dragStartPosition = details.globalPosition;
      },
      onHorizontalDragUpdate: (details) {
        if (_dragStartPosition != null &&
            widget.onHorizontalDragUpdate != null) {
          widget.onHorizontalDragUpdate!(details);
        }
      },
      onHorizontalDragEnd: (details) {
        _dragStartPosition = null;
      },
      onVerticalDragStart: (details) {
        _dragStartPosition = details.globalPosition;
      },
      onVerticalDragUpdate: (details) {
        if (_dragStartPosition != null && widget.onVerticalDragUpdate != null) {
          widget.onVerticalDragUpdate!(details);
        }
      },
      onVerticalDragEnd: (details) {
        _dragStartPosition = null;
      },
      child: widget.child,
    );
  }
}

/// Seek preview widget for horizontal drag gestures
class SeekPreview extends StatelessWidget {
  final Duration currentPosition;
  final Duration totalDuration;
  final Duration seekPosition;
  final bool show;

  const SeekPreview({
    super.key,
    required this.currentPosition,
    required this.totalDuration,
    required this.seekPosition,
    required this.show,
  });

  @override
  Widget build(BuildContext context) {
    if (!show) return const SizedBox.shrink();

    final progress = seekPosition.inMilliseconds / totalDuration.inMilliseconds;
    final clampedProgress = progress.clamp(0.0, 1.0);

    return Positioned(
      top: MediaQuery.of(context).size.height / 2 - 50,
      left: 16,
      right: 16,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.8),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Progress bar
            LinearProgressIndicator(
              value: clampedProgress,
              backgroundColor: Colors.white.withValues(alpha: 0.3),
              valueColor: const AlwaysStoppedAnimation<Color>(
                Color(0xFF5B13EC),
              ),
            ),
            const SizedBox(height: 8),
            // Time display
            Text(
              '${_formatDuration(seekPosition)} / ${_formatDuration(totalDuration)}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
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
}

/// Brightness/Volume control preview for vertical drag gestures
class ControlPreview extends StatelessWidget {
  final String icon;
  final double value;
  final bool show;

  const ControlPreview({
    super.key,
    required this.icon,
    required this.value,
    required this.show,
  });

  @override
  Widget build(BuildContext context) {
    if (!show) return const SizedBox.shrink();

    return Positioned(
      top: MediaQuery.of(context).size.height / 2 - 50,
      right: 16,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.8),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(icon, style: const TextStyle(fontSize: 24)),
            const SizedBox(height: 8),
            SizedBox(
              width: 40,
              height: 120,
              child: RotatedBox(
                quarterTurns: 3,
                child: LinearProgressIndicator(
                  value: value.clamp(0.0, 1.0),
                  backgroundColor: Colors.white.withValues(alpha: 0.3),
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    Color(0xFF5B13EC),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${(value * 100).round()}%',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
