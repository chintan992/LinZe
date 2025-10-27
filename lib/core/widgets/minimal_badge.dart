import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/constants.dart';

enum MinimalBadgeStyle {
  textOnly,
  outlined,
  filled,
}

enum MinimalBadgeSize {
  small,
  medium,
  large,
}

class MinimalBadge extends StatelessWidget {
  final String text;
  final MinimalBadgeStyle style;
  final Color? customColor;
  final MinimalBadgeSize size;

  const MinimalBadge({
    super.key,
    required this.text,
    this.style = MinimalBadgeStyle.textOnly,
    this.customColor,
    this.size = MinimalBadgeSize.medium,
  });

  @override
  Widget build(BuildContext context) {
    // Determine colors based on style and custom color
    Color textColor = customColor ?? textSecondaryColor;
    Color backgroundColor = Colors.transparent;
    Color borderColor = Colors.transparent;
    
    // Determine size parameters based on the size enum
    double fontSize;
    EdgeInsets padding;
    
    // Set defaults before the switch
    fontSize = 11;
    padding = const EdgeInsets.symmetric(horizontal: 8, vertical: 4);
    
    switch (size) {
      case MinimalBadgeSize.small:
        fontSize = 10;
        padding = const EdgeInsets.symmetric(horizontal: 6, vertical: 3);
        break;
      case MinimalBadgeSize.large:
        fontSize = 12;
        padding = const EdgeInsets.symmetric(horizontal: 10, vertical: 5);
        break;
      case MinimalBadgeSize.medium:
        fontSize = 11;
        padding = const EdgeInsets.symmetric(horizontal: 8, vertical: 4);
        break;
    }

    switch (style) {
      case MinimalBadgeStyle.outlined:
        borderColor = (customColor ?? textTertiaryColor).withValues(alpha: 0.4);
        textColor = customColor ?? textSecondaryColor;
        break;
      case MinimalBadgeStyle.filled:
        backgroundColor = (customColor ?? textTertiaryColor).withValues(alpha: 0.2);
        textColor = Colors.white.withValues(alpha: 0.9);
        break;
      case MinimalBadgeStyle.textOnly:
        // textOnly style - no background, no border
        break;
    }

    Widget badge = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor,
        border: style == MinimalBadgeStyle.outlined
            ? Border.all(color: borderColor, width: 1)
            : null,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: GoogleFonts.plusJakartaSans(
          fontSize: fontSize,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );

    return Semantics(
      label: text,
      child: badge,
    );
  }
}