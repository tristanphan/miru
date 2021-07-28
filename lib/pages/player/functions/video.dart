import 'dart:io' show Platform;

import 'package:video_player/video_player.dart';
import 'package:wakelock/wakelock.dart';

class Video {
  String _url;
  bool buffering = true;

  // iOS and Android
  VideoPlayerController? _controller;

  Video({required String url, required Function onInitialized, required Function setPopup, required Function setState}) : _url = url {
    if (Platform.isIOS || Platform.isAndroid) {
      _controller = VideoPlayerController.network(_url);
      _controller!.initialize().then((value) {
        onInitialized();
        _controller!.addListener(() {
          if (_controller!.value.isBuffering != buffering) {
            setState(() {
              buffering = _controller!.value.isBuffering;
            });
          }
          if (_controller!.value.position == _controller!.value.duration) {
            Wakelock.disable();
            setPopup(true);
          }
        });
      });
    }
  }

  Future<void> seekTo(Duration duration) async {
    if (Platform.isIOS || Platform.isAndroid) {
      await _controller!.seekTo(duration);
    }
  }

  Future<void> play() async {
    if (Platform.isIOS || Platform.isAndroid) {
      await _controller!.play();
    }
  }

  Future<void> pause() async {
    if (Platform.isIOS || Platform.isAndroid) {
      await _controller!.pause();
    }
  }

  Future<void> setSpeed(double speed) async {
    if (Platform.isIOS || Platform.isAndroid) {
      await _controller!.setPlaybackSpeed(speed);
    }
  }

  double getSpeed() {
    if (Platform.isIOS || Platform.isAndroid) {
      return _controller!.value.playbackSpeed;
    }
    return 1.0;
  }

  Future<void> setVolume(double volume) async {
    if (Platform.isIOS || Platform.isAndroid) {
      await _controller!.setVolume(volume);
    }
  }

  double getVolume() {
    if (Platform.isIOS || Platform.isAndroid) {
      return _controller!.value.volume;
    }
    return 1.0;
  }

  Duration getPosition() {
    if (Platform.isIOS || Platform.isAndroid) {
      return _controller!.value.position;
    }
    return Duration();
  }

  Duration getDuration() {
    if (Platform.isIOS || Platform.isAndroid) {
      return _controller!.value.duration;
    }
    return Duration();
  }

  bool isPlaying() {
    if (Platform.isIOS || Platform.isAndroid) {
      return _controller!.value.isPlaying;
    }
    return false;
  }

  Future<void> dispose() async {
    if (Platform.isIOS || Platform.isAndroid) {
      await _controller!.dispose();
    }
  }

  List<DurationRange> getBuffered() {
    if (Platform.isIOS || Platform.isAndroid) {
      return _controller!.value.buffered;
    }
    return [];
  }

  dynamic getDetails() {
    if (Platform.isIOS || Platform.isAndroid) {
      return _controller;
    }
  }
}
