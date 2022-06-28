import 'package:flutter/material.dart';
import 'package:fuzzy/fuzzy.dart';
import 'package:http/http.dart';
import 'package:miru/data/anime.dart';
import 'package:miru/data/structures/search_item.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:web_scraper/web_scraper.dart';

Future<List<SearchItem>> search(String keyword, Language language) async {
  int startTime = DateTime.now().millisecondsSinceEpoch;

  print("Searching: " + keyword);
  Response searchRequest = await post(
    Uri.parse("https://genoanime.com/data/searchdata-test.php"),
    headers: <String, String>{
      'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8',
    },
    body: "anime=" + Uri.encodeQueryComponent(keyword),
  );
  WebScraper web = WebScraper('https://genoanime.com/');
  web.loadFromString(searchRequest.body);
  // await web.loadFullURL(
  //     "https://genoanime.com/search?ani=" + Uri.encodeQueryComponent(keyword));

  List<SearchItem> items = [];

  // Get number of search entries
  List<String> titles = web.getElementTitle('div.product__item__text > h5 > a');
  print(titles);
  List<String?> images =
      web.getElementAttribute("div.product__item__pic", "data-setbg");
  List<String?> urls =
      web.getElementAttribute("div.product__item__text > a", "href");
  List<String> subtitles =
      web.getElementTitle("div.product__item__pic > div.comment");

  print("Search Time: " +
      ((DateTime.now().millisecondsSinceEpoch - startTime) / 1000)
          .toStringAsFixed(4) +
      " seconds");

  // Loop through entries
  for (int entry = 0; entry < titles.length; entry++) {
    String title = titles[entry].trim();

    // Filter by Language
    if (language != Language.ALL) {
      if (title.endsWith("(Dub)")) {
        if (language == Language.SUB) continue;
      } else if (language == Language.DUB) continue;
    }

    // Get the rest of the attributes
    String image =
        "https://genoanime.com/" + images[entry]!.trim().substring(2);
    String url = "https://genoanime.com/" + urls[entry]!.trim().substring(3);
    String subtitle = subtitles[entry].trim();
    items.add(
      SearchItem(
        title: title,
        image: image,
        url: url,
        subtitle: subtitle,
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
