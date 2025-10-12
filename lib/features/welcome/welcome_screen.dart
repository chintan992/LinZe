import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:linze/features/auth/presentation/screen/login_signup_screen.dart';
import 'package:linze/features/home/presentation/screen/main_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({Key? key}) : super(key: key);

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
            Container(
              decoration: BoxDecoration(
                image: const DecorationImage(
                  image: NetworkImage(
                    'https://lh3.googleusercontent.com/aida-public/AB6AXuCjNoZITN0gaEQrPhMu5VjvgB_7a3E3Qak-Nkoc4mCJt8fsgqMccV8JcXBnwdPKXvVptSiCdi9pWyOPAzklkLy0Xg6XCLORixYkBtB2AWU_px-KspesVFbdAe9jerPpUqqwLk0uojfE5UMUM35wHo4dACmVEvKLyaxS0oUOoHDhMlOjOtuJxZrSQ6dayscU_aPjV0CTopPc5DHwE8CzilCUihF7eSjip0AhKrH9iMtFvo0KEqTFYWiKEbSKwC85mIXBKHQKJmqrcJ4',
                  ),
                  fit: BoxFit.cover,
                ),
                color: Color(0x99161022), // 60% opacity overlay
              ),
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, const Color(0xFF161022)],
                ),
              ),
            ),
            SafeArea(
              child: Column(
                children: [
                  const Spacer(flex: 2),
                  // Logo and title section
                  Column(
                    children: [
                      Icon(
                        Icons.live_tv_rounded,
                        size: 64,
                        color: const Color(0xFF5B13EC),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Your Gateway to Infinite Anime',
                        style: GoogleFonts.plusJakartaSans(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          height: 1.2,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Dive into the World of Anime.',
                        style: GoogleFonts.plusJakartaSans(
                          color: Colors.white70,
                          fontSize: 14,
                          fontWeight: FontWeight.normal,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                  const Spacer(flex: 2),
                  // Buttons section
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32.0),
                    child: Column(
                      children: [
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton(
                            onPressed: () {
                              // Navigate to sign up
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const LoginSignupScreen(),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF5B13EC),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                            ),
                            child: Text(
                              'Sign Up',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.015,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: OutlinedButton(
                            onPressed: () {
                              // Navigate to login
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const LoginSignupScreen(),
                                ),
                              );
                            },
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(
                                color: Color(0xFF5B13EC),
                                width: 1,
                              ),
                              backgroundColor: const Color(0xFF5B13EC).withOpacity(0.3),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                            ),
                            child: Text(
                              'Login',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.015,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                height: 1,
                                color: Colors.white24,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16.0),
                              child: Text(
                                'or',
                                style: GoogleFonts.plusJakartaSans(
                                  color: Colors.white60,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Container(
                                height: 1,
                                color: Colors.white24,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: SizedBox(
                                height: 48,
                                child: ElevatedButton(
                                  onPressed: () {},
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF2F2348),
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8.0),
                                    ),
                                    padding: const EdgeInsets.symmetric(horizontal: 16),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Image.network(
                                        'https://www.google.com/favicon.ico',
                                        width: 24,
                                        height: 24,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Google',
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w700,
                                          letterSpacing: 0.015,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: SizedBox(
                                height: 48,
                                child: ElevatedButton(
                                  onPressed: () {},
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF2F2348),
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8.0),
                                    ),
                                    padding: const EdgeInsets.symmetric(horizontal: 16),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.code,
                                        size: 24,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'GitHub',
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w700,
                                          letterSpacing: 0.015,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        TextButton(
                          onPressed: () {
                            // Navigate to home screen directly
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const MainScreen(),
                              ),
                            );
                          },
                          child: Text(
                            'Skip for now',
                            style: GoogleFonts.plusJakartaSans(
                              color: Colors.white60,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(flex: 1),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
