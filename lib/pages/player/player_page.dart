import 'dart:async';
import 'dart:io';

import 'package:dart_vlc/dart_vlc.dart' as Vlc;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:miru/data/persistent_data/data_storage.dart';
import 'package:miru/data/structures/anime_details.dart';
import 'package:miru/pages/player/functions/keyboard_events.dart';
import 'package:miru/pages/player/functions/video.dart';
import 'package:miru/pages/player/widgets/popup.dart';
import 'package:miru/pages/player/widgets/seek_targets_layer.dart';
import 'package:video_player/video_player.dart';
import 'package:wakelock/wakelock.dart';

import 'widgets/darken_layer.dart';

class Player extends StatefulWidget {
  final String name;
  final String url;
  final String sourceUrl;
  final AnimeDetails anime;
  final List<String> lastEpisode;
  final List<String> nextEpisode;
  final Function detailsState;

  const Player(
      {required this.name,
      required this.url,
      required this.sourceUrl,
      required this.anime,
      required this.lastEpisode,
      required this.nextEpisode,
      required this.detailsState,
      Key? key})
      : super(key: key);

  static bool showPopup = true;

  @override
  _PlayerState createState() => _PlayerState();
}

class _PlayerState extends State<Player> {
  Video? video;
  Timer? close;
  bool isInitialized = false;

  FocusNode keyboardFocus = FocusNode();

  @override
  void initState() {
    if (!Storage.isBookmarked(widget.anime.url, widget.sourceUrl)) {
      Storage.addEpisode(
          widget.name.substring(widget.name.lastIndexOf("Episode")),
          widget.sourceUrl,
          widget.anime);
    }
    video = Video(
      url: widget.url,
      onInitialized: (Video video) {
        if (!mounted) return;
        setState(
          () {
            int position =
                Storage.getEpisodePosition(widget.anime.url, widget.sourceUrl);
            int duration =
                Storage.getEpisodeDuration(widget.anime.url, widget.sourceUrl);
            if (position != duration && position != 0) {
              video.seekTo(
                Duration(
                  milliseconds: Storage.getEpisodePosition(
                      widget.anime.url, widget.sourceUrl),
                ),
              );
            }
            video.play();
            Wakelock.enable();
            setTimer();
            isInitialized = true;
          },
        );
      },
      setPopup: setPopup,
      setState: (void Function() function) {
        if (mounted) setState(function);
      },
    );
    SystemChrome.setPreferredOrientations(
      [DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight],
    );
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    super.initState();
  }

  @override
  void dispose() {
    Wakelock.disable();
    SystemChrome.setPreferredOrientations(
      [
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
        DeviceOrientation.portraitDown,
        DeviceOrientation.portraitUp
      ],
    );
    SystemChrome.restoreSystemUIOverlays();
    if (isInitialized) {
      video!.pause();
      video!.dispose();
    }
    super.dispose();
  }

  @override
  void deactivate() {
    if (isInitialized) {
      video!.pause();
      if (video!.getPosition().inSeconds != 0) {
        Storage.updateEpisodeTime(
            widget.anime.url,
            widget.sourceUrl,
            video!.getPosition().inMilliseconds,
            video!.getDuration().inMilliseconds);
      }
    }
    widget.detailsState(() {});
    unsetTimer();
    super.deactivate();
  }

  @override
  Widget build(BuildContext context) {
    if (!isInitialized) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            Positioned(
              left: 30,
              top: 30,
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(500),
                  child: Container(
                    height: 50,
                    width: 50,
                    child: Icon(Icons.close_rounded,
                        color: Colors.white, size: 30),
                  ),
                  onTap: () {
                    unsetTimer();
                    Navigator.of(context).pop();
                  },
                ),
              ),
            ),
            Center(
              child: CupertinoActivityIndicator(),
            ),
          ],
        ),
      );
    }
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: RawKeyboardListener(
          focusNode: keyboardFocus,
          autofocus: true,
          onKey: (RawKeyEvent e) =>
              keyboardEvents(context, e, video!, setPopup, setState),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Video
              if (Platform.isIOS || Platform.isAndroid)
                AspectRatio(
                  aspectRatio: video!.getDetails().value.aspectRatio,
                  child: VideoPlayer(
                    video!.getDetails(),
                  ),
                ),
              if (Platform.isWindows || Platform.isLinux)
                Vlc.Video(player: video?.vlcPlayer, width: 1920, height: 1080),

              for (Widget i in darkenLayer()) i,

              // Buffering Indicator
              Opacity(
                opacity: video!.isBuffering && Player.showPopup ? 1 : 0,
                child: SizedBox(
                  height: 70,
                  width: 70,
                  child: CircularProgressIndicator(color: Colors.white),
                ),
              ),

              seekTargetsLayer(context, togglePopup, video!, setPopup, setState,
                  setTimer, unsetTimer),

              AnimatedOpacity(
                duration: Duration(milliseconds: 200),
                opacity: Player.showPopup ? 1 : 0,
                child: IgnorePointer(
                  ignoring: !Player.showPopup,
                  child: Popup(
                      video: video!,
                      name: widget.name,
                      url: widget.url,
                      sourceUrl: widget.sourceUrl,
                      anime: widget.anime,
                      setPopup: setPopup,
                      setTimer: setTimer,
                      unsetTimer: unsetTimer,
                      lastEpisode: widget.lastEpisode,
                      nextEpisode: widget.nextEpisode,
                      detailsState: widget.detailsState,
                      setState: setState),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void setPopup(bool set) {
    if (!mounted) return;
    setState(
      () {
        Player.showPopup = set;
      },
    );
  }

  void togglePopup() {
    setPopup(!Player.showPopup);
    if (Player.showPopup)
      setTimer();
    else
      unsetTimer();
  }

  void unsetTimer() {
    if (close != null && close!.isActive) close!.cancel();
    close = null;
  }

  void setTimer() {
    if (close != null && close!.isActive) close!.cancel();
    close = Timer(
      Duration(seconds: 2),
      () {
        if (!mounted) return;
        if (video!.isPlaying()) {
          setPopup(false);
        }
      },
    );
  }
}
