import 'package:miru/data/structures/video_details.dart';
import 'package:miru/data/utilities/js_unpack.dart';
import 'package:web_scraper/web_scraper.dart';

int _step = 100 ~/ 4;

Future<VideoDetails?> getVideo(String url, Function changeProgress) async {
  int startTime = DateTime.now().millisecondsSinceEpoch;

  print("Getting Video URL: " + url);

  changeProgress("Loading Episode URL", _step);
  WebScraper web = WebScraper("https://genoanime.com/");
  await web.loadFullURL(url);

  changeProgress("Fetching Data", _step);
  String title = web
      .getElementTitle('div.breadcrumb__links > span')[0]
      .replaceAll(" (Dub)", "")
      .trim();

  // Get next/last episode
  List<String> episodeNames = web.getElementTitle('a.episode');
  List<String> episodeURLs = web
      .getElementAttribute('a.episode', 'href')
      .map<String>(
          (String? s) => "https://genoanime.com/" + (s?.substring(3) ?? ""))
      .toList();
  List<String?> episodeStyles = web.getElementAttribute('a.episode', 'style');

  // Current episode has the longest style
  int currentEpisodeIndex = episodeStyles.indexOf(episodeStyles
      .reduce((String? s1, String? s2) => (s1 == null || s2 == null)
          ? ""
          : (s1.length > s2.length)
              ? s1
              : s2));

  List<String> lastEpisode = [];
  List<String> nextEpisode = [];
  if (currentEpisodeIndex == 0 && episodeNames.length >= 2) {
    nextEpisode = [
      episodeNames[currentEpisodeIndex + 1].replaceAll("Ep ", "Episode "),
      episodeURLs[currentEpisodeIndex + 1]
    ];
  } else if (currentEpisodeIndex == episodeNames.length - 1 &&
      episodeNames.length >= 0) {
    lastEpisode = [
      episodeNames[currentEpisodeIndex - 1].replaceAll("Ep ", "Episode "),
      episodeURLs[currentEpisodeIndex - 1]
    ];
  } else if (episodeNames.length >= 3) {
    nextEpisode = [
      episodeNames[currentEpisodeIndex + 1].replaceAll("Ep ", "Episode "),
      episodeURLs[currentEpisodeIndex + 1]
    ];
    lastEpisode = [
      episodeNames[currentEpisodeIndex - 1].replaceAll("Ep ", "Episode "),
      episodeURLs[currentEpisodeIndex - 1]
    ];
  }
  print(nextEpisode);
  print(lastEpisode);

  changeProgress("Loading Video Player URL", _step);
  // Get URL of iframe and load it
  String? frameURL1 = web.getElementAttribute('div#video > iframe', 'src')[0];
  if (frameURL1 == null) return null;

  print("Frame URL (1/2): " + frameURL1);
  await web.loadFullURL(frameURL1);

  // Get URL of iframe and load it
  String? frameURL2 = web.getElementAttribute('body > iframe', 'src')[0];
  if (frameURL2 == null) return null;

  frameURL2 = "https://mplayer.sbs" + frameURL2;
  print("Frame URL (2/2): " + frameURL2);
  await web.loadFullURL(frameURL2);

  String packedJS = web.getElementTitle('body > script')[0];
  String unpackedJS = jsUnpack(packedJS);

  RegExp urlPattern = new RegExp(
      r"((https?:www\.)|(https?://)|(www\.))[-a-zA-Z\d@:%._+~#=]{1,256}\.[a-zA-Z\d]{1,6}(/[-a-zA-Z\d()@:%_+.~#?&/=]*)?");
  List<String?> urls = urlPattern
      .allMatches(unpackedJS)
      .map<String?>((e) => e.group(0))
      .toList();
  String videoURL = urls[0]!;

  changeProgress("Preparing Video Player", _step);
  print("Video URL: " + videoURL);
  if (!videoURL.startsWith("ht")) return null;

  print("Video Loading Time: " +
      ((DateTime.now().millisecondsSinceEpoch - startTime) / 1000)
          .toStringAsFixed(4) +
      " seconds");

  return VideoDetails(
      title: title, url: videoURL, next: nextEpisode, last: lastEpisode);
}
