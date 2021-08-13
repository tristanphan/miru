import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fuzzy/fuzzy.dart';
import 'package:http/http.dart';
import 'package:miru/data/structures/anime_details.dart';
import 'package:miru/data/structures/episode.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:web_scraper/web_scraper.dart';

Future<AnimeDetails> getDetails(String url) async {
  int startTime = DateTime.now().millisecondsSinceEpoch;

  print("Getting Details: " + url);
  WebScraper web = WebScraper('https://animesuge.io');
  await web.loadFullURL(url);

  // Properties
  String name = web.getElementTitle('h2.title')[0].trim();
  String summary = web.getElementTitle('p.desc')[0].trim();
  String type = "";
  String genre = "";
  String released = "";
  String status = "";
  int malID = 1;
  String score = "N/A";
  String alias = web
      .getElementTitle('div.alias')[0]
      .replaceAll('Other names:', '')
      .replaceAll(',', ', ')
      .trim();

  // Extra info
  try {
    String jname =
        web.getElementAttribute('div.heading > h1', 'data-jtitle')[0]!;
    Response jikanSearch = await get(
      Uri.parse(
          "https://api.jikan.moe/v3/search/anime?q=${jname.replaceAll(' (Dub)', '')}"),
    ).timeout(
      Duration(seconds: 5),
    );
    dynamic jikanBody = jsonDecode(jikanSearch.body);

    // Fuzzy Matching for Title
    Map<String, int> entries = {};
    for (Map entry in jikanBody['results']) {
      entries[entry['title'].trim()] = entry['mal_id'];
    }
    malID = entries[Fuzzy(
          entries.keys.toList(),
        ).search(jname).first.item] ??
        jikanBody['results'][0]['mal_id'];

    Response jikanStr = await get(
      Uri.parse('https://api.jikan.moe/v3/anime/$malID'),
    ).timeout(
      Duration(seconds: 5),
    );
    score = (jsonDecode(jikanStr.body)['score'] ?? score).toString();
  } catch (e) {}

  List<String> properties = web.getElementTitle('div.col1 > div');
  properties.addAll(
    web.getElementTitle('div.col2 > div'),
  );
  for (String content in properties) {
    content = content.trim();
    if (content.startsWith("Type:"))
      type = content.replaceAll("Type:", "").trim();
    if (content.startsWith("Genre:"))
      genre = content.replaceAll("Genre:", "").trim();
    if (content.startsWith("Premiered:"))
      released = content.replaceAll("Premiered:", "").trim();
    if (content.startsWith("Status:"))
      status = content.replaceAll("Status:", "").trim();
  }

  String image = web.getElementAttribute('div.poster > div > img', 'src')[0]!;

  // Episodes
  List<Episode> episodes = [];
  String id = web.getElementAttribute('div.watchpage', 'data-id')[0]!;
  Response response = await get(
    Uri.parse('https://animesuge.io/ajax/anime/servers?id=' + id),
  );
  String episodesHtml = jsonDecode(response.body)['html'];
  web.loadFromString(episodesHtml);

  print("Details Loading Time: " +
      ((DateTime.now().millisecondsSinceEpoch - startTime) / 1000)
          .toStringAsFixed(4) +
      " seconds");

  int episodeCount = web.getElementTitle('ul.episodes > li > a').length;
  for (int i = 0; i < episodeCount; i++) {
    episodes.add(
      Episode(
          name: "Episode " + web.getElementTitle('ul.episodes > li > a')[i],
          url: 'https://animesuge.io' +
              web.getElementAttribute('ul.episodes > li > a', 'href')[i]!),
    );
  }

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
    palette: await PaletteGenerator.fromImageProvider(
      NetworkImage(image),
    ),
  );
}
