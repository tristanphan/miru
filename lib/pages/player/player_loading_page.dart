import 'package:flutter/material.dart';
import 'package:flutter_animation_progress_bar/flutter_animation_progress_bar.dart';
import 'package:miru/data/sources/sources.dart';
import 'package:miru/data/structures/anime_details.dart';
import 'package:miru/pages/home/home_card.dart';
import 'package:miru/pages/player/player_page.dart';

class PlayerLoadingPage extends StatefulWidget {
  final String name;
  final String url;
  final AnimeDetails anime;
  final Function detailsState;
  final String? customCrawler;

  const PlayerLoadingPage(
      {required this.name,
      required this.url,
      required this.anime,
      required this.detailsState,
      Key? key,
      this.customCrawler})
      : super(key: key);

  @override
  _PlayerLoadingPageState createState() => _PlayerLoadingPageState();
}

class _PlayerLoadingPageState extends State<PlayerLoadingPage> {
  String loadingProgress = "";
  int progress = 0;

  @override
  void initState() {
    Sources.get(widget.customCrawler).getVideo(widget.url, changeProgress).then(
      (video) {
        if (!mounted) return;
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => Player(
                name: video!.title,
                url: video.url,
                sourceUrl: widget.url,
                anime: widget.anime,
                detailsState: widget.detailsState,
                lastEpisode: video.last,
                nextEpisode: video.next),
          ),
        );
      },
      onError: (obj, stackTrace) {
        print(stackTrace);
        Navigator.of(context).pop();
      },
    );
    super.initState();
  }

  void changeProgress(String newProgress, int percent) {
    if (!mounted) return;
    setState(
      () {
        progress += percent;
        loadingProgress = newProgress;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        body: Container(
          width: double.maxFinite,
          height: double.maxFinite,
          child: Stack(
            alignment: Alignment.center,
            children: [
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
                    subtext: widget.name,
                  ),
                  Padding(
                    padding: EdgeInsets.all(4),
                  ),
                  Container(
                    width: 300,
                    child: FAProgressBar(
                        borderRadius: BorderRadius.circular(15),
                        animatedDuration: Duration(milliseconds: 300),
                        maxValue: 100,
                        size: 10,
                        backgroundColor:
                            isDark ? Colors.white24 : Colors.black26,
                        progressColor: isDark ? Colors.white : Colors.black,
                        currentValue: progress.toDouble()),
                  ),
                  Padding(
                    padding: EdgeInsets.all(4),
                  ),
                  Text(
                    loadingProgress,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
