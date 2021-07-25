import 'package:miru/data/anime.dart';

import 'animesuge/animesuge.dart';
import 'gogoanime/gogoanime.dart';

class Sources {
  static int _selected = 0;
  static List<Anime> list = [GoGoAnime(), AnimeSuge()];

  static Anime get() => list[_selected];

  static int getIndex() => _selected;

  static void set(int i) {
    if (i < list.length && i >= 0) _selected = i;
  }
}
