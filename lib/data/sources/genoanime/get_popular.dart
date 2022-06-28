import 'package:flutter/material.dart';
import 'package:miru/data/structures/popular.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:web_scraper/web_scraper.dart';

Future<List<Popular>> getPopular() async {
  // https://genoanime.com/browse?sort=top_rated

  int startTime = DateTime.now().millisecondsSinceEpoch;

  print("Fetching Popular Page");

  WebScraper web = WebScraper("https://genoanime.com/");
  await web.loadFullURL("https://genoanime.com/browse?sort=top_rated");

  List<Popular> popular = [];

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

  print("Popular Page Loading Time: " +
      ((DateTime.now().millisecondsSinceEpoch - startTime) / 1000)
          .toStringAsFixed(4) +
      " seconds");

  for (int item = 0; item < titles.length; item++) {
    String title = titles[item]!.trim();
    String url = links[item]!.trim();
    String image = images[item]!.trim();
    String subtext = subtexts[item].trim().replaceAll(": ", " in ");

    popular.add(
      Popular(
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

  return popular;
}
