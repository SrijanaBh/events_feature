
class TicketModel {
  final int id;
  final String title;
  final String description;
  final int availableQty;
  final double price;
  final int persons;
  final String imgPath;
  final double totalPaidByBuyer;
  final double moneyToYou;

  TicketModel({
    required this.id,
    required this.title,
    required this.description,
    required this.availableQty,
    required this.price,
    required this.persons,
    required this.imgPath,
    required this.totalPaidByBuyer,
    required this.moneyToYou,
  });

  factory TicketModel.fromJson(Map<String, dynamic> json) {
    return TicketModel(
      id: json['id'],
      title: json['title'],
      description: json['description'] ?? '',
      availableQty: json['available_qty'],
      price: (json['price'] as num).toDouble(),
      persons: json['persons'],
      imgPath: json['img_path'],
      totalPaidByBuyer: (json['total_paid_by_buyer'] as num).toDouble(),
      moneyToYou: (json['money_to_you'] as num).toDouble(),
    );
  }
}
