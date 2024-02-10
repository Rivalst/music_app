import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';

import 'package:music_app/app_config/app_config.dart';
import 'package:music_app/common/extension.dart';
import 'package:music_app/common/value.dart';
import 'package:music_app/data/data.dart';
import 'package:music_app/favorites/favorites.dart';
import 'package:music_app/home/home.dart';

/// Represents a widget for displaying a small view of an author.
/// Uses ImageFactory widget to display the author's image.
class AuthorSmallViewWidget extends StatelessWidget {
  final String imageUrl;
  final String name;

  const AuthorSmallViewWidget({
    required this.imageUrl,
    required this.name,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(kSmallPadding),
      child: Column(
        children: [
          Row(
            children: [
              ImageFactory.small(
                imageUrl: imageUrl,
              ),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Padding(
                  padding: const EdgeInsets.only(left: kMediumPadding),
                  child: Text(
                    name,
                    softWrap: true,
                    style: const TextStyle(
                      fontSize: kMediumFontSize,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const Divider(),
        ],
      ),
    );
  }
}

/// Represents a widget for displaying details of a track.
/// Builds the UI for the TrackViewWidget with details of the track including index, image, name, duration, and favorite icon.
/// Uses ImageFactory widget to display the track's image.
/// Handles favorite button tap events using BlocBuilder<FavoritesBloc, FavoritesState> to add/remove track from favorites.
class TrackViewWidget extends StatelessWidget {
  final int index;
  final MusicModel track;
  final AuthorModel author;
  final String authorImageUrl;

  const TrackViewWidget({
    required this.index,
    required this.track,
    required this.authorImageUrl,
    required this.author,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final duration = context.millisecondsToMinutes(track);

    final smallImage = track.images.firstWhere(
      (image) => image['size'] == 'large',
      orElse: () => {
        '#text': authorImageUrl,
      },
    );
    final imageUrl = smallImage['#text'];

    return BlocBuilder<FavoritesBloc, FavoritesState>(
      builder: (context, state) {
        return Padding(
          padding: const EdgeInsets.all(kSmallPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    Text(
                      '${index + 1}.',
                      style: const TextStyle(fontSize: kSmallFontSize),
                    ),
                    ImageFactory.small(imageUrl: imageUrl),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: kSmallPadding,
                      ),
                      child: Text(
                        track.musicName,
                        style: const TextStyle(
                          fontSize: kMediumFontSize,
                        ),
                      ),
                    ),
                    Text(
                      duration,
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: kMediumFontSize,
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        state.isInFavorites(author, track)
                            ? context.read<FavoritesBloc>().add(
                                  TrackRemovedFromFavorite(
                                    author: author,
                                    track: track,
                                  ),
                                )
                            : context.read<FavoritesBloc>().add(
                                  TrackAddedToFavorite(
                                    author: author,
                                    track: track,
                                  ),
                                );
                      },
                      icon: state.isInFavorites(author, track)
                          ? const Icon(
                              Icons.favorite,
                              color: Colors.red,
                            )
                          : const Icon(
                              Icons.favorite_outline,
                            ),
                    )
                  ],
                ),
              ),
              const Divider(),
            ],
          ),
        );
      },
    );
  }
}

/// Represents a widget for displaying an image with customizable size
/// Initializes the ImageFactory widget with required parameters: imageUrl, weight, and height
/// Factory constructor for creating a small-sized image widget
/// Factory constructor for creating a big-sized image widget
class ImageFactory extends StatelessWidget {
  final String imageUrl;
  final double weight;
  final double height;

  const ImageFactory({
    required this.height,
    required this.weight,
    required this.imageUrl,
    super.key,
  });

  factory ImageFactory.small({required String imageUrl}) {
    return ImageFactory(
      height: kSmallImageSize,
      weight: kSmallImageSize,
      imageUrl: imageUrl,
    );
  }

  factory ImageFactory.big({required String imageUrl}) {
    return ImageFactory(
      height: kBigImageSize,
      weight: kBigImageSize,
      imageUrl: imageUrl,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: kSmallPadding,
      ),
      child: Card(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(kSmallBorderRadius),
          child: Image.network(
            imageUrl,
            width: weight,
            height: height,
            errorBuilder: (
              BuildContext context,
              Object error,
              StackTrace? stackTrace,
            ) {
              return SizedBox(
                width: weight,
                height: height,
                child: const Card(
                  child: Icon(Icons.music_note),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

/// Represents a widget for the bottom bar at the bottom of the screen
/// Builds the UI for the SelectedScreen widget using 
/// AnimatedSwitcher to switch between home and favorites screens based on the selected screen
class BottomBar extends StatelessWidget {
  const BottomBar({super.key});

  @override
  Widget build(BuildContext context) {
    return const BottomAppBar(
      height: kBottomBarHeight,
      padding: EdgeInsets.all(0),
      color: Colors.white,
      shadowColor: Colors.white,
      surfaceTintColor: Colors.white,
      child: Align(
        alignment: Alignment.topCenter,
        child: Divider(
          color: Colors.black,
          height: 0,
        ),
      ),
    );
  }
}

class SelectedScreen extends StatelessWidget {
  final Screens screen;

  const SelectedScreen({super.key, required this.screen});

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: switch (screen) {
        Screens.home => const HomeScreen(),
        Screens.favorites => const FavoritesScreen(),
      },
    );
  }
}

/// Represents a widget for floating action buttons to navigate between screens
class FloatingActionButtons extends StatelessWidget {
  final Screens screen;

  const FloatingActionButtons({
    required this.screen,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          onPressed: () => context.read<ScreenBloc>().add(
                ScreenChanged(
                  selectedScreen: Screens.home,
                ),
              ),
          icon: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              border: Border.all(
                color: Colors.black,
                width: kSmallBorderWidth,
              ),
            ),
            padding: const EdgeInsets.all(kSmallPadding),
            child: Icon(
              Icons.home,
              color: screen == Screens.home ? Colors.orange : Colors.black,
            ),
          ),
        ),
        const MaxGap(kMediumPadding),
        IconButton(
          onPressed: () {
            context.read<ScreenBloc>().add(
                  ScreenChanged(
                    selectedScreen: Screens.favorites,
                  ),
                );
          },
          icon: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              border: Border.all(
                color: Colors.black,
                width: kSmallBorderWidth,
              ),
            ),
            padding: const EdgeInsets.all(kSmallPadding),
            child: Icon(
              Icons.favorite,
              color: screen == Screens.favorites ? Colors.red : Colors.black,
            ),
          ),
        ),
      ],
    );
  }
}
