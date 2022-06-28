import 'package:flutter/material.dart';
import 'package:miru/info.dart';
import 'package:miru/pages/details/details_loading_page.dart';
import 'package:palette_generator/palette_generator.dart';

class HomeCard extends StatefulWidget {
  final String img;
  final String url;
  final String title;
  final String subtext;
  final PaletteGenerator palette;
  final double width;
  final Function(VoidCallback fn) setState;
  final bool? useCustomCrawler;

  const HomeCard(
      {Key? key,
      required this.img,
      required this.title,
      this.subtext = "",
      required this.palette,
      required this.width,
      required this.url,
      required this.setState,
      this.useCustomCrawler})
      : super(key: key);

  @override
  _HomeCardState createState() => _HomeCardState();
}

class _HomeCardState extends State<HomeCard> {
  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    double imageHeight = 130;
    Color backgroundColor;
    PaletteColor? colorSet =
        isDark ? widget.palette.vibrantColor : widget.palette.lightVibrantColor;
    if (colorSet == null) {
      backgroundColor =
          isDark ? Colors.blueGrey : Colors.lightBlueAccent.shade100;
    } else {
      backgroundColor = colorSet.color;
    }
    Color textColor = isDark ? Colors.white : Colors.black;

    return Stack(
      alignment: Alignment.topRight,
      children: [
        Container(
          width: widget.width.toDouble(),
          padding: EdgeInsets.all(8.0),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              splashColor: isDark
                  ? Colors.white.withOpacity(0.1)
                  : Colors.black.withOpacity(0.1),
              highlightColor: isDark
                  ? Colors.white.withOpacity(0.05)
                  : Colors.black.withOpacity(0.05),
              borderRadius: BorderRadius.circular(20),
              onTap: () async {
                if (widget.url.isEmpty) return;
                await Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (BuildContext context) => DetailsLoadingPage(
                      title: widget.title,
                      url: widget.url,
                      useCustomCrawler: widget.useCustomCrawler,
                      homeCard: HomeCard(
                          palette: widget.palette,
                          url: '',
                          img: widget.img,
                          title: widget.title,
                          width: 350,
                          setState: setState,
                          subtext: widget.subtext),
                    ),
                  ),
                );
                widget.setState(() {});
              },
              onLongPress: () async {
                if (widget.url.isEmpty) return;
                await showInfo(
                    context: context,
                    setState: widget.setState,
                    image: widget.img,
                    name: widget.title,
                    url: widget.url,
                    shouldPop: false);
                widget.setState(() {});
              },
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: backgroundColor.withOpacity(isDark ? 0.4 : 0.3),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: Image.network(widget.img,
                            fit: BoxFit.cover,
                            height: imageHeight,
                            width: imageHeight * 2 / 3),
                      ),
                      Padding(
                        padding: EdgeInsets.all(8),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.title.replaceAll(" (Dub)", ""),
                              maxLines: 4,
                              style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: textColor),
                            ),
                            if (widget.subtext.isNotEmpty)
                              Padding(
                                padding: EdgeInsets.all(2),
                              ),
                            if (widget.subtext.isNotEmpty)
                              Text(
                                widget.subtext,
                                maxLines: 3,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: textColor.withOpacity(0.8),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        if (widget.title.endsWith(" (Dub)"))
          Positioned(
            top: 0,
            right: 0,
            child: Tooltip(
              message: "Dubbed",
              child: Card(
                color: Color.alphaBlend(
                    backgroundColor.withOpacity(0.8), Colors.black),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                elevation: 8,
                child: Padding(
                  padding: EdgeInsets.all(8),
                  child: Icon(Icons.language),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
