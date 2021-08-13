import 'package:miru/pages/player/functions/video.dart';

enum SeekDirection { FORWARDS, BACKWARDS }

int seekAmount = 0;

class Seek {
  // When these are true, the seek indicators will appear
  static bool left = false;
  static bool right = false;

  static void seek(Video video, SeekDirection direction, int seconds,
      Function setState) async {
    bool isPlaying = video.isPlaying();
    await video.pause();
    seekAmount = seconds;
    Seek.animation(direction, setState);
    Duration newDuration;
    if (direction == SeekDirection.BACKWARDS)
      newDuration = video.getPosition() - Duration(seconds: seconds);
    else
      newDuration = video.getPosition() + Duration(seconds: seconds);
    await video.seekTo(newDuration);
    if (isPlaying) await video.play();
  }

  static void animation(SeekDirection direction, setState) {
    return setState(
      () {
        if (direction == SeekDirection.BACKWARDS)
          left = true;
        else
          right = true;
        Future.delayed(
          Duration(milliseconds: 400),
        ).then(
          (value) => setState(
            () {
              if (direction == SeekDirection.BACKWARDS)
                left = false;
              else
                right = false;
            },
          ),
        );
      },
    );
  }
}
