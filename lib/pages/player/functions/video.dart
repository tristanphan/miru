import 'dart:io' show Platform;

import 'package:dart_vlc/dart_vlc.dart' as Vlc;
import 'package:video_player/video_player.dart';
import 'package:wakelock/wakelock.dart';

class Video {
  String url;
  bool isBuffering = true;

  // iOS and Android
  VideoPlayerController? _videoPlayerController;

  // Windows and Linux
  Vlc.Player? vlcPlayer;

  Video(
      {required String url,
      required Function onInitialized,
      required Function setPopup,
      required Function setState})
      : this.url = url {
    if (Platform.isIOS || Platform.isAndroid) {
      _videoPlayerController = VideoPlayerController.network(this.url);
      _videoPlayerController!.initialize().then(
        (value) {
          onInitialized(this);
          _videoPlayerController!.addListener(
            () {
              if (_videoPlayerController!.value.isBuffering != isBuffering) {
                setState(
                  () {
                    isBuffering = _videoPlayerController!.value.isBuffering;
                  },
                );
              }
              if (_videoPlayerController!.value.position ==
                  _videoPlayerController!.value.duration) {
                Wakelock.disable();
                setPopup(true);
              }
            },
          );
        },
      );
    }
    if (Platform.isWindows || Platform.isLinux) {
      vlcPlayer = Vlc.Player(id: 1, videoDimensions: Vlc.VideoDimensions(1920, 1080));
      vlcPlayer!.open(Vlc.Media.network(url), autoStart: false);
      (() async {
        // Ensure initialized
        while (getDuration() == Duration(milliseconds: 1)) {
          await Future.delayed(
            Duration(milliseconds: 10),
          );
        }
        onInitialized(this);
        setState(
          () {
            isBuffering = false;
          },
        );
      })();
    }
  }

  Future<void> seekTo(Duration duration) async {
    if (Platform.isIOS || Platform.isAndroid) {
      await _videoPlayerController!.seekTo(duration);
    }
    if (Platform.isWindows || Platform.isLinux) {
      vlcPlayer!.seek(duration);
    }
  }

  Future<void> play() async {
    if (getPosition().inSeconds.toInt() < getDuration().inSeconds.toInt()) {
      if (Platform.isIOS || Platform.isAndroid) {
        await _videoPlayerController!.play();
      }
      if (Platform.isWindows || Platform.isLinux) {
        vlcPlayer!.play();
      }
    }
  }

  Future<void> pause() async {
    if (Platform.isIOS || Platform.isAndroid) {
      await _videoPlayerController!.pause();
    }
    if (Platform.isWindows || Platform.isLinux) {
      vlcPlayer!.pause();
    }
  }

  Future<void> setSpeed(double speed) async {
    if (Platform.isIOS || Platform.isAndroid) {
      await _videoPlayerController!.setPlaybackSpeed(speed);
    }
    if (Platform.isWindows || Platform.isLinux) {
      vlcPlayer!.setRate(speed);
    }
  }

  double getSpeed() {
    if (Platform.isIOS || Platform.isAndroid) {
      return _videoPlayerController!.value.playbackSpeed;
    }
    if (Platform.isWindows || Platform.isLinux) {
      return vlcPlayer!.general.rate;
    }
    return 1.0;
  }

  Future<void> setVolume(double volume) async {
    if (Platform.isIOS || Platform.isAndroid) {
      await _videoPlayerController!.setVolume(volume);
    }
    if (Platform.isWindows || Platform.isLinux) {
      vlcPlayer!.setVolume(volume);
    }
  }

  double getVolume() {
    if (Platform.isIOS || Platform.isAndroid) {
      return _videoPlayerController!.value.volume;
    }
    if (Platform.isWindows || Platform.isLinux) {
      return vlcPlayer!.general.volume;
    }
    return 1.0;
  }

  Duration getPosition() {
    if (Platform.isIOS || Platform.isAndroid) {
      return _videoPlayerController!.value.position;
    }
    if (Platform.isWindows || Platform.isLinux) {
      return vlcPlayer!.position.position ?? Duration();
    }
    return Duration();
  }

  Future<Duration> getPrecisePosition() async {
    if (Platform.isIOS || Platform.isAndroid) {
      return await _videoPlayerController!.position ?? getPosition();
    }
    return getPosition();
  }

  Duration getDuration() {
    if (Platform.isIOS || Platform.isAndroid) {
      return _videoPlayerController!.value.duration;
    }
    if (Platform.isWindows || Platform.isLinux) {
      // To avoid divide by zero
      Duration duration =
          vlcPlayer!.position.duration ?? Duration(milliseconds: 1);
      if (duration.isNegative || duration.inMicroseconds == 0) {
        duration = Duration(milliseconds: 1);
      }
      return duration;
    }
    return Duration();
  }

  bool isPlaying() {
    if (Platform.isIOS || Platform.isAndroid) {
      return _videoPlayerController!.value.isPlaying;
    }
    if (Platform.isWindows || Platform.isLinux) {
      return vlcPlayer!.playback.isPlaying;
    }
    return false;
  }

  Future<void> dispose() async {
    if (Platform.isIOS || Platform.isAndroid) {
      await _videoPlayerController!.dispose();
    }
    if (Platform.isWindows || Platform.isLinux) {
      vlcPlayer!.dispose();
    }
  }

  Duration getBuffered() {
    if (Platform.isIOS || Platform.isAndroid) {
      List<DurationRange> bufferedList = _videoPlayerController!.value.buffered;
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
      return _videoPlayerController;
    }
  }

  static void onAppStart() {
    if (Platform.isWindows || Platform.isLinux) {
      Vlc.DartVLC.initialize();
    }
  }
}
