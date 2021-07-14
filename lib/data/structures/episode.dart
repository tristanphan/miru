class Episode {
  String name;
  String url;
  String category;

  Episode({required this.name, required this.url, required this.category});

  @override
  String toString() {
    return "\nName: $name"
        "\nLink: $url"
        "\nCategory: $category";
  }
}
