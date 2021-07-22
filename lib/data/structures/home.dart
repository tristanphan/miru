import 'package:palette_generator/palette_generator.dart';

class Home {
  List<RecentRelease> recentReleases;
  List<Popular> popular;

  Home({required this.recentReleases, required this.popular});
}

class AnimeCollection {}

class RecentRelease {
  String title;
  String latestEp;
  String image;
  String url;
  PaletteGenerator palette;

  RecentRelease(
      {required this.title,
      required this.latestEp,
      required this.image,
      required this.url,
      required this.palette});
}

class Popular {
  String title;
  String image;
  String genres;
  String latestEp;
  String url;
  PaletteGenerator palette;

  Popular(
      {required this.title,
      required this.image,
      required this.genres,
      required this.latestEp,
      required this.url,
      required this.palette});
}
