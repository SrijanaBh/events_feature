class FloorResponse {
  final List<Floor> result;

  FloorResponse({required this.result});

  factory FloorResponse.fromJson(Map<String, dynamic> json) {
    var list = json['result'] as List? ?? [];
    return FloorResponse(
      result: list.map((item) => Floor.fromJson(item)).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'result': result.map((e) => e.toJson()).toList(),
    };
  }
}

class Floor {
  final int id;
  final String title;
  final String imgPath;

  Floor({
    required this.id,
    required this.title,
    required this.imgPath,
  });

  factory Floor.fromJson(Map<String, dynamic> json) {
    return Floor(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      imgPath: json['img_path'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'img_path': imgPath,
    };
  }
}
