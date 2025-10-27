import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:linze/core/models/anime_model.dart';
import 'package:linze/core/constants/constants.dart';

class MinimalContinueWatchingCard extends StatefulWidget {
  final Anime anime;
  final double progress;
  final String currentEpisode;
  final VoidCallback? onTap;
  final VoidCallback? onResume;

  const MinimalContinueWatchingCard({
    super.key,
    required this.anime,
    required this.progress,
    required this.currentEpisode,
    this.onTap,
    this.onResume,
  });

  @override
  State<MinimalContinueWatchingCard> createState() => _MinimalContinueWatchingCardState();
}

class _MinimalContinueWatchingCardState extends State<MinimalContinueWatchingCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.02,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (details) {
        _animationController.forward();
      },
      onTapUp: (details) {
        _animationController.reverse();
      },
      onTapCancel: () {
        _animationController.reverse();
      },
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              width: 200,
              decoration: BoxDecoration(
                color: surfaceElevatedColor,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Image with progress bar
                    Stack(
                      children: [
                        AspectRatio(
                          aspectRatio: 2 / 3,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: CachedNetworkImage(
                              imageUrl: widget.anime.poster.isEmpty ? 'https://via.placeholder.com/200x300/1F1F1F/EAEAEA?text=No+Image' : widget.anime.poster,
                              width: double.infinity,
                              height: double.infinity,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Container(
                                color: surfaceColor,
                                child: const Center(
                                  child: CircularProgressIndicator(
                                    color: primaryColor,
                                  ),
                                ),
                              ),
                              errorWidget: (context, url, error) => Container(
                                color: surfaceColor,
                                child: const Icon(
                                  Icons.error,
                                  color: Colors.red,
                                ),
                              ),
                            ),
                          ),
                        ),
                        // Progress bar at the bottom
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: Container(
                            height: 3,
                            color: surfaceElevatedColor,
                            child: LayoutBuilder(
                              builder: (context, constraints) {
                                // Clamp progress to [0, 1] to prevent overflow
                                double clampedProgress = widget.progress.clamp(0.0, 1.0);
                                return Stack(
                                  children: [
                                    Container(
                                      width: constraints.maxWidth,
                                      height: 3,
                                      color: surfaceElevatedColor,
                                    ),
                                    Container(
                                      width: constraints.maxWidth * clampedProgress,
                                      height: 3,
                                      color: primaryColor,
                                    ),
                                  ],
                                );
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                    // Content padding
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.anime.title,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.currentEpisode,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                              color: textSecondaryColor,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${(widget.progress * 100).round()}% watched',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: textTertiaryColor,
                            ),
                          ),
                          const SizedBox(height: 12),
                          // Resume button
                          GestureDetector(
                            onTap: widget.onResume,
                            child: Container(
                              width: double.infinity,
                              height: 36,
                              decoration: BoxDecoration(
                                color: surfaceElevatedColor,
                                border: Border.all(
                                  color: dividerColor,
                                  width: 1,
                                ),
                                borderRadius: BorderRadius.circular(18),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.play_arrow,
                                    color: textSecondaryColor,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Resume',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: textSecondaryColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}