import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/constants.dart';

/// A reusable wrapper widget for content sections with consistent elevation and spacing.
/// 
/// The background color is automatically determined based on the elevation:
/// - If elevation > 2, uses [surfaceElevatedColor] 
/// - Otherwise, uses [surfaceColor]
/// This creates a visual hierarchy where higher elevation cards appear more prominent.
class SectionCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final double? elevation;
  final String? title;
  final Widget? trailing;

  const SectionCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.elevation,
    this.title,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    // Default values
    final EdgeInsets actualPadding = padding ?? const EdgeInsets.all(16);
    final EdgeInsets actualMargin = margin ?? const EdgeInsets.symmetric(vertical: 24, horizontal: 16);
    final double actualElevation = elevation ?? 2.0;
    
    Color backgroundColor = actualElevation > 2 ? surfaceElevatedColor : surfaceColor;

    return Padding(
      padding: actualMargin,
      child: Material(
        color: backgroundColor,
        elevation: actualElevation,
        borderRadius: BorderRadius.circular(16),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (title != null || trailing != null) ...[
              Padding(
                padding: const EdgeInsets.only(bottom: 20, left: 16, right: 16, top: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (title != null)
                      Text(
                        title!,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    if (trailing != null) trailing!,
                  ],
                ),
              ),
            ],
            Padding(
              padding: actualPadding,
              child: child,
            ),
          ],
        ),
      ),
    );
  }
}