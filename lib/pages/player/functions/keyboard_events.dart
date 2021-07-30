import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:miru/pages/player/functions/seek.dart';
import 'package:miru/pages/player/functions/video.dart';
import 'package:miru/pages/player/widgets/popup.dart';
import 'package:wakelock/wakelock.dart';

void keyboardEvents(RawKeyEvent e, Video video, void Function(bool set) setPopup, void Function(VoidCallback fn) setState) {
  if (!(e is RawKeyDownEvent)) return;
  if (e.physicalKey == PhysicalKeyboardKey.space) if (video.isPlaying()) {
    video.pause();
    Wakelock.disable();
    setPopup(true);
  } else {
    video.play();
    Wakelock.enable();
    setPopup(false);
  }

  if (e.physicalKey == PhysicalKeyboardKey.arrowLeft) {
    if (e.isShiftPressed)
      Seek.seek(video, SeekDirection.BACKWARDS, 83, setState);
    else
      Seek.seek(video, SeekDirection.BACKWARDS, 5, setState);
    Seek.animation(SeekDirection.BACKWARDS, setState);
  }

  if (e.physicalKey == PhysicalKeyboardKey.arrowRight) {
    if (e.isShiftPressed)
      Seek.seek(video, SeekDirection.FORWARDS, 83, setState);
    else
      Seek.seek(video, SeekDirection.FORWARDS, 5, setState);
    Seek.animation(SeekDirection.FORWARDS, setState);
  }

  if (e.physicalKey == PhysicalKeyboardKey.arrowUp) {
    if (e.isShiftPressed) {
      video.setSpeed(min(2, video.getSpeed() + 0.25));
    } else {
      video.setVolume(min(1, video.getVolume() + 0.1));
      Popup.volume = min(1, video.getVolume() + 0.1);
    }
  }

  if (e.physicalKey == PhysicalKeyboardKey.arrowDown) {
    if (e.isShiftPressed) {
      video.setSpeed(max(0.25, video.getSpeed() - 0.25));
    } else {
      video.setVolume(max(0, video.getVolume() - 0.1));
    }
    Popup.volume = max(0, video.getVolume() - 0.1);
  }
}
