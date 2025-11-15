class Layout {
  final int id;
  final String title;
  final String? imagePath;

  Layout({required this.id, required this.title, required this.imagePath});

  factory Layout.fromJson(Map<String, dynamic> json) {
    return Layout(
      id: json['id'],
      title: json['title'],
      imagePath: json['img_path'],
    );
  }
}
