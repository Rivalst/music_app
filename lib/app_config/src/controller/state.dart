part of 'bloc.dart';

// Represents the state of the screen
// Contains the current screen
final class ScreenState extends Equatable {
  final Screens screen;

  const ScreenState({
    required this.screen,
  });

  ScreenState copyWith({
    Screens? screen,
  }) {
    return ScreenState(
      screen: screen ?? this.screen,
    );
  }

  @override
  List<Object?> get props => [screen];
}
