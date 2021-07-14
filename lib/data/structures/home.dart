class Home {
  List<RecentRelease> recentReleases;
  List<Popular> popular;

  Home({required this.recentReleases, required this.popular});

  @override
  String toString() {
    return "\nRecent Releases: $recentReleases"
        "\nPopular: $popular";
  }
}

class AnimeCollection {}

class RecentRelease {
  String title;
  String latestEp;
  String image;
  String url;

  RecentRelease(
      {required this.title,
      required this.latestEp,
      required this.image,
      required this.url});

  @override
  String toString() {
    return "\nTitle: $title"
        "\nLatest Episode: $latestEp"
        "\nImage: $image"
        "\nURL: $url";
  }
}

class Popular {
  String title;
  String image;
  String genres;
  String latestEp;
  String url;

  Popular(
      {required this.title,
      required this.image,
      required this.genres,
      required this.latestEp,
      required this.url});

  @override
  String toString() {
    return "\nTitle: $title"
        "\nImage: $image"
        "\nGenres: $genres"
        "\nLatest Episode: $latestEp"
        "\nURL: $url";
  }
}
