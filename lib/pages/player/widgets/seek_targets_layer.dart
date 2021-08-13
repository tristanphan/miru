import 'dart:io';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:miru/pages/player/functions/seek.dart';
import 'package:miru/pages/player/functions/video.dart';
import 'package:miru/pages/player/player_page.dart';
import 'package:wakelock/wakelock.dart';

double distance = 0;

Widget seekTargetsLayer(
    BuildContext context,
    void Function() togglePopup,
    Video video,
    void Function(bool set) setPopup,
    void Function(VoidCallback fn) setState,
    void Function() setTimer,
    void Function() unsetTimer) {
  return MouseRegion(
    onHover: (PointerHoverEvent event) {
      if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
        double thisDistance = event.position.distance - distance;
        distance = event.position.distance;
        if (thisDistance.abs() < 5) return;
        if (!video.isPlaying()) return;
        if (!Player.showPopup) {
          setPopup(true);
        }
        setTimer();
      }
    },
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        SizedBox(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width * 0.3,
          // Left Seek
          child: GestureDetector(
            onTap: togglePopup,
            onLongPress: null,
            onDoubleTap: () {
              Seek.seek(video, SeekDirection.BACKWARDS, 5, setState);
            },
          ),
        ),
        // Play Double Tap
        SizedBox(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width * 0.4,
          // Left Seek
          child: GestureDetector(
              onTap: togglePopup,
              onLongPress: null,
              onDoubleTap: (Platform.isAndroid || Platform.isIOS)
                  ? () {
                      setState(
                        () {
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
                        },
                      );
                    }
                  : null),
        ),
        SizedBox(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width * 0.3,
          // Right Seek
          child: GestureDetector(
            onTap: togglePopup,
            onLongPress: null,
            onDoubleTap: () {
              Seek.seek(video, SeekDirection.FORWARDS, 5, setState);
            },
          ),
        ),
      ],
    ),
  );
}
