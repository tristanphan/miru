import 'package:shared_preferences/shared_preferences.dart';

import 'anime.dart';
import 'structures/anime_details.dart';
import 'structures/episode.dart';

SharedPreferences? data;

List<String> pinnedURLs = [];
List<String> pinnedImages = [];
List<String> pinnedNames = [];
List<String> markedEpisodes = [];
List<String> markedEpisodeTimes = [];
List<String> markedEpisodeLength = [];


void save() {
  data!.setStringList("markedEpisodes", markedEpisodes);
  data!.setStringList("markedEpisodeTimes", markedEpisodeTimes);
  data!.setStringList("markedEpisodeLength", markedEpisodeLength);
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
    if (isMarked(episode.url)) {
      int index = markedEpisodes.indexOf(episode.url);
      markedEpisodes.removeAt(index);
      markedEpisodeTimes.removeAt(index);
      markedEpisodeLength.removeAt(index);
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
  markedEpisodes.add(url);
  markedEpisodeTimes.add(
    timeMs.toString(),
  );
  markedEpisodeLength.add(
    totalTime.toString(),
  );
  if (!pinnedURLs.contains(anime.url)) {
    pinnedURLs.add(anime.url);
    pinnedNames.add(anime.name);
    pinnedImages.add(anime.image);
  }
  save();
}

void updateEpisodeTime(String url, int newTimeMs, int totalTimeMs) {
  markedEpisodeTimes[markedEpisodes.indexOf(url)] = newTimeMs.toString();
  markedEpisodeLength[markedEpisodes.indexOf(url)] = totalTimeMs.toString();
  save();
}

int getEpisodeTime(String url) {
  return int.parse(markedEpisodeTimes[markedEpisodes.indexOf(url)]);
}

int getEpisodeTotalTime(String url) {
  return int.parse(markedEpisodeLength[markedEpisodes.indexOf(url)]);
}

void removeEpisode(String url) {
  int index = markedEpisodes.indexOf(url);
  removeEpisodeAt(index);
}

void removeEpisodeAt(int index) {
  markedEpisodes.removeAt(index);
  markedEpisodeTimes.removeAt(index);
  markedEpisodeLength.removeAt(index);
  save();
}

void toggleEpisode(String url, AnimeDetails anime) {
  if (markedEpisodes.contains(url)) {
    removeEpisode(url);
  } else {
    addEpisode(url, anime);
  }
}

bool isMarked(String url) {
  return markedEpisodes.contains(url);
}

void clearAll() {
  pinnedURLs.clear();
  pinnedImages.clear();
  pinnedNames.clear();
  markedEpisodes.clear();
  markedEpisodeTimes.clear();
  markedEpisodeLength.clear();
  save();
}
