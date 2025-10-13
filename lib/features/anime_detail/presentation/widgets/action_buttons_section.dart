import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ActionButtonsSection extends StatefulWidget {
  final VoidCallback? onPlayPressed;
  final VoidCallback? onAddToListPressed;
  final VoidCallback? onSharePressed;
  final VoidCallback? onDownloadPressed;
  final bool isInWatchlist;
  final bool isFavorite;
  final String? continueFromEpisode;

  const ActionButtonsSection({
    super.key,
    this.onPlayPressed,
    this.onAddToListPressed,
    this.onSharePressed,
    this.onDownloadPressed,
    this.isInWatchlist = false,
    this.isFavorite = false,
    this.continueFromEpisode,
  });

  @override
  State<ActionButtonsSection> createState() => _ActionButtonsSectionState();
}

class _ActionButtonsSectionState extends State<ActionButtonsSection>
    with TickerProviderStateMixin {
  late AnimationController _buttonAnimationController;
  late Animation<double> _buttonScaleAnimation;

  @override
  void initState() {
    super.initState();
    _buttonAnimationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _buttonScaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _buttonAnimationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _buttonAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Primary action buttons
          Row(
            children: [
              // Play button
              Expanded(
                flex: 3,
                child: AnimatedBuilder(
                  animation: _buttonScaleAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _buttonScaleAnimation.value,
                      child: _buildPrimaryButton(
                        icon: Icons.play_arrow_rounded,
                        label: widget.continueFromEpisode != null
                            ? 'Continue from ${widget.continueFromEpisode}'
                            : 'Play Episode',
                        onPressed: () {
                          _buttonAnimationController.forward().then((_) {
                            _buttonAnimationController.reverse();
                            widget.onPlayPressed?.call();
                          });
                        },
                        gradient: const LinearGradient(
                          colors: [Color(0xFF5B13EC), Color(0xFF7B2CBF)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                    );
                  },
                ),
              ),
              
              const SizedBox(width: 12),
              
              // Add to list button
              _buildSecondaryButton(
                icon: widget.isInWatchlist ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                onPressed: widget.onAddToListPressed,
                isActive: widget.isInWatchlist,
                tooltip: widget.isInWatchlist ? 'Remove from Watchlist' : 'Add to Watchlist',
              ),
              
              const SizedBox(width: 8),
              
              // Share button
              _buildSecondaryButton(
                icon: Icons.share_rounded,
                onPressed: widget.onSharePressed,
                tooltip: 'Share Anime',
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          // Secondary action buttons
          Row(
            children: [
              // Download button (if available)
              if (widget.onDownloadPressed != null)
                Expanded(
                  child: _buildTertiaryButton(
                    icon: Icons.download_rounded,
                    label: 'Download',
                    onPressed: widget.onDownloadPressed!,
                  ),
                ),
              
              if (widget.onDownloadPressed != null)
                const SizedBox(width: 12),
              
              // Favorite button
              Expanded(
                child: _buildTertiaryButton(
                  icon: widget.isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                  label: widget.isFavorite ? 'Favorited' : 'Add to Favorites',
                  onPressed: () {
                    // This would be handled by the parent widget
                  },
                  isActive: widget.isFavorite,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPrimaryButton({
    required IconData icon,
    required String label,
    required VoidCallback? onPressed,
    required Gradient gradient,
  }) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF5B13EC).withValues(alpha: 0.4),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onPressed,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  color: Colors.white,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    label,
                    style: GoogleFonts.plusJakartaSans(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSecondaryButton({
    required IconData icon,
    required VoidCallback? onPressed,
    String? tooltip,
    bool isActive = false,
  }) {
    return Container(
      height: 56,
      width: 56,
      decoration: BoxDecoration(
        color: isActive
            ? const Color(0xFF5B13EC).withValues(alpha: 0.2)
            : const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isActive
              ? const Color(0xFF5B13EC)
              : const Color(0xFF2F2F2F),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onPressed,
          child: Tooltip(
            message: tooltip ?? '',
            child: Icon(
              icon,
              color: isActive ? const Color(0xFF5B13EC) : Colors.white,
              size: 24,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTertiaryButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    bool isActive = false,
  }) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: isActive
            ? const Color(0xFFEF4444).withValues(alpha: 0.2)
            : const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isActive
              ? const Color(0xFFEF4444)
              : const Color(0xFF2F2F2F),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onPressed,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  color: isActive ? const Color(0xFFEF4444) : Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    label,
                    style: GoogleFonts.plusJakartaSans(
                      color: isActive ? const Color(0xFFEF4444) : Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
