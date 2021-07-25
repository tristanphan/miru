import 'package:flutter/material.dart';
import 'package:miru/data/structures/anime_details.dart';
import 'package:miru/data/structures/episode.dart';
import 'package:miru/data/web.dart';
import 'package:palette_generator/palette_generator.dart';

Future<AnimeDetails> getDetails(String url) async {
  int startTime = DateTime.now().millisecondsSinceEpoch;

  print("Getting Details: " + url);
  Web web = await Web.init(url);
  int count = 0;
  while ((await web.evaluate(
          "document.querySelectorAll('#info > div.info > p').length")) <
      1) {
    await Future.delayed(Duration(milliseconds: 100));
    if (count > 5) {
      await web.evaluate(
          "document.querySelector('div.controls > div.ctl.info').click()");
    }
    print(count);
    count++;
  }
  if ((await web.evaluate(
          "document.querySelectorAll('#info > div.info > p > span').length")) >
      0) {
    if (await web.evaluate(
        "document.querySelector('#info > div.info > p > span').textContent.includes('more')")) {
      await web.evaluate(
          "document.querySelector('#info > div.info > p > span').click()");
    }
  }
  // Hide more button
  await web.evaluate(
      "document.querySelector('#info > div.info > p').removeChild(document.querySelector('#info > div.info > p > span'))");
  String summary = await web
      .evaluate("document.querySelector('#info > div.info > p').textContent");
  String genre = await web.evaluate(
      "document.querySelector('#info > div.info > div.meta > div.col2 > div:nth-child(1) > span').textContent.trim()");
  String released = await web.evaluate(
      "document.querySelector('#info > div.info > div.meta > div.col2 > div:nth-child(2) > span > a').textContent");
  String type = await web.evaluate(
      "document.querySelector('#info > div.info > div.meta > div.col1 > div:nth-child(1) > span').textContent");
  String name = await web
      .evaluate("document.querySelector('#info > div.info > h2').textContent");
  String image = await web
      .evaluate("document.querySelector('#info > div.poster > div > img').src");
  String status = await web.evaluate(
      "document.querySelector('#info > div.info > div.meta > div.col1 > div:nth-child(4) > span').textContent");
  String alias = await web.evaluate(
      "document.querySelector('#info > div.info > div.alias').textContent.trim()");

  await web.load(url);
  int errorCount = 0;
  while (await web.getURL() != url) {
    errorCount += 1;
    print("Error: URL changed incorrectly!");
    await web.load(url);
    if (errorCount > 100) {
      web.destroy();
    }
  }
  count = 0;
  while (
      (await web.evaluate("document.querySelectorAll('ul.episodes').length")) <
          1) {
    await Future.delayed(Duration(milliseconds: 100));
    if (count > 100) {
      await web.reload();
      await web.finishLoading();
      count = 0;
    }
    count++;
  }

  List<Episode> episodes = [];
  var numberOfEpisodes = await web
      .evaluate("document.querySelectorAll('ul.episodes > li > a').length");
  for (int index = 0; index < numberOfEpisodes; index++) {
    String epName = "Episode " +
        await web.evaluate(
            "document.querySelectorAll('ul.episodes > li > a')[$index].textContent");
    String epUrl = await web.evaluate(
        "document.querySelectorAll('ul.episodes > li > a')[$index].href");
    episodes.add(Episode(name: epName, url: epUrl));
  }

  print("Details Loading Time: " +
      ((DateTime.now().millisecondsSinceEpoch - startTime) / 1000)
          .toStringAsFixed(4) +
      " seconds");
  web.destroy();

  return AnimeDetails(
      name: name,
      image: image,
      summary: summary,
      type: type,
      genre: genre,
      released: released,
      status: status,
      alias: alias,
      episodes: episodes,
      url: url,
      palette: await PaletteGenerator.fromImageProvider(NetworkImage(image)));
}
