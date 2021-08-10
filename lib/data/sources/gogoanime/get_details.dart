import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:fuzzy/fuzzy.dart';
import 'package:http/http.dart';
import 'package:miru/data/structures/anime_details.dart';
import 'package:miru/data/structures/episode.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:web_scraper/web_scraper.dart';

Future<AnimeDetails> getDetails(String url) async {
  int startTime = DateTime.now().millisecondsSinceEpoch;

  print("Getting Details: " + url);
  WebScraper web = WebScraper('https://gogoanime.vc/');
  await web.loadFullURL(url);

  // Properties
  String name = web.getElementTitle('h1')[0].trim();
  String summary = "";
  String type = "";
  String genre = "";
  String released = "";
  String status = "";
  int malID = 1;
  String score = "N/A";
  String alias = "";

  try {
    Response jikanSearch = await get(Uri.parse(
            "https://api.jikan.moe/v3/search/anime?q=${name.replaceAll(' (Dub)', '')}"))
        .timeout(Duration(seconds: 5));
    var jikanBody = jsonDecode(jikanSearch.body);

    // Fuzzy Matching for Title
    Map<String, int> entries = {};
    for (Map entry in jikanBody['results']) {
      entries[entry['title'].trim()] = entry['mal_id'];
    }
    malID = entries[Fuzzy(entries.keys.toList()).search(name).first.item] ??
        jikanBody['results'][0]['mal_id'];

    Response jikanStr =
        await get(Uri.parse('https://api.jikan.moe/v3/anime/$malID'))
            .timeout(Duration(seconds: 5));
    score = (jsonDecode(jikanStr.body)['score'] ?? score).toString();
  } catch (e) {}

  List<String> properties = web.getElementTitle('p.type');
  for (String content in properties) {
    content = content.trim();
    if (content.startsWith("Plot Summary:"))
      summary = content.replaceAll("Plot Summary:", "").trim();
    if (content.startsWith("Type:"))
      type = content.replaceAll("Type:", "").trim();
    if (content.startsWith("Genre:"))
      genre = content.replaceAll("Genre:", "").trim();
    if (content.startsWith("Released:"))
      released = content.replaceAll("Released:", "").trim();
    if (content.startsWith("Status:"))
      status = content.replaceAll("Status:", "").trim();
    if (content.startsWith("Other name:"))
      alias = content.replaceAll("Other name:", "").trim();
  }

  String image =
      web.getElementAttribute('div.anime_info_body_bg > img', 'src')[0]!;

  // Episodes
  List<Episode> episodes = [];

  await (() async {
    String id = web.getElementAttribute('input#movie_id.movie_id', 'value')[0]!;
    String defaultEp =
        web.getElementAttribute('input#default_ep.default_ep', 'value')[0]!;
    String alias =
        web.getElementAttribute('input#alias_anime.alias_anime', 'value')[0]!;
    String start = web.getElementAttribute(
        'ul#episode_page > li:first-child > a', 'ep_start')[0]!;
    String end = web.getElementAttribute(
        'ul#episode_page > li:last-child > a', 'ep_end')[0]!;

    await web.loadFullURL(
        'https://ajax.gogo-load.com/ajax/load-list-episode?ep_start=$start&ep_end=$end&id=$id&default_ep=$defaultEp&alias=$alias');
  })();
  List<String> episodeLinks = List.from(
      web.getElementAttribute('ul > li > a', 'href').reversed,
      growable: true);
  List<String> episodeNames = List.from(
      web.getElementTitle('ul > li > a > div.name').reversed,
      growable: true);
  for (int i = 0; i < episodeNames.length; i++) {
    episodeNames[i] = episodeNames[i].replaceAll("EP", "Episode").trim();
    episodeLinks[i] = "https://gogoanime.vc" + episodeLinks[i].trim();
    episodes.add(Episode(name: episodeNames[i], url: episodeLinks[i]));
  }

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
      released: released,
      status: status,
      malID: malID,
      score: score,
      alias: alias,
      episodes: episodes,
      url: url,
      palette: await PaletteGenerator.fromImageProvider(NetworkImage(image)));
}
