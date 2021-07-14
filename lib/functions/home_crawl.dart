import 'dart:async';

import 'package:miru/data/anime.dart';
import 'package:miru/data/structures/home.dart';

Future<Home> homeCrawl() async {
  print("Fetching Home Page");
  await Anime.load("https://gogoanime.vc/");

  List<RecentRelease> recentReleases = await _getRecentReleases();
  List<Popular> popular = await _getPopular();

  return Home(recentReleases: recentReleases, popular: popular);
}

Future<List<RecentRelease>> _getRecentReleases() async {
  List<RecentRelease> recentReleases = [];

  var numberOfAnime =
      await Anime.evaluate("document.querySelectorAll('ul.items > li').length");
  while (numberOfAnime == 0) {
    await Future.delayed(
      Duration(milliseconds: 10),
    );
    numberOfAnime = await Anime.evaluate(
        "document.querySelectorAll('div.popular.added_series_body > ul > li').length");
  }
  for (int item = 0; item < numberOfAnime; item++) {
    String title = await Anime.evaluate(
        "document.querySelectorAll('ul.items > li > p.name')[$item].textContent.trim()");

    // Get Anime URL rather than Episode URL
    String url = await Anime.evaluate(
        "document.querySelectorAll('ul.items > li > div > a')[$item].href.trim()");
    url = url.replaceFirst(
        "https://gogoanime.vc/", "https://gogoanime.vc/category/");
    url = url
        .split("-episode-")
        .sublist(0, url.split("-episode-").length - 1)
        .join("-episode-");
    String image = await Anime.evaluate(
        "document.querySelectorAll('ul.items > li > div > a > img')[$item].src.trim()");
    String latestEp = await Anime.evaluate(
        "document.querySelectorAll('ul.items > li > p.episode')[$item].textContent.trim()");
    recentReleases.add(
      RecentRelease(title: title, url: url, image: image, latestEp: latestEp),
    );
  }

  return recentReleases;
}

Future<List<Popular>> _getPopular() async {
  List<Popular> popular = [];

  var numberOfAnime = await Anime.evaluate(
      "document.querySelectorAll('div.popular.added_series_body > ul > li').length");
  while (numberOfAnime == 0) {
    await Future.delayed(
      Duration(milliseconds: 10),
    );
    numberOfAnime = await Anime.evaluate(
        "document.querySelectorAll('div.popular.added_series_body > ul > li').length");
  }
  for (int item = 0; item < numberOfAnime; item++) {
    String title = await Anime.evaluate(
        "document.querySelectorAll('div.popular.added_series_body > ul > li > a:nth-child(1)')[$item].title.trim()");
    String url = await Anime.evaluate(
        "document.querySelectorAll('div.popular.added_series_body > ul > li > a:nth-child(1)')[$item].href.trim()");
    String image = await Anime.evaluate(
        "document.querySelectorAll('div.popular.added_series_body > ul > li > a:nth-child(1) > div')[$item].style.backgroundImage.slice(4, -1).replace(/\"/g, '').trim()");
    String latestEp = await Anime.evaluate(
        "document.querySelectorAll('div.popular.added_series_body > ul > li > p:last-child > a')[$item].textContent.trim()");
    String genres = await Anime.evaluate(
        "document.querySelectorAll('div.popular.added_series_body > ul > li > p.genres')[$item].textContent.replace('Genres:', '').trim()");
    popular.add(
      Popular(
          title: title,
          url: url,
          image: image,
          latestEp: latestEp,
          genres: genres),
    );
  }

  return popular;
}
