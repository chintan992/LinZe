import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:linze/core/models/anime_model.dart';
import 'package:linze/core/constants/constants.dart';
import 'package:linze/core/widgets/minimal_badge.dart';

class MinimalHeroBanner extends StatefulWidget {
  final Anime featuredAnime;
  final VoidCallback? onPlay;
  final VoidCallback? onAddToList;
  final ValueChanged<Anime>? onTap;
  final double heightPercentage;

  const MinimalHeroBanner({
    super.key,
    required this.featuredAnime,
    this.onPlay,
    this.onAddToList,
    this.onTap,
    this.heightPercentage = 0.38,
  });

  @override
  State<MinimalHeroBanner> createState() => _MinimalHeroBannerState();
}

class _MinimalHeroBannerState extends State<MinimalHeroBanner>
    with SingleTickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    ));
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final calculatedHeight = screenHeight * widget.heightPercentage;

    Widget bannerContent = Container(
      height: calculatedHeight,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: CachedNetworkImageProvider(
            (widget.featuredAnime.poster.isNotEmpty) 
                ? widget.featuredAnime.poster 
                : 'https://via.placeholder.com/800x450/1F1F1F/EAEAEA?text=No+Image',
          ),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(
            Colors.black.withValues(alpha: 0.4),
            BlendMode.darken,
          ),
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.transparent,
              Colors.black.withValues(alpha: 0.3),
              Colors.black.withValues(alpha: 0.85),
            ],
            stops: const [0.0, 0.5, 1.0],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.only(left: 20, right: 20, bottom: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              MinimalBadge(
                text: 'FEATURED',
                style: MinimalBadgeStyle.filled,
                customColor: primaryColor,
              ),
              const SizedBox(height: 10),
              Text(
                widget.featuredAnime.title,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              if (widget.featuredAnime.description?.isNotEmpty == true) ...[
                Text(
                  widget.featuredAnime.description!,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: textSecondaryColor,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 16),
              ],
              if (widget.featuredAnime.tvInfo?.eps != null) ...[
                Row(
                  children: [
                    MinimalBadge(
                      text: '${widget.featuredAnime.tvInfo!.eps} Episodes',
                      style: MinimalBadgeStyle.outlined,
                    ),
                    const SizedBox(width: 8),
                    if (widget.featuredAnime.tvInfo?.showType != null)
                      MinimalBadge(
                        text: widget.featuredAnime.tvInfo!.showType!,
                        style: MinimalBadgeStyle.outlined,
                      ),
                  ],
                ),
                const SizedBox(height: 16),
              ],
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: GestureDetector(
                      onTap: widget.onPlay,
                      child: Container(
                        height: 52,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(26),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.play_arrow,
                              color: primaryColor,
                              size: 26,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Play',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: primaryColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: widget.onAddToList,
                    child: Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: surfaceElevatedColor,
                        borderRadius: BorderRadius.circular(26),
                        border: Border.all(
                          color: dividerColor,
                          width: 1,
                        ),
                      ),
                      child: const Icon(
                        Icons.add,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    // Wrap in FadeTransition for animation
    bannerContent = FadeTransition(
      opacity: _fadeAnimation,
      child: bannerContent,
    );

    // Wrap in GestureDetector if onTap is provided
    if (widget.onTap != null) {
      bannerContent = GestureDetector(
        onTap: () => widget.onTap?.call(widget.featuredAnime),
        child: bannerContent,
      );
    }

    return SizedBox(
      height: calculatedHeight,
      child: bannerContent,
    );
  }
}