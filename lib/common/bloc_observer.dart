import 'package:bloc/bloc.dart';
import 'package:logger/logger.dart';

/// Basic observer for tracking activities in any BLoC
class Observer extends BlocObserver {
  final logger = Logger();

  // tracking when event sended to BLoC
  @override
  void onEvent(Bloc bloc, Object? event) {
    super.onEvent(bloc, event);
    logger.i('$event sent to bloc $bloc');
  }

  // tracking transition in BLoC
  @override
  void onTransition(Bloc bloc, Transition transition) {
    super.onTransition(bloc, transition);
    logger.i('State transition in bloc $bloc: $transition');
  }

  // tracking any state changes in BLoC
  @override
  void onChange(BlocBase bloc, Change change) {
    super.onChange(bloc, change);
    logger.i('State changed in bloc $bloc: $change');
  }

  // tracking error in BLoC
  @override
  void onError(BlocBase bloc, Object error, StackTrace stackTrace) {
    super.onError(bloc, error, stackTrace);
    logger.e('Error in bloc ${bloc.runtimeType}: $error, $stackTrace');
  }
}