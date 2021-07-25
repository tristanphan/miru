import 'dart:async';

import 'package:miru/data/structures/video_details.dart';
import 'package:miru/data/web.dart';

Completer<String> errorVideoUrl = Completer<String>();

Future<VideoDetails?> getVideo(String url, Function changeProgress) async {
  int startTime = DateTime.now().millisecondsSinceEpoch;
  errorVideoUrl = Completer<String>();

  print("Getting Video URL: " + url);

  changeProgress("Loading Episode URL");
  Web web = await Web.init(url);
  int errorCount = 0;
  int count = 0;
  while (
      (await web.evaluate("document.querySelectorAll('div.server').length")) <
          1) {
    await Future.delayed(Duration(milliseconds: 100));
    if (errorCount > 5) return null;
    if (count > 100) {
      await web.reload();
      await web.finishLoading();
      errorCount++;
      count = 0;
    }
    count++;
  }

  String title =
      await web.evaluate("document.querySelector('h1.title').textContent");

  var numberOfEpisodes = await web
      .evaluate("document.querySelectorAll('ul.episodes > li > a').length");
  List<String> lastEpisode = [];
  List<String> nextEpisode = [];
  for (int index = 0; index < numberOfEpisodes; index++) {
    if (await web.evaluate(
        "document.querySelectorAll('ul.episodes > li > a')[$index].className === 'active'")) {
      if (index - 1 >= 0) {
        lastEpisode.add("Episode " +
            await web.evaluate(
                "document.querySelectorAll('ul.episodes > li > a')[${index - 1}].text"));
        lastEpisode.add("Episode " +
            await web.evaluate(
                "document.querySelectorAll('ul.episodes > li > a')[${index - 1}].href"));
      }
      if (index + 1 < numberOfEpisodes) {
        nextEpisode.add("Episode " +
            await web.evaluate(
                "document.querySelectorAll('ul.episodes > li > a')[${index + 1}].text"));
        nextEpisode.add("Episode " +
            await web.evaluate(
                "document.querySelectorAll('ul.episodes > li > a')[${index + 1}].href"));
      }
    }
  }

  await web.evaluate("document.querySelector('#server40 > input').click()");

  while ((await web.evaluate(
              "document.querySelectorAll('#player > iframe').length") <
          1 ||
      !(await web.evaluate(
          "document.querySelector('#player > iframe').src.includes('streamtape')")))) {
    await Future.delayed(Duration(milliseconds: 100));
    if (errorCount > 5) return null;
    if (count > 100) {
      await web.reload();
      await web.finishLoading();
      errorCount++;
      count = 0;
    }
    count++;
  }

  String iframeURL =
      await web.evaluate("document.querySelector('#player > iframe').src");
  errorVideoUrl.complete(iframeURL);
  changeProgress("Loading Video Player URL");

  await web.load(iframeURL);
  errorCount = 0;
  while (await web.getURL() != iframeURL) {
    errorCount += 1;
    print("Error: URL changed incorrectly!");
    await web.load(iframeURL);
    if (errorCount > 100) {
      web.destroy();
      return null;
    }
  }

  String videoURL =
      await web.evaluate("document.querySelector('#videolink').textContent");
  if (videoURL.startsWith("//")) videoURL = "http:" + videoURL;
  await web.load(videoURL);
  await Future.delayed(Duration(milliseconds: 20));
  videoURL = await web.getURL();

  print(videoURL);

  print("Video Loading Time: " +
      ((DateTime.now().millisecondsSinceEpoch - startTime) / 1000)
          .toStringAsFixed(4) +
      " seconds");
  web.destroy();

  return VideoDetails(
      title: title, url: videoURL, next: nextEpisode, last: lastEpisode);
}
