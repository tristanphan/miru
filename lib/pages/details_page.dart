import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animation_progress_bar/flutter_animation_progress_bar.dart';
import 'package:miru/data/anime.dart';
import 'package:miru/data/data_storage.dart';
import 'package:miru/data/structures/anime_details.dart';
import 'package:miru/data/temporary_memory.dart';
import 'package:miru/info.dart';
import 'package:miru/pages/watch_page/functions/formatter.dart';
import 'package:miru/pages/watch_page/loading.dart';

class DetailsPage extends StatefulWidget {
  final String title;
  final String url;

  const DetailsPage({Key? key, required this.title, required this.url})
      : super(key: key);

  @override
  _DetailsPageState createState() => _DetailsPageState();
}

class _DetailsPageState extends State<DetailsPage> {
  Future<AnimeDetails>? detailsFuture;

  @override
  Widget build(BuildContext context) {
    bool pinned = isPinned(widget.url);
    if (detailsFuture == null) {
      if (loadedDetails.containsKey(widget.url))
        detailsFuture = (() async => loadedDetails[widget.url]!)();
      else {
        detailsFuture = Anime.getDetails(widget.url);
        detailsFuture!.then((value) => loadedDetails[widget.url] = value);
      }
    }

    return FutureBuilder(
        future: detailsFuture,
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting ||
              snapshot.data == null)
            return Scaffold(
                appBar: AppBar(centerTitle: true, title: Text(widget.title)),
                body: Center(child: CupertinoActivityIndicator()));
          AnimeDetails details = snapshot.data;
          return Scaffold(
              appBar: AppBar(actions: [
                IconButton(
                    icon: Icon(pinned ? Icons.favorite : Icons.favorite_border),
                    color: pinned ? Colors.pink : Colors.white,
                    tooltip: "Pin",
                    onPressed: () async {
                      showInfo(
                          context: context,
                          url: details.url,
                          name: details.name,
                          image: details.image,
                          setState: setState);
                    })
              ], centerTitle: true, title: Text(widget.title)),
              body: Container(
                  height: double.maxFinite,
                  child: RefreshIndicator(
                      color: Colors.black,
                      backgroundColor: Colors.white,
                      onRefresh: () async {
                        setState(() {
                          detailsFuture = null;
                          loadedDetails.remove(widget.url);
                        });
                      },
                      child: SingleChildScrollView(
                          child: Column(children: [
                        Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16.0, vertical: 16),
                            child: Card(
                                elevation: 8,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15)),
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
                                                            MainAxisAlignment
                                                                .end,
                                                        children: [
                                                          FloatingActionButton(
                                                              heroTag: Random()
                                                                  .nextDouble(),
                                                              mini: true,
                                                              onPressed: () {
                                                                showDialog(
                                                                    builder:
                                                                        (BuildContext
                                                                            context) {
                                                                      return AlertDialog(
                                                                          title: Text(
                                                                              "More Info"),
                                                                          shape:
                                                                              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
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
                                                                            Padding(padding: EdgeInsets.all(8)),
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
                                                                  Colors.teal,
                                                              foregroundColor:
                                                                  Colors.white,
                                                              child: Icon(
                                                                  Icons.info),
                                                              tooltip:
                                                                  "More Info"),
                                                          Padding(
                                                              padding:
                                                                  EdgeInsets
                                                                      .all(4)),
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
                                                                    int epNum =
                                                                        details.episodes.length -
                                                                            1;
                                                                    while (epNum >=
                                                                            0 &&
                                                                        !isBookmarked(details
                                                                            .episodes[epNum]
                                                                            .url)) {
                                                                      epNum--;
                                                                    }
                                                                    if (epNum <
                                                                        0)
                                                                      epNum = 0;
                                                                    if (isBookmarked(details
                                                                            .episodes[
                                                                                epNum]
                                                                            .url) &&
                                                                        getEpisodeTotalTime(details.episodes[epNum].url) ==
                                                                            getEpisodeTime(details.episodes[epNum].url))
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
                                                                              details.episodes[epNum].name,
                                                                          anime: details,
                                                                          detailsState: setState);
                                                                    }));
                                                                    setState(
                                                                        () {});
                                                                  },
                                                                  backgroundColor:
                                                                      Colors
                                                                          .red)
                                                        ])
                                                  ])))
                                    ])))),
                        Padding(padding: EdgeInsets.all(8)),
                        Divider(height: 0),
                        ListView.separated(
                            physics: NeverScrollableScrollPhysics(),
                            itemCount: details.episodes.length,
                            shrinkWrap: true,
                            itemBuilder: (BuildContext context, int index) {
                              int episodeTime = 0;
                              int totalTime = 0;
                              bool bookmarked = pinned &&
                                  isBookmarked(details.episodes[index].url);
                              if (bookmarked) {
                                episodeTime =
                                    getEpisodeTime(details.episodes[index].url);
                                totalTime = getEpisodeTotalTime(
                                    details.episodes[index].url);
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
                                  child: Container(
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
                                                        CrossAxisAlignment.end,
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
                                                                maxWidth: 200),
                                                        child: Row(
                                                            mainAxisSize:
                                                                MainAxisSize
                                                                    .min,
                                                            children: [
                                                              Padding(
                                                                  padding: EdgeInsets
                                                                      .only(
                                                                          right:
                                                                              16)),
                                                              Text(((episodeTime / totalTime * 10000)
                                                                              .floor() /
                                                                          100)
                                                                      .toString() +
                                                                  "%"),
                                                              Padding(
                                                                  padding: EdgeInsets
                                                                      .only(
                                                                          right:
                                                                              8)),
                                                              Expanded(
                                                                  child: FAProgressBar(
                                                                      borderRadius:
                                                                          BorderRadius.circular(
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
                                                toggleEpisode(
                                                    details.episodes[index].url,
                                                    details);
                                                setState(() {});
                                              }),
                                        Padding(padding: EdgeInsets.all(4)),
                                        Icon(Icons.navigate_next),
                                        Padding(padding: EdgeInsets.all(8))
                                      ])));
                            },
                            separatorBuilder:
                                (BuildContext context, int index) {
                              return Divider(height: 0);
                            })
                      ])))));
        });
  }
}
