import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:linze/features/welcome/welcome_screen.dart';
import 'package:linze/core/providers/user_preferences_provider.dart';
import 'package:linze/core/services/user_preferences_service.dart';

class ProfileSettingsScreen extends ConsumerStatefulWidget {
  const ProfileSettingsScreen({super.key});

  @override
  ConsumerState<ProfileSettingsScreen> createState() => _ProfileSettingsScreenState();
}

class _ProfileSettingsScreenState extends ConsumerState<ProfileSettingsScreen> {
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
                  value: ref.watch(userPreferencesProvider).notificationsEnabled,
                  onChanged: (value) {
                    ref.read(userPreferencesProvider.notifier).updateNotificationsEnabled(value);
                  },
                ),
                _buildListTile(
                  icon: Icons.high_quality,
                  title: 'Streaming Quality',
                  trailingText: ref.watch(userPreferencesProvider).streamingQuality,
                  onTap: () => _showQualityDialog(),
                ),
                _buildSwitchListTile(
                  icon: Icons.data_saver_on,
                  title: 'Data Saver',
                  value: ref.watch(userPreferencesProvider).dataSaverMode,
                  onChanged: (value) {
                    ref.read(userPreferencesProvider.notifier).updateDataSaverMode(value);
                  },
                ),
              ]),
            ),
            // Video Player Settings Section
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(left: 16.0, top: 32.0),
                child: Text(
                  'Video Player Settings',
                  style: GoogleFonts.plusJakartaSans(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            // Video Player Settings List Items
            SliverList(
              delegate: SliverChildListDelegate([
                _buildListTile(
                  icon: Icons.audiotrack,
                  title: 'Preferred Audio',
                  trailingText: ref.watch(userPreferencesProvider).preferredAudioType.toUpperCase(),
                  onTap: () => _showAudioTypeDialog(),
                ),
                _buildListTile(
                  icon: Icons.dns,
                  title: 'Default Server',
                  trailingText: ref.watch(userPreferencesProvider).defaultServer,
                  onTap: () => _showServerDialog(),
                ),
                _buildSwitchListTile(
                  icon: Icons.skip_next,
                  title: 'Auto Skip Intro',
                  value: ref.watch(userPreferencesProvider).autoSkipIntro,
                  onChanged: (value) {
                    ref.read(userPreferencesProvider.notifier).updateAutoSkipIntro(value);
                  },
                ),
                _buildSwitchListTile(
                  icon: Icons.skip_previous,
                  title: 'Auto Skip Outro',
                  value: ref.watch(userPreferencesProvider).autoSkipOutro,
                  onChanged: (value) {
                    ref.read(userPreferencesProvider.notifier).updateAutoSkipOutro(value);
                  },
                ),
                _buildListTile(
                  icon: Icons.speed,
                  title: 'Default Playback Speed',
                  trailingText: '${ref.watch(userPreferencesProvider).defaultPlaybackSpeed}x',
                  onTap: () => _showPlaybackSpeedDialog(),
                ),
                _buildListTile(
                  icon: Icons.restore,
                  title: 'Reset Video Settings',
                  onTap: () => _showResetDialog(),
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

  void _showAudioTypeDialog() {
    final currentAudioType = ref.read(userPreferencesProvider).preferredAudioType;
    final audioTypes = UserPreferencesService.getAudioTypes();
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF2C2C2E),
          title: Text(
            'Select Preferred Audio',
            style: GoogleFonts.plusJakartaSans(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: audioTypes.map((audioType) {
              final isSelected = audioType == currentAudioType;
              return ListTile(
                title: Text(
                  audioType.toUpperCase(),
                  style: GoogleFonts.plusJakartaSans(
                    color: Colors.white,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
                subtitle: Text(
                  audioType == 'sub' ? 'Subtitled' : 'Dubbed',
                  style: GoogleFonts.plusJakartaSans(color: Colors.grey),
                ),
                leading: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected ? const Color(0xFF5B13EC) : Colors.grey,
                      width: 2,
                    ),
                    color: isSelected ? const Color(0xFF5B13EC) : Colors.transparent,
                  ),
                  child: isSelected
                      ? const Icon(
                          Icons.check,
                          color: Colors.white,
                          size: 16,
                        )
                      : null,
                ),
                onTap: () {
                  ref.read(userPreferencesProvider.notifier).updatePreferredAudioType(audioType);
                  Navigator.of(context).pop();
                },
              );
            }).toList(),
          ),
        );
      },
    );
  }

  void _showServerDialog() {
    final currentServer = ref.read(userPreferencesProvider).defaultServer;
    final servers = UserPreferencesService.getAvailableServers();
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF2C2C2E),
          title: Text(
            'Select Default Server',
            style: GoogleFonts.plusJakartaSans(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: servers.map((server) {
              final isSelected = server == currentServer;
              return ListTile(
                title: Text(
                  server,
                  style: GoogleFonts.plusJakartaSans(
                    color: Colors.white,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
                subtitle: Text(
                  _getServerDescription(server),
                  style: GoogleFonts.plusJakartaSans(color: Colors.grey),
                ),
                leading: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected ? const Color(0xFF5B13EC) : Colors.grey,
                      width: 2,
                    ),
                    color: isSelected ? const Color(0xFF5B13EC) : Colors.transparent,
                  ),
                  child: isSelected
                      ? const Icon(
                          Icons.check,
                          color: Colors.white,
                          size: 16,
                        )
                      : null,
                ),
                onTap: () {
                  ref.read(userPreferencesProvider.notifier).updateDefaultServer(server);
                  Navigator.of(context).pop();
                },
              );
            }).toList(),
          ),
        );
      },
    );
  }

  void _showQualityDialog() {
    final currentQuality = ref.read(userPreferencesProvider).streamingQuality;
    final qualities = UserPreferencesService.getStreamingQualities();
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF2C2C2E),
          title: Text(
            'Select Streaming Quality',
            style: GoogleFonts.plusJakartaSans(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: qualities.map((quality) {
              final isSelected = quality == currentQuality;
              return ListTile(
                title: Text(
                  quality.toUpperCase(),
                  style: GoogleFonts.plusJakartaSans(
                    color: Colors.white,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
                subtitle: Text(
                  quality == 'auto' ? 'Automatically adjust based on connection' : 'Fixed quality',
                  style: GoogleFonts.plusJakartaSans(color: Colors.grey),
                ),
                leading: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected ? const Color(0xFF5B13EC) : Colors.grey,
                      width: 2,
                    ),
                    color: isSelected ? const Color(0xFF5B13EC) : Colors.transparent,
                  ),
                  child: isSelected
                      ? const Icon(
                          Icons.check,
                          color: Colors.white,
                          size: 16,
                        )
                      : null,
                ),
                onTap: () {
                  ref.read(userPreferencesProvider.notifier).updateStreamingQuality(quality);
                  Navigator.of(context).pop();
                },
              );
            }).toList(),
          ),
        );
      },
    );
  }

  void _showPlaybackSpeedDialog() {
    final currentSpeed = ref.read(userPreferencesProvider).defaultPlaybackSpeed;
    final speeds = UserPreferencesService.getPlaybackSpeeds();
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF2C2C2E),
          title: Text(
            'Select Default Playback Speed',
            style: GoogleFonts.plusJakartaSans(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: speeds.map((speed) {
              final isSelected = speed == currentSpeed;
              return ListTile(
                title: Text(
                  '${speed}x',
                  style: GoogleFonts.plusJakartaSans(
                    color: Colors.white,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
                subtitle: Text(
                  speed == 1.0 ? 'Normal speed' : speed < 1.0 ? 'Slower' : 'Faster',
                  style: GoogleFonts.plusJakartaSans(color: Colors.grey),
                ),
                leading: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected ? const Color(0xFF5B13EC) : Colors.grey,
                      width: 2,
                    ),
                    color: isSelected ? const Color(0xFF5B13EC) : Colors.transparent,
                  ),
                  child: isSelected
                      ? const Icon(
                          Icons.check,
                          color: Colors.white,
                          size: 16,
                        )
                      : null,
                ),
                onTap: () {
                  ref.read(userPreferencesProvider.notifier).updateDefaultPlaybackSpeed(speed);
                  Navigator.of(context).pop();
                },
              );
            }).toList(),
          ),
        );
      },
    );
  }

  void _showResetDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF2C2C2E),
          title: Text(
            'Reset Video Settings',
            style: GoogleFonts.plusJakartaSans(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          content: Text(
            'Are you sure you want to reset all video player settings to their default values?',
            style: GoogleFonts.plusJakartaSans(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: GoogleFonts.plusJakartaSans(
                  color: const Color(0xFF8E8E93),
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                ref.read(userPreferencesProvider.notifier).resetToDefault();
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Video settings reset to default',
                      style: GoogleFonts.plusJakartaSans(),
                    ),
                    backgroundColor: const Color(0xFF5B13EC),
                  ),
                );
              },
              child: Text(
                'Reset',
                style: GoogleFonts.plusJakartaSans(
                  color: Colors.red,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  String _getServerDescription(String server) {
    switch (server) {
      case 'HD-1':
        return 'High quality server (recommended)';
      case 'HD-2':
        return 'Alternative high quality server';
      case 'HD-3':
        return 'Backup high quality server';
      case 'Multi Quality':
        return 'Multiple quality options available';
      default:
        return 'Standard server';
    }
  }
}