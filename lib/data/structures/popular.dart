import 'package:palette_generator/palette_generator.dart';

class Popular {
  String title;
  String image;
  String subtext;
  String url;
  PaletteGenerator palette;

  Popular(
      {required this.title,
      required this.image,
      required this.subtext,
      required this.url,
      required this.palette});
}
