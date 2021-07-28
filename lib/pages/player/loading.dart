import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animation_progress_bar/flutter_animation_progress_bar.dart';
import 'package:miru/data/sources/sources.dart';
import 'package:miru/data/structures/anime_details.dart';
import 'package:miru/pages/home/home_card.dart';
import 'package:miru/pages/player/player.dart';

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

  @override
  void initState() {
    Sources.get().getVideo(widget.url, changeProgress).then((video) {
      if (!mounted) return;
      Navigator.of(context)
          .pushReplacement(MaterialPageRoute(builder: (context) {
        return Player(
            name: video!.title,
            url: video.url,
            sourceUrl: widget.url,
            anime: widget.anime,
            detailsState: widget.detailsState,
            lastEpisode: video.last,
            nextEpisode: video.next);
      }));
    });
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void changeProgress(String newProgress, int percent) {
    if (!mounted) return;
    setState(() {
      progress += percent;
      loadingProgress = newProgress;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
        data: ThemeData.dark(),
        child: Scaffold(
            body: Container(
                width: double.maxFinite,
                height: double.maxFinite,
                child: Stack(alignment: Alignment.center, children: [
                  Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        HomeCard(
                            title: widget.anime.name,
                            setState: setState,
                            width: 350,
                            img: widget.anime.image,
                            url: '',
                            palette: widget.anime.palette,
                            subtext:
                                "Episode " + widget.name.split('Episode ')[1]),
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
                        Text(loadingProgress,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold))
                      ]),
                  Positioned(
                      top: 40,
                      left: 20,
                      child: FloatingActionButton.extended(
                          heroTag: "back",
                          backgroundColor: Colors.black,
                          foregroundColor: Colors.white,
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          label: Text("Back"),
                          icon: Icon(Icons.navigate_before_rounded)))
                ]))));
  }
}
