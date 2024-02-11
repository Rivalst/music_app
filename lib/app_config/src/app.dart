import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:music_app/common/value.dart';

import 'package:music_app/common/widgets.dart';
import 'package:music_app/data/data.dart';
import 'package:music_app/favorites/favorites.dart';
import 'package:music_app/home/home.dart';

import 'controller/bloc.dart';

/// Represents the root widget of the application.
/// Initializes the App widget.
/// Builds the UI for the App widget using MultiBlocProvider to provide
/// multiple blocs to the widget tree.
/// Provides ScreenBloc, HomeBloc, and FavoritesBloc using BlocProvider.
class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => ScreenBloc(),
        ),
        BlocProvider(
          create: (context) => HomeBloc(
            musicAuthorDataService: MusicAuthorDataService(),
          ),
        ),
        BlocProvider(
          create: (context) => FavoritesBloc(
            trackDataService: TrackDataService(),
          ),
        ),
      ],
      child: MaterialApp(
        theme: ThemeData(
          useMaterial3: true,
        ),
        debugShowCheckedModeBanner: false,
        home: BlocBuilder<ScreenBloc, ScreenState>(
          builder: (context, stateScreen) {
            // load authors
            final homeBloc = context.read<HomeBloc>();
            if (homeBloc.state.allAuthor.isEmpty &&
                homeBloc.state.load != Load.error) {
              homeBloc.add(
                AllAuthorLoaded(),
              );
            }

            // load favorites
            final favoritesBloc = context.read<FavoritesBloc>();
            if (favoritesBloc.state.favorites.isEmpty &&
                favoritesBloc.state.load != Load.error) {
              favoritesBloc.add(
                FavoritesLoaded(),
              );
            }
            return Scaffold(
              body: SelectedScreen(
                screen: stateScreen.screen,
              ),
              floatingActionButton:
                  FloatingActionButtons(screen: stateScreen.screen),
              floatingActionButtonLocation:
                  FloatingActionButtonLocation.centerDocked,
              bottomNavigationBar: const BottomBar(),
            );
          },
        ),
      ),
    );
  }
}
