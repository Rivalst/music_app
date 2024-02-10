part of 'bloc.dart';
// Represents events related to the favorites screen

sealed class FavoritesEvent extends Equatable {}

// Event indicating that favorites are loaded
final class FavoritesLoaded extends FavoritesEvent {
  @override
  List<Object?> get props => [];
}

// Event indicating that a track is removed from favorites
final class TrackRemovedFromFavorite extends FavoritesEvent {
  final AuthorModel author;
  final MusicModel track;

  TrackRemovedFromFavorite({
    required this.author,
    required this.track,
  });

  @override
  List<Object?> get props => [author, track];
}

// Event indicating that a track is added to favorites
final class TrackAddedToFavorite extends FavoritesEvent {
  final AuthorModel author;
  final MusicModel track;

  TrackAddedToFavorite({
    required this.author,
    required this.track,
  });

  @override
  List<Object?> get props => [author, track];
}
