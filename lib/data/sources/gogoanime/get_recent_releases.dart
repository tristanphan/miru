import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:miru/data/structures/recent_release.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:web_scraper/web_scraper.dart';

Future<List<RecentRelease>> getRecentReleases() async {
  int startTime = DateTime.now().millisecondsSinceEpoch;

  print("Fetching Recent Releases Page");

  WebScraper web = WebScraper("https://gogoanime.vc/");
  await web.loadFullURL("https://gogoanime.vc/");

  List<RecentRelease> recentReleases = [];

  List<String?> titles =
      web.getElementAttribute('ul.items > li > p.name > a', 'title');
  List<String?> links =
      web.getElementAttribute('ul.items > li > p.name > a', 'href');
  List<String?> images =
      web.getElementAttribute('ul.items > li > div.img > a > img', 'src');
  List<String> latestEps = web.getElementTitle('ul.items > li > p.episode');

  print("Recent Releases Page Loading Time: " +
      ((DateTime.now().millisecondsSinceEpoch - startTime) / 1000)
          .toStringAsFixed(4) +
      " seconds");

  for (int item = 0; item < titles.length; item++) {
    String title = titles[item]!.trim();

    // Get Anime URL rather than Episode URL
    String url = "https://gogoanime.vc/category" + links[item]!.trim();
    url = url
        .split("-episode-")
        .sublist(0, url.split("-episode-").length - 1)
        .join("-episode-");

    String image = images[item]!.trim();
    String latestEp = latestEps[item].trim();

    recentReleases.add(RecentRelease(
        title: title,
        url: url,
        image: image,
        subtext: latestEp,
        palette:
            await PaletteGenerator.fromImageProvider(NetworkImage(image))));
  }

  return recentReleases;
}
