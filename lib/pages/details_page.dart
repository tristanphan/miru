import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animation_progress_bar/flutter_animation_progress_bar.dart';
import 'package:miru/data/persistent_data/data_storage.dart';
import 'package:miru/data/structures/anime_details.dart';
import 'package:miru/info.dart';
import 'package:miru/pages/details_loading_page.dart';
import 'package:miru/pages/download_page.dart';
import 'package:miru/pages/home/header_silver_builder.dart';
import 'package:miru/pages/home/home_card.dart';
import 'package:miru/pages/player/functions/formatter.dart';
import 'package:miru/pages/player/player_loading_page.dart';
import 'package:palette_generator/palette_generator.dart';

class DetailsPage2 extends StatefulWidget {
  final AnimeDetails details;
  final String title;
  final String url;
  final HomeCard homeCard;

  const DetailsPage2(
      {Key? key,
      required this.details,
      required this.title,
      required this.url,
      required this.homeCard})
      : super(key: key);

  @override
  _DetailsPage2State createState() => _DetailsPage2State();
}

class _DetailsPage2State extends State<DetailsPage2> {
  @override
  Widget build(BuildContext context) {
    AnimeDetails details = widget.details;
    bool pinned = Storage.isPinned(widget.url);
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    Color cardColor;
    PaletteColor? cardSet = isDark
        ? details.palette.vibrantColor
        : details.palette.lightVibrantColor;
    if (cardSet == null) {
      cardColor = isDark ? Colors.blueGrey : Colors.lightBlueAccent.shade100;
    } else {
      cardColor = cardSet.color;
    }
    return Scaffold(
        floatingActionButton: FloatingActionButton.extended(
            onPressed: () {
              showInfo(
                  context: context,
                  url: widget.url,
                  name: widget.title,
                  image: details.image,
                  setState: setState);
            },
            label: Text(pinned ? "Unpin" : "Pin"),
            icon: Icon(pinned ? Icons.favorite : Icons.favorite_border),
            foregroundColor: pinned
                ? Colors.white
                : isDark
                    ? Colors.black
                    : Colors.white,
            backgroundColor: pinned
                ? Colors.red
                : isDark
                    ? Colors.white
                    : Colors.black),
        body: NestedScrollView(
            headerSliverBuilder: (BuildContext context, bool scroll) =>
                headerSilverBuilder(context, widget.title),
            body: Container(
                height: double.maxFinite,
                child: RefreshIndicator(
                    color: isDark ? Colors.black : Colors.white,
                    backgroundColor: isDark ? Colors.white : Colors.black,
                    onRefresh: () async {
                      Navigator.of(context).pushReplacement(MaterialPageRoute(
                          builder: (BuildContext context) => DetailsLoadingPage(
                              homeCard: widget.homeCard,
                              title: widget.title,
                              url: widget.url)));
                    },
                    child: Scrollbar(
                        child: SingleChildScrollView(
                            child: Column(children: [
                      Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16.0, vertical: 16),
                          child: Container(
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  color: cardColor
                                      .withOpacity(isDark ? 0.2 : 0.2)),
                              child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Row(children: [
                                    ClipRRect(
                                        child: Image.network(details.image,
                                            height: min(
                                                    200,
                                                    MediaQuery.of(context)
                                                            .size
                                                            .width /
                                                        3) *
                                                1.5,
                                            width: min(
                                                200,
                                                MediaQuery.of(context)
                                                        .size
                                                        .width /
                                                    3),
                                            fit: BoxFit.cover,
                                            alignment: Alignment.center),
                                        borderRadius:
                                            BorderRadius.circular(15)),
                                    Padding(padding: EdgeInsets.all(8)),
                                    Expanded(
                                        child: SizedBox(
                                            height: min(
                                                    200,
                                                    MediaQuery.of(context)
                                                            .size
                                                            .width /
                                                        3) *
                                                1.5,
                                            child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.end,
                                                children: [
                                                  Expanded(
                                                      child: GestureDetector(
                                                          onTap: () {
                                                            showDialog(
                                                                barrierDismissible:
                                                                    false,
                                                                builder:
                                                                    (BuildContext
                                                                        context) {
                                                                  return AlertDialog(
                                                                      title: Text(
                                                                          "Selectable Summary"),
                                                                      shape: RoundedRectangleBorder(
                                                                          borderRadius: BorderRadius.circular(
                                                                              15)),
                                                                      content: Column(
                                                                          mainAxisSize:
                                                                              MainAxisSize.min,
                                                                          children: [
                                                                            Flexible(child: SingleChildScrollView(child: SelectableText(details.summary))),
                                                                            Padding(padding: EdgeInsets.all(8)),
                                                                            CupertinoButton(
                                                                                child: Text("Dismiss"),
                                                                                color: Colors.red,
                                                                                onPressed: () {
                                                                                  Navigator.of(context).pop();
                                                                                })
                                                                          ]));
                                                                },
                                                                context:
                                                                    context);
                                                          },
                                                          child: Center(
                                                              child: Text(
                                                                  details
                                                                      .summary,
                                                                  overflow:
                                                                      TextOverflow
                                                                          .fade)))),
                                                  Padding(
                                                      padding:
                                                          EdgeInsets.all(8)),
                                                  Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment.end,
                                                      children: [
                                                        FloatingActionButton(
                                                            heroTag:
                                                                "moreInfoMini",
                                                            mini: true,
                                                            onPressed: () {
                                                              showDialog(
                                                                  barrierDismissible:
                                                                      false,
                                                                  builder:
                                                                      (BuildContext
                                                                          context) {
                                                                    return AlertDialog(
                                                                        title: Text(
                                                                            "More Info"),
                                                                        shape: RoundedRectangleBorder(
                                                                            borderRadius:
                                                                                BorderRadius.circular(15)),
                                                                        content: SingleChildScrollView(
                                                                            child: Column(mainAxisSize: MainAxisSize.min, children: [
                                                                          SelectableText.rich(
                                                                              TextSpan(children: [
                                                                                TextSpan(text: "Type: ", style: TextStyle(fontWeight: FontWeight.bold)),
                                                                                TextSpan(text: "${details.type}\n\n"),
                                                                                TextSpan(text: "Genre: ", style: TextStyle(fontWeight: FontWeight.bold)),
                                                                                TextSpan(text: "${details.genre}\n\n"),
                                                                                TextSpan(text: "Released: ", style: TextStyle(fontWeight: FontWeight.bold)),
                                                                                TextSpan(text: "${details.released}\n\n"),
                                                                                TextSpan(text: "Status: ", style: TextStyle(fontWeight: FontWeight.bold)),
                                                                                TextSpan(text: "${details.status}\n\n"),
                                                                                TextSpan(text: "Alias: ", style: TextStyle(fontWeight: FontWeight.bold)),
                                                                                TextSpan(text: details.alias)
                                                                              ]),
                                                                              textAlign: TextAlign.start),
                                                                          Padding(
                                                                              padding: EdgeInsets.all(8)),
                                                                          CupertinoButton(
                                                                              onPressed: () {
                                                                                Navigator.of(context).pop();
                                                                              },
                                                                              color: Colors.red,
                                                                              child: Text("Dismiss"))
                                                                        ])));
                                                                  },
                                                                  context:
                                                                      context);
                                                            },
                                                            backgroundColor:
                                                                isDark
                                                                    ? Colors
                                                                        .white
                                                                    : Colors
                                                                        .black,
                                                            foregroundColor:
                                                                isDark
                                                                    ? Colors
                                                                        .black
                                                                    : Colors
                                                                        .white,
                                                            child: Icon(
                                                                Icons.info),
                                                            tooltip:
                                                                "More Info"),
                                                        Padding(
                                                            padding:
                                                                EdgeInsets.all(
                                                                    4)),
                                                        FloatingActionButton
                                                            .extended(
                                                                label: Text(
                                                                    "Play"),
                                                                icon: Icon(Icons
                                                                    .play_arrow_rounded),
                                                                foregroundColor:
                                                                    Colors
                                                                        .white,
                                                                onPressed:
                                                                    () async {
                                                                  int epNum = details
                                                                          .episodes
                                                                          .length -
                                                                      1;
                                                                  while (epNum >=
                                                                          0 &&
                                                                      !Storage.isBookmarked(
                                                                          details
                                                                              .url,
                                                                          details
                                                                              .episodes[epNum]
                                                                              .url)) {
                                                                    epNum--;
                                                                  }
                                                                  if (epNum < 0)
                                                                    epNum = 0;
                                                                  if (Storage.isBookmarked(
                                                                          details
                                                                              .url,
                                                                          details
                                                                              .episodes[
                                                                                  epNum]
                                                                              .url) &&
                                                                      Storage.getEpisodeDuration(details.url, details.episodes[epNum].url) ==
                                                                          Storage.getEpisodePosition(
                                                                              details
                                                                                  .url,
                                                                              details.episodes[epNum].url))
                                                                    epNum++;
                                                                  if (epNum >=
                                                                      details
                                                                          .episodes
                                                                          .length)
                                                                    epNum = 0;
                                                                  await Navigator.of(
                                                                          context)
                                                                      .push(MaterialPageRoute(builder:
                                                                          (BuildContext
                                                                              context) {
                                                                    return Loading(
                                                                        url: details
                                                                            .episodes[
                                                                                epNum]
                                                                            .url,
                                                                        name: details.name +
                                                                            " " +
                                                                            details
                                                                                .episodes[
                                                                                    epNum]
                                                                                .name,
                                                                        anime:
                                                                            details,
                                                                        detailsState:
                                                                            setState);
                                                                  }));
                                                                  setState(
                                                                      () {});
                                                                },
                                                                backgroundColor:
                                                                    Colors.red,
                                                                heroTag: "play")
                                                      ])
                                                ])))
                                  ])))),
                      Padding(padding: EdgeInsets.all(4)),
                      Divider(height: 0),
                      MediaQuery.removePadding(
                          removeTop: true,
                          context: context,
                          child: ListView.separated(
                              physics: NeverScrollableScrollPhysics(),
                              itemCount: details.episodes.length,
                              shrinkWrap: true,
                              itemBuilder: (BuildContext context, int index) {
                                int episodeTime = 0;
                                int totalTime = 0;
                                bool bookmarked = pinned &&
                                    Storage.isBookmarked(details.url,
                                        details.episodes[index].url);
                                if (bookmarked) {
                                  episodeTime = Storage.getEpisodePosition(
                                      details.url, details.episodes[index].url);
                                  totalTime = Storage.getEpisodeDuration(
                                      details.url, details.episodes[index].url);
                                }
                                return InkWell(
                                    onTap: () async {
                                      await Navigator.of(context).push(
                                          MaterialPageRoute(
                                              builder: (BuildContext context) {
                                        return Loading(
                                            url: details.episodes[index].url,
                                            name: details.name +
                                                " " +
                                                details.episodes[index].name,
                                            anime: details,
                                            detailsState: setState);
                                      }));
                                      setState(() {});
                                    },
                                    onLongPress: () {
                                      downloadPopup(details, index);
                                    },
                                    child: Container(
                                        height: 60,
                                        padding: EdgeInsets.all(4),
                                        child: Row(children: [
                                          Padding(padding: EdgeInsets.all(8)),
                                          Text(details.episodes[index].name,
                                              style: TextStyle(fontSize: 20)),
                                          bookmarked
                                              ? Expanded(
                                                  child: Column(
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .end,
                                                      children: [
                                                      if (episodeTime == 0)
                                                        Text("Not Started",
                                                            style: TextStyle(
                                                                fontSize: 20)),
                                                      if (episodeTime ==
                                                          totalTime)
                                                        Text("Finished",
                                                            style: TextStyle(
                                                                fontSize: 20)),
                                                      if (episodeTime != 0 &&
                                                          episodeTime !=
                                                              totalTime)
                                                        Text(
                                                            formatDuration(
                                                                    Duration(
                                                                        milliseconds:
                                                                            episodeTime),
                                                                    Duration(
                                                                        milliseconds:
                                                                            episodeTime)) +
                                                                " / " +
                                                                formatDuration(
                                                                    Duration(
                                                                        milliseconds:
                                                                            totalTime),
                                                                    Duration(
                                                                        milliseconds:
                                                                            totalTime)),
                                                            style: TextStyle(
                                                                fontSize: 20)),
                                                      ConstrainedBox(
                                                          constraints:
                                                              BoxConstraints(
                                                                  maxWidth:
                                                                      200),
                                                          child: Row(
                                                              mainAxisSize:
                                                                  MainAxisSize
                                                                      .min,
                                                              children: [
                                                                Padding(
                                                                    padding: EdgeInsets.only(
                                                                        right:
                                                                            16)),
                                                                Text(((episodeTime / totalTime * 10000).floor() /
                                                                            100)
                                                                        .toString() +
                                                                    "%"),
                                                                Padding(
                                                                    padding: EdgeInsets.only(
                                                                        right:
                                                                            8)),
                                                                Expanded(
                                                                    child: FAProgressBar(
                                                                        borderRadius: BorderRadius.circular(
                                                                            15),
                                                                        animatedDuration: Duration(
                                                                            milliseconds:
                                                                                100),
                                                                        maxValue:
                                                                            totalTime,
                                                                        size: 5,
                                                                        backgroundColor:
                                                                            Colors
                                                                                .white24,
                                                                        progressColor:
                                                                            Colors
                                                                                .white,
                                                                        currentValue:
                                                                            episodeTime))
                                                              ]))
                                                    ]))
                                              : Expanded(child: Container()),
                                          Padding(padding: EdgeInsets.all(4)),
                                          if (bookmarked)
                                            IconButton(
                                                tooltip: "Remove Bookmark",
                                                icon: Icon(() {
                                                  if (bookmarked)
                                                    return Icons.bookmark_added;
                                                  else
                                                    return Icons
                                                        .bookmark_add_outlined;
                                                }()),
                                                onPressed: () {
                                                  Storage.toggleEpisode(
                                                      details
                                                          .episodes[index].url,
                                                      details);
                                                  setState(() {});
                                                }),
                                          Padding(padding: EdgeInsets.all(4)),
                                          Icon(Icons.navigate_next),
                                          Padding(padding: EdgeInsets.all(8))
                                        ])));
                              },
                              separatorBuilder:
                                  (BuildContext context, int index) =>
                                      Divider(height: 0)))
                    ])))))));
  }

  void downloadPopup(AnimeDetails details, int index) {
    showCupertinoModalPopup(
        context: context,
        builder: (BuildContext context) {
          return CupertinoAlertDialog(
              actions: [
                CupertinoActionSheetAction(
                    onPressed: () async {
                      await Navigator.of(context).pushReplacement(
                          MaterialPageRoute(builder: (BuildContext context) {
                        return Download(
                            name: details.name +
                                " (" +
                                details.episodes[index].name +
                                ")",
                            url: details.episodes[index].url);
                      }));
                      setState(() {});
                    },
                    child: Text("Yes")),
                CupertinoActionSheetAction(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    isDestructiveAction: true,
                    child: Text("No"))
              ],
              content: Text("Do you want to download " +
                  details.episodes[index].name +
                  "?"),
              title: Text("Download"));
        });
  }
}
