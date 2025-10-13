import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:linze/core/services/first_time_service.dart';
import 'package:linze/features/auth/presentation/screen/login_signup_screen.dart';
import 'package:linze/features/home/presentation/screen/main_screen.dart';
import 'package:linze/features/welcome/welcome_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  runApp(const ProviderScope(
    child: AnimeStreamingApp(),
  ));
}

class AnimeStreamingApp extends StatelessWidget {
  const AnimeStreamingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Linze - Anime Streaming App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        primarySwatch: Colors.purple,
        primaryColor: const Color(0xFF5B13EC),
        scaffoldBackgroundColor: const Color(0xFF161022), // background-dark
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF5B13EC),
          brightness: Brightness.dark,
        ),
      ),
      home: const AppInitializer(),
    );
  }
}

class AppInitializer extends StatefulWidget {
  const AppInitializer({super.key});

  @override
  State<AppInitializer> createState() => _AppInitializerState();
}

class _AppInitializerState extends State<AppInitializer> {
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    final isLoggedIn = await FirstTimeService.isLoggedIn();
    final isFirstTime = await FirstTimeService.isFirstTimeUser();

    if (mounted) {
      if (isLoggedIn) {
        // User is logged in, go to main screen
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const MainScreen()),
        );
      } else if (isFirstTime) {
        // First time user, show welcome screen
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const WelcomeScreen()),
        );
      } else {
        // Returning user but not logged in, go to login/signup
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const LoginSignupScreen(),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(
          color: Color(0xFF5B13EC),
        ),
      ),
    );
  }
}
