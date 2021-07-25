import 'dart:async';

import 'package:miru/data/structures/anime_details.dart';
import 'package:miru/data/structures/popular.dart';
import 'package:miru/data/structures/recent_release.dart';
import 'package:miru/data/structures/search_item.dart';
import 'package:miru/data/structures/video_details.dart';

abstract class Anime {
  Future<List<RecentRelease>> getRecentReleases();

  Future<List<Popular>> getPopular();

  Future<List<SearchItem>> search(String keyword, Language language);

  Future<AnimeDetails> getDetails(String url);

  Future<VideoDetails?> getVideo(String url, [Function? changeProgress]);
}

enum Language { SUB, DUB, ALL }
