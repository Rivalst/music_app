part of 'bloc.dart';

// Represents events related to artist information
sealed class InfoEvent extends Equatable {}

// Event indicating that all tracks for a specific author are loaded
final class AllTrackLoaded extends InfoEvent {
  final String authorName;

  AllTrackLoaded({required this.authorName});

  @override
  List<Object?> get props => [authorName];
}

