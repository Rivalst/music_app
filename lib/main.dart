import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:music_app/common/bloc_observer.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:music_app/data/data.dart';

import 'app_config/app_config.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  Bloc.observer = Observer();

  await Hive.initFlutter();
  Hive
    ..registerAdapter(MusicModelAdapter())
    ..registerAdapter(AuthorModelAdapter());
  
  runApp(const App());
}
