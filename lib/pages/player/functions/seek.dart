import 'package:miru/pages/player/functions/video.dart';

enum SeekDirection { FORWARDS, BACKWARDS }

int seekAmount = 0;

class Seek {
  static bool darkenLeft = false;
  static bool darkenRight = false;

  static void seek(Video video, SeekDirection direction, int seconds,
      Function setState) async {
    bool play = video.isPlaying();
    await video.pause();
    seekAmount = seconds;
    Seek.animation(direction, setState);
    Duration newDuration;
    if (direction == SeekDirection.BACKWARDS)
      newDuration = video.getPosition() - Duration(seconds: seconds);
    else
      newDuration = video.getPosition() + Duration(seconds: seconds);
    await video.seekTo(newDuration);
    if (play) await video.play();
  }

  static void animation(SeekDirection direction, setState) {
    setState(() {
      if (direction == SeekDirection.BACKWARDS)
        darkenLeft = true;
      else
        darkenRight = true;
      Future.delayed(Duration(milliseconds: 400)).then((value) {
        setState(() {
          if (direction == SeekDirection.BACKWARDS)
            darkenLeft = false;
          else
            darkenRight = false;
        });
      });
    });
  }
}
