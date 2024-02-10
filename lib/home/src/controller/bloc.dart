import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:logger/logger.dart';

import 'package:music_app/common/value.dart';
import 'package:music_app/data/data.dart';

part 'event.dart';
part 'state.dart';

// Represents the business logic component (Bloc) for managing the home screen state
// Initializes the HomeBloc with MusicAuthorDataService and initial state
// Handles the AllAuthorLoaded event by loading all authors asynchronously
class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final MusicAuthorDataService musicAuthorDataService;

  HomeBloc({required this.musicAuthorDataService})
      : super(
          const HomeState(
            load: Load.loading,
            allAuthor: [],
            errorMessage: '',
          ),
        ) {
    on<AllAuthorLoaded>(_allAuthorLoad);
  }

  Future<void> _allAuthorLoad(
    AllAuthorLoaded event,
    Emitter<HomeState> emit,
  ) async {
    try {
      emit(
        state.copyWith(
          load: Load.loading,
        ),
      );

      final allAuthor = await musicAuthorDataService.getAuthorData();

      emit(
        state.copyWith(
          load: Load.loaded,
          allAuthor: allAuthor,
        ),
      );
    } catch (e) {
      _logger.log(Level.warning, e);
      emit(
        state.copyWith(
          load: Load.error,
          errorMessage:
              "Can't get the list of authors, please try again or try again later",
        ),
      );
    }
  }

  final _logger = Logger();
}
