import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:linze/core/services/first_time_service.dart';
import 'package:linze/core/providers/anilist_auth_provider.dart';
import 'package:linze/core/api/anilist_api_service.dart';
import 'package:linze/features/home/presentation/screen/main_screen.dart';

class LoginSignupScreen extends ConsumerStatefulWidget {
  const LoginSignupScreen({super.key});

  @override
  ConsumerState<LoginSignupScreen> createState() => _LoginSignupScreenState();
}

class _LoginSignupScreenState extends ConsumerState<LoginSignupScreen>
    with TickerProviderStateMixin {
  bool isLogin = true;
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _usernameController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _passwordVisible = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _usernameController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _toggleForm() {
    setState(() {
      isLogin = !isLogin;
    });
  }

  void _login() async {
    if (_formKey.currentState!.validate()) {
      await FirstTimeService.setLoggedIn(true);
      
      // Navigate to main screen
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const MainScreen(),
        ),
      );
    }
  }

  void _loginWithAniList() async {
    try {
      final authService = ref.read(anilistAuthServiceProvider);
      await authService.startOAuthFlow();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('AniList login failed: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
        debugPrint('AniList login error: $e');
      }
    }
  }

  void _testAniListMetadata() async {
    try {
      final authService = ref.read(anilistAuthServiceProvider);
      
      if (!authService.isLoggedIn) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please login to AniList first'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      // Show loading
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Testing AniList metadata fetch...'),
          backgroundColor: Colors.blue,
        ),
      );

      // Test fetching anime metadata
      final apiService = AniListApiService(accessToken: authService.currentTokens?.accessToken);
      
      // Test 1: Search for a popular anime
      debugPrint('Testing AniList search...');
      final searchResults = await apiService.searchMedia('Attack on Titan', perPage: 5);
      debugPrint('Search results: ${searchResults.length} anime found');
      
      if (searchResults.isNotEmpty) {
        final firstAnime = searchResults.first;
        debugPrint('First result: ${firstAnime.title?.english ?? firstAnime.title?.romaji}');
        debugPrint('Anime ID: ${firstAnime.id}');
        debugPrint('Episodes: ${firstAnime.episodes}');
        debugPrint('Status: ${firstAnime.status}');
        debugPrint('Genres: ${firstAnime.genres}');
        
        // Test 2: Get detailed info for the first anime
        debugPrint('Testing detailed anime fetch...');
        final detailedAnime = await apiService.getMedia(firstAnime.id, authService.currentTokens?.accessToken);
        debugPrint('Detailed anime: ${detailedAnime.title?.english ?? detailedAnime.title?.romaji}');
        debugPrint('Description: ${detailedAnime.description?.substring(0, 100)}...');
        
        // Test 3: Get trending anime
        debugPrint('Testing trending anime fetch...');
        final trendingAnime = await apiService.getTrendingMedia(perPage: 3);
        debugPrint('Trending anime: ${trendingAnime.length} found');
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('✅ AniList metadata test successful!\nFound ${searchResults.length} anime, ${trendingAnime.length} trending'),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 5),
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('❌ No anime found in search results'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
      
    } catch (e) {
      debugPrint('AniList metadata test error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ AniList metadata test failed: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  @override
  void initState() {
    super.initState();
    
    // Listen for AniList authentication success
    ref.listenManual(anilistLoginStatusProvider, (previous, next) {
      if (next && mounted) {
        // AniList login successful, navigate to main screen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const MainScreen(),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF221A38),
              Color(0xFF161022),
            ],
          ),
        ),
        child: Stack(
          children: [
            // Background image with blur
            Container(
              decoration: BoxDecoration(
                image: const DecorationImage(
                  image: NetworkImage(
                    'https://lh3.googleusercontent.com/aida-public/AB6AXuC4Bf8UC57jLzHh3Ag6uKHMLn7irDtj8g0smZj4piJH8P_-l0kcUf3hVdLsEg5ARN2MP3D9iL6hUrXE44oylSGBodWxGeOAzEP5qrNOrXQ0sE7E9xtsRzDqEbHWhyNkLB8Vf-HRg5-VzutcM7VlH0rEevo4NJ2VFWoR1hOunesTsViVG7aBBIUDeJDzJHjqizRFvisn5ylgBjd5lJUbifMIDJfO7jsPdyBmOVZTfvEvd3iiyigDR3lGaieW5SCm5LrKQ944V64AYt0',
                  ),
                  fit: BoxFit.cover,
                ),
                color: Color(0x99161022), // 60% opacity overlay
              ),
            ),
            // Dark overlay
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    const Color(0x80161022),
                    const Color(0x80161022),
                  ],
                ),
              ),
            ),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    // Logo at top
                    Align(
                      alignment: Alignment.center,
                      child: Container(
                        width: 96,
                        height: 96,
                        decoration: BoxDecoration(
                          color: const Color(0xFF5B13EC).withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(
                          Icons.account_circle,
                          size: 64,
                          color: const Color(0xFF5B13EC),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Tabs for Login/Signup
                    Container(
                      height: 48,
                      decoration: BoxDecoration(
                        color: const Color(0xFF2F2348),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () => setState(() => isLogin = true),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: isLogin ? const Color(0xFF5B13EC) : Colors.transparent,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Center(
                                  child: Text(
                                    'Login',
                                    style: GoogleFonts.plusJakartaSans(
                                      color: isLogin ? Colors.white : const Color(0xFFA492C9),
                                      fontSize: 16,
                                      fontWeight: isLogin ? FontWeight.w700 : FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTap: () => setState(() => isLogin = false),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: !isLogin ? const Color(0xFF5B13EC) : Colors.transparent,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Center(
                                  child: Text(
                                    'Sign Up',
                                    style: GoogleFonts.plusJakartaSans(
                                      color: !isLogin ? Colors.white : const Color(0xFFA492C9),
                                      fontSize: 16,
                                      fontWeight: !isLogin ? FontWeight.w700 : FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Form
                    Expanded(
                      child: Form(
                        key: _formKey,
                        child: SingleChildScrollView(
                          child: Column(
                            children: [
                              // Login Form
                              if (isLogin) ...[
                                _buildTextField(
                                  controller: _emailController,
                                  labelText: 'Email/Username',
                                  hintText: 'Enter your email or username',
                                ),
                                const SizedBox(height: 16),
                                _buildPasswordField(
                                  controller: _passwordController,
                                  labelText: 'Password',
                                  hintText: 'Enter your password',
                                ),
                                const SizedBox(height: 8),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: TextButton(
                                    onPressed: () {},
                                    child: Text(
                                      'Forgot Password?',
                                      style: GoogleFonts.plusJakartaSans(
                                        color: const Color(0xFF5B13EC),
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                SizedBox(
                                  width: double.infinity,
                                  height: 48,
                                  child: ElevatedButton(
                                    onPressed: _login,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF5B13EC),
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    child: Text(
                                      'Login',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                              // Sign Up Form
                              if (!isLogin) ...[
                                _buildTextField(
                                  controller: _emailController,
                                  labelText: 'Email',
                                  hintText: 'Enter your email',
                                  keyboardType: TextInputType.emailAddress,
                                ),
                                const SizedBox(height: 16),
                                _buildTextField(
                                  controller: _usernameController,
                                  labelText: 'Username',
                                  hintText: 'Choose a username',
                                ),
                                const SizedBox(height: 16),
                                _buildPasswordField(
                                  controller: _passwordController,
                                  labelText: 'Password',
                                  hintText: 'Create a password',
                                ),
                                const SizedBox(height: 16),
                                _buildPasswordField(
                                  controller: _confirmPasswordController,
                                  labelText: 'Confirm Password',
                                  hintText: 'Confirm your password',
                                  isConfirmPassword: true,
                                ),
                                const SizedBox(height: 16),
                                SizedBox(
                                  width: double.infinity,
                                  height: 48,
                                  child: ElevatedButton(
                                    onPressed: _login,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF5B13EC),
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    child: Text(
                                      'Sign Up',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                              const SizedBox(height: 24),
                              Row(
                                children: [
                                  Expanded(
                                    child: Container(
                                      height: 1,
                                      color: const Color(0xFF2F2348),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                                    child: Text(
                                      'Or continue with',
                                      style: GoogleFonts.plusJakartaSans(
                                        color: const Color(0xFFA492C9),
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Container(
                                      height: 1,
                                      color: const Color(0xFF2F2348),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 24),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Column(
                                    children: [
                                      SizedBox(
                                        width: 56,
                                        height: 56,
                                        child: ElevatedButton(
                                          onPressed: _loginWithAniList,
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: const Color(0xFF2F2348),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(28),
                                            ),
                                          ),
                                          child: Container(
                                            width: 24,
                                            height: 24,
                                            decoration: const BoxDecoration(
                                              color: Color(0xFF02A9FF),
                                              borderRadius: BorderRadius.all(Radius.circular(4)),
                                            ),
                                            child: const Center(
                                              child: Text(
                                                'A',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 14,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'AniList',
                                        style: GoogleFonts.plusJakartaSans(
                                          color: const Color(0xFFA492C9),
                                          fontSize: 10,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(width: 32),
                                  Column(
                                    children: [
                                      SizedBox(
                                        width: 56,
                                        height: 56,
                                        child: ElevatedButton(
                                          onPressed: _login,
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: const Color(0xFF2F2348),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(28),
                                            ),
                                          ),
                                          child: const Icon(
                                            Icons.person_outline,
                                            color: Colors.white,
                                            size: 24,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Guest',
                                        style: GoogleFonts.plusJakartaSans(
                                          color: const Color(0xFFA492C9),
                                          fontSize: 10,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              // Test AniList Metadata Button
                              SizedBox(
                                width: double.infinity,
                                height: 40,
                                child: ElevatedButton(
                                  onPressed: _testAniListMetadata,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF02A9FF),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  child: Text(
                                    '🧪 Test AniList Metadata',
                                    style: GoogleFonts.plusJakartaSans(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 24),
                              Text(
                                isLogin
                                    ? 'Don\'t have an account? '
                                    : 'Already have an account? ',
                                style: GoogleFonts.plusJakartaSans(
                                  color: const Color(0xFFA492C9),
                                  fontSize: 14,
                                ),
                              ),
                              TextButton(
                                onPressed: _toggleForm,
                                child: Text(
                                  isLogin ? 'Sign Up' : 'Login',
                                  style: GoogleFonts.plusJakartaSans(
                                    color: const Color(0xFF5B13EC),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    required String hintText,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          labelText,
          style: GoogleFonts.plusJakartaSans(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 56,
          decoration: BoxDecoration(
            color: const Color(0xFF2F2348),
            borderRadius: BorderRadius.circular(8),
          ),
          child: TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            style: GoogleFonts.plusJakartaSans(
              color: Colors.white,
              fontSize: 16,
            ),
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: GoogleFonts.plusJakartaSans(
                color: const Color(0xFFA492C9),
                fontSize: 16,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter $labelText';
              }
              return null;
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String labelText,
    required String hintText,
    bool isConfirmPassword = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          labelText,
          style: GoogleFonts.plusJakartaSans(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 56,
          decoration: BoxDecoration(
            color: const Color(0xFF2F2348),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: controller,
                  obscureText: !_passwordVisible,
                  style: GoogleFonts.plusJakartaSans(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                  decoration: InputDecoration(
                    hintText: hintText,
                    hintStyle: GoogleFonts.plusJakartaSans(
                      color: const Color(0xFFA492C9),
                      fontSize: 16,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _passwordVisible
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: const Color(0xFFA492C9),
                      ),
                      onPressed: () {
                        setState(() {
                          _passwordVisible = !_passwordVisible;
                        });
                      },
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter $labelText';
                    }
                    if (value.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    if (isConfirmPassword && value != _passwordController.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}