import 'dart:async';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_xlider/flutter_xlider.dart';
import 'package:miru/data/structures/anime_details.dart';
import 'package:miru/pages/watch_page/functions/controls.dart';
import 'package:miru/pages/watch_page/functions/formatter.dart';
import 'package:miru/pages/watch_page/loading.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share/share.dart';
import 'package:video_player/video_player.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:wakelock/wakelock.dart';

class Popup extends StatefulWidget {
  final VideoPlayerController controller;
  final String name;
  final String url;
  final String sourceUrl;
  final AnimeDetails anime;
  final Function setPopup;
  final Function setTimer;
  final Function unsetTimer;
  final List<String> lastEpisode;
  final List<String> nextEpisode;
  final Function detailsState;

  static double volume = 1;

  const Popup(
      {required this.controller,
      required this.name,
      required this.url,
      required this.sourceUrl,
      required this.anime,
      required this.setPopup,
      required this.setTimer,
      required this.unsetTimer,
      required this.lastEpisode,
      required this.nextEpisode,
      required this.detailsState,
      Key? key})
      : super(key: key);

  @override
  _PopupState createState() => _PopupState();
}

class _PopupState extends State<Popup> {
  Timer? timer;

  @override
  void initState() {
    super.initState();
    Timer.periodic(Duration(milliseconds: 100), (Timer t) {
      if (!mounted) t.cancel();
      if (t.tick == 1) timer = t;
      setState(() {});
    });
  }

  @override
  void deactivate() {
    if (timer != null) timer!.cancel();
    timer = null;
    super.deactivate();
  }

  @override
  Widget build(BuildContext context) {
    Duration? buffered;
    List<DurationRange> bufferedList = widget.controller.value.buffered;
    for (var i in bufferedList) {
      if (buffered == null)
        buffered = i.end;
      else {
        if (buffered.inMilliseconds < i.end.inMilliseconds) buffered = i.end;
      }
    }

    return Container(
        child: Stack(alignment: Alignment.center, children: [
      // Play Button Row
      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        Material(
            color: Colors.transparent,
            child: InkWell(
                borderRadius: BorderRadius.circular(500),
                child: Container(
                    height: 80,
                    width: 80,
                    child: Icon(CupertinoIcons.gobackward_10,
                        color: Colors.white, size: 30)),
                onTap: () {
                  Seek.seek(
                      widget.controller, SeekDirection.BACKWARDS, 10, setState);
                  widget.setTimer();
                },
                onLongPress: () {
                  Seek.seek(
                      widget.controller, SeekDirection.BACKWARDS, 83, setState);
                  widget.setTimer();
                })),
        Padding(padding: EdgeInsets.all(24)),
        Stack(alignment: Alignment.center, children: [
          Material(
              color: Colors.transparent,
              child: InkWell(
                  borderRadius: BorderRadius.circular(500),
                  child: Container(
                      height: 80,
                      width: 80,
                      child: Icon(
                          widget.controller.value.isPlaying
                              ? Icons.pause_rounded
                              : Icons.play_arrow_rounded,
                          color: Colors.white,
                          size: 60)),
                  onTap: () {
                    setState(() {
                      if (widget.controller.value.isPlaying) {
                        widget.controller.pause();
                        Wakelock.disable();
                        widget.unsetTimer();
                      } else {
                        widget.controller.play();
                        Wakelock.enable();
                        widget.setPopup(false);
                      }
                    });
                  }))
        ]),
        Padding(padding: EdgeInsets.all(24)),
        Material(
            color: Colors.transparent,
            child: InkWell(
                borderRadius: BorderRadius.circular(500),
                child: Container(
                    height: 80,
                    width: 80,
                    child: Icon(CupertinoIcons.goforward_10,
                        color: Colors.white, size: 30)),
                onTap: () {
                  Seek.seek(
                      widget.controller, SeekDirection.FORWARDS, 10, setState);
                  widget.setTimer();
                },
                onLongPress: () {
                  Seek.seek(
                      widget.controller, SeekDirection.FORWARDS, 83, setState);
                  widget.setTimer();
                }))
      ]),
      // Bottom Scroll Indicators
      Column(mainAxisAlignment: MainAxisAlignment.end, children: [
        Row(children: [
          Padding(padding: EdgeInsets.all(8)),
          Container(
              width: widget.controller.value.duration.inHours > 0 ? 90 : 60,
              child: Center(
                  child: Text(
                      formatDuration(widget.controller.value.position,
                          widget.controller.value.duration),
                      style: TextStyle(color: Colors.white)))),
          Expanded(child: Container()),
          Container(
              width: widget.controller.value.duration.inHours > 0 ? 90 : 60,
              child: Center(
                  child: Text(
                      formatDuration(
                          widget.controller.value.duration -
                              widget.controller.value.position,
                          widget.controller.value.duration),
                      style: TextStyle(color: Colors.white)))),
          Padding(padding: EdgeInsets.all(8))
        ]),
        SizedBox(
            height: 25,
            child: Stack(children: [
              Positioned(
                  left: 10,
                  right: 10,
                  child: SizedBox(
                      height: 25,
                      child: FlutterSlider(
                          selectByTap: false,
                          values: [
                            min(
                                widget.controller.value.duration.inMicroseconds
                                    .toDouble(),
                                max(
                                    0,
                                    buffered == null
                                        ? 0
                                        : buffered.inMicroseconds.toDouble()))
                          ],
                          min: 0,
                          max: widget.controller.value.duration.inMicroseconds
                              .toDouble(),
                          trackBar: FlutterSliderTrackBar(
                              activeTrackBar: BoxDecoration(
                                  color: Colors.white60,
                                  borderRadius: BorderRadius.circular(15)),
                              inactiveTrackBar: BoxDecoration(
                                  color: Colors.transparent,
                                  borderRadius: BorderRadius.circular(15))),
                          handler: FlutterSliderHandler(opacity: 0),
                          onDragging: null,
                          handlerWidth: 20,
                          handlerHeight: 20))),
              Positioned(
                  left: 10,
                  right: 10,
                  child: SizedBox(
                      height: 25,
                      child: FlutterSlider(
                          values: [
                            widget.controller.value.position.inMicroseconds
                                .toDouble()
                          ],
                          selectByTap: false,
                          handlerWidth: 20,
                          handlerHeight: 20,
                          min: 0,
                          max: widget.controller.value.duration.inMicroseconds
                              .toDouble(),
                          onDragStarted: (handlerIndex, firstValue, secondValue) {
                            widget.unsetTimer();
                          },
                          onDragCompleted:
                              (handlerIndex, firstValue, secondValue) {
                            widget.setTimer();
                          },
                          onDragging:
                              (handlerIndex, firstValue, secondValue) async {
                            await widget.controller.seekTo(
                                Duration(microseconds: firstValue.floor()));
                            setState(() {});
                          },
                          tooltip: FlutterSliderTooltip(
                              direction: FlutterSliderTooltipDirection.top,
                              textStyle: TextStyle(color: Colors.black),
                              format: (text) => formatDuration(
                                  Duration(
                                      microseconds: double.parse(text).floor()),
                                  widget.controller.value.duration),
                              boxStyle: FlutterSliderTooltipBox(
                                  decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(15))),
                              positionOffset:
                                  FlutterSliderTooltipPositionOffset(top: -10)),
                          trackBar: FlutterSliderTrackBar(
                              activeTrackBarHeight: 5,
                              activeTrackBar: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(15)),
                              inactiveTrackBar: BoxDecoration(
                                  color: Colors.white24,
                                  borderRadius: BorderRadius.circular(15))),
                          handler: FlutterSliderHandler(
                              decoration: BoxDecoration(color: Colors.tealAccent, shape: BoxShape.circle),
                              child: Container()))))
            ])),
        Padding(padding: EdgeInsets.all(8))
      ]),
      // Top Toolbar
      Column(children: [
        Padding(padding: EdgeInsets.all(4)),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Padding(padding: EdgeInsets.all(8)),
          // Close Button
          Material(
              color: Colors.transparent,
              child: InkWell(
                  borderRadius: BorderRadius.circular(500),
                  child: Tooltip(
                      message: 'Close',
                      child: Container(
                          height: 50,
                          width: 50,
                          child: Icon(Icons.close_rounded,
                              color: Colors.white, size: 30))),
                  onTap: () {
                    Navigator.of(context).pop();
                  })),
          Padding(padding: EdgeInsets.all(20)),
          IgnorePointer(
              ignoring: widget.lastEpisode.isEmpty,
              child: Opacity(
                  opacity: widget.lastEpisode.isEmpty ? 0 : 1,
                  child: FloatingActionButton.extended(
                      elevation: 0,
                      foregroundColor: Colors.white,
                      onPressed: widget.lastEpisode.isEmpty
                          ? null
                          : () {
                              Navigator.of(context).pushReplacement(
                                  MaterialPageRoute(
                                      builder: (BuildContext context) =>
                                          Loading(
                                              anime: widget.anime,
                                              detailsState: widget.detailsState,
                                              name: widget.lastEpisode[0],
                                              url: widget.lastEpisode[1])));
                            },
                      heroTag: "lastEp",
                      backgroundColor: Colors.transparent,
                      icon: Icon(Icons.navigate_before_rounded),
                      label: Text("Last Episode")))),
          Expanded(
              child: Center(
                  child: (MediaQuery.of(context).size.height > 500)
                      ? Container(
                          decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(15)),
                          padding: EdgeInsets.symmetric(
                              vertical: 8, horizontal: 12),
                          child: Text(widget.name,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.white)))
                      : Container())),
          IgnorePointer(
              ignoring: widget.nextEpisode.isEmpty,
              child: Opacity(
                  opacity: widget.nextEpisode.isEmpty ? 0 : 1,
                  child: FloatingActionButton.extended(
                      elevation: 0,
                      foregroundColor: Colors.white,
                      onPressed: widget.nextEpisode.isEmpty
                          ? null
                          : () {
                              Navigator.of(context).pushReplacement(
                                  MaterialPageRoute(
                                      builder: (BuildContext context) =>
                                          Loading(
                                              anime: widget.anime,
                                              detailsState: widget.detailsState,
                                              name: widget.nextEpisode[0],
                                              url: widget.nextEpisode[1])));
                            },
                      heroTag: "nextEp",
                      backgroundColor: Colors.transparent,
                      icon: Icon(Icons.navigate_next_rounded),
                      label: Text("Next Episode")))),
          Padding(padding: EdgeInsets.all(10)),
          Material(
              color: Colors.transparent,
              child: InkWell(
                  borderRadius: BorderRadius.circular(500),
                  child: Tooltip(
                      message: 'Save Frame',
                      child: Container(
                          height: 50,
                          width: 50,
                          child: Icon(Icons.add_photo_alternate_outlined,
                              color: Colors.white, size: 30))),
                  onTap: () async {
                    widget.controller.pause();
                    Wakelock.disable();
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        behavior: SnackBarBehavior.floating,
                        content: Text("Saving Frame..."),
                        duration: Duration(seconds: 2)));
                    String? fileName = await VideoThumbnail.thumbnailFile(
                        video: widget.url,
                        imageFormat: ImageFormat.PNG,
                        maxHeight: 0,
                        maxWidth: 0,
                        quality: 100,
                        timeMs: widget.controller.value.position.inMilliseconds,
                        thumbnailPath: (await getTemporaryDirectory()).path);
                    if (fileName != null)
                      Share.shareFiles([fileName]);
                    else {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          behavior: SnackBarBehavior.floating,
                          content: Text("Failed to save frame"),
                          duration: Duration(seconds: 3)));
                    }
                  })),
          Padding(padding: EdgeInsets.all(8))
        ])
      ]),
      if (MediaQuery.of(context).size.height > 500)
        Positioned(
            left: 10,
            top: 100,
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  IconButton(
                      icon: Icon(widget.controller.value.volume != 0
                          ? Icons.volume_up_rounded
                          : Icons.volume_off_rounded),
                      tooltip: "Volume",
                      iconSize: 30,
                      onPressed: () {
                        if (widget.controller.value.volume == 0) {
                          widget.controller.setVolume(
                              Popup.volume == 0 ? 0.5 : Popup.volume);
                        } else {
                          widget.controller.setVolume(0);
                        }
                      }),
                  SizedBox(
                      height: 200,
                      child: Container(
                          height: 20,
                          child: FlutterSlider(
                              min: 0,
                              max: 100,
                              handlerWidth: 20,
                              handlerHeight: 20,
                              selectByTap: false,
                              tooltip: FlutterSliderTooltip(
                                  direction:
                                      FlutterSliderTooltipDirection.right,
                                  textStyle: TextStyle(color: Colors.black),
                                  format: (text) =>
                                      double.parse(text).floor().toString() +
                                      "%",
                                  boxStyle: FlutterSliderTooltipBox(
                                      decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(15)))),
                              trackBar: FlutterSliderTrackBar(
                                  activeTrackBarHeight: 5,
                                  activeTrackBar: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(15)),
                                  inactiveTrackBar: BoxDecoration(
                                      color: Colors.white24,
                                      borderRadius: BorderRadius.circular(15))),
                              handler: FlutterSliderHandler(
                                  decoration: BoxDecoration(
                                      color: Colors.tealAccent,
                                      shape: BoxShape.circle),
                                  child: Container()),
                              onDragStarted:
                                  (handlerIndex, firstValue, secondValue) {
                                widget.unsetTimer();
                              },
                              onDragCompleted:
                                  (handlerIndex, firstValue, secondValue) {
                                widget.setTimer();
                              },
                              onDragging:
                                  (handlerIndex, lowerValue, upperValue) {
                                widget.controller.setVolume(lowerValue / 100);
                                Popup.volume = lowerValue / 100;
                              },
                              axis: Axis.vertical,
                              rtl: true,
                              values: [
                                max(min(widget.controller.value.volume, 1), 0) *
                                    100
                              ])))
                ])),
      if (MediaQuery.of(context).size.height > 500)
        Positioned(
            right: 10,
            top: 100,
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  IconButton(
                      icon: Icon(Icons.speed_rounded),
                      disabledColor: Colors.white,
                      tooltip: "Playback Speed",
                      onPressed: () {
                        widget.controller.setPlaybackSpeed(1);
                      }),
                  SizedBox(
                      height: 200,
                      child: Container(
                          height: 20,
                          child: FlutterSlider(
                              min: 0.25,
                              max: 1.75,
                              handlerWidth: 20,
                              handlerHeight: 20,
                              selectByTap: false,
                              step: FlutterSliderStep(step: 0.25),
                              tooltip: FlutterSliderTooltip(
                                  direction: FlutterSliderTooltipDirection.left,
                                  textStyle: TextStyle(color: Colors.black),
                                  format: (text) =>
                                      double.parse(text).toString() + "x",
                                  boxStyle: FlutterSliderTooltipBox(
                                      decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(15)))),
                              trackBar: FlutterSliderTrackBar(
                                  activeTrackBarHeight: 5,
                                  activeTrackBar: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(15)),
                                  inactiveTrackBar: BoxDecoration(
                                      color: Colors.white24,
                                      borderRadius: BorderRadius.circular(15))),
                              handler: FlutterSliderHandler(
                                  decoration: BoxDecoration(
                                      color: Colors.tealAccent,
                                      shape: BoxShape.circle),
                                  child: Container()),
                              onDragStarted:
                                  (handlerIndex, firstValue, secondValue) {
                                widget.unsetTimer();
                              },
                              onDragCompleted:
                                  (handlerIndex, firstValue, secondValue) {
                                widget.setTimer();
                              },
                              onDragging:
                                  (handlerIndex, lowerValue, upperValue) {
                                widget.controller.setPlaybackSpeed(lowerValue);
                              },
                              axis: Axis.vertical,
                              rtl: true,
                              values: [
                                max(
                                    min(widget.controller.value.playbackSpeed,
                                        2),
                                    0.25)
                              ])))
                ]))
    ]));
  }
}
