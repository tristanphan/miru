class SearchItem {
  String title;
  String url;
  String image;
  String released;

  SearchItem(
      {required this.title,
      required this.url,
      required this.image,
      required this.released});

  @override
  String toString() {
    return "\nTitle: $title"
        "\nURL: $url"
        "\nImage: $image"
        "\nReleased: $released";
  }
}
