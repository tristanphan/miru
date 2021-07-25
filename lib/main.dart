import 'package:easy_dynamic_theme/easy_dynamic_theme.dart';
import 'package:flutter/material.dart';
import 'package:miru/data/persistent_data/data_storage.dart';
import 'package:miru/data/persistent_data/theme.dart';
import 'package:miru/navigator.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Storage.initialize();
  Storage.load();
  AppTheme.load();
  runApp(
      EasyDynamicThemeWidget(child: MyApp(), initialThemeMode: AppTheme.theme));
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: "Miru",
        theme: ThemeData(accentColor: AppTheme.color),
        darkTheme:
            ThemeData(brightness: Brightness.dark, accentColor: AppTheme.color),
        themeMode: EasyDynamicTheme.of(context).themeMode,
        home: Navigation());
  }
}
