class Bookmark {
  String name;
  String url;
  int position;
  int duration;

  Bookmark({required this.name, required this.url, this.position = 0, this.duration = 10});

  Bookmark.fromJson(Map<String, dynamic> json)
      : this.name = json['name'],
        this.url = json['url'],
        this.position = json['position'],
        this.duration = json['duration'];

  Map<String, dynamic> toJson() =>
      {'name': this.name, 'url': this.url, 'position': this.position, 'duration': this.duration};
}
