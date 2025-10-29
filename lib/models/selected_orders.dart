import 'dart:convert';

/// Parses the entire JSON response into a model
EventsResponse eventsResponseFromJson(String str) =>
    EventsResponse.fromJson(json.decode(str));

/// Converts the model back into JSON
String eventsResponseToJson(EventsResponse data) =>
    json.encode(data.toJson());

class EventsResponse {
  final bool success;
  final String message;
  final List<EventData> data;

  EventsResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory EventsResponse.fromJson(Map<String, dynamic> json) => EventsResponse(
        success: json["success"] ?? false,
        message: json["message"] ?? "",
        data: json["data"] == null
            ? []
            : List<EventData>.from(
                json["data"].map((x) => EventData.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "success": success,
        "message": message,
        "data": List<dynamic>.from(data.map((x) => x.toJson())),
      };
}

class EventData {
  final int orderId;
  final int userId;
  final String? identityType;
  final String? name;
  final String? tableNumber;
  final double? actualPrice;
  final double? discountPrice;
  final double? totalPrice;
  final int? status;
  final double? actualTotalPrice;
  final int? qty;
  final int? entryUpto;
  final double? totalPriceWithTaxes;
  final String? invoice;
  final int? eventId;
  final String? title;
  final String? description;
  final String? imgPath;
  final String? startTime;
  final String? endTime;
  final String? onlyToday;
  final String? createDate;
  final DateTime? fromDate;
  final DateTime? toDate;

  EventData({
    required this.orderId,
    required this.userId,
    this.identityType,
    this.name,
    this.tableNumber,
    this.actualPrice,
    this.discountPrice,
    this.totalPrice,
    this.status,
    this.actualTotalPrice,
    this.qty,
    this.entryUpto,
    this.totalPriceWithTaxes,
    this.invoice,
    this.eventId,
    this.title,
    this.description,
    this.imgPath,
    this.startTime,
    this.endTime,
    this.onlyToday,
    this.createDate,
    this.fromDate,
    this.toDate,
  });

  factory EventData.fromJson(Map<String, dynamic> json) => EventData(
        orderId: json["order_id"] ?? 0,
        userId: json["user_id"] ?? 0,
        identityType: json["identity_type"]?.toString(),
        name: json["name"],
        tableNumber: json["table_number"]?.toString(),
        actualPrice: (json["actual_price"] ?? 0).toDouble(),
        discountPrice: (json["discount_price"] ?? 0).toDouble(),
        totalPrice: (json["total_price"] ?? 0).toDouble(),
        status: json["status"],
        actualTotalPrice: (json["actual_total_price"] ?? 0).toDouble(),
        qty: json["qty"],
        entryUpto: json["entry_upto"],
        totalPriceWithTaxes: (json["total_price_with_taxes"] ?? 0).toDouble(),
        invoice: json["invoice"],
        eventId: json["event_id"],
        title: json["title"],
        description: json["description"],
        imgPath: json["img_path"],
        startTime: json["start_time"],
        endTime: json["end_time"],
        onlyToday: json["only_today"],
        createDate: json["create_date"],
        fromDate: _parseDate(json["from_date"]),
        toDate: _parseDate(json["to_date"]),
      );

  Map<String, dynamic> toJson() => {
        "order_id": orderId,
        "user_id": userId,
        "identity_type": identityType,
        "name": name,
        "table_number": tableNumber,
        "actual_price": actualPrice,
        "discount_price": discountPrice,
        "total_price": totalPrice,
        "status": status,
        "actual_total_price": actualTotalPrice,
        "qty": qty,
        "entry_upto": entryUpto,
        "total_price_with_taxes": totalPriceWithTaxes,
        "invoice": invoice,
        "event_id": eventId,
        "title": title,
        "description": description,
        "img_path": imgPath,
        "start_time": startTime,
        "end_time": endTime,
        "only_today": onlyToday,
        "create_date": createDate,
        "from_date": fromDate?.toIso8601String(),
        "to_date": toDate?.toIso8601String(),
      };

  static DateTime? _parseDate(String? dateStr) {
    if (dateStr == null ||
        dateStr.isEmpty ||
        dateStr == "0000-00-00" ||
        dateStr == "1899-11-30T00:00:00.000Z") {
      return null;
    }
    try {
      return DateTime.parse(dateStr);
    } catch (_) {
      return null;
    }
  }
}
