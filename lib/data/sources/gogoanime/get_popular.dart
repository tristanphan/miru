import 'package:flutter/material.dart';
import 'package:miru/data/structures/popular.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:web_scraper/web_scraper.dart';

Future<List<Popular>> getPopular() async {
  int startTime = DateTime.now().millisecondsSinceEpoch;

  print("Fetching Popular Page");

  WebScraper web = WebScraper("https://gogoanime.vc/");
  await web.loadFullURL("https://gogoanime.vc/popular.html");

  List<Popular> popular = [];

  List<String?> titles =
      web.getElementAttribute('ul.items > li > p.name > a', 'title');
  List<String?> links =
      web.getElementAttribute('ul.items > li > p.name > a', 'href');
  List<String?> images =
      web.getElementAttribute('ul.items > li > div.img > a > img', 'src');
  List<String> releases = web.getElementTitle('ul.items > li > p.released');

  print("Popular Page Loading Time: " +
      ((DateTime.now().millisecondsSinceEpoch - startTime) / 1000)
          .toStringAsFixed(4) +
      " seconds");

  for (int item = 0; item < titles.length; item++) {
    String title = titles[item]!.trim();
    String url = "https://gogoanime.vc" + links[item]!.trim();
    String image = images[item]!.trim();
    String released = releases[item].trim().replaceAll(": ", " in ");

    popular.add(Popular(
        title: title,
        url: url,
        image: image,
        subtext: released,
        palette:
            await PaletteGenerator.fromImageProvider(NetworkImage(image))));
  }

  return popular;
}
