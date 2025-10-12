import 'package:linze/core/models/anime_model.dart';

class StreamingLink {
  final int? id;
  final String? type;
  final LinkInfo? link;
  final List<Track>? tracks;
  final dynamic intro;
  final dynamic outro;
  final String? server;

  StreamingLink({
    this.id,
    this.type,
    this.link,
    this.tracks,
    this.intro,
    this.outro,
    this.server,
  });

  factory StreamingLink.fromJson(Map<String, dynamic> json) {
    return StreamingLink(
      id: int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      type: json['type'],
      link: json['link'] != null ? LinkInfo.fromJson(json['link']) : null,
      tracks: json['tracks'] != null
          ? (json['tracks'] as List).map((e) => Track.fromJson(e)).toList()
          : null,
      intro: json['intro'],
      outro: json['outro'],
      server: json['server'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'link': link?.toJson(),
      'tracks': tracks?.map((e) => e.toJson()).toList(),
      'intro': intro,
      'outro': outro,
      'server': server,
    };
  }
}

class LinkInfo {
  final String? file;
  final String? type;

  LinkInfo({this.file, this.type});

  factory LinkInfo.fromJson(Map<String, dynamic> json) {
    return LinkInfo(
      file: json['file'],
      type: json['type'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'file': file,
      'type': type,
    };
  }
}

class Track {
  final String? file;
  final String? label;
  final String? kind;
  final bool? isDefault;

  Track({this.file, this.label, this.kind, this.isDefault});

  factory Track.fromJson(Map<String, dynamic> json) {
    return Track(
      file: json['file'],
      label: json['label'],
      kind: json['kind'],
      isDefault: json['default'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'file': file,
      'label': label,
      'kind': kind,
      'default': isDefault,
    };
  }
}

class Server {
  final String? type;
  final int? dataId;
  final int? serverId;
  final String? serverName;

  Server({this.type, this.dataId, this.serverId, this.serverName});

  factory Server.fromJson(Map<String, dynamic> json) {
    return Server(
      type: json['type'],
      dataId: int.tryParse(json['data_id']?.toString() ?? '0') ?? 0,
      serverId: int.tryParse(json['server_id']?.toString() ?? '0') ?? 0,
      serverName: json['server_name'] ?? json['serverName'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'data_id': dataId,
      'server_id': serverId,
      'server_name': serverName,
    };
  }
}

class Character {
  final String? id;
  final String? name;
  final String? japaneseName;
  final String? profile;
  final String? about;
  final List<VoiceActor>? voiceActors;
  final List<Animeography>? animeography;
  final List<CharacterRole>? roles;

  Character({
    this.id,
    this.name,
    this.japaneseName,
    this.profile,
    this.about,
    this.voiceActors,
    this.animeography,
    this.roles,
  });

  factory Character.fromJson(Map<String, dynamic> json) {
    return Character(
      id: json['id'],
      name: json['name'],
      japaneseName: json['japaneseName'],
      profile: json['profile'],
      about: json['about']?['description'],
      voiceActors: json['voiceActors'] != null
          ? (json['voiceActors'] as List)
              .map((e) => VoiceActor.fromJson(e))
              .toList()
          : null,
      animeography: json['animeography'] != null
          ? (json['animeography'] as List)
              .map((e) => Animeography.fromJson(e))
              .toList()
          : null,
      roles: json['roles'] != null
          ? (json['roles'] as List)
              .map((e) => CharacterRole.fromJson(e))
              .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'japaneseName': japaneseName,
      'profile': profile,
      'about': {'description': about},
      'voiceActors': voiceActors?.map((e) => e.toJson()).toList(),
      'animeography': animeography?.map((e) => e.toJson()).toList(),
      'roles': roles?.map((e) => e.toJson()).toList(),
    };
  }
}

class VoiceActor {
  final String? id;
  final String? name;
  final String? profile;
  final String? language;
  final String? japaneseName;

  VoiceActor({this.id, this.name, this.profile, this.language, this.japaneseName});

  factory VoiceActor.fromJson(Map<String, dynamic> json) {
    return VoiceActor(
      id: json['id'],
      name: json['name'],
      profile: json['profile'],
      language: json['language'],
      japaneseName: json['japaneseName'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'profile': profile,
      'language': language,
      'japaneseName': japaneseName,
    };
  }
}

class Animeography {
  final String? title;
  final String? id;
  final String? role;
  final String? type;
  final String? poster;

  Animeography({this.title, this.id, this.role, this.type, this.poster});

  factory Animeography.fromJson(Map<String, dynamic> json) {
    return Animeography(
      title: json['title'],
      id: json['id'],
      role: json['role'],
      type: json['type'],
      poster: json['poster'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'id': id,
      'role': role,
      'type': type,
      'poster': poster,
    };
  }
}

class CharacterRole {
  final AnimeDetail? anime;
  final CharacterInfo? character;

  CharacterRole({this.anime, this.character});

  factory CharacterRole.fromJson(Map<String, dynamic> json) {
    return CharacterRole(
      anime: json['anime'] != null ? AnimeDetail.fromJson(json['anime']) : null,
      character: json['character'] != null ? CharacterInfo.fromJson(json['character']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'anime': anime?.toJson(),
      'character': character?.toJson(),
    };
  }
}

class AnimeDetail {
  final String? title;
  final String? poster;
  final String? type;
  final String? year;
  final String? id;

  AnimeDetail({this.title, this.poster, this.type, this.year, this.id});

  factory AnimeDetail.fromJson(Map<String, dynamic> json) {
    return AnimeDetail(
      title: json['title'],
      poster: json['poster'],
      type: json['type'],
      year: json['year'],
      id: json['id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'poster': poster,
      'type': type,
      'year': year,
      'id': id,
    };
  }
}

class CharacterInfo {
  final String? name;
  final String? profile;
  final String? role;

  CharacterInfo({this.name, this.profile, this.role});

  factory CharacterInfo.fromJson(Map<String, dynamic> json) {
    return CharacterInfo(
      name: json['name'],
      profile: json['profile'],
      role: json['role'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'profile': profile,
      'role': role,
    };
  }
}

class ScheduleItem {
  final String? id;
  final int? dataId;
  final String? title;
  final String? japaneseTitle;
  final String? releaseDate;
  final String? time;
  final int? episodeNo;

  ScheduleItem({
    this.id,
    this.dataId,
    this.title,
    this.japaneseTitle,
    this.releaseDate,
    this.time,
    this.episodeNo,
  });

  factory ScheduleItem.fromJson(Map<String, dynamic> json) {
    return ScheduleItem(
      id: json['id'],
      dataId: json['data_id'],
      title: json['title'],
      japaneseTitle: json['japanese_title'],
      releaseDate: json['releaseDate'],
      time: json['time'],
      episodeNo: json['episode_no'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'data_id': dataId,
      'title': title,
      'japanese_title': japaneseTitle,
      'releaseDate': releaseDate,
      'time': time,
      'episode_no': episodeNo,
    };
  }
}

// Additional models for API endpoints
class TopSearch {
  final String? title;
  final String? link;

  TopSearch({this.title, this.link});

  factory TopSearch.fromJson(Map<String, dynamic> json) {
    return TopSearch(
      title: json['title'],
      link: json['link'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'link': link,
    };
  }
}

class AnimeDetailResponse {
  final Anime? data;
  final List<Season>? seasons;
  final List<Anime>? relatedData;
  final List<Anime>? recommendedData;

  AnimeDetailResponse({
    this.data,
    this.seasons,
    this.relatedData,
    this.recommendedData,
  });

  factory AnimeDetailResponse.fromJson(Map<String, dynamic> json) {
    return AnimeDetailResponse(
      data: json['data'] != null ? Anime.fromJson(json['data']) : null,
      seasons: json['seasons'] != null
          ? (json['seasons'] as List).map((e) => Season.fromJson(e)).toList()
          : null,
      relatedData: json['related_data'] != null && json['related_data'].isNotEmpty
          ? (json['related_data'][0] as List).map((e) => Anime.fromJson(e)).toList()
          : null,
      recommendedData: json['recommended_data'] != null && json['recommended_data'].isNotEmpty
          ? (json['recommended_data'][0] as List).map((e) => Anime.fromJson(e)).toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'data': data?.toJson(),
      'seasons': seasons?.map((e) => e.toJson()).toList(),
      'related_data': relatedData != null ? [relatedData?.map((e) => e.toJson()).toList()] : null,
      'recommended_data': recommendedData != null ? [recommendedData?.map((e) => e.toJson()).toList()] : null,
    };
  }
}

class Schedule {
  final String? id;
  final int? dataId;
  final String? title;
  final String? japaneseTitle;
  final String? releaseDate;
  final String? time;
  final int? episodeNo;

  Schedule({
    this.id,
    this.dataId,
    this.title,
    this.japaneseTitle,
    this.releaseDate,
    this.time,
    this.episodeNo,
  });

  factory Schedule.fromJson(Map<String, dynamic> json) {
    return Schedule(
      id: json['id'],
      dataId: json['data_id'],
      title: json['title'],
      japaneseTitle: json['japanese_title'],
      releaseDate: json['releaseDate'],
      time: json['time'],
      episodeNo: json['episode_no'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'data_id': dataId,
      'title': title,
      'japanese_title': japaneseTitle,
      'releaseDate': releaseDate,
      'time': time,
      'episode_no': episodeNo,
    };
  }
}

class NextEpisodeSchedule {
  final String? nextEpisodeSchedule;

  NextEpisodeSchedule({this.nextEpisodeSchedule});

  factory NextEpisodeSchedule.fromJson(Map<String, dynamic> json) {
    return NextEpisodeSchedule(
      nextEpisodeSchedule: json['nextEpisodeSchedule'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nextEpisodeSchedule': nextEpisodeSchedule,
    };
  }
}

class QtipInfo {
  final String? title;
  final double? rating;
  final String? quality;
  final int? subCount;
  final int? dubCount;
  final int? episodeCount;
  final String? type;
  final String? description;
  final String? japaneseTitle;
  final String? synonyms;
  final String? airedDate;
  final String? status;
  final List<String>? genres;
  final String? watchLink;

  QtipInfo({
    this.title,
    this.rating,
    this.quality,
    this.subCount,
    this.dubCount,
    this.episodeCount,
    this.type,
    this.description,
    this.japaneseTitle,
    this.synonyms,
    this.airedDate,
    this.status,
    this.genres,
    this.watchLink,
  });

  factory QtipInfo.fromJson(Map<String, dynamic> json) {
    return QtipInfo(
      title: json['title'],
      rating: json['rating']?.toDouble(),
      quality: json['quality'],
      subCount: json['subCount'],
      dubCount: json['dubCount'],
      episodeCount: json['episodeCount'],
      type: json['type'],
      description: json['description'],
      japaneseTitle: json['japaneseTitle'],
      synonyms: json['Synonyms'],
      airedDate: json['airedDate'],
      status: json['status'],
      genres: json['genres'] != null ? List<String>.from(json['genres']) : null,
      watchLink: json['watchLink'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'rating': rating,
      'quality': quality,
      'subCount': subCount,
      'dubCount': dubCount,
      'episodeCount': episodeCount,
      'type': type,
      'description': description,
      'japaneseTitle': japaneseTitle,
      'Synonyms': synonyms,
      'airedDate': airedDate,
      'status': status,
      'genres': genres,
      'watchLink': watchLink,
    };
  }
}

class CharacterListResponse {
  final int? currentPage;
  final int? totalPages;
  final List<CharacterListItem>? data;

  CharacterListResponse({
    this.currentPage,
    this.totalPages,
    this.data,
  });

  factory CharacterListResponse.fromJson(Map<String, dynamic> json) {
    return CharacterListResponse(
      currentPage: json['currentPage'],
      totalPages: json['totalPages'],
      data: json['data'] != null
          ? (json['data'] as List).map((e) => CharacterListItem.fromJson(e)).toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'currentPage': currentPage,
      'totalPages': totalPages,
      'data': data?.map((e) => e.toJson()).toList(),
    };
  }
}

class CharacterListItem {
  final Character? character;
  final List<VoiceActor>? voiceActors;

  CharacterListItem({
    this.character,
    this.voiceActors,
  });

  factory CharacterListItem.fromJson(Map<String, dynamic> json) {
    return CharacterListItem(
      character: json['character'] != null ? Character.fromJson(json['character']) : null,
      voiceActors: json['voiceActors'] != null
          ? (json['voiceActors'] as List).map((e) => VoiceActor.fromJson(e)).toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'character': character?.toJson(),
      'voiceActors': voiceActors?.map((e) => e.toJson()).toList(),
    };
  }
}

class CharacterDetail {
  final String? id;
  final String? name;
  final String? profile;
  final String? japaneseName;
  final AboutInfo? about;
  final List<VoiceActor>? voiceActors;
  final List<Animeography>? animeography;

  CharacterDetail({
    this.id,
    this.name,
    this.profile,
    this.japaneseName,
    this.about,
    this.voiceActors,
    this.animeography,
  });

  factory CharacterDetail.fromJson(Map<String, dynamic> json) {
    return CharacterDetail(
      id: json['id'],
      name: json['name'],
      profile: json['profile'],
      japaneseName: json['japaneseName'],
      about: json['about'] != null ? AboutInfo.fromJson(json['about']) : null,
      voiceActors: json['voiceActors'] != null
          ? (json['voiceActors'] as List).map((e) => VoiceActor.fromJson(e)).toList()
          : null,
      animeography: json['animeography'] != null
          ? (json['animeography'] as List).map((e) => Animeography.fromJson(e)).toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'profile': profile,
      'japaneseName': japaneseName,
      'about': about?.toJson(),
      'voiceActors': voiceActors?.map((e) => e.toJson()).toList(),
      'animeography': animeography?.map((e) => e.toJson()).toList(),
    };
  }
}

class AboutInfo {
  final String? description;
  final String? style;

  AboutInfo({this.description, this.style});

  factory AboutInfo.fromJson(Map<String, dynamic> json) {
    return AboutInfo(
      description: json['description'],
      style: json['style'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'description': description,
      'style': style,
    };
  }
}

class VoiceActorDetail {
  final String? id;
  final String? name;
  final String? profile;
  final String? japaneseName;
  final AboutInfo? about;
  final List<CharacterRole>? roles;

  VoiceActorDetail({
    this.id,
    this.name,
    this.profile,
    this.japaneseName,
    this.about,
    this.roles,
  });

  factory VoiceActorDetail.fromJson(Map<String, dynamic> json) {
    return VoiceActorDetail(
      id: json['id'],
      name: json['name'],
      profile: json['profile'],
      japaneseName: json['japaneseName'],
      about: json['about'] != null ? AboutInfo.fromJson(json['about']) : null,
      roles: json['roles'] != null
          ? (json['roles'] as List).map((e) => CharacterRole.fromJson(e)).toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'profile': profile,
      'japaneseName': japaneseName,
      'about': about?.toJson(),
      'roles': roles?.map((e) => e.toJson()).toList(),
    };
  }
}