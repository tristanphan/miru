import 'dart:async';

import 'package:miru/data/anime.dart';
import 'package:miru/data/sources/animesuge/get_details.dart' as Data;
import 'package:miru/data/sources/animesuge/get_popular.dart' as Data;
import 'package:miru/data/sources/animesuge/get_recent_releases.dart' as Data;
import 'package:miru/data/sources/animesuge/get_video.dart' as Data;
import 'package:miru/data/sources/animesuge/search.dart' as Data;
import 'package:miru/data/structures/anime_details.dart';
import 'package:miru/data/structures/popular.dart';
import 'package:miru/data/structures/recent_release.dart';
import 'package:miru/data/structures/search_item.dart';
import 'package:miru/data/structures/video_details.dart';

class AnimeSuge implements Anime {
  Future<List<RecentRelease>> getRecentReleases() => Data.getRecentReleases();

  Future<List<Popular>> getPopular() => Data.getPopular();

  Future<List<SearchItem>> search(String keyword, Language language) =>
      Data.search(keyword, language);

  Future<AnimeDetails> getDetails(String url) => Data.getDetails(url);

  Future<VideoDetails?> getVideo(String url, [Function? changeProgress]) =>
      Data.getVideo(
        url,
        changeProgress ?? (String a) {},
      );
}
