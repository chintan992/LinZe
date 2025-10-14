import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:linze/core/services/first_time_service.dart';
import 'package:linze/features/auth/presentation/screen/login_signup_screen.dart';
import 'package:linze/core/providers/user_preferences_provider.dart';
import 'package:linze/core/services/user_preferences_service.dart';
import 'package:linze/core/providers/anilist_auth_provider.dart';
import 'package:linze/core/providers/anilist_data_providers.dart'
    as anilist_providers;
import 'package:linze/core/providers/user_list_provider.dart';

class ProfileSettingsScreen extends ConsumerStatefulWidget {
  const ProfileSettingsScreen({super.key});

  @override
  ConsumerState<ProfileSettingsScreen> createState() =>
      _ProfileSettingsScreenState();
}

class _ProfileSettingsScreenState extends ConsumerState<ProfileSettingsScreen> {
  void _logout() async {
    // Logout from AniList if connected
    final authService = ref.read(anilistAuthServiceProvider);
    if (authService.isLoggedIn) {
      await authService.logout();
    }

    // Set user as logged out but keep welcome screen as seen
    await FirstTimeService.setLoggedIn(false);

    // Navigate back to login screen (not welcome screen for returning users)
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const LoginSignupScreen()),
      (route) => false,
    );
  }

  void _disconnectAniList() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2C2C2E),
        title: Text(
          'Disconnect AniList',
          style: GoogleFonts.plusJakartaSans(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          'Are you sure you want to disconnect your AniList account? Your watch progress will no longer sync automatically.',
          style: GoogleFonts.plusJakartaSans(
            color: Colors.white70,
            fontSize: 14,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              'Cancel',
              style: GoogleFonts.plusJakartaSans(
                color: const Color(0xFF8E8E93),
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(
              'Disconnect',
              style: GoogleFonts.plusJakartaSans(
                color: Colors.red,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final authService = ref.read(anilistAuthServiceProvider);
      await authService.logout();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'AniList account disconnected',
              style: GoogleFonts.plusJakartaSans(),
            ),
            backgroundColor: const Color(0xFF5B13EC),
          ),
        );
      }
    }
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 8.0,
                ),
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
                child: Consumer(
                  builder: (context, ref, child) {
                    final anilistUserAsync = ref.watch(
                      anilist_providers.anilistCurrentUserProvider,
                    );
                    final userStatsAsync = ref.watch(
                      anilist_providers.userAnimeStatsProvider,
                    );
                    final isLoggedIn = ref.watch(anilistLoginStatusProvider);

                    return Column(
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 96,
                              height: 96,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: const Color(0xFF5B13EC),
                                  width: 2,
                                ),
                              ),
                              child: CircleAvatar(
                                radius: 46,
                                backgroundColor: const Color(0xFF2F2348),
                                backgroundImage:
                                    anilistUserAsync.hasValue &&
                                        anilistUserAsync
                                                .value?['avatar']?['large'] !=
                                            null
                                    ? CachedNetworkImageProvider(
                                        anilistUserAsync
                                            .value!['avatar']['large'],
                                      )
                                    : null,
                                child:
                                    !anilistUserAsync.hasValue ||
                                        anilistUserAsync
                                                .value?['avatar']?['large'] ==
                                            null
                                    ? Icon(
                                        Icons.person,
                                        size: 48,
                                        color: Colors.white.withValues(
                                          alpha: 0.7,
                                        ),
                                      )
                                    : null,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    anilistUserAsync.hasValue
                                        ? (anilistUserAsync.value?['name'] ??
                                              'Guest User')
                                        : 'Guest User',
                                    style: GoogleFonts.plusJakartaSans(
                                      color: Colors.white,
                                      fontSize: 22,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  Text(
                                    isLoggedIn
                                        ? 'AniList Member'
                                        : 'Guest Mode',
                                    style: GoogleFonts.plusJakartaSans(
                                      color: isLoggedIn
                                          ? const Color(0xFF02A9FF)
                                          : const Color(0xFFA7A7A7),
                                      fontSize: 16,
                                    ),
                                  ),
                                  if (isLoggedIn &&
                                      userStatsAsync.hasValue &&
                                      userStatsAsync.value!.totalWatched >
                                          0) ...[
                                    const SizedBox(height: 4),
                                    Text(
                                      '${userStatsAsync.value!.totalWatched} anime • ${userStatsAsync.value!.totalEpisodes} episodes',
                                      style: GoogleFonts.plusJakartaSans(
                                        color: const Color(0xFFA7A7A7),
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            if (isLoggedIn)
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: const Color(
                                    0xFF02A9FF,
                                  ).withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  Icons.check_circle,
                                  color: Color(0xFF02A9FF),
                                  size: 20,
                                ),
                              ),
                          ],
                        ),
                        if (isLoggedIn &&
                            userStatsAsync.hasValue &&
                            userStatsAsync.value!.totalWatched > 0) ...[
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: const Color(0xFF2F2348),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    _buildStatItem(
                                      'Watching',
                                      userStatsAsync.hasValue
                                          ? userStatsAsync.value!.watchingCount
                                                .toString()
                                          : '0',
                                      const Color(0xFF02A9FF),
                                    ),
                                    _buildStatItem(
                                      'Completed',
                                      userStatsAsync.hasValue
                                          ? userStatsAsync.value!.completedCount
                                                .toString()
                                          : '0',
                                      const Color(0xFF00C851),
                                    ),
                                    _buildStatItem(
                                      'Planning',
                                      userStatsAsync.hasValue
                                          ? userStatsAsync.value!.planningCount
                                                .toString()
                                          : '0',
                                      const Color(0xFFFFB300),
                                    ),
                                  ],
                                ),
                                if (userStatsAsync.hasValue &&
                                    userStatsAsync.value!.averageScore > 0) ...[
                                  const SizedBox(height: 12),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.star,
                                        color: const Color(0xFFFFD700),
                                        size: 16,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        'Average Score: ${userStatsAsync.value!.averageScore}/10',
                                        style: GoogleFonts.plusJakartaSans(
                                          color: Colors.white,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ],
                    );
                  },
                ),
              ),
            ),
            // Divider
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: Divider(color: Color(0xFF444444), thickness: 1),
              ),
            ),
            // AniList Account Section
            Consumer(
              builder: (context, ref, child) {
                final isLoggedIn = ref.watch(anilistLoginStatusProvider);
                final syncStatus = ref.watch(syncStatusProvider);

                if (isLoggedIn) {
                  return SliverList(
                    delegate: SliverChildListDelegate([
                      // Section header
                      Padding(
                        padding: const EdgeInsets.only(left: 16.0, top: 16.0),
                        child: Text(
                          'AniList Account',
                          style: GoogleFonts.plusJakartaSans(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      _buildListTile(
                        icon: Icons.sync,
                        title: 'Sync Status',
                        trailingText: syncStatus.isUpToDate
                            ? 'Up to date'
                            : '${syncStatus.queueSize} pending',
                        onTap: () async {
                          if (syncStatus.hasPendingSync) {
                            final messenger = ScaffoldMessenger.of(context);
                            await ref.read(manualSyncProvider.future);
                            if (!mounted) return;
                            messenger.showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Sync completed',
                                  style: GoogleFonts.plusJakartaSans(),
                                ),
                                backgroundColor: const Color(0xFF5B13EC),
                              ),
                            );
                          }
                        },
                      ),
                      _buildListTile(
                        icon: Icons.sync_problem,
                        title: 'Manual Sync',
                        onTap: () async {
                          final messenger = ScaffoldMessenger.of(context);
                          await ref.read(manualSyncProvider.future);
                          if (!mounted) return;
                          messenger.showSnackBar(
                            SnackBar(
                              content: Text(
                                'Manual sync completed',
                                style: GoogleFonts.plusJakartaSans(),
                              ),
                              backgroundColor: const Color(0xFF5B13EC),
                            ),
                          );
                        },
                      ),
                      _buildListTile(
                        icon: Icons.link_off,
                        title: 'Disconnect AniList',
                        onTap: _disconnectAniList,
                      ),
                    ]),
                  );
                } else {
                  return SliverList(
                    delegate: SliverChildListDelegate([
                      // Section header
                      Padding(
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
                      _buildListTile(
                        icon: Icons.login,
                        title: 'Connect AniList',
                        onTap: () {
                          Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(
                              builder: (context) => const LoginSignupScreen(),
                            ),
                            (route) => false,
                          );
                        },
                      ),
                    ]),
                  );
                }
              },
            ),
            // General Account Section
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(left: 16.0, top: 16.0),
                child: Text(
                  'General',
                  style: GoogleFonts.plusJakartaSans(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            // General List Items
            SliverList(
              delegate: SliverChildListDelegate([
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
                  value: ref
                      .watch(userPreferencesProvider)
                      .notificationsEnabled,
                  onChanged: (value) {
                    ref
                        .read(userPreferencesProvider.notifier)
                        .updatePreference('notificationsEnabled', value);
                  },
                ),
                _buildListTile(
                  icon: Icons.high_quality,
                  title: 'Streaming Quality',
                  trailingText: ref
                      .watch(userPreferencesProvider)
                      .streamingQuality,
                  onTap: () => _showQualityDialog(),
                ),
                _buildSwitchListTile(
                  icon: Icons.data_saver_on,
                  title: 'Data Saver',
                  value: ref.watch(userPreferencesProvider).dataSaverMode,
                  onChanged: (value) {
                    ref
                        .read(userPreferencesProvider.notifier)
                        .updatePreference('dataSaverMode', value);
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
                  trailingText: ref
                      .watch(userPreferencesProvider)
                      .preferredAudioType
                      .toUpperCase(),
                  onTap: () => _showAudioTypeDialog(),
                ),
                _buildListTile(
                  icon: Icons.dns,
                  title: 'Default Server',
                  trailingText: ref
                      .watch(userPreferencesProvider)
                      .defaultServer,
                  onTap: () => _showServerDialog(),
                ),
                _buildSwitchListTile(
                  icon: Icons.skip_next,
                  title: 'Auto Skip Intro',
                  value: ref.watch(userPreferencesProvider).autoSkipIntro,
                  onChanged: (value) {
                    ref
                        .read(userPreferencesProvider.notifier)
                        .updateAutoSkipIntro(value);
                  },
                ),
                _buildSwitchListTile(
                  icon: Icons.skip_previous,
                  title: 'Auto Skip Outro',
                  value: ref.watch(userPreferencesProvider).autoSkipOutro,
                  onChanged: (value) {
                    ref
                        .read(userPreferencesProvider.notifier)
                        .updateAutoSkipOutro(value);
                  },
                ),
                _buildListTile(
                  icon: Icons.speed,
                  title: 'Default Playback Speed',
                  trailingText:
                      '${ref.watch(userPreferencesProvider).defaultPlaybackSpeed}x',
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
            const SliverToBoxAdapter(child: SizedBox(height: 40)),
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
        child: Icon(icon, color: Colors.white, size: 20),
      ),
      title: Text(
        title,
        style: GoogleFonts.plusJakartaSans(color: Colors.white, fontSize: 16),
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
                const Icon(Icons.chevron_right, color: Color(0xFF888888)),
              ],
            )
          : const Icon(Icons.chevron_right, color: Color(0xFF888888)),
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
        child: Icon(icon, color: Colors.white, size: 20),
      ),
      title: Text(
        title,
        style: GoogleFonts.plusJakartaSans(color: Colors.white, fontSize: 16),
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
    final currentAudioType = ref
        .read(userPreferencesProvider)
        .preferredAudioType;
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
                    fontWeight: isSelected
                        ? FontWeight.w600
                        : FontWeight.normal,
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
                    color: isSelected
                        ? const Color(0xFF5B13EC)
                        : Colors.transparent,
                  ),
                  child: isSelected
                      ? const Icon(Icons.check, color: Colors.white, size: 16)
                      : null,
                ),
                onTap: () {
                  ref
                      .read(userPreferencesProvider.notifier)
                      .updatePreferredAudioType(audioType);
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
                    fontWeight: isSelected
                        ? FontWeight.w600
                        : FontWeight.normal,
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
                    color: isSelected
                        ? const Color(0xFF5B13EC)
                        : Colors.transparent,
                  ),
                  child: isSelected
                      ? const Icon(Icons.check, color: Colors.white, size: 16)
                      : null,
                ),
                onTap: () {
                  ref
                      .read(userPreferencesProvider.notifier)
                      .updateDefaultServer(server);
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
                    fontWeight: isSelected
                        ? FontWeight.w600
                        : FontWeight.normal,
                  ),
                ),
                subtitle: Text(
                  quality == 'auto'
                      ? 'Automatically adjust based on connection'
                      : 'Fixed quality',
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
                    color: isSelected
                        ? const Color(0xFF5B13EC)
                        : Colors.transparent,
                  ),
                  child: isSelected
                      ? const Icon(Icons.check, color: Colors.white, size: 16)
                      : null,
                ),
                onTap: () {
                  ref
                      .read(userPreferencesProvider.notifier)
                      .updateStreamingQuality(quality);
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
                    fontWeight: isSelected
                        ? FontWeight.w600
                        : FontWeight.normal,
                  ),
                ),
                subtitle: Text(
                  speed == 1.0
                      ? 'Normal speed'
                      : speed < 1.0
                      ? 'Slower'
                      : 'Faster',
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
                    color: isSelected
                        ? const Color(0xFF5B13EC)
                        : Colors.transparent,
                  ),
                  child: isSelected
                      ? const Icon(Icons.check, color: Colors.white, size: 16)
                      : null,
                ),
                onTap: () {
                  ref
                      .read(userPreferencesProvider.notifier)
                      .updateDefaultPlaybackSpeed(speed);
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

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.plusJakartaSans(
            color: color,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            color: Colors.white70,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
