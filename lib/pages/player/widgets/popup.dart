import 'dart:async';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_xlider/flutter_xlider.dart';
import 'package:miru/data/structures/anime_details.dart';
import 'package:miru/pages/player/functions/formatter.dart';
import 'package:miru/pages/player/functions/frame.dart';
import 'package:miru/pages/player/functions/seek.dart';
import 'package:miru/pages/player/functions/video.dart';
import 'package:miru/pages/player/player_loading_page.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wakelock/wakelock.dart';

class Popup extends StatefulWidget {
  final Video video;
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
  final Function setState;

  static double volume = 1;

  const Popup(
      {required this.video,
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
      required this.setState,
      Key? key})
      : super(key: key);

  @override
  _PopupState createState() => _PopupState();
}

class _PopupState extends State<Popup> {
  Timer? timer;
  Duration position = Duration();
  bool _lockPosition = false;
  bool _isPlayingBeforeScrub = false;
  double speed = 1.0;

  @override
  void initState() {
    super.initState();
    Timer.periodic(
      Duration(milliseconds: 100),
      (Timer t) {
        if (!mounted) t.cancel();
        if (t.tick == 1) timer = t;
        setState(
          () {}
        );
      },
    );
  }

  @override
  void setState(VoidCallback fn) {
    if (!_lockPosition) {
      position = widget.video.getPosition();
    }
    super.setState(fn);
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
    buffered = widget.video.getBuffered();

    return Container(
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Play Button Row
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(500),
                  child: Container(
                    height: 80,
                    width: 80,
                    child:
                        Icon(Icons.fast_rewind, color: Colors.white, size: 40),
                  ),
                  onTap: () {
                    Seek.seek(widget.video, SeekDirection.BACKWARDS, 5,
                        widget.setState);
                    widget.setTimer();
                  },
                  onLongPress: () {
                    Seek.seek(widget.video, SeekDirection.BACKWARDS, 83,
                        widget.setState);
                    widget.setTimer();
                  },
                ),
              ),
              Padding(
                padding: EdgeInsets.all(24),
              ),
              Stack(
                alignment: Alignment.center,
                children: [
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(500),
                      child: Container(
                        height: 80,
                        width: 80,
                        child: Icon(
                            widget.video.isPlaying()
                                ? Icons.pause
                                : Icons.play_arrow,
                            color: Colors.white,
                            size: 60),
                      ),
                      onTap: () {
                        setState(
                          () {
                            if (widget.video.isPlaying()) {
                              widget.video.pause();
                              Wakelock.disable();
                              widget.unsetTimer();
                            } else {
                              widget.video.play();
                              Wakelock.enable();
                              widget.setPopup(false);
                            }
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
              Padding(
                padding: EdgeInsets.all(24),
              ),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(500),
                  child: Container(
                    height: 80,
                    width: 80,
                    child:
                        Icon(Icons.fast_forward, color: Colors.white, size: 40),
                  ),
                  onTap: () {
                    Seek.seek(widget.video, SeekDirection.FORWARDS, 5,
                        widget.setState);
                    widget.setTimer();
                  },
                  onLongPress: () {
                    Seek.seek(widget.video, SeekDirection.FORWARDS, 83,
                        widget.setState);
                    widget.setTimer();
                  },
                ),
              ),
            ],
          ),
          // Bottom Scroll Indicators
          Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Row(
                children: [
                  Padding(
                    padding: EdgeInsets.all(8),
                  ),
                  Container(
                    width: widget.video.getDuration().inHours > 0 ? 90 : 60,
                    child: Center(
                      child: Text(
                        formatDuration(
                          position,
                          widget.video.getDuration(),
                        ),
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(),
                  ),
                  Container(
                    width: widget.video.getDuration().inHours > 0 ? 90 : 60,
                    child: Center(
                      child: Text(
                        formatDuration(
                          widget.video.getDuration() - position,
                          widget.video.getDuration(),
                        ),
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(8),
                  ),
                ],
              ),
              SizedBox(
                height: 25,
                child: Stack(
                  children: [
                    Positioned(
                      left: 10,
                      right: 10,
                      child: SizedBox(
                        height: 25,
                        width: MediaQuery.of(context).size.width,
                        child: FlutterSlider(
                            selectByTap: false,
                            values: [
                              min(
                                widget.video
                                    .getDuration()
                                    .inMicroseconds
                                    .toDouble(),
                                max(
                                  0,
                                  buffered.inMicroseconds.toDouble(),
                                ),
                              ),
                            ],
                            min: 0,
                            max: widget.video
                                .getDuration()
                                .inMicroseconds
                                .toDouble(),
                            trackBar: FlutterSliderTrackBar(
                              activeTrackBar: BoxDecoration(
                                color: Colors.white60,
                                borderRadius: BorderRadius.circular(15),
                              ),
                              inactiveTrackBar: BoxDecoration(
                                color: Colors.transparent,
                                borderRadius: BorderRadius.circular(15),
                              ),
                            ),
                            handler: FlutterSliderHandler(opacity: 0),
                            onDragging: null,
                            handlerWidth: 20,
                            handlerHeight: 20),
                      ),
                    ),
                    Positioned(
                      left: 10,
                      right: 10,
                      child: SizedBox(
                        height: 25,
                        width: MediaQuery.of(context).size.width,
                        child: FlutterSlider(
                          values: [
                            position.inMicroseconds.toDouble(),
                          ],
                          selectByTap: true,
                          handlerWidth: 20,
                          handlerHeight: 20,
                          min: 0,
                          max: widget.video
                              .getDuration()
                              .inMicroseconds
                              .toDouble(),
                          onDragStarted:
                              (handlerIndex, firstValue, secondValue) {
                            _lockPosition = true;
                            _isPlayingBeforeScrub = widget.video.isPlaying();
                            if (_isPlayingBeforeScrub) {
                              widget.video.pause();
                            }
                            widget.unsetTimer();
                          },
                          onDragCompleted:
                              (handlerIndex, firstValue, secondValue) async {
                            await widget.video.seekTo(
                              Duration(
                                microseconds: firstValue.floor(),
                              ),
                            );
                            if (_isPlayingBeforeScrub) {
                              widget.video.play();
                            }
                            setState(
                              () {}
                            );
                            widget.setTimer();
                            while ((widget.video.getPosition() -
                                        Duration(
                                          microseconds: firstValue.floor(),
                                        ))
                                    .abs() >
                                Duration(milliseconds: 500)) {
                              await Future.delayed(
                                Duration(milliseconds: 10),
                              );
                            }
                            _lockPosition = false;
                          },
                          onDragging: (handlerIndex, firstValue, secondValue) {
                            position = Duration(
                              microseconds: firstValue.floor(),
                            );
                          },
                          tooltip: FlutterSliderTooltip(
                            direction: FlutterSliderTooltipDirection.top,
                            textStyle: TextStyle(color: Colors.black),
                            format: (text) => formatDuration(
                              Duration(
                                microseconds: double.parse(text).floor(),
                              ),
                              widget.video.getDuration(),
                            ),
                            boxStyle: FlutterSliderTooltipBox(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(15),
                              ),
                            ),
                            positionOffset:
                                FlutterSliderTooltipPositionOffset(top: -10),
                          ),
                          trackBar: FlutterSliderTrackBar(
                            activeTrackBarHeight: 5,
                            activeTrackBar: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(15),
                            ),
                            inactiveTrackBar: BoxDecoration(
                              color: Colors.white24,
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          handler: FlutterSliderHandler(
                            decoration: BoxDecoration(
                                color: Colors.tealAccent,
                                shape: BoxShape.circle),
                            child: Container(),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.all(8),
              ),
            ],
          ),
          // Top Toolbar
          Column(
            children: [
              Padding(
                padding: EdgeInsets.all(4),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: EdgeInsets.all(8),
                  ),
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
                          child:
                              Icon(Icons.close, color: Colors.white, size: 30),
                        ),
                      ),
                      onTap: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(20),
                  ),
                  IgnorePointer(
                    ignoring: widget.lastEpisode.isEmpty,
                    child: Opacity(
                      opacity: widget.lastEpisode.isEmpty ? 0 : 1,
                      child: ElevatedButton.icon(
                        onPressed: widget.lastEpisode.isEmpty
                            ? null
                            : () {
                                Navigator.of(context).pushReplacement(
                                  MaterialPageRoute(
                                    builder: (BuildContext context) => Loading(
                                      anime: widget.anime,
                                      detailsState: widget.detailsState,
                                      name: widget.lastEpisode[0],
                                      url: widget.lastEpisode[1],
                                    ),
                                  ),
                                );
                              },
                        style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.all(Colors.transparent),
                          foregroundColor:
                              MaterialStateProperty.all(Colors.white),
                          elevation: MaterialStateProperty.all(0),
                          shape: MaterialStateProperty.all(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                        ),
                        icon: Icon(Icons.skip_previous),
                        label: Text("Last Episode"),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: (MediaQuery.of(context).size.height > 500)
                          ? InkWell(
                              borderRadius: BorderRadius.circular(15),
                              onTap: (widget.anime.score == "N/A")
                                  ? null
                                  : () {
                                      widget.video.pause();
                                      launch(
                                          'https://myanimelist.net/anime/${widget.anime.malID}');
                                    },
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.3),
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                padding: EdgeInsets.symmetric(
                                    vertical: 8, horizontal: 12),
                                child: Text(
                                  widget.name,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            )
                          : Container(),
                    ),
                  ),
                  IgnorePointer(
                    ignoring: widget.nextEpisode.isEmpty,
                    child: Opacity(
                      opacity: widget.nextEpisode.isEmpty ? 0 : 1,
                      child: ElevatedButton.icon(
                        onPressed: widget.nextEpisode.isEmpty
                            ? null
                            : () {
                                Navigator.of(context).pushReplacement(
                                  MaterialPageRoute(
                                    builder: (BuildContext context) => Loading(
                                      anime: widget.anime,
                                      detailsState: widget.detailsState,
                                      name: widget.nextEpisode[0],
                                      url: widget.nextEpisode[1],
                                    ),
                                  ),
                                );
                              },
                        style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.all(Colors.transparent),
                          foregroundColor:
                              MaterialStateProperty.all(Colors.white),
                          elevation: MaterialStateProperty.all(0),
                          shape: MaterialStateProperty.all(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                        ),
                        icon: Icon(Icons.skip_next),
                        label: Text("Next Episode"),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(10),
                  ),
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
                              color: Colors.white, size: 30),
                        ),
                      ),
                      onTap: () async {
                        widget.video.pause();
                        Wakelock.disable();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            behavior: SnackBarBehavior.floating,
                            content: Text("Saving Frame..."),
                            duration: Duration(seconds: 2),
                          ),
                        );
                        saveFrame(
                          context,
                          widget.url,
                          await widget.video.getPrecisePosition(),
                        );
                      },
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(8),
                  ),
                ],
              ),
            ],
          ),
          if (MediaQuery.of(context).size.height > 500)
            Positioned(
              left: 10,
              top: 100,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  IconButton(
                    icon: Icon(widget.video.getVolume() != 0
                        ? Icons.volume_up
                        : Icons.volume_off),
                    tooltip: "Volume",
                    iconSize: 30,
                    onPressed: () {
                      if (widget.video.getVolume() == 0) {
                        widget.video
                            .setVolume(Popup.volume == 0 ? 0.5 : Popup.volume);
                      } else {
                        widget.video.setVolume(0);
                      }
                    },
                  ),
                  SizedBox(
                    height: 200,
                    child: Container(
                      height: 20,
                      child: FlutterSlider(
                        min: 0,
                        max: 100,
                        handlerWidth: 20,
                        handlerHeight: 20,
                        selectByTap: true,
                        tooltip: FlutterSliderTooltip(
                          direction: FlutterSliderTooltipDirection.right,
                          textStyle: TextStyle(color: Colors.black),
                          format: (text) =>
                              double.parse(text).floor().toString() + "%",
                          boxStyle: FlutterSliderTooltipBox(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                        ),
                        trackBar: FlutterSliderTrackBar(
                          activeTrackBarHeight: 5,
                          activeTrackBar: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(15),
                          ),
                          inactiveTrackBar: BoxDecoration(
                            color: Colors.white24,
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        handler: FlutterSliderHandler(
                          decoration: BoxDecoration(
                              color: Colors.tealAccent, shape: BoxShape.circle),
                          child: Container(),
                        ),
                        onDragStarted: (handlerIndex, firstValue, secondValue) {
                          widget.unsetTimer();
                        },
                        onDragCompleted:
                            (handlerIndex, firstValue, secondValue) {
                          widget.setTimer();
                        },
                        onDragging: (handlerIndex, lowerValue, upperValue) {
                          widget.video.setVolume(lowerValue / 100);
                          Popup.volume = lowerValue / 100;
                        },
                        axis: Axis.vertical,
                        rtl: true,
                        values: [
                          max(min(widget.video.getVolume(), 1), 0) * 100
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          if (MediaQuery.of(context).size.height > 500)
            Positioned(
              right: 10,
              top: 100,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  IconButton(
                    icon: Icon(Icons.timer),
                    disabledColor: Colors.white,
                    tooltip: "Playback Speed",
                    onPressed: () {
                      speed = 1;
                      widget.video.setSpeed(1);
                    },
                  ),
                  SizedBox(
                    height: 200,
                    child: Container(
                      height: 20,
                      child: FlutterSlider(
                        min: 0.25,
                        max: 1.75,
                        handlerWidth: 20,
                        handlerHeight: 20,
                        selectByTap: true,
                        step: FlutterSliderStep(step: 0.25),
                        tooltip: FlutterSliderTooltip(
                          direction: FlutterSliderTooltipDirection.left,
                          textStyle: TextStyle(color: Colors.black),
                          format: (text) => double.parse(text).toString() + "x",
                          boxStyle: FlutterSliderTooltipBox(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                        ),
                        trackBar: FlutterSliderTrackBar(
                          activeTrackBarHeight: 5,
                          activeTrackBar: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(15),
                          ),
                          inactiveTrackBar: BoxDecoration(
                            color: Colors.white24,
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        handler: FlutterSliderHandler(
                          decoration: BoxDecoration(
                              color: Colors.tealAccent, shape: BoxShape.circle),
                          child: Container(),
                        ),
                        onDragStarted: (handlerIndex, firstValue, secondValue) {
                          widget.unsetTimer();
                        },
                        onDragCompleted:
                            (handlerIndex, firstValue, secondValue) {
                          widget.setTimer();
                          widget.video.setSpeed(speed);
                        },
                        onDragging: (handlerIndex, firstValue, secondValue) {
                          speed = firstValue;
                        },
                        axis: Axis.vertical,
                        rtl: true,
                        values: [
                          max(min(speed, 1.75), 0.25),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
