import 'dart:collection';

import 'package:miru/data/structures/anime_details.dart';
import 'package:miru/data/structures/video_details.dart';

SplayTreeMap<String, AnimeDetails> loadedDetails =
    SplayTreeMap<String, AnimeDetails>();
SplayTreeMap<String, VideoDetails> loadedVideos =
    SplayTreeMap<String, VideoDetails>();
