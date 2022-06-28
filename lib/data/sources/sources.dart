import 'package:miru/data/anime.dart';
import 'package:miru/data/persistent_data/data_storage.dart';
import 'package:miru/data/sources/genoanime/genoanime.dart';

class Sources {
  static int _selected = 0;
  static List<Anime> list = [
    Genoanime(),
    // Gogoanime(),
    // AnimeSuge(),
  ];

  static Anime get([String? name]) {
    if (name != null) {
      for (Anime anime in list) {
        if (anime.runtimeType.toString() == name) {
          return anime;
        }
      }
    }
    return list[_selected];
  }

  static int getIndex() => _selected;

  static String getName() => list[_selected].runtimeType.toString();

  static void set(int i) {
    if (i < list.length && i >= 0) {
      _selected = i;
      Storage.sharedPreferences!.setInt('source', i);
    }
  }

  static void load() {
    if (!Storage.sharedPreferences!.containsKey('source')) {
      Storage.sharedPreferences!.setInt('source', _selected);
    } else {
      _selected = Storage.sharedPreferences!.getInt('source')!;
    }
  }
}
