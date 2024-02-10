import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import 'package:music_app/common/value.dart';

part 'event.dart';
part 'state.dart';

// Represents the business logic component (Bloc) for managing the current screen state
// Initializes the ScreenBloc with initial state setting the current screen to home
class ScreenBloc extends Bloc<ScreenEvent, ScreenState> {
  ScreenBloc()
      : super(
          const ScreenState(
            screen: Screens.home,
          ),
        ) {
    on<ScreenChanged>(_changeScreen);
  }

  void _changeScreen(
    ScreenChanged event,
    Emitter<ScreenState> emit,
  ) {
    switch (event.selectedScreen) {
      case Screens.home:
        emit(
          state.copyWith(
            screen: event.selectedScreen,
          ),
        );

      case Screens.favorites:
        emit(
          state.copyWith(
            screen: event.selectedScreen,
          ),
        );
    }
  }
}
