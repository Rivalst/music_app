part of 'bloc.dart';

// Represents events related to artist information
sealed class InfoEvent extends Equatable {}

// Event indicating that all album for a specific author are loaded
final class AllAlbumLoaded extends InfoEvent {
  final String authorName;

  AllAlbumLoaded({required this.authorName});

  @override
  List<Object?> get props => [authorName];
}

