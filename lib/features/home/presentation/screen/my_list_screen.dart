import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MyListScreen extends StatelessWidget {
  const MyListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.video_library,
                color: const Color(0xFF5B13EC),
                size: 64,
              ),
              const SizedBox(height: 24),
              Text(
                'My List',
                style: GoogleFonts.plusJakartaSans(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Your saved anime will appear here',
                style: GoogleFonts.plusJakartaSans(
                  color: const Color(0xFFA9A9A9),
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}