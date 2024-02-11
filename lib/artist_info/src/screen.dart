import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:music_app/common/value.dart';
import 'package:music_app/common/widgets.dart';
import 'package:music_app/data/data.dart';

import 'controller/bloc.dart';

/// Represents a StatefulWidget for displaying detailed information about an artist
class ArtistInfo extends StatefulWidget {
  final AuthorModel author;

  const ArtistInfo({required this.author, super.key});

  @override
  State<ArtistInfo> createState() => _ArtistInfoState();
}

class _ArtistInfoState extends State<ArtistInfo> {
  @override
  Widget build(BuildContext context) {
    final authorName = widget.author.authorName;

    final authorImages = widget.author.images;

    final image = authorImages.firstWhere(
      (image) => image['size'] == 'mega',
    );

    final imageUrl = image['#text'];

    return BlocProvider<InfoBloc>(
      create: (context) => InfoBloc(
        musicAuthorDataService: MusicAuthorDataService(),
      ),
      child: BlocBuilder<InfoBloc, InfoState>(
        builder: (context, state) {
          if (state.allMusic.isEmpty && state.load != Load.error) {
            context.read<InfoBloc>().add(
                  AllAlbumLoaded(
                    authorName: authorName,
                  ),
                );
          }

          return Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.white,
              surfaceTintColor: Colors.grey,
            ),
            body: _buildScreen(
              state,
              imageUrl,
              widget.author,
              context,
            ),
          );
        },
      ),
    );
  }

  // Builds the UI for the HomeScreen based on the current state
  Widget _buildScreen(
    InfoState state,
    String authorImageUrl,
    AuthorModel author,
    BuildContext context,
  ) {
    return switch (state.load) {
      Load.loading => _buildLoading(),
      Load.loaded => _buildLoaded(
          state,
          authorImageUrl,
          author,
        ),
      Load.error => _buildError(author, state, context),
    };
  }

  // Builds the loading indicator when data is being fetched
  Widget _buildLoading() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(kSmallPadding),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            Padding(
              padding: EdgeInsets.all(kSmallPadding),
              child: Text('Please wait tracks are loading '),
            )
          ],
        ),
      ),
    );
  }

  // Builds the error UI when there's a failure in loading data
  Widget _buildLoaded(
    InfoState state,
    String authorImageUrl,
    AuthorModel author,
  ) {
    return Padding(
      padding: const EdgeInsets.all(kMediumPadding),
      child: ListView.builder(
        itemCount: state.allMusic.length,
        itemBuilder: (BuildContext context, int index) {
          final album = state.allMusic[index];
          final albumInfo = album.keys.first;

          final albumTracks = album.values.first;

          final albumImages = albumInfo.images;
          final largeImage = albumImages.firstWhere(
            (image) => image['size'] == 'large',
          );
          final imageUrl = largeImage['#text'];
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(kBigPadding),
                child: Image.network(imageUrl),
              ),
              AuthorSmallViewWidget(
                imageUrl: authorImageUrl,
                name: author.authorName,
              ),
              for (var i = 0; i < albumTracks.length; i++)
                TrackInAlbumViewWidget(
                  index: i,
                  track: albumTracks[i],
                  author: author,
                ),
            ],
          );
        },
      ),
    );
  }

  // Builds the error UI when there's a failure in loading data
  Widget _buildError(
    AuthorModel author,
    InfoState state,
    BuildContext context,
  ) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            state.errorMessage,
            style: const TextStyle(fontSize: kMediumFontSize),
          ),
          TextButton(
            onPressed: () => context.read<InfoBloc>().add(AllAlbumLoaded(
                  authorName: author.authorName,
                )),
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
