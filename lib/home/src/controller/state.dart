part of 'bloc.dart';

// Represents the state of the home screen with information about data loading status,
// list of authors, and error message
final class HomeState extends Equatable {
  final Load load;
  final List<AuthorModel> allAuthor;
  final String errorMessage;

  const HomeState({
    required this.load,
    required this.allAuthor,
    required this.errorMessage,
  });

  HomeState copyWith({
    Load? load,
    List<AuthorModel>? allAuthor,
    String? errorMessage,
  }) {
    return HomeState(
      load: load ?? this.load,
      allAuthor: allAuthor == null
          ? this.allAuthor
          : [
              ...this.allAuthor,
              ...allAuthor,
            ],
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        load,
        allAuthor,
        errorMessage,
      ];
}
