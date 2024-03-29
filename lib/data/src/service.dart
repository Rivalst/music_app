import 'dart:convert';

import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;

import 'package:music_app/data/data.dart';

/// Represents an abstract class for fetching data from an API
abstract class ApiFetcher {
  /// Retrieves author data asynchronously
  /// Returns a Future containing a list of AuthorModel
  Future<List<AuthorModel>> getAuthorData();

  /// Retrieves music data for a specific artist asynchronously
  /// Takes artist name as input parameter
  /// Returns a Future containing a list of MusicModel
  Future<List<Map<AlbumModel, List<MusicModel>>>> getMusicData(String artist);
}

/// Represents an abstract class for local data service operations
abstract class LocalDataService {
  /// Retrieves data asynchronously
  /// Returns a Future containing a list of maps with dynamic keys and values
  Future<List<Map<dynamic, dynamic>>> getData();

  /// Adds new data to the local storage asynchronously
  /// Takes an AuthorModel and a MusicModel as input parameters
  Future<void> setData(
    AuthorModel author,
    MusicModel track,
  );

  ///Updates existing data in the local storage asynchronously
  /// Takes an AuthorModel and a MusicModel as input parameters
  Future<void> updateData(
    AuthorModel author,
    MusicModel track,
  );

  /// Deletes data from the local storage asynchronously
  /// Takes an AuthorModel and an optional MusicModel as input parameters
  Future<void> deleteData(
    AuthorModel author,
    MusicModel? track,
  );
}

class MusicAuthorDataService extends ApiFetcher {
  @override
  Future<List<AuthorModel>> getAuthorData() async {
    const method = 'chart.gettopartists';

    final response = await http.get(
      Uri.parse("$_apiURL?method=$method&api_key=$_apiKey&format=$_formatJson"),
    );

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body) as Map<dynamic, dynamic>;
      final List<AuthorModel> authors = [];

      for (final author in body['artists']['artist']) {
        authors.add(AuthorModel.fromJson(
          json: author,
        ));
      }
      return authors;
    } else {
      throw Exception(
        'Bad response. Response status code: ${response.statusCode}, response body: ${response.body}',
      );
    }
  }

  @override
  Future<List<Map<AlbumModel, List<MusicModel>>>> getMusicData(
    String artist,
  ) async {
    const method = "artist.gettopalbums";
    const limit = 5;

    final formattedArtist = artist.toLowerCase().replaceAll(' ', '+');

    final response = await http.get(
      Uri.parse(
          "$_apiURL?method=$method&artist=$formattedArtist&api_key=$_apiKey&format=$_formatJson&limit=$limit"),
    );

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body) as Map<dynamic, dynamic>;
      final List<Map<AlbumModel, List<MusicModel>>> allMusic = [];

      for (final album in body['topalbums']['album']) {
        final albumName = album['name'];
        final albumsTrackInfo = await _getAlbumInfo(
          formattedArtist,
          albumName,
        );

        final albumModel = AlbumModel.fromJson(json: album);
        if (albumsTrackInfo != null) {
          allMusic.add({albumModel: albumsTrackInfo});
        }
      }
      return allMusic;
    } else {
      throw Exception(
        'Bad response. Response status code: ${response.statusCode}, response body: ${response.body}',
      );
    }
  }

  Future<List<MusicModel>?> _getAlbumInfo(
    String artist,
    String albumName,
  ) async {
    const method = 'album.getinfo';

    final formattedAlbumName = albumName.replaceAll(' ', '+');

    final response = await http.get(
      Uri.parse(
          "$_apiURL?method=$method&api_key=$_apiKey&artist=$artist&album=$formattedAlbumName&format=$_formatJson"),
    );

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body) as Map<dynamic, dynamic>;
      final music = <MusicModel>[];

      final tracks = body['album']['tracks'];

      if (tracks == null) {
        return tracks;
      }

      if (tracks['track'] is Map<String, dynamic>) {
        return null;
      }

      final albumImages = body['album']['image'];

      for (final track in tracks['track']) {
        final trackName = track['name'];

        final trackInfo = await _getTrackInfo(
          artist,
          trackName,
          albumImages,
        );
        music.add(trackInfo);
      }
      return music;
    } else {
      throw Exception(
        'Bad response. Response status code: ${response.statusCode}, response body: ${response.body}',
      );
    }
  }

  Future<MusicModel> _getTrackInfo(
    String artist,
    String trackName,
    List<dynamic> albumImages,
  ) async {
    const method = 'track.getInfo';

    final formattedTrack = trackName.toLowerCase().replaceAll(' ', '+');

    final response = await http.get(
      Uri.parse(
          "$_apiURL?method=$method&api_key=$_apiKey&artist=$artist&track=$formattedTrack&format=$_formatJson"),
    );

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body) as Map<dynamic, dynamic>;

      final music = MusicModel.fromJson(
        json: body,
        isFavorite: false,
        images: albumImages,
      );
      return music;
    } else {
      throw Exception(
        'Bad response. Response status code: ${response.statusCode}, response body: ${response.body}',
      );
    }
  }

  final _apiURL = "http://ws.audioscrobbler.com/2.0/";
  final _apiKey = "9caa6842f4e12353d2257c9065244c9c";
  final _formatJson = 'json';
}

class TrackDataService extends LocalDataService {
  @override
  Future<void> deleteData(
    AuthorModel author,
    MusicModel? track,
  ) async {
    final box = await Hive.openBox<Map<dynamic, dynamic>>(_boxName);
    final value = box.values.toList();

    if (track == null) {
      await box.delete(author.authorName);
      await box.close();
      return;
    }

    final authorIndex = value.indexWhere(
        (element) => element.keys.first.authorName == author.authorName);

    late List<dynamic>? tracksByAuthor;
    late int trackIndex;

    if (authorIndex != -1) {
      final authorInfo = box.getAt(authorIndex);
      tracksByAuthor = authorInfo?.values.first;
    } else {
      await box.close();

      return;
    }

    if (tracksByAuthor != null) {
      trackIndex = tracksByAuthor.indexWhere(
        (element) => track.musicName == element.musicName,
      );
    } else {
      await box.close();
      return;
    }

    if (trackIndex != -1) {
      tracksByAuthor.removeAt(trackIndex);
      await box.putAt(
        authorIndex,
        {
          author: tracksByAuthor,
        },
      );
    }

    if (tracksByAuthor.isEmpty) {
      await box.delete(author.authorName);
    }

    await box.close();
  }

  @override
  Future<List<Map<dynamic, dynamic>>> getData() async {
    final box = await Hive.openBox<Map<dynamic, dynamic>>(_boxName);

    final authors = box.values.toList();

    return authors;
  }

  @override
  Future<void> setData(
    AuthorModel author,
    MusicModel track,
  ) async {
    final box = await Hive.openBox<Map<dynamic, dynamic>>(_boxName);

    late List<dynamic>? tracksByAuthor;

    if (box.containsKey(author.authorName)) {
      final authors = box.values.toList();
      final authorInfo = authors.firstWhere(
          (element) => element.keys.first.authorName == author.authorName);

      tracksByAuthor = authorInfo.values.first;
    } else {
      tracksByAuthor = null;

      await box.put(
        author.authorName,
        {
          author: [
            track.copyWith(
              isFavorite: true,
            )
          ]
        },
      );
    }

    if (tracksByAuthor != null) {
      tracksByAuthor.add(
        track.copyWith(
          isFavorite: true,
        ),
      );

      await box.put(
        author.authorName,
        {
          author: tracksByAuthor,
        },
      );
    }

    await box.close();
  }

  @override
  Future<void> updateData(
    AuthorModel author,
    MusicModel track,
  ) async {
    // There is no need to implement logic for this method yet
  }

  final _boxName = 'music';
}
