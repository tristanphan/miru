import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animation_progress_bar/flutter_animation_progress_bar.dart';
import 'package:miru/data/cache.dart';
import 'package:miru/data/sources/sources.dart';
import 'package:miru/data/structures/anime_details.dart';
import 'package:miru/data/structures/video_details.dart';
import 'package:miru/pages/watch_page/player.dart';

class Loading extends StatefulWidget {
  final String name;
  final String url;
  final AnimeDetails anime;
  final Function detailsState;

  const Loading(
      {required this.name,
      required this.url,
      required this.anime,
      required this.detailsState,
      Key? key})
      : super(key: key);

  @override
  _LoadingState createState() => _LoadingState();
}

class _LoadingState extends State<Loading> {
  String loadingProgress = "";
  int progress = 0;
  bool fallback = false;

  @override
  void initState() {
    if (Cache.loadedVideos.containsKey(widget.url)) {
      VideoDetails video = Cache.loadedVideos[widget.url]!;
      Future(() => Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (context) => Player(
              name: video.title,
              url: video.url,
              sourceUrl: widget.url,
              anime: widget.anime,
              detailsState: widget.detailsState,
              lastEpisode: video.last,
              nextEpisode: video.next))));
    } else {
      Sources.get().getVideo(widget.url, changeProgress).then((video) {
        if (!mounted) return;
        Cache.loadedVideos[widget.url] = video!;
        Navigator.of(context)
            .pushReplacement(MaterialPageRoute(builder: (context) {
          return Player(
              name: video.title,
              url: video.url,
              sourceUrl: widget.url,
              anime: widget.anime,
              detailsState: widget.detailsState,
              lastEpisode: video.last,
              nextEpisode: video.next);
        }));
      });
    }
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void changeProgress(String newProgress) {
    setState(() {
      progress += 34;
      loadingProgress = newProgress;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
        data: ThemeData.dark(),
        child: Scaffold(
            backgroundColor: Colors.black,
            body: Container(
                width: double.maxFinite,
                height: double.maxFinite,
                child: Stack(alignment: Alignment.center, children: [
                  Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text((fallback ? "Fallback: " : "") + loadingProgress,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold)),
                        Padding(padding: EdgeInsets.all(4)),
                        Container(
                            width: 300,
                            child: FAProgressBar(
                                borderRadius: BorderRadius.circular(15),
                                animatedDuration: Duration(milliseconds: 300),
                                maxValue: 100,
                                size: 10,
                                backgroundColor: Colors.white24,
                                progressColor: Colors.white,
                                currentValue: progress)),
                        Padding(padding: EdgeInsets.all(4)),
                        Text(widget.name,
                            style: TextStyle(fontSize: 20),
                            textAlign: TextAlign.center)
                      ]),
                  Positioned(
                      top: 40,
                      left: 20,
                      child: FloatingActionButton.extended(
                          heroTag: "back",
                          backgroundColor: Colors.white12,
                          foregroundColor: Colors.white,
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          label: Text("Back"),
                          icon: Icon(Icons.navigate_before_rounded)))
                ]))));
  }
}
