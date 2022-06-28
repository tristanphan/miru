import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:miru/data/persistent_data/data_storage.dart';
import 'package:miru/data/structures/anime_details.dart';
import 'package:miru/pages/player/player_loading_page.dart';
import 'package:url_launcher/url_launcher_string.dart';

Widget detailsCard(BuildContext context, AnimeDetails details, Color cardColor,
    bool isDark, void Function(VoidCallback fn) setState) {
  return Stack(
    alignment: Alignment.center,
    children: [
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            showDialog(
                barrierDismissible: false,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text("More Info"),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    content: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SelectableText.rich(
                              TextSpan(
                                children: [
                                  TextSpan(
                                    text: "Type: ",
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  TextSpan(text: "${details.type}\n\n"),
                                  TextSpan(
                                    text: "Genre: ",
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  TextSpan(text: "${details.genre}\n\n"),
                                  TextSpan(
                                    text: "Released: ",
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  TextSpan(text: "${details.released}\n\n"),
                                  TextSpan(
                                    text: "Status: ",
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  TextSpan(text: "${details.status}\n\n"),
                                  TextSpan(
                                    text: "Alias: ",
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  TextSpan(text: details.alias),
                                ],
                              ),
                              textAlign: TextAlign.start),
                          Padding(
                            padding: EdgeInsets.all(8),
                          ),
                          CupertinoButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            color: Colors.red,
                            child: Text("Dismiss"),
                          ),
                        ],
                      ),
                    ),
                  );
                },
                context: context);
          },
          onLongPress: () {
            showDialog(
                barrierDismissible: false,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text("Selectable Summary"),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Flexible(
                          child: SingleChildScrollView(
                            child: SelectableText(details.summary),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.all(8),
                        ),
                        CupertinoButton(
                          child: Text("Dismiss"),
                          color: Colors.red,
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                      ],
                    ),
                  );
                },
                context: context);
          },
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: cardColor.withOpacity(isDark ? 0.5 : 0.2),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  ClipRRect(
                    child: Image.network(details.image,
                        height:
                            min(200, MediaQuery.of(context).size.width / 3) *
                                1.5,
                        width: min(200, MediaQuery.of(context).size.width / 3),
                        fit: BoxFit.cover,
                        alignment: Alignment.center),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  Padding(
                    padding: EdgeInsets.all(8),
                  ),
                  Expanded(
                    child: SizedBox(
                      height:
                          min(200, MediaQuery.of(context).size.width / 3) * 1.5,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Expanded(
                            child: Center(
                              child: Text(details.summary,
                                  overflow: TextOverflow.fade),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.all(8),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              FloatingActionButton.extended(
                                  label: Text("Play"),
                                  icon: Icon(Icons.play_arrow_rounded),
                                  foregroundColor: Colors.white,
                                  onPressed: () async {
                                    int epNum = _getLatestEpisode(details);

                                    await Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (BuildContext context) {
                                          return PlayerLoadingPage(
                                              url: details.episodes[epNum].url,
                                              name: details.episodes[epNum].name,
                                              anime: details,
                                              detailsState: setState);
                                        },
                                      ),
                                    );

                                    // Update episode progress when returned to page
                                    setState(() {});
                                  },
                                  backgroundColor: Colors.red,
                                  heroTag: "play"),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      if (double.tryParse(details.score) != null)
        Positioned(
          top: 5,
          right: 5,
          child: Tooltip(
            message: "Open MyAnimeList",
            child: InkWell(
              borderRadius: BorderRadius.circular(15),
              onTap: () =>
                  launchUrlString('https://myanimelist.net/anime/${details.malID}'),
              child: Card(
                color:
                    Color.alphaBlend(cardColor.withOpacity(0.8), Colors.black),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                elevation: 8,
                child: Padding(
                  padding: EdgeInsets.all(8),
                  child: Row(
                    children: [
                      Icon(Icons.star),
                      Padding(
                        padding: EdgeInsets.all(2),
                      ),
                      Text(
                        double.parse(details.score).toStringAsFixed(2),
                        style: TextStyle(fontSize: 20),
                      ),
                      Padding(
                        padding: EdgeInsets.all(2),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
    ],
  );
}

int _getLatestEpisode(AnimeDetails details) {
  int epNum = details.episodes.length - 1;

  // Find last bookmarked episode
  while (epNum >= 0 &&
      !Storage.isBookmarked(details.url, details.episodes[epNum].url)) {
    epNum--;
  }

  // If no episode was bookmarked
  if (epNum < 0) epNum = 0;

  // Skip episode if finished (progress >= 90%)
  if (Storage.isBookmarked(details.url, details.episodes[epNum].url) &&
      (Storage.getEpisodePosition(details.url, details.episodes[epNum].url) /
              Storage.getEpisodeDuration(
                  details.url, details.episodes[epNum].url)) >=
          0.9) epNum++;

  // If entire finished last episode, go to beginning
  if (epNum >= details.episodes.length) epNum = 0;

  return epNum;
}
