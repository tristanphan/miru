class Pin {
  String url;
  String title;
  String image;
  List<Bookmark> episodes;

  Pin(
      {required this.url,
      required this.title,
      required this.image,
      required this.episodes});

  Pin.fromJson(Map<String, dynamic> json)
      : this.url = json['url'],
        this.title = json['title'],
        this.image = json['image'],
        this.episodes = [
          for (var episode in json['episodes']) Bookmark.fromJson(episode)
        ];

  Map<String, dynamic> toJson() => {
        'url': this.url,
        'title': this.title,
        'image': this.image,
        'episodes': this.episodes,
      };
}

class Bookmark {
  String url;
  int position;
  int duration;

  Bookmark({required this.url, this.position = 0, this.duration = 10});

  Bookmark.fromJson(Map<String, dynamic> json)
      : this.url = json['url'],
        this.position = json['position'],
        this.duration = json['duration'];

  Map<String, dynamic> toJson() => {
        'url': this.url,
        'position': this.position,
        'duration': this.duration,
      };
}
