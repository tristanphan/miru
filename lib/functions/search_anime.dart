import 'dart:async';

import 'package:miru/data/anime.dart';
import 'package:miru/data/structures/search_item.dart';

Future<List<SearchItem>> animeSearch(String keyword, Language language) async {
  print("Searching: " + keyword);

  await Anime.load(
      "https://gogoanime.vc//search.html?keyword=" + Uri.encodeFull(keyword));

  return _searchEngine(language);
}

Future<List<SearchItem>> _searchEngine(Language language) async {
  List<SearchItem> items = [];

  // Get number of search entries
  var numberOfEntries = await Anime.evaluate(
      "window.document.querySelectorAll('div.img > a').length");

  // Loop through entries
  for (int entry = 0; entry < numberOfEntries; entry++) {
    String title = await Anime.evaluate(
        "window.document.querySelectorAll('ul.items > li > p.name > a')[$entry].text.trim()");

    // Filter by Language
    if (language != Language.ALL) {
      if (title.endsWith("(Dub)")) {
        if (language == Language.SUB) continue;
      } else if (language == Language.DUB) continue;
    }

    // Get the rest of the attributes
    String image = await Anime.evaluate(
        "window.document.querySelectorAll('ul.items > li > div.img > a > img')[$entry].src.trim()");
    String url = await Anime.evaluate(
        "window.document.querySelectorAll('ul.items > li > p.name > a')[$entry].href.trim()");
    String released = await Anime.evaluate(
        "window.document.querySelectorAll('ul.items > li > p.released')[$entry].textContent.replace('Released:', '').trim()");
    items.add(
        SearchItem(title: title, image: image, url: url, released: released));
  }

  return items;
}
