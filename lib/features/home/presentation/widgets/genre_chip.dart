import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:linze/core/constants/constants.dart';

class GenreChip extends StatefulWidget {
  final String genre;
  final bool isSelected;
  final VoidCallback? onTap;

  const GenreChip({
    super.key,
    required this.genre,
    this.isSelected = false,
    this.onTap,
  });

  @override
  State<GenreChip> createState() => _GenreChipState();
}

class _GenreChipState extends State<GenreChip>
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
  void didUpdateWidget(GenreChip oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isSelected != oldWidget.isSelected) {
      if (widget.isSelected) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (_) => _animationController.forward(),
      onTapUp: (_) {
        if (!widget.isSelected) {
          _animationController.reverse();
        }
      },
      onTapCancel: () {
        if (!widget.isSelected) {
          _animationController.reverse();
        }
      },
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: widget.isSelected 
                    ? primaryColor
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: widget.isSelected 
                      ? primaryColor
                      : dividerColor,
                  width: 1,
                ),
              ),
              child: Text(
                widget.genre,
                style: GoogleFonts.plusJakartaSans(
                  color: widget.isSelected 
                      ? Colors.white
                      : textSecondaryColor,
                  fontSize: 14,
                  fontWeight: widget.isSelected 
                      ? FontWeight.w600
                      : FontWeight.w500,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class GenreChipsList extends StatefulWidget {
  final List<String> genres;
  final String? selectedGenre;
  final Function(String)? onGenreSelected;

  const GenreChipsList({
    super.key,
    required this.genres,
    this.selectedGenre,
    this.onGenreSelected,
  });

  @override
  State<GenreChipsList> createState() => _GenreChipsListState();
}

class _GenreChipsListState extends State<GenreChipsList> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: widget.genres.length,
        itemBuilder: (context, index) {
          final genre = widget.genres[index];
          final isSelected = widget.selectedGenre == genre;
          
          return GenreChip(
            genre: genre,
            isSelected: isSelected,
            onTap: () {
              widget.onGenreSelected?.call(genre);
            },
          );
        },
      ),
    );
  }
}
