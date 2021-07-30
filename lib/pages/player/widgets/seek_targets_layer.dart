import 'package:flutter/material.dart';
import 'package:miru/pages/player/functions/seek.dart';
import 'package:miru/pages/player/functions/video.dart';
import 'package:wakelock/wakelock.dart';

Widget seekTargetsLayer(
    BuildContext context,
    void Function() togglePopup,
    Video video,
    void Function(bool set) setPopup,
    void Function(VoidCallback fn) setState, void Function() unsetTimer) {
  return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
    SizedBox(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width * 0.3,
        // Left Seek
        child: GestureDetector(
            onTap: togglePopup,
            onLongPress: null,
            onDoubleTap: () {
              Seek.seek(video, SeekDirection.BACKWARDS, 5, setState);
              Seek.animation(SeekDirection.BACKWARDS, setState);
            })),
    // Play Double Tap
    SizedBox(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width * 0.4,
        // Left Seek
        child: GestureDetector(
            onTap: togglePopup,
            onLongPress: null,
            onDoubleTap: () {
              setState(() {
                if (video.isPlaying()) {
                  video.pause();
                  Wakelock.disable();
                  setPopup(true);
                } else {
                  video.play();
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
            onTap: togglePopup,
            onLongPress: null,
            onDoubleTap: () {
              Seek.seek(video, SeekDirection.FORWARDS, 5, setState);
              Seek.animation(SeekDirection.FORWARDS, setState);
            }))
  ]);
}
