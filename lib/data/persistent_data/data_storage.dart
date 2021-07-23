import 'dart:convert';

import 'package:miru/data/cache.dart';
import 'package:miru/data/persistent_data/pinmark.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../structures/anime_details.dart';

SharedPreferences? sharedPreferences;

List<Pin> pinned = [];

void save() {
  if (sharedPreferences == null) return;
  print("Saving: " + jsonEncode(pinned));
  sharedPreferences!.setString("pinned", jsonEncode(pinned));
}

void load() async {
  if (sharedPreferences == null)
    sharedPreferences = await SharedPreferences.getInstance();
  String? pref = sharedPreferences!.getString("pinned");
  try {
    List<dynamic> data = jsonDecode(pref!) as List<dynamic>;
    pinned = [for (var pin in data) Pin.fromJson(pin)];
  } catch (e) {
    print("Error: " + e.toString());
    sharedPreferences!.clear();
    sharedPreferences!.setString("pinned", "[]");
    pinned = [];
  }
  print("Loaded Pinned: " + pinned.toString());
}

void addPin(String url, String title, String image) {
  pinned.add(Pin(
      url: url,
      title: title,
      image: image,
      episodes: List.empty(growable: true)));
  while (pinned.length > 50) {
    pinned.removeAt(0);
  }
  save();
}

void removePin(String url) {
  int index = pinned.indexWhere((Pin pin) => pin.url == url);
  removePinAt(index);
}

void removePinAt(int index) async {
  pinned.removeAt(index);
  save();
}

void togglePin(String url, String title, String image) {
  if (pinned.indexWhere((Pin pin) => pin.url == url) == -1) {
    addPin(url, title, image);
  } else {
    removePin(url);
  }
}

bool isPinned(String url) =>
    pinned.indexWhere((Pin pin) => pin.url == url) != -1;

void addEpisode(String url, AnimeDetails anime,
    {int timeMs = 0, int totalTime = 10}) {
  if (!isPinned(anime.url)) {
    addPin(anime.url, anime.name, anime.image);
  }
  int animeIndex = pinned.indexWhere((Pin pin) => pin.url == anime.url);
  pinned[animeIndex]
      .episodes
      .add(Bookmark(url: url, duration: totalTime, position: timeMs));
  save();
}

void updateEpisodeTime(
    String animeUrl, String url, int newTimeMs, int totalTimeMs) {
  int animeIndex = pinned.indexWhere((Pin pin) => pin.url == animeUrl);
  int episodeIndex = pinned[animeIndex]
      .episodes
      .indexWhere((Bookmark bookmark) => bookmark.url == url);
  pinned[animeIndex].episodes[episodeIndex].duration = totalTimeMs;
  pinned[animeIndex].episodes[episodeIndex].position = newTimeMs;
  save();
}

int getEpisodePosition(String animeUrl, String url) {
  int animeIndex = pinned.indexWhere((Pin pin) => pin.url == animeUrl);
  int episodeIndex = pinned[animeIndex]
      .episodes
      .indexWhere((Bookmark bookmark) => bookmark.url == url);
  return pinned[animeIndex].episodes[episodeIndex].position;
}

int getEpisodeDuration(String animeUrl, String url) {
  int animeIndex = pinned.indexWhere((Pin pin) => pin.url == animeUrl);
  int episodeIndex = pinned[animeIndex]
      .episodes
      .indexWhere((Bookmark bookmark) => bookmark.url == url);
  return pinned[animeIndex].episodes[episodeIndex].duration;
}

void removeEpisode(String animeUrl, String url) {
  int animeIndex = pinned.indexWhere((Pin pin) => pin.url == animeUrl);
  pinned[animeIndex]
      .episodes
      .removeWhere((Bookmark bookmark) => bookmark.url == url);
}

void toggleEpisode(String url, AnimeDetails anime) {
  if (isBookmarked(anime.url, url)) {
    removeEpisode(anime.url, url);
  } else {
    addEpisode(url, anime);
  }
}

bool isBookmarked(String animeUrl, String url) {
  int animeIndex = pinned.indexWhere((Pin pin) => pin.url == animeUrl);
  if (animeIndex == -1) return false;
  return pinned[animeIndex]
          .episodes
          .indexWhere((Bookmark bookmark) => bookmark.url == url) !=
      -1;
}

void clearAll() {
  pinned.clear();
  save();
  Cache.loadedDetails.clear();
  Cache.loadedVideos.clear();
}
