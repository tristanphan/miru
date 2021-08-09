import 'package:miru/data/anime.dart';
import 'package:miru/data/sources/animesuge/animesuge.dart';
import 'package:miru/data/sources/gogoanime/gogoanime.dart';

class Sources {
  static int _selected = 0;
  static List<Anime> list = [AnimeSuge(), Gogoanime()];

  static Anime get() => list[_selected];

  static int getIndex() => _selected;

  static String getName() => list[_selected].runtimeType.toString();

  static void set(int i) {
    if (i < list.length && i >= 0) _selected = i;
  }
}
