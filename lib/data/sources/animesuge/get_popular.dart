import 'dart:async';

import 'package:flutter/material.dart';
import 'package:miru/data/structures/popular.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:web_scraper/web_scraper.dart';

Future<List<Popular>> getPopular() async {
  int startTime = DateTime.now().millisecondsSinceEpoch;

  print("Fetching Popular Page");

  WebScraper web = WebScraper("https://animesuge.io/");
  await web.loadFullURL("https://animesuge.io/most-watched");

  List<Popular> popular = [];

  List<String?> titles = web.getElementAttribute(
      'ul.itemlist > li > div.info > div.name > h3 > a', 'title');
  List<String?> links = web.getElementAttribute(
      'ul.itemlist > li > div.info > div.name > h3 > a', 'href');
  List<String?> images =
      web.getElementAttribute('ul.itemlist > li > a.poster > img', 'src');
  List<String> latestEps =
      web.getElementTitle('ul.itemlist > li > div.info > div.status');

  print("Popular Page Loading Time: " +
      ((DateTime.now().millisecondsSinceEpoch - startTime) / 1000)
          .toStringAsFixed(4) +
      " seconds");

  for (int item = 0; item < titles.length; item++) {
    String title = titles[item]!.trim();
    String url = 'https://animesuge.io' + links[item]!.trim();
    String image = images[item]!.trim();
    String latestEp = latestEps[item]
        .replaceAll('Ep ', 'Episode ')
        .replaceAll('dub', '')
        .replaceAll('/', ' / ')
        .trim();

    popular.add(Popular(
        title: title,
        url: url,
        image: image,
        subtext: latestEp,
        palette:
            await PaletteGenerator.fromImageProvider(NetworkImage(image))));
  }

  return popular;
}
