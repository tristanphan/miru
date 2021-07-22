import 'dart:async';

import 'package:easy_dynamic_theme/easy_dynamic_theme.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'data/anime.dart';
import 'data/data_storage.dart';
import 'navigator.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Anime.view.run();
  await getPrefs();
  runApp(EasyDynamicThemeWidget(child: MyApp()));
}

Future<Null> getPrefs() async {
  SharedPreferences sharedPrefs = await SharedPreferences.getInstance();
  data = sharedPrefs;
  if (sharedPrefs.containsKey("pinnedURLs")) {
    pinnedURLs.addAll(sharedPrefs.getStringList("pinnedURLs")!);
  }
  if (sharedPrefs.containsKey("pinnedImages")) {
    pinnedImages.addAll(sharedPrefs.getStringList("pinnedImages")!);
  }
  if (sharedPrefs.containsKey("pinnedNames")) {
    pinnedNames.addAll(sharedPrefs.getStringList("pinnedNames")!);
  }
  if (sharedPrefs.containsKey("bookmarkedEpisodes")) {
    bookmarkedEpisodes.addAll(sharedPrefs.getStringList("bookmarkedEpisodes")!);
  }
  if (sharedPrefs.containsKey("bookmarkedEpisodeTimes")) {
    bookmarkedEpisodeTimes
        .addAll(sharedPrefs.getStringList("bookmarkedEpisodeTimes")!);
  }
  if (sharedPrefs.containsKey("bookmarkedEpisodeLength")) {
    bookmarkedEpisodeLength
        .addAll(sharedPrefs.getStringList("bookmarkedEpisodeLength")!);
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: "Miru",
        theme: ThemeData.light(),
        darkTheme: ThemeData.dark(),
        themeMode: EasyDynamicTheme.of(context).themeMode,
        home: Navigation());
  }
}
