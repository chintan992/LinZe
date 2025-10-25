import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ChapterSelector extends StatefulWidget {
  final List<Map<String, dynamic>> chapters;
  final Function(int) onChapterSelected;
  final Duration currentPosition;
  final Duration totalDuration;
  final bool isVisible;
  final Function(bool) onVisibilityChanged;

  const ChapterSelector({
    super.key,
    required this.chapters,
    required this.onChapterSelected,
    required this.currentPosition,
    required this.totalDuration,
    this.isVisible = false,
    required this.onVisibilityChanged,
  });

  @override
  State<ChapterSelector> createState() => _ChapterSelectorState();
}

class _ChapterSelectorState extends State<ChapterSelector> {
  bool _isVisible = false;

  @override
  Widget build(BuildContext context) {
    if (widget.chapters.isEmpty || !widget.isVisible) {
      return const SizedBox.shrink();
    }

    return Positioned(
      bottom: 150,
      left: 16,
      right: 16,
      child: AnimatedOpacity(
        opacity: widget.isVisible ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 300),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF5B13EC), width: 1),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Row(
                children: [
                  Icon(
                    Icons.menu_book,
                    color: const Color(0xFF5B13EC),
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Chapters',
                    style: GoogleFonts.plusJakartaSans(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () {
                      widget.onVisibilityChanged(false);
                    },
                    icon: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Chapter list
              ...widget.chapters.asMap().entries.map((entry) {
                int index = entry.key;
                var chapter = entry.value;

                // Calculate progress for this chapter
                final startSec = (chapter['start'] as Duration).inSeconds;
                final currentSec = widget.currentPosition.inSeconds;

                bool isCurrent = currentSec >= startSec;
                bool isPlayed =
                    currentSec > (chapter['end'] as Duration).inSeconds;

                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                    leading: Icon(
                      Icons.play_circle_outline,
                      color: isPlayed
                          ? const Color(0xFF5B13EC).withValues(alpha: 0.5)
                          : isCurrent
                          ? Colors.yellow
                          : const Color(0xFF5B13EC),
                    ),
                    title: Text(
                      chapter['title'],
                      style: GoogleFonts.plusJakartaSans(
                        color: isPlayed ? Colors.grey : Colors.white,
                        fontWeight: isCurrent
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                    subtitle: Text(
                      '${_formatDuration(chapter['start'])} - ${_formatDuration(chapter['end'])}',
                      style: GoogleFonts.plusJakartaSans(
                        color: Colors.grey[400],
                        fontSize: 12,
                      ),
                    ),
                    onTap: () {
                      widget.onChapterSelected(index);
                      widget.onVisibilityChanged(false);
                    },
                  ),
                );
              }),
            ],
          ),
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

  void toggleVisibility() {
    setState(() {
      _isVisible = !_isVisible;
    });
  }

  void hide() {
    setState(() {
      _isVisible = false;
    });
  }
}
