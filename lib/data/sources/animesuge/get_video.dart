import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart';
import 'package:miru/data/sources/animesuge/decode_iframe_url.dart';
import 'package:miru/data/structures/video_details.dart';
import 'package:web_scraper/web_scraper.dart';

Future<VideoDetails?> getVideo(String url, Function changeProgress) async {
  int startTime = DateTime.now().millisecondsSinceEpoch;

  print("Getting Video URL: " + url);

  changeProgress("Loading Episode URL", 25);
  WebScraper web = WebScraper("https://animesuge.io/");
  await web.loadFullURL(url);

  changeProgress("Fetching Data", 25);
  String title = web.getElementTitle('h1.title')[0].replaceAll(" (Dub)", "");

  String id = web.getElementAttribute('div.watchpage', 'data-id')[0]!;
  Response response = await get(Uri.parse(
      'https://animesuge.io/ajax/anime/servers?id=' +
          id +
          '&episode=' +
          web.getElementAttribute('div.watchpage', 'data-ep-name')[0]!));
  String episodesHtml = jsonDecode(response.body)['html'];
  web.loadFromString(episodesHtml);

  String episodeID = '';

  List<String> lastEpisode = [];
  List<String> nextEpisode = [];

  int episodeCount = web.getElementTitle('ul.episodes > li > a').length;
  for (int i = 0; i < episodeCount; i++) {
    if (web.getElement('ul.episodes > li > a', ['class'])[i]['attributes']
            ['class'] ==
        'active') {
      episodeID = jsonDecode(web.getElementAttribute(
          'ul.episodes > li > a', 'data-sources')[i]!)['40'];
      title += " Episode " + web.getElementTitle('ul.episodes > li > a')[i];
      if (i != 0) {
        lastEpisode.add(
            'Episode ' + web.getElementTitle('ul.episodes > li > a')[i - 1]);
        lastEpisode.add('https://animesuge.io' +
            web.getElementAttribute('ul.episodes > li > a', 'href')[i - 1]!);
      }
      if (i != episodeCount - 1) {
        nextEpisode.add(
            'Episode ' + web.getElementTitle('ul.episodes > li > a')[i + 1]);
        nextEpisode.add('https://animesuge.io' +
            web.getElementAttribute('ul.episodes > li > a', 'href')[i + 1]!);
      }
    }
  }

  // Get URL of iframe and load it
  response = await get(
      Uri.parse('https://animesuge.io/ajax/anime/episode?id=' + episodeID));
  String frameURL = decodeIFrameUrl(jsonDecode(response.body)['url']);

  print("Frame URL: " + frameURL);
  changeProgress("Loading Video Player URL", 25);
  await web.loadFullURL(frameURL);

  String videoURL = '';
  for (var i in web.getElementTitle('script')) {
    if (i.startsWith('document.getElementById(')) {
      List<String> splicedUrl = i.split(RegExp("(\"|')"));
      int index = int.parse(i[i.lastIndexOf("(") + 1]);
      videoURL = "https://streamtape.com/" + splicedUrl[3].split('.com/')[1] + splicedUrl[5].substring(index);
    }
  }
  changeProgress("Preparing Video Player", 25);
  print("Video URL: " + videoURL);

  print("Video Loading Time: " +
      ((DateTime.now().millisecondsSinceEpoch - startTime) / 1000)
          .toStringAsFixed(4) +
      " seconds");

  return VideoDetails(
      title: title, url: videoURL, next: nextEpisode, last: lastEpisode);
}
