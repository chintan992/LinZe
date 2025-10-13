import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:linze/core/models/anime_model.dart';

class ImmersiveHeroSection extends StatefulWidget {
  final List<Anime> spotlights;
  final VoidCallback? onPlay;
  final VoidCallback? onAddToList;
  final VoidCallback? onInfo;
  final Function(Anime)? onTap;

  const ImmersiveHeroSection({
    super.key,
    required this.spotlights,
    this.onPlay,
    this.onAddToList,
    this.onInfo,
    this.onTap,
  });

  @override
  State<ImmersiveHeroSection> createState() => _ImmersiveHeroSectionState();
}

class _ImmersiveHeroSectionState extends State<ImmersiveHeroSection>
    with TickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  int _currentIndex = 0;
  Timer? _autoPlayTimer;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
    _fadeController.forward();
    _startAutoPlay();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _fadeController.dispose();
    _autoPlayTimer?.cancel();
    super.dispose();
  }

  void _startAutoPlay() {
    _autoPlayTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (_pageController.hasClients) {
        int nextPage = (_currentIndex + 1) % widget.spotlights.length;
        _pageController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
    _fadeController.reset();
    _fadeController.forward();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.spotlights.isEmpty) return const SizedBox.shrink();

    final screenHeight = MediaQuery.of(context).size.height;
    final appBarHeight = kToolbarHeight + MediaQuery.of(context).padding.top;
    final heroHeight = screenHeight - appBarHeight;

    return SizedBox(
      height: heroHeight,
      child: Stack(
        children: [
          // Hero Background with Parallax Effect
          PageView.builder(
            controller: _pageController,
            onPageChanged: _onPageChanged,
            itemCount: widget.spotlights.length,
            itemBuilder: (context, index) {
              final anime = widget.spotlights[index];
              return FadeTransition(
                opacity: _fadeAnimation,
                child: _buildHeroSlide(anime, heroHeight),
              );
            },
          ),
          
          // Page Indicators
          Positioned(
            bottom: 60,
            left: 0,
            right: 0,
            child: _buildPageIndicators(),
          ),
          
          // Floating Action Buttons
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: _buildActionButtons(),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroSlide(Anime anime, double height) {
    return Container(
      width: double.infinity,
      height: height,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: CachedNetworkImageProvider(anime.poster.isNotEmpty ? anime.poster : 'https://via.placeholder.com/800x450/1F1F1F/EAEAEA?text=No+Image'),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(
            Colors.black.withValues(alpha: 0.3),
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
                Colors.black.withValues(alpha: 0.2),
                Colors.black.withValues(alpha: 0.8),
            ],
            stops: const [0.0, 0.6, 1.0],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.only(left: 24, right: 24, bottom: 120),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              // Featured Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF5B13EC),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'FEATURED',
                  style: GoogleFonts.plusJakartaSans(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.0,
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Title
              Text(
                anime.title,
                style: GoogleFonts.plusJakartaSans(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  height: 1.1,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              
              const SizedBox(height: 12),
              
              // Description
              if (anime.description?.isNotEmpty == true)
                Text(
                  anime.description!,
                  style: GoogleFonts.plusJakartaSans(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    height: 1.4,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              
              const SizedBox(height: 16),
              
              // Episode Info
              if (anime.tvInfo?.eps != null)
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${anime.tvInfo!.eps} Episodes',
                        style: GoogleFonts.plusJakartaSans(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    if (anime.tvInfo?.showType != null)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          anime.tvInfo!.showType!,
                          style: GoogleFonts.plusJakartaSans(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
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
  }

  Widget _buildPageIndicators() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        widget.spotlights.length,
        (index) => AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: _currentIndex == index ? 24 : 8,
          height: 8,
          decoration: BoxDecoration(
                color: _currentIndex == index 
                    ? const Color(0xFF5B13EC)
                    : Colors.white.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        // Play Button
        Expanded(
          flex: 3,
          child: GestureDetector(
            onTap: widget.onPlay,
            child: Container(
              height: 56,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(28),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.play_arrow,
                    color: Color(0xFF5B13EC),
                    size: 28,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Play',
                    style: GoogleFonts.plusJakartaSans(
                      color: const Color(0xFF5B13EC),
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        
        const SizedBox(width: 16),
        
        // Add to List Button
        GestureDetector(
          onTap: widget.onAddToList,
          child: Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                    color: Colors.white.withValues(alpha: 0.3),
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
        
        const SizedBox(width: 16),
        
        // Info Button
        GestureDetector(
          onTap: widget.onInfo,
          child: Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                    color: Colors.white.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: const Icon(
              Icons.info_outline,
              color: Colors.white,
              size: 24,
            ),
          ),
        ),
      ],
    );
  }
}

