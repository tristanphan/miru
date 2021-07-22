import 'dart:async';

import 'package:miru/data/anime.dart';
import 'package:miru/data/structures/anime_details.dart';
import 'package:miru/data/structures/episode.dart';

Future<AnimeDetails> animeDetails(String url) async {
  print("Getting Details: " + url);

  await Anime.load(url);
  while ((await Anime.controller!.getUrl()).toString() != url) {
    await Anime.load(url);
  }

  // Properties
  String name =
      await Anime.evaluate("document.querySelector('h1').textContent.trim()");
  String summary = "";
  String type = "";
  String genre = "";
  String released = "";
  String status = "";
  String alias = "";

  var propertyCount =
      await Anime.evaluate("document.querySelectorAll('p.type').length");
  for (int i = 0; i < propertyCount; i++) {
    String content = await Anime.evaluate(
        "document.querySelectorAll('p.type')[$i].textContent");
    if (content.trim().startsWith("Plot Summary:"))
      summary = content.replaceAll("Plot Summary:", "").trim();
    if (content.trim().startsWith("Type:"))
      type = content.replaceAll("Type:", "").trim();
    if (content.trim().startsWith("Genre:"))
      genre = content.replaceAll("Genre:", "").trim();
    if (content.trim().startsWith("Released:"))
      released = content.replaceAll("Released:", "").trim();
    if (content.trim().startsWith("Status:"))
      status = content.replaceAll("Status:", "").trim();
    if (content.trim().startsWith("Other name:"))
      alias = content.replaceAll("Other name:", "").trim();
  }

  String image = await Anime.evaluate(
      "document.querySelector('#wrapper_bg > section > section.content_left > div.main_body > div:nth-child(2) > div.anime_info_body_bg > img').src");

  // Episodes
  List<Episode> episodes = [];

  var episodeCount = await Anime.evaluate(
      "document.querySelectorAll('ul#episode_related > li').length");

  for (int item = episodeCount.toInt() - 1; item >= 0; item--) {
    var link = await Anime.evaluate(
        "document.querySelectorAll('ul#episode_related > li > a')[$item].href");
    var name = await Anime.evaluate(
        "document.querySelectorAll('ul#episode_related > li > a > div.name')[$item].textContent");
    name = name.replaceAll("EP", "Episode");
    var category = await Anime.evaluate(
        "document.querySelectorAll('ul#episode_related > li > a > div.cate')[$item].textContent");
    episodes.add(Episode(name: name, url: link, category: category));
  }

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
      url: url);
}
