import 'dart:async';

import 'package:miru/data/anime.dart';
import 'package:miru/data/sources/gogoanime/get_details.dart' as Data;
import 'package:miru/data/sources/gogoanime/get_popular.dart' as Data;
import 'package:miru/data/sources/gogoanime/get_recent_releases.dart' as Data;
import 'package:miru/data/sources/gogoanime/get_video.dart' as Data;
import 'package:miru/data/sources/gogoanime/search.dart' as Data;
import 'package:miru/data/structures/anime_details.dart';
import 'package:miru/data/structures/popular.dart';
import 'package:miru/data/structures/recent_release.dart';
import 'package:miru/data/structures/search_item.dart';
import 'package:miru/data/structures/video_details.dart';

class Gogoanime implements Anime {
  // GoGoAnime Home Page
  Future<List<RecentRelease>> getRecentReleases() => Data.getRecentReleases();

  Future<List<Popular>> getPopular() => Data.getPopular();

  // Searches Anime Titles by Keyword
  Future<List<SearchItem>> search(String keyword, Language language) =>
      Data.search(keyword, language);

  // Gets details of an Anime by URL
  Future<AnimeDetails> getDetails(String url) => Data.getDetails(url);

  // Get video from Episode URL
  Future<VideoDetails?> getVideo(String url, [Function? changeProgress]) =>
      Data.getVideo(
        url,
        changeProgress ?? (String a) {},
      );
}
