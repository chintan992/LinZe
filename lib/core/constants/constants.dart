import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

const Color primaryColor = Color(0xFF5B13EC); // Purple as main brand color
const Color secondaryColor = Color(0xFFF2F2F2);
const Color accentColor = Color(0xFFE50914);

// New color constants for the minimal design system
// Background colors
const Color surfaceColor = Color(0xFF1A1A1A); // Base surface color for cards and containers
const Color surfaceElevatedColor = Color(0xFF242424); // Elevated surface color for raised cards

// Text colors
const Color textSecondaryColor = Color(0xFFB0B0B0); // Secondary text color for less prominent text
const Color textTertiaryColor = Color(0xFF808080); // Tertiary text color for metadata and hints

// Other colors
const Color dividerColor = Color(0xFF2A2A2A); // Divider and border color
const Color primarySubtleColor = Color(0x335B13EC); // Subtle primary color for backgrounds (20% opacity)

// AniList API Configuration
class AniListConfig {
  static const String clientId = '23101';
  static const String clientSecret = 'cuZR7aaVPa2bNUGVhSlTKHEJ8uxhcjwxprD5ayDk';
  static const String redirectUri = 'linze://anilist/callback';
  static const String baseUrl = 'https://graphql.anilist.co';
  static const String oauthUrl = 'https://anilist.co/api/v2/oauth/authorize';
  static const String tokenUrl = 'https://anilist.co/api/v2/oauth/token';
}

// Streaming API Configuration
class StreamingApiConfig {
  static String get baseUrl => dotenv.env['API_BASE_URL'] ?? 'https://anime-api-test-one.vercel.app';
}
