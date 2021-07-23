import 'package:easy_dynamic_theme/easy_dynamic_theme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:miru/data/persistent_data/data_storage.dart';

class AppTheme {
  static ThemeMode theme = ThemeMode.system;
  static Color? color;

  static void load() {
    if (Storage.sharedPreferences == null) return;
    String? themePref = Storage.sharedPreferences!.getString("theme");
    if (themePref == null) {
      Storage.sharedPreferences!.setString("theme", "system");
    }
    if (themePref == "dark")
      theme = ThemeMode.dark;
    else if (themePref == "light")
      theme = ThemeMode.light;
    else
      theme = ThemeMode.system;
    if (Storage.sharedPreferences!.containsKey("color")) {
      color = Color(Storage.sharedPreferences!.getInt("color")!);
    }
  }

  static void setTheme(BuildContext context, ThemeMode mode) {
    if (Storage.sharedPreferences == null) return;
    theme = mode;

    // Shared Preferences
    String themeString;
    if (theme == ThemeMode.dark)
      themeString = "dark";
    else if (theme == ThemeMode.light)
      themeString = "light";
    else
      themeString = "system";

    Storage.sharedPreferences!.setString("theme", themeString);
    _theme(context);
  }

  static void setColor(BuildContext context, Color? newColor) {
    if (Storage.sharedPreferences == null) return;
    if (newColor == null && Storage.sharedPreferences!.containsKey("color")) {
      Storage.sharedPreferences!.remove("color");
    } else if (newColor != null) {
      Storage.sharedPreferences!.setInt("color", newColor.value);
    }
    color = newColor;
    _theme(context);
  }

  static void _theme(BuildContext context) {
    if (theme == ThemeMode.dark) {
      EasyDynamicTheme.of(context).changeTheme(dark: true, dynamic: false);
    } else if (theme == ThemeMode.light) {
      EasyDynamicTheme.of(context).changeTheme(dark: false, dynamic: false);
    } else {
      EasyDynamicTheme.of(context).changeTheme(dynamic: true);
    }
  }
}
