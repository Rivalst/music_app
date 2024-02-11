part of 'bloc.dart';

// Represents the state of artist information
final class InfoState extends Equatable {
  final Load load;
  final List<Map<AlbumModel, List<MusicModel>>> allMusic;
  final String errorMessage;

  const InfoState({
    required this.load,
    required this.allMusic,
    required this.errorMessage,
  });

  InfoState copyWith({
    Load? load,
    List<Map<AlbumModel, List<MusicModel>>>? allMusic,
    String? errorMessage,
  }) {
    return InfoState(
      load: load ?? this.load,
      allMusic: allMusic ?? this.allMusic,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        load,
        allMusic,
        errorMessage,
      ];
}
