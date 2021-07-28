import 'package:miru/data/persistent_data/bookmark.dart';

class Pin {
  String url;
  String title;
  String image;
  List<Bookmark> episodes;
  String source;

  Pin(
      {required this.url,
      required this.title,
      required this.image,
      required this.episodes,
      required this.source});

  Pin.fromJson(Map<String, dynamic> json)
      : this.url = json['url'],
        this.title = json['title'],
        this.image = json['image'],
        this.episodes = [
          for (var episode in json['episodes']) Bookmark.fromJson(episode)
        ],
        this.source = json['source'];

  Map<String, dynamic> toJson() => {
        'url': this.url,
        'title': this.title,
        'image': this.image,
        'episodes': this.episodes,
        'source': this.source
      };
}
