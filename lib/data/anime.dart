import 'dart:async';

import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:miru/data/structures/anime_details.dart';
import 'package:miru/data/structures/home.dart';
import 'package:miru/data/structures/search_item.dart';
import 'package:miru/data/structures/video_details.dart';
import 'package:miru/functions/anime_details.dart';

import '../functions/fetch_video.dart';
import '../functions/home_crawl.dart';
import '../functions/search_anime.dart';

class Anime {
  static Future<void> load(String url) async {
    controller!.loadUrl(urlRequest: URLRequest(url: Uri.parse(url)));
    while (await controller!.isLoading()) {
      await Future.delayed(Duration(milliseconds: 10));
    }
    return;
  }

  static Future<dynamic> evaluate(String javascript) async =>
      controller!.evaluateJavascript(source: javascript);

  static InAppWebViewController? controller;
  static HeadlessInAppWebView view = new HeadlessInAppWebView(
      onWebViewCreated: (c) {
        controller = c;
      },
      initialOptions: InAppWebViewGroupOptions(
          crossPlatform: InAppWebViewOptions(
              incognito: true,
              cacheEnabled: true,
              javaScriptCanOpenWindowsAutomatically: false)));

  // GoGoAnime Home Page
  static Future<List<RecentRelease>> getRecentReleases() =>
      recentReleasesCrawl();

  static Future<List<Popular>> getPopular() => popularCrawl();

  // Searches Anime Titles by Keyword
  static Future<List<SearchItem>> search(String keyword, Language language) =>
      animeSearch(keyword, language);

  // Gets details of an Anime by URL
  static Future<AnimeDetails> getDetails(String url) => animeDetails(url);

  // Get video from Episode URL
  static Future<VideoDetails?> getVideo(String url) =>
      animeVideo(url, (String a) {});

  static Future<VideoDetails?> getVideoWithProgress(
          String url, Function changeProgress) =>
      animeVideo(url, changeProgress);

  static void doNothing(anything, somethingElse) {}
}

enum Language { SUB, DUB, ALL }
