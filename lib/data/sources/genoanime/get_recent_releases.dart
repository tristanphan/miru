import 'package:flutter/material.dart';
import 'package:miru/data/structures/recent_release.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:web_scraper/web_scraper.dart';

Future<List<RecentRelease>> getRecentReleases() async {
  // https://genoanime.com/browse?sort=latest

  int startTime = DateTime.now().millisecondsSinceEpoch;

  print("Fetching Recent Releases Page");

  WebScraper web = WebScraper("https://genoanime.com/");
  await web.loadFullURL("https://genoanime.com/browse?sort=latest");

  List<RecentRelease> recentReleases = [];

  List<String?> titles = web.getElementTitle('div.product__item__text > h5');
  List<String?> links = web
      .getElementAttribute('div.product__item__text > a', 'href')
      .map<String?>(
          (String? str) => "https://genoanime.com/" + (str?.substring(3) ?? ""))
      .toList();
  List<String?> images = web
      .getElementAttribute('div.product__item__pic', 'data-setbg')
      .map<String?>(
          (String? str) => "https://genoanime.com/" + (str?.substring(2) ?? ""))
      .toList();
  List<String> subtexts = web
      .getElementTitle('div.product__item__pic > div.ep')
      .map<String>((String? str) => (str?.trim() ?? ""))
      .toList();

  print("Recent Releases Page Loading Time: " +
      ((DateTime.now().millisecondsSinceEpoch - startTime) / 1000)
          .toStringAsFixed(4) +
      " seconds");

  for (int item = 0; item < titles.length; item++) {
    String title = titles[item]!.trim();

    // Get Anime URL rather than Episode URL
    String url = links[item]!.trim();
    String image = images[item]!.trim();
    String subtext = subtexts[item].trim();

    recentReleases.add(
      RecentRelease(
        title: title,
        url: url,
        image: image,
        subtext: subtext,
        palette: await PaletteGenerator.fromImageProvider(
          NetworkImage(image),
        ),
      ),
    );
  }

  return recentReleases;
}
