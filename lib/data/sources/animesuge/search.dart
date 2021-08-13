import 'dart:async';

import 'package:flutter/material.dart';
import 'package:fuzzy/fuzzy.dart';
import 'package:miru/data/anime.dart';
import 'package:miru/data/structures/search_item.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:web_scraper/web_scraper.dart';

Future<List<SearchItem>> search(String keyword, Language language) async {
  int startTime = DateTime.now().millisecondsSinceEpoch;

  print("Searching: " + keyword);
  WebScraper web = WebScraper('https://animesuge.io');

  if (language == Language.SUB) {
    await web.loadFullURL(
        "https://animesuge.io/filter?language%5B%5D=subbed&keyword=" + keyword);
  } else if (language == Language.DUB) {
    await web.loadFullURL(
        "https://animesuge.io/filter?language%5B%5D=dubbed&keyword=" + keyword);
  } else {
    await web.loadFullURL("https://animesuge.io/search?keyword=" + keyword);
  }

  List<SearchItem> items = [];

  // Get number of search entries
  int numberOfEntries = web
      .getElementTitle('ul.itemlist > li > div.info > div.name > h3 > a')
      .length;

  print("Search Time: " +
      ((DateTime.now().millisecondsSinceEpoch - startTime) / 1000)
          .toStringAsFixed(4) +
      " seconds");

  // Loop through entries
  for (int entry = 0; entry < numberOfEntries; entry++) {
    String title = web
        .getElementTitle(
            'ul.itemlist > li > div.info > div.name > h3 > a')[entry]
        .trim();

    // Get the rest of the attributes
    String image = web
        .getElementAttribute('ul.itemlist > li > a.poster > img', 'src')[entry]!
        .trim();
    String url = ("https://animesuge.io" +
            web.getElementAttribute(
                'ul.itemlist > li > div.info > div.name > h3 > a',
                'href')[entry]!)
        .trim();
    String status = web
        .getElementTitle('ul.itemlist > li > div.info > div.status')[entry]
        .replaceAll("Ep ", "Episode ")
        .replaceAll("dub", '')
        .trim();
    items.add(
      SearchItem(
        title: title,
        image: image,
        url: url,
        subtitle: status,
        palette: await PaletteGenerator.fromImageProvider(
          NetworkImage(image),
        ),
      ),
    );
  }

  items.sort(
    (SearchItem a, SearchItem b) {
      if (a.title == b.title) return 0;
      return a.title ==
              Fuzzy(
                [a.title, b.title],
                options: FuzzyOptions(threshold: 1),
              ).search(keyword).first.item
          ? -1
          : 1;
    },
  );

  return items;
}
