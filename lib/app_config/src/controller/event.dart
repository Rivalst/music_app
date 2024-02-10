part of 'bloc.dart';

// Represents events related to screen changes
sealed class ScreenEvent extends Equatable {}

// Event indicating that the selected screen has changed
final class ScreenChanged extends ScreenEvent {
  final Screens selectedScreen;

  ScreenChanged({required this.selectedScreen});

  @override
  List<Object?> get props => [selectedScreen];
}
