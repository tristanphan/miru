import 'package:easy_dynamic_theme/easy_dynamic_theme.dart';
import 'package:flutter/material.dart';

import 'data/anime.dart';
import 'data/persistent_data/data_storage.dart';
import 'navigator.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  load();
  await Anime.view.run();
  runApp(EasyDynamicThemeWidget(child: MyApp()));
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
