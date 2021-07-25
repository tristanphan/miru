import 'dart:async';

import 'package:flutter/material.dart';
import 'package:miru/data/anime.dart';
import 'package:miru/data/structures/search_item.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:web_scraper/web_scraper.dart';

Future<List<SearchItem>> search(String keyword, Language language) async {
  int startTime = DateTime.now().millisecondsSinceEpoch;

  print("Searching: " + keyword);
  WebScraper web = WebScraper('https://gogoanime.vc/');
  await web.loadFullURL("https://gogoanime.vc//search.html?keyword=" + keyword);

  List<SearchItem> items = [];

  // Get number of search entries
  var numberOfEntries = web.getElementAttribute('div.img > a', 'title').length;

  print("Search Time: " +
      ((DateTime.now().millisecondsSinceEpoch - startTime) / 1000)
          .toStringAsFixed(4) +
      " seconds");

  // Loop through entries
  for (int entry = 0; entry < numberOfEntries; entry++) {
    String title =
        web.getElementTitle('ul.items > li > p.name > a')[entry].trim();

    // Filter by Language
    if (language != Language.ALL) {
      if (title.endsWith("(Dub)")) {
        if (language == Language.SUB) continue;
      } else if (language == Language.DUB) continue;
    }

    // Get the rest of the attributes
    String image = web
        .getElementAttribute('ul.items > li > div.img > a > img', 'src')[entry]!
        .trim();
    String url = ("https://gogoanime.vc" +
            web.getElementAttribute(
                'ul.items > li > p.name > a', 'href')[entry]!)
        .trim();
    String released = web
        .getElement('ul.items > li > p.released', [''])[entry]['title']
        .replaceAll('Released: ', '')
        .trim();
    items.add(SearchItem(
        title: title,
        image: image,
        url: url,
        subtitle: released,
        palette:
            await PaletteGenerator.fromImageProvider(NetworkImage(image))));
  }

  return items;
}
