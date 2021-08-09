import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:miru/pages/player/functions/frame.dart';
import 'package:miru/pages/player/functions/seek.dart';
import 'package:miru/pages/player/functions/video.dart';
import 'package:miru/pages/player/widgets/popup.dart';
import 'package:wakelock/wakelock.dart';

void keyboardEvents(BuildContext context, RawKeyEvent e, Video video,
    void Function(bool set) setPopup, void Function(VoidCallback fn) setState) {
  if (!(e is RawKeyDownEvent)) return;

  // Functions
  void pause() {
    video.pause();
    Wakelock.disable();
    setPopup(true);
  }

  void play() {
    video.play();
    Wakelock.enable();
    setPopup(false);
  }

  // Play Pause
  if (e.physicalKey == PhysicalKeyboardKey.space ||
      e.physicalKey == PhysicalKeyboardKey.mediaPlayPause) {
    if (video.isPlaying())
      pause();
    else
      play();
  }
  if (e.physicalKey == PhysicalKeyboardKey.mediaPlay ||
      e.physicalKey == PhysicalKeyboardKey.mediaSelect) play();
  if (e.physicalKey == PhysicalKeyboardKey.mediaPause ||
      e.physicalKey == PhysicalKeyboardKey.mediaStop) pause();

  // Position
  if (e.physicalKey == PhysicalKeyboardKey.arrowLeft ||
      e.physicalKey == PhysicalKeyboardKey.mediaRewind) {
    if (e.isShiftPressed)
      Seek.seek(video, SeekDirection.BACKWARDS, 83, setState);
    else
      Seek.seek(video, SeekDirection.BACKWARDS, 5, setState);
  }
  if (e.physicalKey == PhysicalKeyboardKey.arrowRight ||
      e.physicalKey == PhysicalKeyboardKey.mediaFastForward) {
    if (e.isShiftPressed)
      Seek.seek(video, SeekDirection.FORWARDS, 83, setState);
    else
      Seek.seek(video, SeekDirection.FORWARDS, 5, setState);
  }
  if (e.physicalKey == PhysicalKeyboardKey.keyH) {
    if (e.isShiftPressed)
      Seek.seek(video, SeekDirection.BACKWARDS, 83, setState);
    else
      Seek.seek(video, SeekDirection.BACKWARDS, 10, setState);
  }
  if (e.physicalKey == PhysicalKeyboardKey.keyL) {
    if (e.isShiftPressed)
      Seek.seek(video, SeekDirection.FORWARDS, 83, setState);
    else
      Seek.seek(video, SeekDirection.FORWARDS, 10, setState);
  }

  // Speed
  if (e.physicalKey == PhysicalKeyboardKey.keyJ) {
    video.setSpeed(max(0.25, video.getSpeed() - 0.25));
  }
  if (e.physicalKey == PhysicalKeyboardKey.keyK) {
    video.setSpeed(min(2, video.getSpeed() + 0.25));
  }
  if (e.physicalKey == PhysicalKeyboardKey.keyM) {
    video.setSpeed(1);
  }

  // Volume
  if (e.physicalKey == PhysicalKeyboardKey.arrowUp) {
    video.setVolume(min(1, video.getVolume() + 0.1));
    Popup.volume = min(1, video.getVolume() + 0.1);
  }
  if (e.physicalKey == PhysicalKeyboardKey.arrowDown) {
    video.setVolume(max(0, video.getVolume() - 0.1));
    Popup.volume = max(0, video.getVolume() - 0.1);
  }

  // Frame
  if (e.physicalKey == PhysicalKeyboardKey.keyI) {
    video.pause();
    Wakelock.disable();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        behavior: SnackBarBehavior.floating,
        content: Text("Saving Frame..."),
        duration: Duration(seconds: 2)));
    saveFrame(context, video.url, video.getPosition());
  }
}
