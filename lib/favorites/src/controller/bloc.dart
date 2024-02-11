import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:music_app/common/value.dart';
import 'package:music_app/data/data.dart';

part 'event.dart';
part 'state.dart';

// Represents the business logic component (Bloc) for managing the favorites screen state
// Initializes the FavoritesBloc with TrackDataService and initial state
class FavoritesBloc extends Bloc<FavoritesEvent, FavoritesState> {
  final TrackDataService trackDataService;

  FavoritesBloc({required this.trackDataService})
      : super(
          const FavoritesState(
            favorites: [],
            load: Load.loading,
          ),
        ) {
    on<FavoritesLoaded>(_loadFavorites);
    on<TrackRemovedFromFavorite>(_removeFromFavorite);
    on<TrackAddedToFavorite>(_addToFavorite);
  }

  Future<void> _loadFavorites(
    FavoritesLoaded event,
    Emitter<FavoritesState> emit,
  ) async {
    final favorites = await trackDataService.getData();

    // Since Hive does not particularly support various types of typing,
    // we need to extract data from it with the dynamic type and,
    // for convenience, also change it here to the data type we need
    final List<Map<AuthorModel, List<MusicModel>>> convertedFavorites =
        favorites.map((map) {
      final author = map.keys.first as AuthorModel;
      final tracks = (map.values.first as List<dynamic>).map((music) {
        if (music is MusicModel) {
          return music;
        } else {
          return music as MusicModel;
        }
      }).toList();
      return {author: tracks};
    }).toList();

    for (var authorInfo in convertedFavorites) {
      final tracks = authorInfo.values.first;
      tracks.sort(
        (a, b) => a.musicName.toLowerCase().compareTo(
              b.musicName.toLowerCase(),
            ),
      );
    }

    favorites.sort((a, b) {
      final authorNameA = a.keys.first.authorName.toLowerCase();
      final authorNameB = b.keys.first.authorName.toLowerCase();
      return authorNameA.compareTo(authorNameB);
    });

    emit(
      state.copyWith(
        favorites: convertedFavorites,
        load: Load.loaded,
      ),
    );
  }

  Future<void> _removeFromFavorite(
    TrackRemovedFromFavorite event,
    Emitter<FavoritesState> emit,
  ) async {
    emit(
      state.copyWith(
        load: Load.loading,
      ),
    );

    final favorites = state.favorites;
    final author = favorites.firstWhere(
      (element) => element.keys.first.authorName == event.author.authorName,
    );
    final tracks = author.values.first;

    tracks.removeWhere((element) => element.musicName == event.track.musicName);

    if (tracks.isEmpty) {
      favorites.remove(author);
      trackDataService.deleteData(
        event.author,
        null,
      );
      emit(
        state.copyWith(
          favorites: favorites,
          load: Load.loaded,
        ),
      );
    } else {
      trackDataService.deleteData(
        event.author,
        event.track,
      );
      emit(
        state.copyWith(
          favorites: favorites,
          load: Load.loaded,
        ),
      );
    }
  }

  Future<void> _addToFavorite(
    TrackAddedToFavorite event,
    Emitter<FavoritesState> emit,
  ) async {
    emit(
      state.copyWith(
        load: Load.loading,
      ),
    );

    var favorites =
        List<Map<AuthorModel, List<MusicModel>>>.from(state.favorites);
    late final Map<dynamic, dynamic> author;

    if (favorites.isEmpty) {
      await trackDataService.setData(event.author, event.track);

      favorites.add({
        event.author: [event.track]
      });

      for (var authorInfo in favorites) {
        final tracks = authorInfo.values.first;
        tracks.sort(
          (a, b) => a.musicName.toLowerCase().compareTo(
                b.musicName.toLowerCase(),
              ),
        );
      }

      favorites.sort((a, b) {
        final authorNameA = a.keys.first.authorName.toLowerCase();
        final authorNameB = b.keys.first.authorName.toLowerCase();
        return authorNameA.compareTo(authorNameB);
      });

      emit(
        state.copyWith(
          favorites: favorites,
          load: Load.loaded,
        ),
      );
      return;
    }

    final isAuthor = favorites.any(
      (element) => element.keys.first.authorName == event.author.authorName,
    );

    if (isAuthor) {
      author = favorites.firstWhere(
        (element) => element.keys.first.authorName == event.author.authorName,
      );
    } else {
      trackDataService.setData(event.author, event.track);
      favorites.add({
        event.author: [event.track]
      });

      for (var authorInfo in favorites) {
        final tracks = authorInfo.values.first;
        tracks.sort(
          (a, b) => a.musicName.toLowerCase().compareTo(
                b.musicName.toLowerCase(),
              ),
        );
      }

      favorites.sort((a, b) {
        final authorNameA = a.keys.first.authorName.toLowerCase();
        final authorNameB = b.keys.first.authorName.toLowerCase();
        return authorNameA.compareTo(authorNameB);
      });

      emit(
        state.copyWith(
          favorites: favorites,
          load: Load.loaded,
        ),
      );
      return;
    }

    final tracks = author.values.first;

    tracks.add(event.track);
    trackDataService.setData(event.author, event.track);

    for (var authorInfo in favorites) {
      final tracks = authorInfo.values.first;
      tracks.sort(
        (a, b) => a.musicName.toLowerCase().compareTo(
              b.musicName.toLowerCase(),
            ),
      );
    }

    favorites.sort((a, b) {
      final authorNameA = a.keys.first.authorName.toLowerCase();
      final authorNameB = b.keys.first.authorName.toLowerCase();
      return authorNameA.compareTo(authorNameB);
    });

    emit(
      state.copyWith(
        favorites: favorites,
        load: Load.loaded,
      ),
    );
  }
}
