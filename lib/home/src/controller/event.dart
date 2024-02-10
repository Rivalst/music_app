part of 'bloc.dart';

// Represents events related to the home screen
sealed class HomeEvent extends Equatable {}

// Event indicating that all authors are loaded©
final class AllAuthorLoaded extends HomeEvent {
  @override
  List<Object?> get props => [];
}
