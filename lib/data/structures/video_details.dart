class VideoDetails {
  String title;
  String url;
  List<String> next;
  List<String> last;

  VideoDetails(
      {required this.title,
      required this.url,
      required this.next,
      required this.last});

  @override
  String toString() {
    return "\nTitle: $title"
        "\nURL: $url"
        "\nNext: ${next.toString()}"
        "\nLast: ${last.toString()}";
  }
}
