import 'package:flutter/cupertino.dart';
import 'package:miru/data/structures/popular.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:web_scraper/web_scraper.dart';

Future<List<Popular>> getPopular() async {
  int startTime = DateTime.now().millisecondsSinceEpoch;

  print("Fetching Popular Page");

  WebScraper web = WebScraper("https://animesuge.io/");
  await web.loadFullURL("https://animesuge.io/most-watched");

  List<String> titles =
      web.getElementTitle('ul.itemlist > li > div.info > div.name > h3 > a');
  List<String?> links = web.getElementAttribute(
      'ul.itemlist > li > div.info > div.name > h3 > a', 'href');
  List<String?> images =
      web.getElementAttribute('ul.itemlist > li > a.poster > img', 'src');
  List<String> status =
      web.getElementTitle('ul.itemlist > li > div.info > div.status');

  print("Popular Page Loading Time: " +
      ((DateTime.now().millisecondsSinceEpoch - startTime) / 1000)
          .toStringAsFixed(4) +
      " seconds");

  List<Popular> popular = [];

  for (int i = 0; i < titles.length; i++) {
    String epStatus = status[i];
    epStatus = epStatus.replaceAll("dub", "").toUpperCase().trim();
    epStatus.replaceAll("EP", epStatus.contains("FULL") ? "" : "Episode");

    popular.add(Popular(
        title: titles[i].trim(),
        subtext: epStatus,
        image: images[i]!.trim(),
        url: links[i]!.trim(),
        palette: await PaletteGenerator.fromImageProvider(
            NetworkImage(images[i]!.trim()))));
  }

  return popular;
}
