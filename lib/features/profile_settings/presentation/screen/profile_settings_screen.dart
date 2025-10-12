import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:linze/features/welcome/welcome_screen.dart';

class ProfileSettingsScreen extends StatefulWidget {
  const ProfileSettingsScreen({super.key});

  @override
  State<ProfileSettingsScreen> createState() => _ProfileSettingsScreenState();
}

class _ProfileSettingsScreenState extends State<ProfileSettingsScreen> {
  void _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', false);
    
    // Navigate back to welcome screen
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const WelcomeScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF161022),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // App Bar
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      'Profile & Settings',
                      style: GoogleFonts.plusJakartaSans(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const Spacer(),
                    // Empty space to center the title
                  ],
                ),
              ),
            ),
            // Profile Header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Container(
                      width: 96,
                      height: 96,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        image: DecorationImage(
                          image: CachedNetworkImageProvider(
                            'https://lh3.googleusercontent.com/aida-public/AB6AXuATcP3hJPv-5TbUrys3aOKV6p4vcEfyrv5LkFqPLJqNqM8Tv044un2KjFqhBu2VgWOrYpnYq2hfLNTrj5_Beh5FqpZ9rNOOceeoORQLLtqIMxATFxMo3Po77mhOqVTNeVJEfWihEohm4_Rl98tXVU8h1YaCc7yPau_s9YXTEDt3duK5vS5mC0t3j3xkZtvdAWyDjvFrcNP9gqQCW6J_37nMc-nnUL147XF_hHWKPbLDsncZPpS4RMLBxeKXq-lRcFfWqIoVAg8gygk',
                          ),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'AnimeFan_92',
                          style: GoogleFonts.plusJakartaSans(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          'Premium Member',
                          style: GoogleFonts.plusJakartaSans(
                            color: const Color(0xFFA7A7A7),
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            // Divider
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: Divider(
                  color: Color(0xFF444444),
                  thickness: 1,
                ),
              ),
            ),
            // Account Section
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(left: 16.0, top: 16.0),
                child: Text(
                  'Account',
                  style: GoogleFonts.plusJakartaSans(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            // Account List Items
            SliverList(
              delegate: SliverChildListDelegate([
                _buildListTile(
                  icon: Icons.person,
                  title: 'Edit Profile',
                  onTap: () {},
                ),
                _buildListTile(
                  icon: Icons.history,
                  title: 'Watch History',
                  onTap: () {},
                ),
                _buildListTile(
                  icon: Icons.subscriptions,
                  title: 'Subscription',
                  onTap: () {},
                ),
              ]),
            ),
            // App Settings Section
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(left: 16.0, top: 32.0),
                child: Text(
                  'App Settings',
                  style: GoogleFonts.plusJakartaSans(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            // App Settings List Items
            SliverList(
              delegate: SliverChildListDelegate([
                _buildSwitchListTile(
                  icon: Icons.notifications,
                  title: 'Notifications',
                  value: true,
                  onChanged: (value) {
                    setState(() {});
                  },
                ),
                _buildListTile(
                  icon: Icons.high_quality,
                  title: 'Streaming Quality',
                  trailingText: 'Auto',
                  onTap: () {},
                ),
                _buildSwitchListTile(
                  icon: Icons.data_saver_on,
                  title: 'Data Saver',
                  value: false,
                  onChanged: (value) {
                    setState(() {});
                  },
                ),
              ]),
            ),
            // Support Section
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(left: 16.0, top: 32.0),
                child: Text(
                  'Support',
                  style: GoogleFonts.plusJakartaSans(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            // Support List Items
            SliverList(
              delegate: SliverChildListDelegate([
                _buildListTile(
                  icon: Icons.help,
                  title: 'Help Center',
                  onTap: () {},
                ),
                _buildListTile(
                  icon: Icons.privacy_tip,
                  title: 'Privacy Policy',
                  onTap: () {},
                ),
              ]),
            ),
            // Log Out Button
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: SizedBox(
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _logout,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF5B13EC),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                    ),
                    child: Text(
                      'Log Out',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            // Bottom padding
            const SliverToBoxAdapter(
              child: SizedBox(height: 40),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    String? trailingText,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: const Color(0xFF2F2F2F),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: Colors.white,
          size: 20,
        ),
      ),
      title: Text(
        title,
        style: GoogleFonts.plusJakartaSans(
          color: Colors.white,
          fontSize: 16,
        ),
      ),
      trailing: trailingText != null
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  trailingText,
                  style: GoogleFonts.plusJakartaSans(
                    color: const Color(0xFF888888),
                    fontSize: 16,
                  ),
                ),
                const Icon(
                  Icons.chevron_right,
                  color: Color(0xFF888888),
                ),
              ],
            )
          : const Icon(
              Icons.chevron_right,
              color: Color(0xFF888888),
            ),
      onTap: onTap,
    );
  }

  Widget _buildSwitchListTile({
    required IconData icon,
    required String title,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: const Color(0xFF2F2F2F),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: Colors.white,
          size: 20,
        ),
      ),
      title: Text(
        title,
        style: GoogleFonts.plusJakartaSans(
          color: Colors.white,
          fontSize: 16,
        ),
      ),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeThumbColor: const Color(0xFF5B13EC),
        activeTrackColor: const Color(0xFF5B13EC).withValues(alpha: 0.5),
        inactiveThumbColor: const Color(0xFF888888),
        inactiveTrackColor: const Color(0xFF444444),
      ),
      onTap: () {
        onChanged(!value);
      },
    );
  }
}