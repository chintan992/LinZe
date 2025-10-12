import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:linze/features/home/presentation/screen/home_screen.dart';
import 'package:linze/features/search_discovery/presentation/screen/search_discovery_screen.dart';
import 'package:linze/features/profile_settings/presentation/screen/profile_settings_screen.dart';
import 'package:linze/features/home/presentation/screen/my_list_screen.dart';
import 'package:linze/features/home/presentation/screen/downloads_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          const HomeScreen(),
          const SearchDiscoveryScreen(),
          const MyListScreen(),
          const DownloadsScreen(),
          const ProfileSettingsScreen(),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1F1F1F),
          border: Border(
            top: BorderSide(
              color: const Color(0xFF2A2A2A),
              width: 1,
            ),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            backgroundColor: const Color(0xFF1F1F1F),
            selectedItemColor: const Color(0xFF5B13EC),
            unselectedItemColor: const Color(0xFFA9A9A9),
            selectedLabelStyle: GoogleFonts.plusJakartaSans(
              fontWeight: FontWeight.w700,
            ),
            unselectedLabelStyle: GoogleFonts.plusJakartaSans(
              fontWeight: FontWeight.w500,
            ),
            currentIndex: _selectedIndex,
            onTap: _onItemTapped,
            items: [
              BottomNavigationBarItem(
                icon: Icon(Icons.home),
                activeIcon: Icon(Icons.home, color: const Color(0xFF5B13EC)),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.explore),
                activeIcon: Icon(Icons.explore, color: const Color(0xFF5B13EC)),
                label: 'Discover',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.video_library),
                activeIcon: Icon(Icons.video_library, color: const Color(0xFF5B13EC)),
                label: 'My List',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.download),
                activeIcon: Icon(Icons.download, color: const Color(0xFF5B13EC)),
                label: 'Downloads',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.account_circle),
                activeIcon: Icon(Icons.account_circle, color: const Color(0xFF5B13EC)),
                label: 'Profile',
              ),
            ],
          ),
        ),
      ),
    );
  }
}