import 'package:shared_preferences/shared_preferences.dart';

import 'anime.dart';
import 'structures/anime_details.dart';
import 'structures/episode.dart';

SharedPreferences? data;

List<String> pinnedURLs = [];
List<String> pinnedImages = [];
List<String> pinnedNames = [];
List<String> bookmarkedEpisodes = [];
List<String> bookmarkedEpisodeTimes = [];
List<String> bookmarkedEpisodeLength = [];

void save() {
  data!.setStringList("bookmarkedEpisodes", bookmarkedEpisodes);
  data!.setStringList("bookmarkedEpisodeTimes", bookmarkedEpisodeTimes);
  data!.setStringList("bookmarkedEpisodeLength", bookmarkedEpisodeLength);
  data!.setStringList("pinnedURLs", pinnedURLs);
  data!.setStringList("pinnedNames", pinnedNames);
  data!.setStringList("pinnedImages", pinnedImages);
}

void addPin(String url, String title, String image) {
  pinnedURLs.add(url);
  pinnedNames.add(title);
  pinnedImages.add(image);
  save();
}

void removePin(String url) {
  int index = pinnedURLs.indexOf(url);
  removePinAt(index);
}

void removePinAt(int index) async {
  String url = pinnedURLs[index];
  pinnedURLs.removeAt(index);
  pinnedNames.removeAt(index);
  pinnedImages.removeAt(index);
  AnimeDetails details = await Anime.getDetails(url);
  for (Episode episode in details.episodes)
    if (isBookmarked(episode.url)) {
      int index = bookmarkedEpisodes.indexOf(episode.url);
      bookmarkedEpisodes.removeAt(index);
      bookmarkedEpisodeTimes.removeAt(index);
      bookmarkedEpisodeLength.removeAt(index);
    }

  save();
}

void togglePin(String url, String title, String image) {
  if (pinnedURLs.contains(url)) {
    removePin(url);
  } else {
    addPin(url, title, image);
  }
}

bool isPinned(String url) {
  return pinnedURLs.contains(url);
}

void addEpisode(String url, AnimeDetails anime) {
  addEpisodeWithTime(url, anime, 0, 10);
}

void addEpisodeWithTime(
    String url, AnimeDetails anime, int timeMs, int totalTime) {
  bookmarkedEpisodes.add(url);
  bookmarkedEpisodeTimes.add(timeMs.toString());
  bookmarkedEpisodeLength.add(totalTime.toString());
  if (!pinnedURLs.contains(anime.url)) {
    pinnedURLs.add(anime.url);
    pinnedNames.add(anime.name);
    pinnedImages.add(anime.image);
  }
  save();
}

void updateEpisodeTime(String url, int newTimeMs, int totalTimeMs) {
  bookmarkedEpisodeTimes[bookmarkedEpisodes.indexOf(url)] =
      newTimeMs.toString();
  bookmarkedEpisodeLength[bookmarkedEpisodes.indexOf(url)] =
      totalTimeMs.toString();
  save();
}

int getEpisodeTime(String url) {
  return int.parse(bookmarkedEpisodeTimes[bookmarkedEpisodes.indexOf(url)]);
}

int getEpisodeTotalTime(String url) {
  return int.parse(bookmarkedEpisodeLength[bookmarkedEpisodes.indexOf(url)]);
}

void removeEpisode(String url) {
  int index = bookmarkedEpisodes.indexOf(url);
  removeEpisodeAt(index);
}

void removeEpisodeAt(int index) {
  bookmarkedEpisodes.removeAt(index);
  bookmarkedEpisodeTimes.removeAt(index);
  bookmarkedEpisodeLength.removeAt(index);
  save();
}

void toggleEpisode(String url, AnimeDetails anime) {
  if (bookmarkedEpisodes.contains(url)) {
    removeEpisode(url);
  } else {
    addEpisode(url, anime);
  }
}

bool isBookmarked(String url) {
  return bookmarkedEpisodes.contains(url);
}

void clearAll() {
  pinnedURLs.clear();
  pinnedImages.clear();
  pinnedNames.clear();
  bookmarkedEpisodes.clear();
  bookmarkedEpisodeTimes.clear();
  bookmarkedEpisodeLength.clear();
  save();
}
