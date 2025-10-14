import 'dart:async';
import 'dart:convert';
import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:linze/core/constants/constants.dart';
import 'package:linze/core/models/anilist/anilist_auth.dart';

class AniListAuthService {
  static const _storage = FlutterSecureStorage();
  static const String _accessTokenKey = 'anilist_access_token';
  static const String _refreshTokenKey = 'anilist_refresh_token';
  static const String _expiresAtKey = 'anilist_expires_at';
  static const String _tokenTypeKey = 'anilist_token_type';

  final AppLinks _appLinks = AppLinks();
  StreamSubscription<Uri>? _linkSubscription;

  AniListAuthTokens? _currentTokens;
  AniListUser? _currentUser;
  String? _lastUsedCode;

  AniListAuthTokens? get currentTokens => _currentTokens;
  AniListUser? get currentUser => _currentUser;
  bool get isLoggedIn => _currentTokens != null && !_currentTokens!.isExpired;

  // Initialize auth service and check for existing tokens
  Future<void> initialize() async {
    await _loadStoredTokens();
    if (_currentTokens != null && !_currentTokens!.isExpired) {
      await _loadUserProfile();
    }
  }

  // Load stored tokens from secure storage
  Future<void> _loadStoredTokens() async {
    try {
      final accessToken = await _storage.read(key: _accessTokenKey);
      final refreshToken = await _storage.read(key: _refreshTokenKey);
      final expiresAtString = await _storage.read(key: _expiresAtKey);
      final tokenType = await _storage.read(key: _tokenTypeKey);

      if (accessToken != null && expiresAtString != null) {
        _currentTokens = AniListAuthTokens(
          accessToken: accessToken,
          refreshToken: refreshToken,
          expiresAt: DateTime.parse(expiresAtString),
          tokenType: tokenType ?? 'Bearer',
        );
      }
    } catch (e) {
      debugPrint('Error loading stored tokens: $e');
      _currentTokens = null;
    }
  }

  // Store tokens in secure storage
  Future<void> _storeTokens(AniListAuthTokens tokens) async {
    try {
      await _storage.write(key: _accessTokenKey, value: tokens.accessToken);
      if (tokens.refreshToken != null) {
        await _storage.write(
          key: _refreshTokenKey,
          value: tokens.refreshToken!,
        );
      }
      await _storage.write(
        key: _expiresAtKey,
        value: tokens.expiresAt.toIso8601String(),
      );
      await _storage.write(key: _tokenTypeKey, value: tokens.tokenType);
      _currentTokens = tokens;
    } catch (e) {
      debugPrint('Error storing tokens: $e');
    }
  }

  // Clear stored tokens
  Future<void> _clearStoredTokens() async {
    try {
      await _storage.delete(key: _accessTokenKey);
      await _storage.delete(key: _refreshTokenKey);
      await _storage.delete(key: _expiresAtKey);
      await _storage.delete(key: _tokenTypeKey);
      _currentTokens = null;
      _currentUser = null;
    } catch (e) {
      debugPrint('Error clearing stored tokens: $e');
    }
  }

  // Test URL launcher with a simple URL first
  Future<bool> _testUrlLauncher() async {
    try {
      final testUrl = Uri.parse('https://www.google.com');
      final launched = await launchUrl(testUrl, mode: LaunchMode.externalApplication);
      debugPrint('URL launcher test result: $launched');
      return launched;
    } catch (e) {
      debugPrint('URL launcher test failed: $e');
      return false;
    }
  }

  // Start OAuth flow
  Future<void> startOAuthFlow() async {
    // Test URL launcher first
    final urlLauncherWorking = await _testUrlLauncher();
    if (!urlLauncherWorking) {
      throw Exception('URL launcher is not working on this device');
    }

    final authUrl = _buildAuthUrl();
    final uri = Uri.parse(authUrl);
    
    debugPrint('Generated OAuth URL: $authUrl');
    debugPrint('Parsed URI: $uri');

    // Listen for deep link callback
    _linkSubscription = _appLinks.uriLinkStream.listen(
      _handleDeepLink,
      onError: (err) => debugPrint('Deep link error: $err'),
    );

    // Launch browser with OAuth URL
    try {
      // Try to launch the URL directly
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      
      if (launched) {
        debugPrint('Successfully launched AniList OAuth URL: $uri');
      } else {
        throw Exception('Failed to launch AniList OAuth URL');
      }
    } catch (e) {
      debugPrint('Error launching OAuth URL: $e');
      debugPrint('URL that failed to launch: $uri');
      
      // Try alternative launch method
      try {
        final launched = await launchUrl(
          uri,
          mode: LaunchMode.platformDefault,
        );
        if (launched) {
          debugPrint('Successfully launched with platform default mode');
        } else {
          throw Exception('Failed to launch with platform default mode');
        }
      } catch (e2) {
        debugPrint('Alternative launch method also failed: $e2');
        rethrow;
      }
    }
  }

  // Build OAuth authorization URL
  String _buildAuthUrl() {
    final params = {
      'client_id': AniListConfig.clientId,
      'response_type': 'code',
      'redirect_uri': AniListConfig.redirectUri,
    };

    // Build URL manually to ensure proper encoding
    final baseUrl = AniListConfig.oauthUrl;
    final queryString = params.entries
        .map((e) => '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
        .join('&');
    
    final fullUrl = '$baseUrl?$queryString';
    debugPrint('Built OAuth URL: $fullUrl');
    
    return fullUrl;
  }

  // Handle deep link callback
  Future<void> _handleDeepLink(Uri uri) async {
    debugPrint('Deep link received: $uri');
    debugPrint('Scheme: ${uri.scheme}, Host: ${uri.host}, Path: ${uri.path}');
    debugPrint('Query parameters: ${uri.queryParameters}');
    
    if (uri.scheme == 'linze' &&
        uri.host == 'anilist' &&
        uri.path == '/callback') {
      final code = uri.queryParameters['code'];
      final error = uri.queryParameters['error'];

      debugPrint('Authorization code: $code');
      debugPrint('Error parameter: $error');

      _linkSubscription?.cancel();

      if (error != null) {
        throw AniListAuthException('OAuth error: $error');
      }

      if (code != null) {
        // Check if we've already used this code
        if (_lastUsedCode == code) {
          debugPrint('Authorization code already used, ignoring duplicate');
          return;
        }
        _lastUsedCode = code;
        await _exchangeCodeForTokens(code);
      } else {
        throw AniListAuthException('No authorization code received');
      }
    } else {
      debugPrint('Deep link does not match expected pattern');
    }
  }

  // Exchange authorization code for access token
  Future<void> _exchangeCodeForTokens(String code) async {
    try {
      debugPrint('Exchanging code for tokens: $code');
      
      final response = await http.post(
        Uri.parse(AniListConfig.tokenUrl),
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
          'Accept': 'application/json',
        },
        body: {
          'grant_type': 'authorization_code',
          'client_id': AniListConfig.clientId,
          'client_secret': AniListConfig.clientSecret,
          'redirect_uri': AniListConfig.redirectUri,
          'code': code,
        },
      );

      debugPrint('Token exchange response status: ${response.statusCode}');
      debugPrint('Token exchange response body: ${response.body}');
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        debugPrint('Token exchange successful, data: $data');
        final tokens = AniListAuthTokens.fromJson(data);
        await _storeTokens(tokens);
        await _loadUserProfile();
        debugPrint('User profile loaded successfully');
      } else {
        debugPrint('Token exchange failed with status: ${response.statusCode}');
        debugPrint('Response body: ${response.body}');
        throw AniListAuthException(
          'Failed to exchange code for tokens: ${response.statusCode} ${response.body}',
        );
      }
    } catch (e) {
      debugPrint('Token exchange error: $e');
      throw AniListAuthException('Token exchange failed: $e');
    }
  }

  // Refresh access token
  Future<void> refreshToken() async {
    if (_currentTokens?.refreshToken == null) {
      throw AniListAuthException('No refresh token available');
    }

    try {
      final response = await http.post(
        Uri.parse(AniListConfig.tokenUrl),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'grant_type': 'refresh_token',
          'client_id': AniListConfig.clientId,
          'client_secret': AniListConfig.clientSecret,
          'refresh_token': _currentTokens!.refreshToken,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final tokens = AniListAuthTokens.fromJson(data);
        await _storeTokens(tokens);
      } else {
        throw AniListAuthException(
          'Failed to refresh token: ${response.statusCode} ${response.body}',
        );
      }
    } catch (e) {
      throw AniListAuthException('Token refresh failed: $e');
    }
  }

  // Load user profile
  Future<void> _loadUserProfile() async {
    if (_currentTokens == null) return;

    try {
      final response = await http.post(
        Uri.parse(AniListConfig.baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization':
              '${_currentTokens!.tokenType} ${_currentTokens!.accessToken}',
        },
        body: jsonEncode({
          'query': '''
            query {
              Viewer {
                id
                name
                avatar {
                  large
                }
                bannerImage
                about
                unreadNotificationCount
                statistics {
                  anime {
                    count
                    meanScore
                    standardDeviation
                    minutesWatched
                    episodesWatched
                  }
                  manga {
                    count
                    meanScore
                    standardDeviation
                    chaptersRead
                    volumesRead
                  }
                }
              }
            }
          ''',
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        if (data['data']?['Viewer'] != null) {
          _currentUser = AniListUser.fromJson(data['data']['Viewer']);
        }
      }
    } catch (e) {
      debugPrint('Error loading user profile: $e');
    }
  }

  // Get valid access token (refresh if needed)
  Future<String?> getValidAccessToken() async {
    if (_currentTokens == null) return null;

    if (_currentTokens!.needsRefresh) {
      try {
        await refreshToken();
      } catch (e) {
        debugPrint('Failed to refresh token: $e');
        await logout();
        return null;
      }
    }

    return _currentTokens!.accessToken;
  }

  // Logout
  Future<void> logout() async {
    _linkSubscription?.cancel();
    await _clearStoredTokens();
  }

  // Dispose
  void dispose() {
    _linkSubscription?.cancel();
  }
}

class AniListAuthException implements Exception {
  final String message;

  const AniListAuthException(this.message);

  @override
  String toString() => 'AniListAuthException: $message';
}
