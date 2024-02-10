import 'package:flutter/material.dart';
import 'package:music_app/data/data.dart';

extension Convert on BuildContext {
  String millisecondsToMinutes(MusicModel track) {
    if (track.duration == 'undefined') {
      return '';
    }
    final minutes = int.parse(track.duration) / 60000;
    final minutesToString = minutes.toStringAsFixed(2);
    return minutesToString;
  }
}
