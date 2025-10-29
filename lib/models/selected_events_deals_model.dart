


/*
class EventOrdersResponse {
  final bool success;
  final String message;
  final List<EventOrder> data;

  EventOrdersResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory EventOrdersResponse.fromJson(Map<String, dynamic> json) {
    return EventOrdersResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data:
          (json['data'] as List<dynamic>?)
              ?.map((e) => EventOrder.fromJson(e))
              .toList() ??
          [],
    );
  }
}

class EventOrder {
  final int orderId;
  final int userId;
  final String identityType;
  final String name;
  final String type;
  final String tableNumber;
  final double actualPrice;
  final double discountPrice;
  final double totalPrice;
  final int status;
  final double actualTotalPrice;
  final int qty;
  final int entryUpto;
  final double totalPriceWithTaxes;
  final String invoice;
  final int eventId;
  final String title;
  final String description;
  final String startTime;
  final String endTime;
  final String onlyToday;
  final String fromDate;
  final String toDate;

  EventOrder({
    required this.orderId,
    required this.userId,
    required this.identityType,
    required this.name,
    required this.tableNumber,
    required this.actualPrice,
    required this.discountPrice,
    required this.totalPrice,
    required this.status,
    required this.actualTotalPrice,
    required this.qty,
    required this.entryUpto,
    required this.totalPriceWithTaxes,
    required this.invoice,
    required this.eventId,
    required this.title,
    required this.description,
    required this.startTime,
    required this.endTime,
    required this.onlyToday,
    required this.fromDate,
    required this.toDate,
    required this.type,
  });

  factory EventOrder.fromJson(Map<String, dynamic> json) {
    return EventOrder(
      orderId: json['order_id'] ?? 0,
      userId: json['user_id'] ?? 0,
      identityType: json['identity_type']?.toString() ?? '',
      name: json['name'] ?? '',
      type: json['type'] ?? '',
      tableNumber: json['table_number']?.toString() ?? '',
      actualPrice: (json['actual_price'] ?? 0).toDouble(),
      discountPrice: (json['discount_price'] ?? 0).toDouble(),
      totalPrice: (json['total_price'] ?? 0).toDouble(),
      status: json['status'] ?? 0,
      actualTotalPrice: (json['actual_total_price'] ?? 0).toDouble(),
      qty: json['qty'] ?? 0,
      entryUpto: json['entry_upto'] ?? 0,
      totalPriceWithTaxes: (json['total_price_with_taxes'] ?? 0).toDouble(),
      invoice: json['invoice'] ?? '',
      eventId: json['event_id'] ?? 0,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      startTime: json['start_time'] ?? '',
      endTime: json['end_time'] ?? '',
      onlyToday: json['only_today'] ?? '',
      fromDate: json['from_date'] ?? '',
      toDate: json['to_date'] ?? '',
    );
  }
}
*/


/*
class EventOrdersResponse {
  final bool success;
  final String message;
  final List<EventOrder> data;

  EventOrdersResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory EventOrdersResponse.fromJson(Map<String, dynamic> json) {
    return EventOrdersResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data:
          (json['data'] as List<dynamic>?)
              ?.map((item) => EventOrder.fromJson(item))
              .toList() ??
          [],
    );
  }
}

class EventOrder {
  final int orderId;
  final int userId;
  final String identityType;
  final String name;
  final String tableNumber;
  final double actualPrice;
  final double discountPrice;
  final double totalPrice;
  final int status;
  final double actualTotalPrice;
  final int qty;
  final int entryUpto;
  final double totalPriceWithTaxes;
  final String invoice;
  final int eventId;
  final String title;
  final String description;
  final String startTime;
  final String endTime;
  final String onlyToday;
  final String fromDate;
  final String toDate;

  EventOrder({
    required this.orderId,
    required this.userId,
    required this.identityType,
    required this.name,
    required this.tableNumber,
    required this.actualPrice,
    required this.discountPrice,
    required this.totalPrice,
    required this.status,
    required this.actualTotalPrice,
    required this.qty,
    required this.entryUpto,
    required this.totalPriceWithTaxes,
    required this.invoice,
    required this.eventId,
    required this.title,
    required this.description,
    required this.startTime,
    required this.endTime,
    required this.onlyToday,
    required this.fromDate,
    required this.toDate,
  });

  factory EventOrder.fromJson(Map<String, dynamic> json) {
    return EventOrder(
      orderId: json['order_id'] ?? 0,
      userId: json['user_id'] ?? 0,
      identityType: json['identity_type']?.toString() ?? '',
      name: json['name'] ?? '',
      tableNumber: json['table_number']?.toString() ?? '',
      actualPrice: (json['actual_price'] ?? 0).toDouble(),
      discountPrice: (json['discount_price'] ?? 0).toDouble(),
      totalPrice: (json['total_price'] ?? 0).toDouble(),
      status: json['status'] ?? 0,
      actualTotalPrice: (json['actual_total_price'] ?? 0).toDouble(),
      qty: json['qty'] ?? 0,
      entryUpto: json['entry_upto'] ?? 0,
      totalPriceWithTaxes: (json['total_price_with_taxes'] ?? 0).toDouble(),
      invoice: json['invoice'] ?? '',
      eventId: json['event_id'] ?? 0,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      startTime: json['start_time'] ?? '',
      endTime: json['end_time'] ?? '',
      onlyToday: json['only_today'] ?? '',
      fromDate: json['from_date'] ?? '',
      toDate: json['to_date'] ?? '',
    );
  }
}
*/