class Bookmark {
  String url;
  int position;
  int duration;

  Bookmark({required this.url, this.position = 0, this.duration = 10});

  Bookmark.fromJson(Map<String, dynamic> json)
      : this.url = json['url'],
        this.position = json['position'],
        this.duration = json['duration'];

  Map<String, dynamic> toJson() =>
      {'url': this.url, 'position': this.position, 'duration': this.duration};
}
