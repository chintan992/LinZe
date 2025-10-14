import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

const Color primaryColor = Color(0xFF1E1E1E);
const Color secondaryColor = Color(0xFFF2F2F2);
const Color accentColor = Color(0xFFE50914);

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
