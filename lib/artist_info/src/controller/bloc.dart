import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:logger/logger.dart';

import 'package:music_app/common/value.dart';
import 'package:music_app/data/data.dart';

part 'event.dart';
part 'state.dart';

// Represents the business logic component (Bloc) for managing state related to artist information
// Initializes the InfoBloc with MusicAuthorDataService and initial state
// Handles the AllTrackLoaded event by loading all tracks for the specified author asynchronously
class InfoBloc extends Bloc<InfoEvent, InfoState> {
  final MusicAuthorDataService musicAuthorDataService;

  InfoBloc({required this.musicAuthorDataService})
      : super(
          const InfoState(
            load: Load.loading,
            allMusic: [],
            errorMessage: '',
          ),
        ) {
    on<AllTrackLoaded>(_allTrackLoad);
  }

  Future<void> _allTrackLoad(
    AllTrackLoaded event,
    Emitter<InfoState> emit,
  ) async {
    try {
      emit(
        state.copyWith(
          load: Load.loading,
        ),
      );

      final allMusic =
          await musicAuthorDataService.getMusicData(event.authorName);

      emit(
        state.copyWith(
          load: Load.loaded,
          allMusic: allMusic,
        ),
      );
    } catch (e) {
      _logger.log(Level.warning, e);
      emit(
        state.copyWith(
          load: Load.error,
          errorMessage:
              "Can't get the list of music, please try again or try again later",
        ),
      );
    }
  }

  final _logger = Logger();
}
