import 'dart:async';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animation_progress_bar/flutter_animation_progress_bar.dart';
import 'package:miru/data/anime.dart';
import 'package:miru/data/structures/anime_details.dart';
import 'package:miru/data/structures/video_details.dart';
import 'package:miru/data/temporary_memory.dart';
import 'package:miru/functions/fetch_video.dart';
import 'package:miru/pages/watch_page/player.dart';

import 'emergency_view.dart';

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
    super.initState();
    if (loadedVideos.containsKey(widget.url)) {
      VideoDetails video = loadedVideos[widget.url]!;
      Future(() => Navigator.of(context)
              .pushReplacement(MaterialPageRoute(builder: (context) {
            return Player(
                name: video.title,
                url: video.url,
                sourceUrl: widget.url,
                anime: widget.anime,
                detailsState: widget.detailsState,
                lastEpisode: video.last,
                nextEpisode: video.next);
          })));
    } else {
      Anime.getVideoWithProgress(widget.url, changeProgress).then((video) {
        if (!mounted) return;
        if (video == null) {
          if (!errorVideoUrl.isCompleted) Navigator.of(context).pop();
          errorVideoUrl.future.then((url) {
            Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (BuildContext context) {
              return EmergencyView(url);
            }));
            errorVideoUrl = Completer<String>();
          });
          return;
        } else {
          loadedVideos[widget.url] = video;
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
        }
      });
    }
  }

  void changeProgress(String newProgress) {
    setState(() {
      progress += 34;
      loadingProgress = newProgress;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.black,
        body: Container(
            width: double.maxFinite,
            height: double.maxFinite,
            child: Stack(alignment: Alignment.center, children: [
              Column(mainAxisSize: MainAxisSize.min, children: [
                Text((fallback ? "Fallback: " : "") + loadingProgress,
                    style:
                        TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
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
                Text(widget.name, style: TextStyle(fontSize: 20))
              ]),
              Positioned(
                  top: 40,
                  right: 20,
                  child: Opacity(
                      opacity: fallback ? 0 : 1,
                      child: FloatingActionButton.extended(
                          heroTag: Random().nextDouble(),
                          backgroundColor: Colors.white12,
                          foregroundColor: Colors.white,
                          onPressed: () {
                            setState(() {
                              fallback = true;
                              errorVideoUrl.future.then((url) {
                                Navigator.of(context).pushReplacement(
                                    MaterialPageRoute(
                                        builder: (BuildContext context) {
                                  return EmergencyView(url);
                                }));
                                errorVideoUrl = Completer<String>();
                              });
                            });
                          },
                          label: Text("Fallback"),
                          icon: Icon(Icons.error_outline_rounded)))),
              Positioned(
                  top: 40,
                  left: 20,
                  child: FloatingActionButton.extended(
                      heroTag: Random().nextDouble(),
                      backgroundColor: Colors.white12,
                      foregroundColor: Colors.white,
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      label: Text("Back"),
                      icon: Icon(Icons.navigate_before_rounded)))
            ])));
  }
}
