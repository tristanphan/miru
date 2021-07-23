import 'dart:collection';

import 'package:miru/data/structures/anime_details.dart';
import 'package:miru/data/structures/video_details.dart';

class Cache {
  static SplayTreeMap<String, AnimeDetails> loadedDetails =
      SplayTreeMap<String, AnimeDetails>();
  static SplayTreeMap<String, VideoDetails> loadedVideos =
      SplayTreeMap<String, VideoDetails>();
}
