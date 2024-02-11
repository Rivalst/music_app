import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:music_app/artist_info/src/screen.dart';
import 'package:music_app/common/value.dart';
import 'package:music_app/common/widgets.dart';
import 'package:music_app/favorites/favorites.dart';

import 'controller/bloc.dart';

// Represents the home screen of the application, which is a StatefulWidget.
// It displays a list of authors fetched from a BlocBuilder<HomeBloc, HomeState>
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeBloc, HomeState>(
      builder: (context, state) {
        // load authors
        if (state.allAuthor.isEmpty && state.load != Load.error) {
          context.read<HomeBloc>().add(
                AllAuthorLoaded(),
              );
        }

        final favoritesBloc = context.read<FavoritesBloc>();
        if (favoritesBloc.state.favorites.isEmpty && favoritesBloc.state.load != Load.error) {
          context.read<FavoritesBloc>().add(
                FavoritesLoaded(),
              );
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('Home'),
            bottom: const PreferredSize(
              preferredSize: Size.fromHeight(kSmallDividerHeight),
              child: Divider(),
            ),
            backgroundColor: Colors.white,
            surfaceTintColor: Colors.grey,
          ),
          body: _buildScreen(state: state),
        );
      },
    );
  }

  // Builds the UI for the HomeScreen based on the current state
  Widget _buildScreen({required HomeState state}) {
    return switch (state.load) {
      Load.loading => _buildLoading(),
      Load.loaded => _buildLoaded(state),
      Load.error => _buildError(state),
    };
  }

  // Builds the loading indicator when data is being fetched
  Widget _buildLoading() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  // Builds the list of authors when data is successfully loaded
  Widget _buildLoaded(HomeState state) {
    return Padding(
      padding: const EdgeInsets.all(kMediumPadding),
      child: ListView.builder(
        key: const PageStorageKey<String>('pageOne'),
        itemCount: state.allAuthor.length,
        itemBuilder: (BuildContext context, int index) {
          final author = state.allAuthor[index];
          final authorName = author.authorName;
          final authorImages = author.images;
          final largeImage = authorImages.firstWhere(
            (image) => image['size'] == 'large',
          );
          final imageUrl = largeImage['#text'];

          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ArtistInfo(
                    author: author,
                  ),
                ),
              );
            },
            child: AuthorSmallViewWidget(
              imageUrl: imageUrl,
              name: authorName,
            ),
          );
        },
      ),
    );
  }

  // Builds the error UI when there's a failure in loading data
  Widget _buildError(HomeState state) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            state.errorMessage,
            style: const TextStyle(fontSize: kMediumFontSize),
          ),
          TextButton(
            onPressed: () => context.read<HomeBloc>().add(AllAuthorLoaded()),
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
