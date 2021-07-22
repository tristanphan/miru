import 'package:palette_generator/palette_generator.dart';

import 'episode.dart';

class AnimeDetails {
  String name;
  String image;
  String summary;
  String type;
  String genre;
  String released;
  String status;
  String alias;
  List<Episode> episodes;
  String url;
  PaletteGenerator palette;

  AnimeDetails(
      {required this.name,
      required this.image,
      required this.summary,
      required this.type,
      required this.genre,
      required this.released,
      required this.status,
      required this.alias,
      required this.episodes,
      required this.url,
      required this.palette});
}
