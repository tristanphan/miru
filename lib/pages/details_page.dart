import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animation_progress_bar/flutter_animation_progress_bar.dart';
import 'package:miru/data/anime.dart';
import 'package:miru/data/data_storage.dart';
import 'package:miru/data/structures/anime_details.dart';
import 'package:miru/data/temporary_memory.dart';
import 'package:miru/info.dart';
import 'package:miru/pages/download_page.dart';
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
  Future<AnimeDetails>? details;

  @override
  Widget build(BuildContext context) {
    bool pinned = isPinned(widget.url);
    if (details == null) {
      if (loadedDetails.containsKey(widget.url))
        details = (() async => loadedDetails[widget.url]!)();
      else {
        details = Anime.getDetails(widget.url);
        details!.then((value) => loadedDetails[widget.url] = value);
      }
    }

    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            icon: Icon(Icons.info),
            onPressed: () {
              showInfo(context);
            },
          ),
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                details = null;
                loadedDetails.remove(widget.url);
              });
            },
          )
        ],
        centerTitle: true,
        title: Text(widget.title),
      ),
      body: FutureBuilder(
        future: details,
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting || snapshot.data == null)
            return Center(
              child: CupertinoActivityIndicator(),
            );
          AnimeDetails details = snapshot.data;
          return SingleChildScrollView(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 16),
                  child: Card(
                    elevation: 8,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          ClipRRect(
                            child: Image.network(
                              details.image,
                              height: min(200,
                                      MediaQuery.of(context).size.width / 2) *
                                  3 /
                                  2,
                              width: min(
                                  200, MediaQuery.of(context).size.width / 2),
                              fit: BoxFit.cover,
                              alignment: Alignment.center,
                            ),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          Padding(
                            padding: EdgeInsets.all(8),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                InkWell(
                                  borderRadius: BorderRadius.circular(15),
                                  onTap: () {
                                    showDialog(
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            title: Text("Selectable Summary"),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(15),
                                            ),
                                            content: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Flexible(
                                                  child: SingleChildScrollView(
                                                    child: SelectableText(
                                                        details.summary),
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
                                                )
                                              ],
                                            ),
                                          );
                                        },
                                        context: context);
                                  },
                                  child: Container(
                                    padding: EdgeInsets.all(8),
                                    height: min(
                                            200,
                                            MediaQuery.of(context).size.width /
                                                2) *
                                        6 /
                                        5,
                                    child: Center(
                                      child: Text(
                                        details.summary,
                                        overflow: TextOverflow.fade,
                                      ),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.all(8),
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    FloatingActionButton(
                                      heroTag: Random().nextDouble(),
                                      mini: true,
                                      tooltip: "Pin Anime",
                                      backgroundColor:
                                          Color.fromRGBO(100, 100, 100, 1),
                                      foregroundColor: Colors.white,
                                      onPressed: () {
                                        togglePin(widget.url, widget.title,
                                            details.image);
                                        setState(() {});
                                      },
                                      child: Icon(
                                        () {
                                          if (pinned)
                                            return Icons.bookmark_added;
                                          else
                                            return Icons.bookmark_add_outlined;
                                        }(),
                                      ),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.all(8),
                                    ),
                                    FloatingActionButton.extended(
                                      heroTag: Random().nextDouble(),
                                      onPressed: () {
                                        showDialog(
                                            builder: (BuildContext context) {
                                              return AlertDialog(
                                                title: Text("More Info"),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(15),
                                                ),
                                                content: SingleChildScrollView(
                                                  child: Column(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      SelectableText.rich(
                                                        TextSpan(children: [
                                                          TextSpan(
                                                            text: "Type: ",
                                                            style: TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold),
                                                          ),
                                                          TextSpan(
                                                              text:
                                                                  "${details.type}\n\n"),
                                                          TextSpan(
                                                            text: "Genre: ",
                                                            style: TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold),
                                                          ),
                                                          TextSpan(
                                                              text:
                                                                  "${details.genre}\n\n"),
                                                          TextSpan(
                                                            text: "Released: ",
                                                            style: TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold),
                                                          ),
                                                          TextSpan(
                                                              text:
                                                                  "${details.released}\n\n"),
                                                          TextSpan(
                                                            text: "Status: ",
                                                            style: TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold),
                                                          ),
                                                          TextSpan(
                                                              text:
                                                                  "${details.status}\n\n"),
                                                          TextSpan(
                                                            text: "Alias: ",
                                                            style: TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold),
                                                          ),
                                                          TextSpan(
                                                              text: details
                                                                  .alias),
                                                        ]),
                                                        textAlign:
                                                            TextAlign.start,
                                                      ),
                                                      Padding(
                                                        padding:
                                                            EdgeInsets.all(8),
                                                      ),
                                                      CupertinoButton(
                                                        onPressed: () {
                                                          Navigator.of(context)
                                                              .pop();
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
                                      backgroundColor: Colors.teal,
                                      foregroundColor: Colors.white,
                                      icon: Icon(Icons.info),
                                      label: Text("More Info"),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(8),
                ),
                Divider(height: 0),
                ListView.separated(
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: details.episodes.length,
                  shrinkWrap: true,
                  itemBuilder: (BuildContext context, int index) {
                    int episodeTime = 0;
                    int totalTime = 0;
                    bool marked =
                        pinned && isMarked(details.episodes[index].url);
                    if (marked) {
                      episodeTime = getEpisodeTime(details.episodes[index].url);
                      totalTime =
                          getEpisodeTotalTime(details.episodes[index].url);
                    }
                    return InkWell(
                      onTap: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (BuildContext context) {
                              return Loading(
                                url: details.episodes[index].url,
                                name: details.name +
                                    " " +
                                    details.episodes[index].name,
                                anime: details,
                                detailsState: setState,
                              );
                            },
                          ),
                        );
                        setState(() {});
                      },
                      child: Container(
                        padding: EdgeInsets.all(4),
                        child: Row(
                          children: [
                            Padding(
                              padding: EdgeInsets.all(6),
                            ),
                            IconButton(
                              onPressed: () async {
                                await Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (BuildContext context) {
                                      return Download(
                                          name: details.name +
                                              " (" +
                                              details.episodes[index].name +
                                              ")",
                                          url: details.episodes[index].url);
                                    },
                                  ),
                                );
                                setState(() {});
                              },
                              icon: Icon(Icons.cloud_download_outlined),
                            ),
                            Padding(
                              padding: EdgeInsets.all(8),
                            ),
                            Text(
                              details.episodes[index].name,
                              style: TextStyle(fontSize: 20),
                            ),
                            Expanded(
                              child: Container(),
                            ),
                            if (marked)
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  if (episodeTime == 0)
                                    Text(
                                      "Not Started",
                                      style: TextStyle(fontSize: 20),
                                    ),
                                  if (episodeTime == totalTime)
                                    Text(
                                      "Finished",
                                      style: TextStyle(fontSize: 20),
                                    ),
                                  if (episodeTime != 0 &&
                                      episodeTime != totalTime)
                                    Text(
                                      formatDuration(
                                            Duration(milliseconds: episodeTime),
                                            Duration(milliseconds: episodeTime),
                                          ) +
                                          " / " +
                                          formatDuration(
                                            Duration(milliseconds: totalTime),
                                            Duration(milliseconds: totalTime),
                                          ),
                                      style: TextStyle(fontSize: 20),
                                    ),
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(((episodeTime / totalTime * 10000)
                                                      .floor() /
                                                  100)
                                              .toString() +
                                          "%"),
                                      Padding(
                                        padding: EdgeInsets.only(right: 8),
                                      ),
                                      SizedBox(
                                        width: 200,
                                        child: FAProgressBar(
                                          borderRadius:
                                              BorderRadius.circular(15),
                                          animatedDuration:
                                              Duration(milliseconds: 100),
                                          maxValue: totalTime,
                                          size: 5,
                                          backgroundColor: Colors.white24,
                                          progressColor: Colors.white,
                                          currentValue: episodeTime,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            IconButton(
                              tooltip: "Mark Episode",
                              icon: Icon(
                                () {
                                  if (marked)
                                    return Icons.bookmark_added;
                                  else
                                    return Icons.bookmark_add_outlined;
                                }(),
                              ),
                              onPressed: () {
                                toggleEpisode(
                                    details.episodes[index].url, details);
                                setState(() {});
                              },
                            ),
                            Padding(
                              padding: EdgeInsets.all(4),
                            ),
                            Icon(Icons.navigate_next),
                            Padding(
                              padding: EdgeInsets.all(8),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                  separatorBuilder: (BuildContext context, int index) {
                    return Divider(
                      height: 0,
                    );
                  },
                )
              ],
            ),
          );
        },
      ),
    );
  }
}
