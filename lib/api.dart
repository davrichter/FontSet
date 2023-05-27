class Fonts {
  String kind;
  List<Item> items;

  Fonts({
    required this.kind,
    required this.items,
  });

  factory Fonts.fromJson(Map<String, dynamic> json) {
    return Fonts(
      kind: json['kind'],
      items: List<Item>.from(json["items"].map((x) => Item.fromJson(x))),
    );
  }
}

class Item {
  String family;
  List<String> variants;
  List<String> subsets;
  String version;
  DateTime lastModified;
  Map<String, dynamic> files;
  String category;
  String kind;
  String menu;

  Item({
    required this.family,
    required this.variants,
    required this.subsets,
    required this.version,
    required this.lastModified,
    required this.files,
    required this.category,
    required this.kind,
    required this.menu,
  });

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      family: json["family"],
      variants: List<String>.from(json["variants"].map((x) => x)),
      subsets: List<String>.from(json["subsets"].map((x) => x)),
      version: json["version"],
      lastModified: DateTime.parse(json["lastModified"]),
      files: json["files"],
      category: json["category"],
      kind: json["kind"],
      menu: json["menu"],
    );

  }
}