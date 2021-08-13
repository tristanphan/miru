import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:miru/data/persistent_data/bookmark.dart';
import 'package:miru/data/persistent_data/pin.dart';
import 'package:miru/data/persistent_data/theme.dart';
import 'package:miru/data/sources/sources.dart';
import 'package:miru/data/structures/anime_details.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Storage {
  static SharedPreferences? sharedPreferences;

  static List<Pin> pinned = [];

  static void save() {
    print("Saving");
    sharedPreferences!.setString(
      "pinned",
      jsonEncode(pinned),
    );
  }

  static Future<void> initialize() async {
    sharedPreferences = await SharedPreferences.getInstance();
  }

  static void load() {
    String? pref = sharedPreferences!.getString("pinned");
    try {
      List<dynamic> data = jsonDecode(pref!) as List<dynamic>;
      pinned = [
        for (Map<String, dynamic> pin in data) Pin.fromJson(pin),
      ];
    } catch (e) {
      print(
        "Error: " + e.toString(),
      );
      sharedPreferences!.clear();
      sharedPreferences!.setString("pinned", "[]");
      pinned = [];
    }
    print("Loaded Pinned");
  }

  static void addPin(String url, String title, String image) {
    pinned.add(
      Pin(
        url: url,
        title: title,
        image: image,
        episodes: List.empty(growable: true),
        source: Sources.getName(),
      ),
    );
    while (pinned.length > 50) {
      pinned.removeAt(0);
    }
    save();
  }

  static void removePin(String url) {
    int index = pinned.indexWhere((Pin pin) => pin.url == url);
    removePinAt(index);
  }

  static void removePinAt(int index) async {
    pinned.removeAt(index);
    save();
  }

  static void togglePin(String url, String title, String image) {
    if (pinned.indexWhere((Pin pin) => pin.url == url) == -1) {
      addPin(url, title, image);
    } else {
      removePin(url);
    }
  }

  static bool isPinned(String url) =>
      pinned.indexWhere((Pin pin) => pin.url == url) != -1;

  static void addEpisode(String url, AnimeDetails anime,
      {int timeMs = 0, int totalTime = 10}) {
    if (!isPinned(anime.url)) {
      addPin(anime.url, anime.name, anime.image);
    }
    int animeIndex = pinned.indexWhere((Pin pin) => pin.url == anime.url);
    pinned[animeIndex].episodes.add(
          Bookmark(url: url, duration: totalTime, position: timeMs),
        );
    save();
  }

  static void updateEpisodeTime(
      String animeUrl, String url, int newTimeMs, int totalTimeMs) {
    int animeIndex = pinned.indexWhere((Pin pin) => pin.url == animeUrl);
    int episodeIndex = pinned[animeIndex]
        .episodes
        .indexWhere((Bookmark bookmark) => bookmark.url == url);
    pinned[animeIndex].episodes[episodeIndex].duration = totalTimeMs;
    pinned[animeIndex].episodes[episodeIndex].position = newTimeMs;
    save();
  }

  static int getEpisodePosition(String animeUrl, String url) {
    int animeIndex = pinned.indexWhere((Pin pin) => pin.url == animeUrl);
    int episodeIndex = pinned[animeIndex]
        .episodes
        .indexWhere((Bookmark bookmark) => bookmark.url == url);
    return pinned[animeIndex].episodes[episodeIndex].position;
  }

  static int getEpisodeDuration(String animeUrl, String url) {
    int animeIndex = pinned.indexWhere((Pin pin) => pin.url == animeUrl);
    int episodeIndex = pinned[animeIndex]
        .episodes
        .indexWhere((Bookmark bookmark) => bookmark.url == url);
    return pinned[animeIndex].episodes[episodeIndex].duration;
  }

  static void removeEpisode(String animeUrl, String url) {
    int animeIndex = pinned.indexWhere((Pin pin) => pin.url == animeUrl);
    pinned[animeIndex]
        .episodes
        .removeWhere((Bookmark bookmark) => bookmark.url == url);
  }

  static void toggleEpisode(String url, AnimeDetails anime) {
    if (isBookmarked(anime.url, url)) {
      removeEpisode(anime.url, url);
    } else {
      addEpisode(url, anime);
    }
  }

  static bool isBookmarked(String animeUrl, String url) {
    int animeIndex = pinned.indexWhere((Pin pin) => pin.url == animeUrl);
    if (animeIndex == -1) return false;
    return pinned[animeIndex]
            .episodes
            .indexWhere((Bookmark bookmark) => bookmark.url == url) !=
        -1;
  }

  static void clearAll() {
    pinned.clear();
    save();
  }

  static Future<void> reset() async {
    pinned.clear();
    AppTheme.theme = ThemeMode.system;
    AppTheme.color = null;
    AppTheme.fullBlack = false;
    Sources.set(0);
    await sharedPreferences!.clear();
  }
}
