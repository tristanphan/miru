import 'package:flutter/material.dart';
import 'package:flutter_animation_progress_bar/flutter_animation_progress_bar.dart';
import 'package:miru/data/persistent_data/data_storage.dart';
import 'package:miru/data/structures/anime_details.dart';
import 'package:miru/pages/details/download_popup.dart';
import 'package:miru/pages/player/functions/formatter.dart';
import 'package:miru/pages/player/player_loading_page.dart';

Widget episodeCard(
    BuildContext context,
    AnimeDetails details,
    int index,
    bool pinned,
    bool isDark,
    void Function(VoidCallback fn) setState,
    String? customCrawler) {
  int episodeTime = 0;
  int totalTime = 1;
  bool bookmarked =
      pinned && Storage.isBookmarked(details.url, details.episodes[index].url);
  if (bookmarked) {
    episodeTime =
        Storage.getEpisodePosition(details.url, details.episodes[index].url);
    totalTime =
        Storage.getEpisodeDuration(details.url, details.episodes[index].url);
  }
  return InkWell(
      onTap: () async {
        await Navigator.of(context)
            .push(MaterialPageRoute(builder: (BuildContext context) {
          return Loading(
              url: details.episodes[index].url,
              name: details.name + " " + details.episodes[index].name,
              anime: details,
              detailsState: setState,
              customCrawler: customCrawler);
        }));
        setState(() {});
      },
      onLongPress: () {
        downloadPopup(details, index, context, setState);
      },
      child: Container(
          height: 60,
          padding: EdgeInsets.all(4),
          child: Row(children: [
            Padding(padding: EdgeInsets.all(8)),
            Text(details.episodes[index].name, style: TextStyle(fontSize: 20)),
            if (bookmarked)
              Expanded(
                  child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                    if (episodeTime == totalTime)
                      Text("Finished", style: TextStyle(fontSize: 20)),
                    if (episodeTime != totalTime)
                      Text(
                          formatDuration(Duration(milliseconds: episodeTime),
                                  Duration(milliseconds: episodeTime)) +
                              " / " +
                              formatDuration(Duration(milliseconds: totalTime),
                                  Duration(milliseconds: totalTime)),
                          style: TextStyle(fontSize: 20)),
                    ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: 200),
                        child: Row(mainAxisSize: MainAxisSize.min, children: [
                          Padding(padding: EdgeInsets.only(right: 16)),
                          Text(((episodeTime / totalTime * 100).floor())
                                  .toString() +
                              "%"),
                          Padding(padding: EdgeInsets.only(right: 8)),
                          Expanded(
                              child: FAProgressBar(
                                  borderRadius: BorderRadius.circular(15),
                                  animatedDuration: Duration(milliseconds: 100),
                                  maxValue: totalTime,
                                  size: 5,
                                  backgroundColor: (isDark)
                                      ? Colors.white24
                                      : Colors.black12,
                                  progressColor:
                                      (isDark) ? Colors.white : Colors.black38,
                                  currentValue: episodeTime))
                        ]))
                  ]))
            else
              Expanded(child: Container()),
            Padding(padding: EdgeInsets.all(4)),
            GestureDetector(
                onLongPress: () {
                  Storage.removeEpisode(
                      details.url, details.episodes[index].url);
                  setState(() {});
                },
                child: Icon(Icons.navigate_next)),
            Padding(padding: EdgeInsets.all(4))
          ])));
}
