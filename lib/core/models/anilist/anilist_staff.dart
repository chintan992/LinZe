class AniListStaff {
  final int id;
  final AniListStaffName? name;
  final String? language;
  final String? image;
  final String? description;
  final String? primaryOccupations;
  final String? gender;
  final String? dateOfBirth;
  final String? dateOfDeath;
  final int? age;
  final String? bloodType;
  final bool? isFavourite;
  final String? siteUrl;
  final List<AniListStaffMedia>? staffMedia;

  const AniListStaff({
    required this.id,
    this.name,
    this.language,
    this.image,
    this.description,
    this.primaryOccupations,
    this.gender,
    this.dateOfBirth,
    this.dateOfDeath,
    this.age,
    this.bloodType,
    this.isFavourite,
    this.siteUrl,
    this.staffMedia,
  });

  factory AniListStaff.fromJson(Map<String, dynamic> json) {
    return AniListStaff(
      id: json['id'] as int,
      name: json['name'] != null
          ? AniListStaffName.fromJson(json['name'])
          : null,
      language: json['language'] as String?,
      image: json['image']?['large'] as String?,
      description: json['description'] as String?,
      primaryOccupations: (json['primaryOccupations'] as List<dynamic>?)?.join(
        ', ',
      ),
      gender: json['gender'] as String?,
      dateOfBirth:
          json['dateOfBirth']?['year'] != null &&
              json['dateOfBirth']?['month'] != null &&
              json['dateOfBirth']?['day'] != null
          ? '${json['dateOfBirth']['year']}-${json['dateOfBirth']['month']}-${json['dateOfBirth']['day']}'
          : null,
      dateOfDeath:
          json['dateOfDeath']?['year'] != null &&
              json['dateOfDeath']?['month'] != null &&
              json['dateOfDeath']?['day'] != null
          ? '${json['dateOfDeath']['year']}-${json['dateOfDeath']['month']}-${json['dateOfDeath']['day']}'
          : null,
      age: json['age'] as int?,
      bloodType: json['bloodType'] as String?,
      isFavourite: json['isFavourite'] as bool?,
      siteUrl: json['siteUrl'] as String?,
      staffMedia: json['staffMedia']?['edges'] != null
          ? (json['staffMedia']['edges'] as List<dynamic>)
                .map((edge) => AniListStaffMedia.fromJson(edge))
                .toList()
          : null,
    );
  }

  String get displayName =>
      name?.full ?? name?.native ?? name?.english ?? 'Unknown Staff';
}

class AniListStaffName {
  final String? first;
  final String? middle;
  final String? last;
  final String? full;
  final String? native;
  final String? english;

  const AniListStaffName({
    this.first,
    this.middle,
    this.last,
    this.full,
    this.native,
    this.english,
  });

  factory AniListStaffName.fromJson(Map<String, dynamic> json) {
    return AniListStaffName(
      first: json['first'] as String?,
      middle: json['middle'] as String?,
      last: json['last'] as String?,
      full: json['full'] as String?,
      native: json['native'] as String?,
      english: json['english'] as String?,
    );
  }
}

class AniListStaffMedia {
  final String? staffRole;
  final int mediaId;
  final String? mediaTitle;

  const AniListStaffMedia({
    this.staffRole,
    required this.mediaId,
    this.mediaTitle,
  });

  factory AniListStaffMedia.fromJson(Map<String, dynamic> json) {
    final nodeRaw = json['node'];
    final Map<String, dynamic>? node = nodeRaw is Map<String, dynamic>
        ? nodeRaw
        : null;
    return AniListStaffMedia(
      staffRole: json['staffRole'] as String?,
      mediaId: node?['id'] as int? ?? 0,
      mediaTitle: node?['title']?['english'] ?? node?['title']?['romaji'],
    );
  }
}
