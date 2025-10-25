class AniListCharacter {
  final int id;
  final AniListCharacterName? name;
  final String? image;
  final String? description;
  final String? gender;
  final String? dateOfBirth;
  final int? age;
  final String? bloodType;
  final bool? isFavourite;
  final String? siteUrl;
  final List<AniListCharacterMedia>? media;

  const AniListCharacter({
    required this.id,
    this.name,
    this.image,
    this.description,
    this.gender,
    this.dateOfBirth,
    this.age,
    this.bloodType,
    this.isFavourite,
    this.siteUrl,
    this.media,
  });

  factory AniListCharacter.fromJson(Map<String, dynamic> json) {
    return AniListCharacter(
      id: json['id'] as int,
      name: json['name'] != null
          ? AniListCharacterName.fromJson(json['name'])
          : null,
      image: json['image']?['large'] as String?,
      description: json['description'] as String?,
      gender: json['gender'] as String?,
      dateOfBirth:
          json['dateOfBirth']?['year'] != null &&
              json['dateOfBirth']?['month'] != null &&
              json['dateOfBirth']?['day'] != null
          ? '${json['dateOfBirth']['year']}-${json['dateOfBirth']['month']}-${json['dateOfBirth']['day']}'
          : null,
      age: json['age'] as int?,
      bloodType: json['bloodType'] as String?,
      isFavourite: json['isFavourite'] as bool?,
      siteUrl: json['siteUrl'] as String?,
      media: json['media']?['edges'] != null
          ? (json['media']['edges'] as List<dynamic>)
                .map((edge) => AniListCharacterMedia.fromJson(edge))
                .toList()
          : null,
    );
  }

  String get displayName =>
      name?.english ?? name?.full ?? name?.native ?? 'Unknown Character';
}

class AniListCharacterName {
  final String? first;
  final String? middle;
  final String? last;
  final String? full;
  final String? native;
  final String? english;
  final List<String>? alternative;

  const AniListCharacterName({
    this.first,
    this.middle,
    this.last,
    this.full,
    this.native,
    this.english,
    this.alternative,
  });

  factory AniListCharacterName.fromJson(Map<String, dynamic> json) {
    return AniListCharacterName(
      first: json['first'] as String?,
      middle: json['middle'] as String?,
      last: json['last'] as String?,
      full: json['full'] as String?,
      native: json['native'] as String?,
      english: json['english'] as String?,
      alternative: (json['alternative'] as List<dynamic>?)?.cast<String>(),
    );
  }
}

class AniListCharacterMedia {
  final String? characterRole;
  final int mediaId;
  final String? mediaTitle;
  final List<AniListVoiceActor>? voiceActors;

  const AniListCharacterMedia({
    this.characterRole,
    required this.mediaId,
    this.mediaTitle,
    this.voiceActors,
  });

  factory AniListCharacterMedia.fromJson(Map<String, dynamic> json) {
    final nodeRaw = json['node'];
    final Map<String, dynamic>? node = nodeRaw is Map<String, dynamic>
        ? nodeRaw
        : null;
    return AniListCharacterMedia(
      characterRole: json['characterRole'] as String?,
      mediaId: node?['id'] as int? ?? 0,
      mediaTitle: node?['title']?['english'] ?? node?['title']?['romaji'],
      voiceActors: json['voiceActors'] != null
          ? (json['voiceActors'] as List<dynamic>)
                .map((actor) => AniListVoiceActor.fromJson(actor))
                .toList()
          : null,
    );
  }
}

class AniListVoiceActor {
  final int id;
  final AniListVoiceActorName? name;
  final String? language;
  final String? image;

  const AniListVoiceActor({
    required this.id,
    this.name,
    this.language,
    this.image,
  });

  factory AniListVoiceActor.fromJson(Map<String, dynamic> json) {
    return AniListVoiceActor(
      id: json['id'] as int,
      name: json['name'] != null
          ? AniListVoiceActorName.fromJson(json['name'])
          : null,
      language: json['language'] as String?,
      image: json['image']?['large'] as String?,
    );
  }

  String get displayName =>
      name?.full ?? name?.native ?? name?.english ?? 'Unknown Actor';
}

class AniListVoiceActorName {
  final String? first;
  final String? middle;
  final String? last;
  final String? full;
  final String? native;
  final String? english;

  const AniListVoiceActorName({
    this.first,
    this.middle,
    this.last,
    this.full,
    this.native,
    this.english,
  });

  factory AniListVoiceActorName.fromJson(Map<String, dynamic> json) {
    return AniListVoiceActorName(
      first: json['first'] as String?,
      middle: json['middle'] as String?,
      last: json['last'] as String?,
      full: json['full'] as String?,
      native: json['native'] as String?,
      english: json['english'] as String?,
    );
  }
}
