import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:linze/core/models/streaming_models.dart';

/// Advanced settings panel for video player
class VideoPlayerSettingsPanel extends StatefulWidget {
  final double playbackSpeed;
  final bool autoSkipIntro;
  final bool autoSkipOutro;
  final List<Track>? availableSubtitles;
  final Track? selectedSubtitle;
  final List<Server>? availableServers;
  final Server? selectedServer;
  final String selectedType;
  final Function(double) onPlaybackSpeedChanged;
  final Function(bool) onAutoSkipIntroChanged;
  final Function(bool) onAutoSkipOutroChanged;
  final Function(Track?) onSubtitleChanged;
  final Function(Server, String)? onServerChanged;

  const VideoPlayerSettingsPanel({
    super.key,
    required this.playbackSpeed,
    required this.autoSkipIntro,
    required this.autoSkipOutro,
    this.availableSubtitles,
    this.selectedSubtitle,
    this.availableServers,
    this.selectedServer,
    required this.selectedType,
    required this.onPlaybackSpeedChanged,
    required this.onAutoSkipIntroChanged,
    required this.onAutoSkipOutroChanged,
    required this.onSubtitleChanged,
    this.onServerChanged,
  });

  @override
  State<VideoPlayerSettingsPanel> createState() =>
      _VideoPlayerSettingsPanelState();
}

class _VideoPlayerSettingsPanelState extends State<VideoPlayerSettingsPanel> {
  late double _tempPlaybackSpeed;
  late bool _tempAutoSkipIntro;
  late bool _tempAutoSkipOutro;
  late Track? _tempSelectedSubtitle;
  late Server? _tempSelectedServer;
  late String _tempSelectedType;

  @override
  void initState() {
    super.initState();
    _tempPlaybackSpeed = widget.playbackSpeed;
    _tempAutoSkipIntro = widget.autoSkipIntro;
    _tempAutoSkipOutro = widget.autoSkipOutro;
    _tempSelectedSubtitle = widget.selectedSubtitle;
    _tempSelectedServer = widget.selectedServer;
    _tempSelectedType = widget.selectedType;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF2C2C2E),
      title: Text(
        'Advanced Settings',
        style: GoogleFonts.plusJakartaSans(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      content: SizedBox(
        width: double.maxFinite,
        height: 400,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Playback Speed
              _buildSectionTitle('Playback Speed'),
              const SizedBox(height: 8),
              _buildPlaybackSpeedSelector(),

              const SizedBox(height: 16),

              // Auto-skip settings
              _buildSectionTitle('Auto-Skip Settings'),
              const SizedBox(height: 8),
              _buildAutoSkipSettings(),

              // Subtitle selection
              if (widget.availableSubtitles?.isNotEmpty == true) ...[
                const SizedBox(height: 16),
                _buildSectionTitle('Subtitles'),
                const SizedBox(height: 8),
                _buildSubtitleSelector(),
              ],

              // Server selection
              if (widget.availableServers?.isNotEmpty == true) ...[
                const SizedBox(height: 16),
                _buildSectionTitle('Server & Quality'),
                const SizedBox(height: 8),
                _buildServerSelector(),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(
            'Cancel',
            style: GoogleFonts.plusJakartaSans(color: const Color(0xFF8E8E93)),
          ),
        ),
        TextButton(
          onPressed: _applyChanges,
          child: Text(
            'Apply',
            style: GoogleFonts.plusJakartaSans(
              color: const Color(0xFF5B13EC),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.plusJakartaSans(
        color: Colors.white,
        fontSize: 16,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget _buildPlaybackSpeedSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF3A3A3C),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButton<double>(
        value: _tempPlaybackSpeed,
        dropdownColor: const Color(0xFF3A3A3C),
        style: GoogleFonts.plusJakartaSans(color: Colors.white),
        underline: const SizedBox.shrink(),
        isExpanded: true,
        items: const [
          DropdownMenuItem(value: 0.25, child: Text('0.25x')),
          DropdownMenuItem(value: 0.5, child: Text('0.5x')),
          DropdownMenuItem(value: 0.75, child: Text('0.75x')),
          DropdownMenuItem(value: 1.0, child: Text('1x (Normal)')),
          DropdownMenuItem(value: 1.25, child: Text('1.25x')),
          DropdownMenuItem(value: 1.5, child: Text('1.5x')),
          DropdownMenuItem(value: 1.75, child: Text('1.75x')),
          DropdownMenuItem(value: 2.0, child: Text('2x')),
        ],
        onChanged: (value) {
          if (value != null) {
            setState(() {
              _tempPlaybackSpeed = value;
            });
          }
        },
      ),
    );
  }

  Widget _buildAutoSkipSettings() {
    return Column(
      children: [
        SwitchListTile(
          title: Text(
            'Skip Intro',
            style: GoogleFonts.plusJakartaSans(color: Colors.white),
          ),
          subtitle: Text(
            'Automatically skip opening sequences',
            style: GoogleFonts.plusJakartaSans(
              color: Colors.white70,
              fontSize: 12,
            ),
          ),
          value: _tempAutoSkipIntro,
          onChanged: (value) {
            setState(() {
              _tempAutoSkipIntro = value;
            });
          },
          activeThumbColor: const Color(0xFF5B13EC),
        ),
        SwitchListTile(
          title: Text(
            'Skip Outro',
            style: GoogleFonts.plusJakartaSans(color: Colors.white),
          ),
          subtitle: Text(
            'Automatically skip ending sequences',
            style: GoogleFonts.plusJakartaSans(
              color: Colors.white70,
              fontSize: 12,
            ),
          ),
          value: _tempAutoSkipOutro,
          onChanged: (value) {
            setState(() {
              _tempAutoSkipOutro = value;
            });
          },
          activeThumbColor: const Color(0xFF5B13EC),
        ),
      ],
    );
  }

  Widget _buildSubtitleSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF3A3A3C),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButton<Track>(
        value: _tempSelectedSubtitle,
        dropdownColor: const Color(0xFF3A3A3C),
        style: GoogleFonts.plusJakartaSans(color: Colors.white),
        underline: const SizedBox.shrink(),
        isExpanded: true,
        hint: Text(
          'Select Subtitle',
          style: GoogleFonts.plusJakartaSans(color: Colors.white70),
        ),
        items: [
          const DropdownMenuItem<Track>(
            value: null,
            child: Text('No subtitles'),
          ),
          ...?widget.availableSubtitles?.map((track) {
            return DropdownMenuItem<Track>(
              value: track,
              child: Text(track.label ?? 'Unknown'),
            );
          }),
        ],
        onChanged: (value) {
          setState(() {
            _tempSelectedSubtitle = value;
          });
        },
      ),
    );
  }

  Widget _buildServerSelector() {
    return Column(
      children: [
        // Audio Type Selection
        Row(
          children: [
            Expanded(child: _buildAudioTypeButton('sub', 'Subtitled')),
            const SizedBox(width: 8),
            Expanded(child: _buildAudioTypeButton('dub', 'Dubbed')),
          ],
        ),
        const SizedBox(height: 12),
        // Server Selection
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFF3A3A3C),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButton<Server>(
            value: _tempSelectedServer,
            dropdownColor: const Color(0xFF3A3A3C),
            style: GoogleFonts.plusJakartaSans(color: Colors.white),
            underline: const SizedBox.shrink(),
            isExpanded: true,
            hint: Text(
              'Select Server',
              style: GoogleFonts.plusJakartaSans(color: Colors.white70),
            ),
            items: widget.availableServers
                ?.where((server) => server.type == _tempSelectedType)
                .map((server) {
                  return DropdownMenuItem<Server>(
                    value: server,
                    child: Text(server.serverName ?? 'Unknown Server'),
                  );
                })
                .toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  _tempSelectedServer = value;
                });
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildAudioTypeButton(String type, String label) {
    final isSelected = _tempSelectedType == type;
    return GestureDetector(
      onTap: () {
        setState(() {
          _tempSelectedType = type;
          // Reset server selection when audio type changes
          final availableServersForType = widget.availableServers
              ?.where((server) => server.type == type)
              .toList();
          _tempSelectedServer = availableServersForType?.isNotEmpty == true
              ? availableServersForType!.first
              : null;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF5B13EC) : const Color(0xFF3A3A3C),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  void _applyChanges() {
    widget.onPlaybackSpeedChanged(_tempPlaybackSpeed);
    widget.onAutoSkipIntroChanged(_tempAutoSkipIntro);
    widget.onAutoSkipOutroChanged(_tempAutoSkipOutro);
    widget.onSubtitleChanged(_tempSelectedSubtitle);

    if (_tempSelectedServer != null && widget.onServerChanged != null) {
      widget.onServerChanged!(_tempSelectedServer!, _tempSelectedType);
    }

    Navigator.of(context).pop();
  }
}
