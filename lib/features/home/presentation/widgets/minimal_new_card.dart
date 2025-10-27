import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:linze/core/models/anime_model.dart';
import 'package:linze/core/constants/constants.dart';
import 'package:linze/core/widgets/minimal_badge.dart';

class MinimalNewCard extends StatefulWidget {
  final Anime anime;
  final String releaseDate;
  final VoidCallback? onTap;
  final VoidCallback? onAddToList;

  const MinimalNewCard({
    super.key,
    required this.anime,
    required this.releaseDate,
    this.onTap,
    this.onAddToList,
  });

  @override
  State<MinimalNewCard> createState() => _MinimalNewCardState();
}

class _MinimalNewCardState extends State<MinimalNewCard>
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
              width: 160,
              decoration: BoxDecoration(
                color: surfaceElevatedColor,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Stack(
                      children: [
                        // Image
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: CachedNetworkImage(
                            imageUrl: widget.anime.poster.isEmpty ? 'https://via.placeholder.com/160x220/1F1F1F/EAEAEA?text=No+Image' : widget.anime.poster,
                            width: double.infinity,
                            height: 220,
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
                        // NEW badge
                        Positioned(
                          top: 8,
                          right: 8,
                          child: MinimalBadge(
                            text: 'NEW',
                            style: MinimalBadgeStyle.textOnly,
                            customColor: primaryColor,
                          ),
                        ),
                        // Add to list button
                        Positioned(
                          bottom: 8,
                          right: 8,
                          child: GestureDetector(
                            onTap: widget.onAddToList,
                            child: Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: surfaceElevatedColor,
                                border: Border.all(
                                  color: dividerColor,
                                  width: 1,
                                ),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: const Icon(
                                Icons.add,
                                color: textSecondaryColor,
                                size: 18,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    // Content section
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Title
                          Text(
                            widget.anime.title,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 6),
                          // Release date
                          Row(
                            children: [
                              Icon(
                                Icons.calendar_today,
                                color: textTertiaryColor,
                                size: 12,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                widget.releaseDate,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w400,
                                  color: textTertiaryColor,
                                ),
                              ),
                            ],
                          ),
                          // Episodes info if available
                          if (widget.anime.tvInfo?.eps != null) ...[
                            const SizedBox(height: 4),
                            Text(
                              '${widget.anime.tvInfo!.eps} episodes',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11,
                                fontWeight: FontWeight.w400,
                                color: textTertiaryColor,
                              ),
                            ),
                          ],
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