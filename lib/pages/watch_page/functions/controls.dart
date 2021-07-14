import 'package:video_player/video_player.dart';

enum SeekDirection { FORWARDS, BACKWARDS }

class Seek {
  static bool darkenLeft = false;
  static bool darkenRight = false;

  static void seek(VideoPlayerController controller, SeekDirection direction,
      int seconds, Function setState) async {
    bool play = controller.value.isPlaying;
    await controller.pause();
    Duration newDuration;
    if (direction == SeekDirection.BACKWARDS)
      newDuration = controller.value.position - Duration(seconds: seconds);
    else
      newDuration = controller.value.position + Duration(seconds: seconds);
    await controller.seekTo(
      newDuration,
    );
    if (play) await controller.play();
  }

  static void animation(SeekDirection direction, setState) {
    setState(() {
      if (direction == SeekDirection.BACKWARDS)
        darkenLeft = true;
      else
        darkenRight = true;
      Future.delayed(
        Duration(milliseconds: 400),
      ).then((value) {
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
