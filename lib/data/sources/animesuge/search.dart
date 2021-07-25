import 'package:flutter/cupertino.dart';
import 'package:miru/data/anime.dart';
import 'package:miru/data/structures/search_item.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:web_scraper/web_scraper.dart';

Future<List<SearchItem>> search(String keyword, Language language) async {
  int startTime = DateTime.now().millisecondsSinceEpoch;

  print("Searching: " + keyword);

  String url;
  if (language == Language.SUB) {
    url = "https://animesuge.io/filter?language[]=subbed&keyword=" + keyword;
  } else if (language == Language.DUB) {
    url = "https://animesuge.io/filter?language[]=dubbed&keyword=" + keyword;
  } else {
    url =
        "https://animesuge.io/filter?language[]=subbed&language[]=dubbed&keyword=" +
            keyword;
  }
  WebScraper web = WebScraper("https://animesuge.io/");
  await web.loadFullURL(url);

  List<SearchItem> items = [];

  List<String> titles =
      web.getElementTitle('ul.itemlist > li > div.info > div.name > h3 > a');
  List<String?> links = web.getElementAttribute(
      'ul.itemlist > li > div.info > div.name > h3 > a', 'href');
  List<String?> images =
      web.getElementAttribute('ul.itemlist > li > a > img', 'src');
  List<String> tags =
      web.getElementTitle('ul.itemlist > li > div.info > div.status');
  for (int index = 0; index < titles.length; index++) {
    String title = titles[index].trim();
    String url = "https://animesuge.io" + links[index]!.trim();
    String image = images[index]!.trim();
    String eptag = tags[index].trim().toUpperCase();
    eptag.replaceAll("EP", eptag.contains("FULL") ? "" : "Episode");

    items.add(SearchItem(
        title: title,
        image: image,
        palette: await PaletteGenerator.fromImageProvider(NetworkImage(image)),
        url: url,
        subtitle: eptag));
  }

  print("Search Time: " +
      ((DateTime.now().millisecondsSinceEpoch - startTime) / 1000)
          .toStringAsFixed(4) +
      " seconds");

  return items;
}
