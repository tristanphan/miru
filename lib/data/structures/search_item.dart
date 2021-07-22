import 'package:palette_generator/palette_generator.dart';

class SearchItem {
  String title;
  String url;
  String image;
  String released;
  PaletteGenerator palette;

  SearchItem(
      {required this.title,
      required this.url,
      required this.image,
      required this.released,
      required this.palette});
}
