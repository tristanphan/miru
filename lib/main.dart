import 'dart:io';

import 'package:easy_dynamic_theme/easy_dynamic_theme.dart';
import 'package:flutter/material.dart';
import 'package:miru/data/persistent_data/data_storage.dart';
import 'package:miru/data/persistent_data/theme.dart';
import 'package:miru/data/sources/sources.dart';
import 'package:miru/data/structures/popular.dart';
import 'package:miru/data/structures/recent_release.dart';
import 'package:miru/navigator.dart';
import 'package:miru/pages/player/functions/video.dart';
import 'package:window_size/window_size.dart';

Future<List<RecentRelease>>? recentlyUpdatedFuture;
Future<List<Popular>>? popularFuture;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (Platform.isWindows || Platform.isLinux) setWindowTitle("Miru");
  await Storage.initialize();
  Storage.load();
  AppTheme.load();
  Sources.load();
  Video.onAppStart();
  recentlyUpdatedFuture = Sources.get().getRecentReleases();
  popularFuture = Sources.get().getPopular();
  runApp(
    EasyDynamicThemeWidget(child: MyApp(), initialThemeMode: AppTheme.theme),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Miru",
      theme: ThemeData(
        switchTheme: SwitchThemeData(
          thumbColor:
              MaterialStateProperty.all(AppTheme.color ?? Colors.blueAccent),
          trackColor: MaterialStateProperty.all(
            (AppTheme.color ?? Colors.blueAccent).withOpacity(0.4),
          ),
        ),
        colorScheme:
            ColorScheme.fromSwatch().copyWith(secondary: AppTheme.color),
      ),
      darkTheme: AppTheme.fullBlack
          ? ThemeData(
              scaffoldBackgroundColor: Colors.black,
              bottomNavigationBarTheme:
                  BottomNavigationBarThemeData(backgroundColor: Colors.black),
              dividerColor: Colors.white38,
              switchTheme: SwitchThemeData(
                thumbColor: MaterialStateProperty.all(
                    AppTheme.color ?? Colors.tealAccent),
                trackColor: MaterialStateProperty.all(
                  (AppTheme.color ?? Colors.tealAccent).withOpacity(0.4),
                ),
              ),
              colorScheme: ColorScheme.fromSwatch().copyWith(
                  secondary: AppTheme.color, brightness: Brightness.dark),
            )
          : ThemeData(
              switchTheme: SwitchThemeData(
                thumbColor: MaterialStateProperty.all(
                    AppTheme.color ?? Colors.tealAccent),
                trackColor: MaterialStateProperty.all(
                  (AppTheme.color ?? Colors.tealAccent).withOpacity(0.4),
                ),
              ),
              colorScheme: ColorScheme.fromSwatch().copyWith(
                  secondary: AppTheme.color, brightness: Brightness.dark),
            ),
      themeMode: EasyDynamicTheme.of(context).themeMode,
      home: Navigation(),
    );
  }
}
