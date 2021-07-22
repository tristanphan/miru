import 'dart:async';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:miru/data/data_storage.dart';
import 'package:miru/data/structures/anime_details.dart';
import 'package:miru/functions/fetch_video.dart';
import 'package:miru/pages/watch_page/functions/controls.dart';
import 'package:miru/pages/watch_page/popup.dart';
import 'package:video_player/video_player.dart';
import 'package:wakelock/wakelock.dart';

import 'emergency_view.dart';

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
  VideoPlayerController? controller;
  Timer? close;

  FocusNode keyboardFocus = FocusNode();

  @override
  void initState() {
    if (!isBookmarked(widget.sourceUrl))
      addEpisode(widget.sourceUrl, widget.anime);
    controller = VideoPlayerController.network(widget.url);
    controller!.initialize().then((value) {
      setState(() {
        if (isBookmarked(widget.sourceUrl) &&
            getEpisodeTime(widget.sourceUrl) !=
                getEpisodeTotalTime(widget.sourceUrl))
          controller!
              .seekTo(Duration(milliseconds: getEpisodeTime(widget.sourceUrl)));
        controller!.play();
        Wakelock.enable();
        setTimer();
      });
    });
    controller!.addListener(() async {
      if (controller!.value.hasError) {
        String url = await errorVideoUrl.future;
        controller!.pause();
        Navigator.of(context).push(MaterialPageRoute(
            builder: (BuildContext context) => EmergencyView(url)));
      }
    });
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);
    SystemChrome.setEnabledSystemUIOverlays([]);
    super.initState();
  }

  @override
  void dispose() {
    Wakelock.disable();
    controller!.dispose();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
      DeviceOrientation.portraitDown,
      DeviceOrientation.portraitUp
    ]);
    SystemChrome.setEnabledSystemUIOverlays(
        [SystemUiOverlay.top, SystemUiOverlay.bottom]);
    super.dispose();
  }

  @override
  void deactivate() {
    controller!.pause();
    if (isBookmarked(widget.sourceUrl) &&
        controller != null &&
        controller!.value.isInitialized) {
      updateEpisodeTime(
          widget.sourceUrl,
          controller!.value.position.inMilliseconds,
          controller!.value.duration.inMilliseconds);
    }
    widget.detailsState(() {});
    unsetTimer();
    super.deactivate();
  }

  @override
  Widget build(BuildContext context) {
    if (controller == null || !controller!.value.isInitialized) {
      return Scaffold(
          backgroundColor: Colors.black,
          body: Stack(children: [
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
                                color: Colors.white, size: 30)),
                        onTap: () {
                          unsetTimer();
                          Navigator.of(context).pop();
                        }))),
            Center(child: CupertinoActivityIndicator())
          ]));
    }
    return WillPopScope(
        onWillPop: () async => false,
        child: Scaffold(
            backgroundColor: Colors.black,
            body: RawKeyboardListener(
                focusNode: keyboardFocus,
                autofocus: true,
                onKey: (RawKeyEvent e) {
                  if (!(e is RawKeyDownEvent)) return;
                  if (e.physicalKey ==
                      PhysicalKeyboardKey
                          .space) if (controller!.value.isPlaying) {
                    controller!.pause();
                    Wakelock.disable();
                    setPopup(true);
                  } else {
                    controller!.play();
                    Wakelock.enable();
                    setPopup(false);
                  }

                  if (e.physicalKey == PhysicalKeyboardKey.arrowLeft) {
                    if (e.isShiftPressed)
                      Seek.seek(
                          controller!, SeekDirection.BACKWARDS, 83, setState);
                    else
                      Seek.seek(
                          controller!, SeekDirection.BACKWARDS, 5, setState);
                    Seek.animation(SeekDirection.BACKWARDS, setState);
                  }

                  if (e.physicalKey == PhysicalKeyboardKey.arrowRight) {
                    if (e.isShiftPressed)
                      Seek.seek(
                          controller!, SeekDirection.FORWARDS, 83, setState);
                    else
                      Seek.seek(
                          controller!, SeekDirection.FORWARDS, 5, setState);
                    Seek.animation(SeekDirection.FORWARDS, setState);
                  }

                  if (e.physicalKey == PhysicalKeyboardKey.arrowUp) {
                    if (e.isShiftPressed) {
                      controller!.setPlaybackSpeed(
                          min(2, controller!.value.playbackSpeed + 0.25));
                    } else {
                      controller!
                          .setVolume(min(1, controller!.value.volume + 0.1));
                      Popup.volume = min(1, controller!.value.volume + 0.1);
                    }
                  }

                  if (e.physicalKey == PhysicalKeyboardKey.arrowDown) {
                    if (e.isShiftPressed) {
                      controller!.setPlaybackSpeed(
                          max(0.25, controller!.value.playbackSpeed - 0.25));
                    } else {
                      controller!
                          .setVolume(max(0, controller!.value.volume - 0.1));
                    }
                    Popup.volume = max(0, controller!.value.volume - 0.1);
                  }
                },
                child: Stack(alignment: Alignment.center, children: [
                  AspectRatio(
                      aspectRatio: controller!.value.aspectRatio,
                      child: VideoPlayer(controller!)),
                  AnimatedOpacity(
                      duration: Duration(milliseconds: 200),
                      opacity: Player.showPopup
                          ? 1
                          : Seek.darkenLeft || Seek.darkenRight
                              ? 0.5
                              : 0,
                      child: Container(color: Color.fromRGBO(0, 0, 0, 0.4))),
                  // Seek Icons, shows on double tap only
                  AnimatedOpacity(
                      duration: Duration(milliseconds: 200),
                      opacity: Seek.darkenLeft ? 1 : 0,
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Padding(padding: EdgeInsets.all(48)),
                            Icon(CupertinoIcons.gobackward,
                                color: Colors.white, size: 90)
                          ])),
                  AnimatedOpacity(
                      duration: Duration(milliseconds: 200),
                      opacity: Seek.darkenRight ? 1 : 0,
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Icon(CupertinoIcons.goforward,
                                color: Colors.white, size: 90),
                            Padding(padding: EdgeInsets.all(48))
                          ])),
                  Opacity(
                      opacity: controller!.value.isBuffering && Player.showPopup
                          ? 1
                          : 0,
                      child: SizedBox(
                          height: 70,
                          width: 70,
                          child:
                              CircularProgressIndicator(color: Colors.white))),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SizedBox(
                            height: MediaQuery.of(context).size.height,
                            width: MediaQuery.of(context).size.width * 0.3,
                            // Left Seek
                            child: GestureDetector(
                                onTap: showHidePopup,
                                onLongPress: null,
                                onDoubleTap: () {
                                  Seek.seek(controller!,
                                      SeekDirection.BACKWARDS, 5, setState);
                                  Seek.animation(
                                      SeekDirection.BACKWARDS, setState);
                                })),
                        // Play Double Tap
                        SizedBox(
                            height: MediaQuery.of(context).size.height,
                            width: MediaQuery.of(context).size.width * 0.4,
                            // Left Seek
                            child: GestureDetector(
                                onTap: showHidePopup,
                                onLongPress: null,
                                onDoubleTap: () {
                                  setState(() {
                                    if (controller!.value.isPlaying) {
                                      controller!.pause();
                                      Wakelock.disable();
                                      setPopup(true);
                                    } else {
                                      controller!.play();
                                      Wakelock.enable();
                                      setPopup(false);
                                    }
                                    unsetTimer();
                                  });
                                })),
                        SizedBox(
                            height: MediaQuery.of(context).size.height,
                            width: MediaQuery.of(context).size.width * 0.3,
                            // Right Seek
                            child: GestureDetector(
                                onTap: showHidePopup,
                                onLongPress: null,
                                onDoubleTap: () {
                                  Seek.seek(controller!, SeekDirection.FORWARDS,
                                      5, setState);
                                  Seek.animation(
                                      SeekDirection.FORWARDS, setState);
                                }))
                      ]),
                  AnimatedOpacity(
                      duration: Duration(milliseconds: 200),
                      opacity: Player.showPopup ? 1 : 0,
                      child: IgnorePointer(
                          ignoring: !Player.showPopup,
                          child: Popup(
                              controller: controller!,
                              name: widget.name,
                              url: widget.url,
                              sourceUrl: widget.sourceUrl,
                              anime: widget.anime,
                              setPopup: setPopup,
                              setTimer: setTimer,
                              unsetTimer: unsetTimer,
                              lastEpisode: widget.lastEpisode,
                              nextEpisode: widget.nextEpisode,
                              detailsState: widget.detailsState)))
                ]))));
  }

  void setPopup(bool set) {
    setState(() {
      Player.showPopup = set;
    });
  }

  void unsetTimer() {
    if (close != null && close!.isActive) close!.cancel();
    close = null;
  }

  void setTimer() {
    if (close != null && close!.isActive) close!.cancel();
    close = Timer(Duration(seconds: 2), () {
      if (!mounted) return;
      if (controller!.value.isPlaying) {
        setPopup(false);
      }
    });
  }

  void showHidePopup() {
    setPopup(!Player.showPopup);
    if (Player.showPopup)
      setTimer();
    else
      unsetTimer();
  }
}
