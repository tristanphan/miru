import 'package:palette_generator/palette_generator.dart';

class RecentRelease {
  String title;
  String subtext;
  String image;
  String url;
  PaletteGenerator palette;

  RecentRelease(
      {required this.title,
      required this.subtext,
      required this.image,
      required this.url,
      required this.palette});
}
