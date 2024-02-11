part of 'bloc.dart';

// Represents the state of the favorites screen with information about 
// favorite authors and tracks, and data loading status
final class FavoritesState extends Equatable {
  final List<Map<AuthorModel, List<MusicModel>>> favorites;
  final Load load;

  const FavoritesState({
    required this.favorites,
    required this.load,
  });

  FavoritesState copyWith({
    List<Map<AuthorModel, List<MusicModel>>>? favorites,
    Load? load,
  }) {
    return FavoritesState(
      favorites: favorites ?? this.favorites,
      load: load ?? this.load,
    );
  }

  bool isInFavorites(
    AuthorModel author,
    MusicModel track,
  ) {
    if (favorites.isEmpty) {
      return false;
    }

    final isAuthor = favorites.any(
      (element) => element.keys.first.authorName == author.authorName,
    );

    if (isAuthor) {
      final authorInfo = favorites.firstWhere(
        (element) => element.keys.first.authorName == author.authorName,
      );
      final tracks = authorInfo.values.first;

      final isInFavorites =
          tracks.any((element) => element.musicName == track.musicName);

      return isInFavorites;
    } else {
      return false;
    }
  }

  @override
  List<Object?> get props => [
        favorites,
        load,
      ];
}
