import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:linze/core/models/streaming_models.dart';

class CharacterGridWidget extends StatelessWidget {
  final List<CharacterListItem> characters;
  final VoidCallback? onCharacterTap;

  const CharacterGridWidget({
    super.key,
    required this.characters,
    this.onCharacterTap,
  });

  @override
  Widget build(BuildContext context) {
    if (characters.isEmpty) {
      return Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFF2F2F2F),
            width: 1,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.person_outline_rounded,
                color: const Color(0xFF888888),
                size: 48,
              ),
              const SizedBox(height: 16),
              Text(
                'No character information available',
                style: GoogleFonts.plusJakartaSans(
                  color: const Color(0xFF888888),
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Text(
                'Characters',
                style: GoogleFonts.plusJakartaSans(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              Text(
                '${characters.length} characters',
                style: GoogleFonts.plusJakartaSans(
                  color: const Color(0xFF888888),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Character grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.85,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: characters.length > 6 ? 6 : characters.length, // Limit to 6 characters initially
            itemBuilder: (context, index) {
              final characterItem = characters[index];
              final character = characterItem.character;
              
              if (character == null) return const SizedBox.shrink();
              
              return _buildCharacterCard(character, character.roles?.isNotEmpty == true ? character.roles!.first.character?.role : null);
            },
          ),
          
          // Show more button if there are more than 6 characters
          if (characters.length > 6) ...[
            const SizedBox(height: 16),
            Center(
              child: TextButton(
                onPressed: () => _showAllCharacters(context),
                child: Text(
                  'View All ${characters.length} Characters',
                  style: GoogleFonts.plusJakartaSans(
                    color: const Color(0xFF5B13EC),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCharacterCard(Character character, String? role) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF2F2F2F),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onCharacterTap,
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Character image
                Expanded(
                  flex: 3,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: const Color(0xFF2F2F2F),
                      ),
                      child: character.profile != null
                          ? CachedNetworkImage(
                              imageUrl: character.profile!,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Container(
                                color: const Color(0xFF2F2F2F),
                                child: const Center(
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Color(0xFF5B13EC),
                                  ),
                                ),
                              ),
                              errorWidget: (context, url, error) => Container(
                                color: const Color(0xFF2F2F2F),
                                child: const Icon(
                                  Icons.person,
                                  color: Colors.white30,
                                  size: 32,
                                ),
                              ),
                            )
                          : Container(
                              color: const Color(0xFF2F2F2F),
                              child: const Icon(
                                Icons.person,
                                color: Colors.white30,
                                size: 32,
                              ),
                            ),
                    ),
                  ),
                ),
                
                const SizedBox(height: 8),
                
                // Character name and role
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Character name
                      Text(
                        character.name ?? 'Unknown Character',
                        style: GoogleFonts.plusJakartaSans(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          height: 1.2,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      
                      const SizedBox(height: 2),
                      
                      // Role badge
                      if (role != null && role.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: _getRoleColor(role).withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: _getRoleColor(role).withValues(alpha: 0.3),
                              width: 1,
                            ),
                          ),
                          child: Text(
                            role,
                            style: GoogleFonts.plusJakartaSans(
                              color: _getRoleColor(role),
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getRoleColor(String role) {
    switch (role.toLowerCase()) {
      case 'main':
      case 'protagonist':
        return const Color(0xFF5B13EC);
      case 'supporting':
        return const Color(0xFF10B981);
      case 'antagonist':
      case 'villain':
        return const Color(0xFFEF4444);
      case 'side':
      case 'minor':
        return const Color(0xFF888888);
      default:
        return const Color(0xFF3B82F6);
    }
  }

  void _showAllCharacters(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF161022),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.8,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFF2F2F2F),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Title
              Text(
                'All Characters (${characters.length})',
                style: GoogleFonts.plusJakartaSans(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Characters list
              Expanded(
                child: GridView.builder(
                  controller: scrollController,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    childAspectRatio: 0.7,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: characters.length,
                  itemBuilder: (context, index) {
                    final characterItem = characters[index];
                    final character = characterItem.character;
                    
                    if (character == null) return const SizedBox.shrink();
                    
                    return _buildCompactCharacterCard(character, character.roles?.isNotEmpty == true ? character.roles!.first.character?.role : null);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCompactCharacterCard(Character character, String? role) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF2F2F2F),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onCharacterTap,
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Character image
                Expanded(
                  flex: 3,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: const Color(0xFF2F2F2F),
                      ),
                      child: character.profile != null
                          ? CachedNetworkImage(
                              imageUrl: character.profile!,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Container(
                                color: const Color(0xFF2F2F2F),
                                child: const Center(
                                  child: CircularProgressIndicator(
                                    strokeWidth: 1,
                                    color: Color(0xFF5B13EC),
                                  ),
                                ),
                              ),
                              errorWidget: (context, url, error) => Container(
                                color: const Color(0xFF2F2F2F),
                                child: const Icon(
                                  Icons.person,
                                  color: Colors.white30,
                                  size: 24,
                                ),
                              ),
                            )
                          : Container(
                              color: const Color(0xFF2F2F2F),
                              child: const Icon(
                                Icons.person,
                                color: Colors.white30,
                                size: 24,
                              ),
                            ),
                    ),
                  ),
                ),
                
                const SizedBox(height: 8),
                
                // Character name and role
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        character.name ?? 'Unknown',
                        style: GoogleFonts.plusJakartaSans(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      
                      if (role != null && role.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 4,
                            vertical: 1,
                          ),
                          decoration: BoxDecoration(
                            color: _getRoleColor(role).withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            role,
                            style: GoogleFonts.plusJakartaSans(
                              color: _getRoleColor(role),
                              fontSize: 8,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
