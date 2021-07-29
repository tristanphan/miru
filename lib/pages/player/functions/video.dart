import 'dart:io' show Platform;

import 'package:dart_vlc/dart_vlc.dart' as Vlc;
import 'package:video_player/video_player.dart';
import 'package:wakelock/wakelock.dart';

class Video {
  String _url;
  bool buffering = true;

  // iOS and Android
  VideoPlayerController? _controller;

  // Windows and Linux
  Vlc.Player? _player;

  Video(
      {required String url,
      required Function onInitialized,
      required Function setPopup,
      required Function setState})
      : _url = url {
    if (Platform.isIOS || Platform.isAndroid) {
      _controller = VideoPlayerController.network(_url);
      _controller!.initialize().then((value) {
        onInitialized(this);
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
    if (Platform.isWindows || Platform.isLinux) {
      _player = Vlc.Player(id: 1, videoHeight: 1080, videoWidth: 1920);
      _player!.open(Vlc.Media.network(url), autoStart: false);
      (() async {
        // Ensure initialized
        while (getDuration() == Duration(milliseconds: 1)) {
          await Future.delayed(Duration(milliseconds: 10));
        }
        onInitialized(this);
        setState(() {
          buffering = false;
        });
      })();
    }
  }

  Future<void> seekTo(Duration duration) async {
    if (Platform.isIOS || Platform.isAndroid) {
      await _controller!.seekTo(duration);
    }
    if (Platform.isWindows || Platform.isLinux) {
      _player!.seek(duration);
    }
  }

  Future<void> play() async {
    if (Platform.isIOS || Platform.isAndroid) {
      await _controller!.play();
    }
    if (Platform.isWindows || Platform.isLinux) {
      _player!.play();
    }
  }

  Future<void> pause() async {
    if (Platform.isIOS || Platform.isAndroid) {
      await _controller!.pause();
    }
    if (Platform.isWindows || Platform.isLinux) {
      _player!.pause();
    }
  }

  Future<void> setSpeed(double speed) async {
    if (Platform.isIOS || Platform.isAndroid) {
      await _controller!.setPlaybackSpeed(speed);
    }
    if (Platform.isWindows || Platform.isLinux) {
      _player!.setRate(speed);
    }
  }

  double getSpeed() {
    if (Platform.isIOS || Platform.isAndroid) {
      return _controller!.value.playbackSpeed;
    }
    if (Platform.isWindows || Platform.isLinux) {
      return _player!.general.rate;
    }
    return 1.0;
  }

  Future<void> setVolume(double volume) async {
    if (Platform.isIOS || Platform.isAndroid) {
      await _controller!.setVolume(volume);
    }
    if (Platform.isWindows || Platform.isLinux) {
      _player!.setVolume(volume);
    }
  }

  double getVolume() {
    if (Platform.isIOS || Platform.isAndroid) {
      return _controller!.value.volume;
    }
    if (Platform.isWindows || Platform.isLinux) {
      return _player!.general.volume;
    }
    return 1.0;
  }

  Duration getPosition() {
    if (Platform.isIOS || Platform.isAndroid) {
      return _controller!.value.position;
    }
    if (Platform.isWindows || Platform.isLinux) {
      return _player!.position.position ?? Duration();
    }
    return Duration();
  }

  Duration getDuration() {
    if (Platform.isIOS || Platform.isAndroid) {
      return _controller!.value.duration;
    }
    if (Platform.isWindows || Platform.isLinux) {
      // To avoid divide by zero
      Duration duration =
          _player!.position.duration ?? Duration(milliseconds: 1);
      if (duration.isNegative || duration.inMicroseconds == 0) {
        duration = Duration(milliseconds: 1);
      }
      return duration;
    }
    return Duration();
  }

  bool isPlaying() {
    if (Platform.isIOS || Platform.isAndroid) {
      return _controller!.value.isPlaying;
    }
    if (Platform.isWindows || Platform.isLinux) {
      return _player!.playback.isPlaying;
    }
    return false;
  }

  Future<void> dispose() async {
    if (Platform.isIOS || Platform.isAndroid) {
      await _controller!.dispose();
    }
    if (Platform.isWindows || Platform.isLinux) {
      _player!.dispose();
    }
  }

  Duration getBuffered() {
    if (Platform.isIOS || Platform.isAndroid) {
      List<DurationRange> bufferedList = _controller!.value.buffered;
      Duration? buffered;
      for (DurationRange i in bufferedList) {
        if (buffered == null) {
          buffered = i.end;
        } else {
          if (buffered.inMilliseconds < i.end.inMilliseconds) buffered = i.end;
        }
      }

      if (buffered != null) {
        return buffered;
      }
    }
    return Duration();
  }

  dynamic getDetails() {
    if (Platform.isIOS || Platform.isAndroid) {
      return _controller;
    }
  }

  static void onAppStart() {
    if (Platform.isWindows || Platform.isLinux) {
      Vlc.DartVLC.initialize();
    }
  }
}
