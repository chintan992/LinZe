import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:linze/features/home/presentation/screen/main_screen.dart';
import 'package:linze/features/welcome/welcome_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
  
  runApp(ProviderScope(
    child: AnimeStreamingApp(isLoggedIn: isLoggedIn),
  ));
}

class AnimeStreamingApp extends StatelessWidget {
  final bool isLoggedIn;

  const AnimeStreamingApp({super.key, required this.isLoggedIn});

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
      home: isLoggedIn ? const MainScreen() : const WelcomeScreen(),
    );
  }
}
