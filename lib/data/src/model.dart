import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

part 'model.g.dart';

@HiveType(typeId: 0)
class AuthorModel extends HiveObject {
  @HiveField(0)
  final String authorName;

  @HiveField(1)
  final String playcount;

  @HiveField(2)
  final String listeners;

  @HiveField(3)
  final String mbid;

  @HiveField(4)
  final String authorUrl;

  @HiveField(5)
  final List<dynamic> images;

  AuthorModel({
    required this.authorName,
    required this.playcount,
    required this.listeners,
    required this.mbid,
    required this.authorUrl,
    required this.images,
  });

  factory AuthorModel.fromJson({required Map<dynamic, dynamic> json}) {
    return AuthorModel(
      authorName: json['name'] ?? 'undefined',
      playcount: json['playcount'] ?? 'undefined',
      listeners: json['listeners'] ?? 'undefined',
      mbid: json['mbid'] ?? 'undefined',
      authorUrl: json['url'] ?? 'undefined',
      images: json['image'] ?? [],
    );
  }

  AuthorModel copyWith({
    String? authorName,
    String? playcount,
    String? listeners,
    String? mbid,
    String? authorUrl,
    List<dynamic>? images,
  }) {
    return AuthorModel(
      authorName: authorName ?? this.authorName,
      playcount: playcount ?? this.playcount,
      listeners: listeners ?? this.listeners,
      mbid: mbid ?? this.listeners,
      authorUrl: authorUrl ?? this.authorUrl,
      images: images ?? this.images,
    );
  }
}

@HiveType(typeId: 1)
class MusicModel extends HiveObject {
  @HiveField(0)
  final String musicName;
  @HiveField(1)
  final String duration;
  @HiveField(2)
  final List<dynamic> images;
  @HiveField(3)
  final bool isFavorite;

  MusicModel({
    required this.musicName,
    required this.duration,
    required this.images,
    required this.isFavorite,
  });

  factory MusicModel.fromJson({
    required Map<dynamic, dynamic> json,
    required bool isFavorite,
  }) {
    return MusicModel(
      musicName: json['track'] != null ? json['track']['name'] : 'undefined',
      duration: json['track'] != null ? json['track']['duration'] : 'undefined',
      images: json['track'] != null
          ? json['track']['album'] == null
              ? []
              : json['track']['album']['image']
          : [],
      isFavorite: isFavorite,
    );
  }

  MusicModel copyWith({
    String? musicName,
    String? duration,
    List<dynamic>? images,
    bool? isFavorite,
  }) {
    return MusicModel(
      musicName: musicName ?? this.musicName,
      duration: duration ?? this.duration,
      images: images ?? this.images,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }
}

class AlbumModel {
  final String albumName;
  final List<dynamic> images;
  final String authorName;

  AlbumModel({
    required this.albumName,
    required this.authorName,
    required this.images,
  });

  factory AlbumModel.fromJson({required Map<dynamic, dynamic> json}) {
    return AlbumModel(
      albumName: json['name'] ?? 'undefined',
      authorName: json['artist']['name'] ?? 'undefined',
      images: json['image'],
    );
  }

  AlbumModel copyWith({
    String? albumName,
    String? authorName,
    List<dynamic>? images,
  }) {
    return AlbumModel(
      albumName: albumName ?? this.albumName,
      authorName: authorName ?? this.authorName,
      images: images ?? this.images,
    );
  }
}
