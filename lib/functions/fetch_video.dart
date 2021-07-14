import 'dart:async';

import 'package:miru/data/anime.dart';
import 'package:miru/data/structures/video_details.dart';

Completer<String> errorVideoUrl = Completer<String>();

Future<VideoDetails?> animeVideo(String url, Function changeProgress) async {
  errorVideoUrl = Completer<String>();
  print("Getting Video URL: " + url);

  changeProgress("Loading Episode URL");
  await Anime.load(url);
  print(
    "Loaded: " + (await Anime.controller!.getUrl()).toString(),
  );

  int errorCount = 0;
  while ((await Anime.controller!.getUrl()).toString() != url) {
    errorCount += 1;
    print("Error: URL changed incorrectly!");
    await Anime.load(url);
    if (errorCount > 100) return null;
  }
  print(
    "Loaded: " + (await Anime.controller!.getUrl()).toString(),
  );

  return _crawl(changeProgress);
}

Future<VideoDetails?> _crawl(Function changeProgress) async {
  String? title = await Anime.evaluate(
      "document.querySelector('div.title_name > h2').textContent.trim()");
  int errorCount = 0;
  while (title == null) {
    errorCount += 1;
    Future.delayed(
      Duration(milliseconds: 10),
    );
    title = await Anime.evaluate(
        "document.querySelector('div.title_name > h2').textContent.trim()");
    if (errorCount > 100) return null;
  }

  // Get Last Episode
  List<String> last = [];
  if (await Anime.evaluate(
          "document.querySelectorAll('div.anime_video_body_episodes_l > a').length") ==
      1) {
    String lastName = await Anime.evaluate(
        "document.querySelector('div.anime_video_body_episodes_l > a').text.trim()");
    String lastURL = await Anime.evaluate(
        "document.querySelector('div.anime_video_body_episodes_l > a').href.trim()");
    last.add(
      lastName.substring(3),
    );
    last.add(lastURL);
  }

  // Get Next Episode
  List<String> next = [];
  if (await Anime.evaluate(
          "document.querySelectorAll('div.anime_video_body_episodes_r > a').length") ==
      1) {
    String nextName = await Anime.evaluate(
        "document.querySelector('div.anime_video_body_episodes_r > a').text.trim()");
    String nextURL = await Anime.evaluate(
        "document.querySelector('div.anime_video_body_episodes_r > a').href.trim()");
    next.add(
      nextName.substring(0, nextName.length - 3),
    );
    next.add(nextURL);
  }

  // Get URL of iframe and load it
  var newURL = await Anime.evaluate(
      "document.querySelector('div.play-video > iframe').src");
  if (newURL == null) return null;
  newURL = newURL.replaceAll("streaming", "loadserver");
  changeProgress("Loading Video Player URL");
  errorVideoUrl.complete(newURL);
  await Anime.load(newURL);

  String url;
  try {
    url = await Anime.evaluate("document.body.outerHTML");
    url = url.split("sources:[{file: '")[1];
    url = url.split("',")[0];
    changeProgress("Preparing Video Player");
    print("Video URL: " + url);
    if (!url.startsWith("ht")) return null;
  } catch (error) {
    return null;
  }

  return VideoDetails(title: title, url: url, next: next, last: last);
}
