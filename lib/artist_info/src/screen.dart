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
          if (state.allMusic.isEmpty) {
            context.read<InfoBloc>().add(
                  AllTrackLoaded(
                    authorName: authorName,
                  ),
                );
          }

          return Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.white,
              surfaceTintColor: Colors.grey,
            ),
            body: Padding(
              padding: const EdgeInsets.all(kMediumPadding),
              child: ListView(
                children: [
                  Image.network(imageUrl),
                  Center(
                    child: Text(
                      authorName,
                      style: const TextStyle(fontSize: kLargeFontSize),
                    ),
                  ),
                  _buildScreen(
                    state,
                    imageUrl,
                    widget.author,
                  )
                ],
              ),
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
  ) {
    return switch (state.load) {
      Load.loading => _buildLoading(),
      Load.loaded => _buildLoaded(
          state,
          authorImageUrl,
          author,
        ),
      Load.error => _buildError(author, state),
    };
  }

  // Builds the loading indicator when data is being fetched
  Widget _buildLoading() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(kSmallPadding),
        child: Column(
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
    return Column(
      children: [
        for (int i = 0; i < state.allMusic.length; i++)
          TrackViewWidget(
            index: i,
            track: state.allMusic[i],
            authorImageUrl: authorImageUrl,
            author: author,
          ),
      ],
    );
  }

  // Builds the error UI when there's a failure in loading data
  Widget _buildError(
    AuthorModel author,
    InfoState state,
  ) {
    return Center(
      child: Column(
        children: [
          Text(
            state.errorMessage,
            style: const TextStyle(fontSize: kMediumFontSize),
          ),
          TextButton(
            onPressed: () => context.read<InfoBloc>().add(AllTrackLoaded(
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
