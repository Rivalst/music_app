import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:music_app/app_config/app_config.dart';
import 'package:music_app/common/value.dart';
import 'package:music_app/common/widgets.dart';
import 'package:music_app/favorites/favorites.dart';

// Represents the FavoritesScreen, a StatefulWidget for displaying favorite authors and tracks
class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  @override
  Widget build(BuildContext context) {
    final appBloc = context.read<ScreenBloc>();

    return BlocBuilder<FavoritesBloc, FavoritesState>(
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Favorite'),
            leading: IconButton(
              icon: const Icon(
                Icons.keyboard_arrow_left,
              ),
              onPressed: () => appBloc.add(
                ScreenChanged(
                  selectedScreen: Screens.home,
                ),
              ),
            ),
            backgroundColor: Colors.white,
            surfaceTintColor: Colors.grey,
          ),
          body: _buildScreen(state),
        );
      },
    );
  }

  // Builds the UI for the HomeScreen based on the current state
  Widget _buildScreen(FavoritesState state) {
    return switch (state.load) {
      Load.loading => _buildLoading(),
      Load.loaded => _buildLoaded(state),
      Load.error => _buildError(),
    };
  }

  // Builds the loading indicator when data is being fetched
  Widget _buildLoading() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  // Builds the list of authors when data is successfully loaded
  Widget _buildLoaded(FavoritesState state) {
    return state.favorites.isEmpty
        ? const Center(
            child: Text('Add tracks to favorite on the Home screen'),
          )
        : ListView.builder(
            itemCount: state.favorites.length,
            itemBuilder: (
              BuildContext context,
              int index,
            ) {
              final favorites = state.favorites;
              final authorInfo = favorites[index];
              final author = authorInfo.keys.first;
              final tracks = authorInfo.values.first;

              final authorImages = author.images;

              final image = authorImages.firstWhere(
                (image) => image['size'] == 'mega',
              );

              final imageUrl = image['#text'];

              return Column(
                children: [
                  AuthorSmallViewWidget(
                    imageUrl: imageUrl,
                    name: author.authorName,
                  ),
                  for (var i = 0; i < tracks.length; i++)
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 40,
                        vertical: kSmallPadding,
                      ),
                      child: TrackViewWidget(
                        index: i,
                        track: tracks[i],
                        authorImageUrl: imageUrl,
                        author: author,
                      ),
                    )
                ],
              );
            },
          );
  }

  // Builds the error UI when there's a failure in loading data
  Widget _buildError() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Cannot load favorites. Please try again or restart the app',
            style: TextStyle(fontSize: kMediumFontSize),
          ),
          TextButton(
            onPressed: () => context.read<FavoritesBloc>().add(
                  FavoritesLoaded(),
                ),
            child: const Text(
              'Try again',
              style: TextStyle(fontSize: kLargeFontSize),
            ),
          )
        ],
      ),
    );
  }
}
