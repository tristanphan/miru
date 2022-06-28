import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:miru/data/structures/anime_details.dart';
import 'package:miru/data/structures/episode.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:web_scraper/web_scraper.dart';

Future<AnimeDetails> getDetails(String url) async {
  // https://genoanime.com/browse/8842

  int startTime = DateTime.now().millisecondsSinceEpoch;

  print("Getting Details: " + url);
  WebScraper web = WebScraper("https://genoanime.com/");
  await web.loadFullURL(url);

  // Trivial
  String name = web.getElementTitle('div.anime__details__title > h3').first;
  String image = "https://genoanime.com/" +
      (web
              .getElementAttribute('div.anime__details__pic', 'data-setbg')
              .first
              ?.substring(3) ??
          "");
  String summary =
      web.getElementTitle('div.anime__details__text > p').first.trim();
  String alias = web.getElementTitle('div.anime__details__title > span').first;

  // List items
  String type = "";
  String genre = "";
  String date = "";
  String status = "";

  for (String elem in web
      .getElementTitle('div.anime__details__widget > div > div > ul > li')) {
    if (elem.startsWith("Type: ")) {
      type = elem.replaceAll("Type: ", "").trim();
    }
    if (elem.startsWith("Date aired: ")) {
      date = elem.replaceAll("Date aired: ", "").trim();
    }
    if (elem.startsWith("Genre: ")) {
      genre = elem.replaceAll("Genre: ", "").trim();
    }
    if (elem.startsWith("Status: ")) {
      status = elem.replaceAll("Status: ", "").trim();
    }
  }

  // MyAnimeList
  int malID;
  String score;
  try {
    Response malGet = await get(Uri.parse(
        "https://api.jikan.moe/v4/anime?q=${Uri.encodeQueryComponent(name)}"));
    malID = jsonDecode(malGet.body)["data"][0]["mal_id"];
    score = jsonDecode(malGet.body)["data"][0]["score"]?.toString() ?? "N/A";
  } catch (e) {
    print(e);
    malID = 1;
    score = "N/A";
  }

  // Episodes
  List<Episode> episodes = _getEpisodes(web);

  print("Details Loading Time: " +
      ((DateTime.now().millisecondsSinceEpoch - startTime) / 1000)
          .toStringAsFixed(4) +
      " seconds");

  return AnimeDetails(
      name: name,
      image: image,
      summary: summary,
      type: type,
      genre: genre,
      released: date,
      status: status,
      malID: malID,
      score: score,
      alias: alias,
      episodes: episodes,
      url: url,
      palette: await PaletteGenerator.fromImageProvider(NetworkImage(image)));
}

List<Episode> _getEpisodes(WebScraper web) {
  List<Episode> episodes = [];

  List<String?> names = web.getElementTitle('a.episode');
  List<String?> links = web.getElementAttribute('a.episode', 'href');

  for (int i = 0; i < names.length; i++) {
    episodes.add(Episode(
        name: names[i]!.replaceAll("Ep ", "Episode "),
        url: "https://genoanime.com/" + links[i]!.substring(3)));
  }

  return episodes;
}
