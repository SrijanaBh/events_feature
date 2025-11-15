class GetEventTicketDetails {
  final int id;
  final String title;
  final String daysType;
  final String toDate;
  final String onlyToday;
  final String description;
  final int availableQty;
  final int price;
  final int persons;
  final String tc;
  final String imgPath;
  final String endTime;
  final String eventTitle;
  final int status;
  final int ticketCreateType;
  final int bookingFeePayer;
  final int paymentGatewayFeePayer;
  final int bookingFee;
  final int paymentGatewayFee;
  final int totalPaidByBuyer;
  final int moneyToYou;
  final String egDate;

  GetEventTicketDetails({
    required this.id,
    required this.title,
    required this.daysType,
    required this.toDate,
    required this.onlyToday,
    required this.description,
    required this.availableQty,
    required this.price,
    required this.persons,
    required this.tc,
    required this.imgPath,
    required this.endTime,
    required this.eventTitle,
    required this.status,
    required this.ticketCreateType,
    required this.bookingFeePayer,
    required this.paymentGatewayFeePayer,
    required this.bookingFee,
    required this.paymentGatewayFee,
    required this.totalPaidByBuyer,
    required this.moneyToYou,
    required this.egDate,
  });

  factory GetEventTicketDetails.fromJson(Map<String, dynamic> json) {
    return GetEventTicketDetails(
      id: json['id'] ?? json['ticket_id'] ?? 0,
      title: json['title'] ?? json['ticket_title'] ?? '',
      daysType: json['days_type'] ?? json['daysType'] ?? '',
      toDate: json['to_date'] ?? json['toDate'] ?? '',
      onlyToday: json['only_today'] ?? json['onlyToday'] ?? '',
      description: json['description'] ?? '',
      availableQty: json['available_qty'] ?? json['availableQty'] ?? 0,
      price: json['price'] ?? json['ticket_price'] ?? 0,
      persons: json['persons'] ?? json['per_person'] ?? 0,
      tc: json['tc'] ?? '',
      imgPath: json['img_path'] ?? json['image'] ?? '',
      endTime: json['end_time'] ?? '',
      eventTitle: json['eventTitle'] ?? json['event_title'] ?? '',
      status: json['status'] ?? 0,
      ticketCreateType: json['ticket_create_type'] ?? json['createType'] ?? 0,
      bookingFeePayer: json['booking_fee_payer'] ?? 0,
      paymentGatewayFeePayer: json['payment_gateway_fee_payer'] ?? 0,
      bookingFee: json['booking_fee'] ?? 0,
      paymentGatewayFee: json['payment_gateway_fee'] ?? 0,
      totalPaidByBuyer: json['total_paid_by_buyer'] ?? 0,
      moneyToYou: json['money_to_you'] ?? 0,
      egDate: json['eg_date'] ?? '',
    );
  }
}



/*
class GetEventTicketDetails {
  final int id;
  final String title;
  final String daysType;
  final String toDate;
  final String onlyToday;
  final String description;
  final int availableQty;
  final int price;
  final int persons;
  final String tc;
  final String imgPath;
  final String endTime;
  final String eventTitle;
  final int status;
  final int ticketCreateType;
  final int bookingFeePayer;
  final int paymentGatewayFeePayer;
  final int bookingFee;
  final int paymentGatewayFee;
  final int totalPaidByBuyer;
  final int moneyToYou;
  final String egDate;

  GetEventTicketDetails({
    required this.id,
    required this.title,
    required this.daysType,
    required this.toDate,
    required this.onlyToday,
    required this.description,
    required this.availableQty,
    required this.price,
    required this.persons,
    required this.tc,
    required this.imgPath,
    required this.endTime,
    required this.eventTitle,
    required this.status,
    required this.ticketCreateType,
    required this.bookingFeePayer,
    required this.paymentGatewayFeePayer,
    required this.bookingFee,
    required this.paymentGatewayFee,
    required this.totalPaidByBuyer,
    required this.moneyToYou,
    required this.egDate,
  });

  factory GetEventTicketDetails.fromJson(Map<String, dynamic> json) {
    return GetEventTicketDetails(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      daysType: json['days_type'] ?? '',
      toDate: json['to_date'] ?? '',
      onlyToday: json['only_today'] ?? '',
      description: json['description'] ?? '',
      availableQty: json['available_qty'] ?? 0,
      price: json['price'] ?? 0,
      persons: json['persons'] ?? 0,
      tc: json['tc'] ?? '',
      imgPath: json['img_path'] ?? '',
      endTime: json['end_time'] ?? '',
      eventTitle: json['eventTitle'] ?? '',
      status: json['status'] ?? 0,
      ticketCreateType: json['ticket_create_type'] ?? 0,
      bookingFeePayer: json['booking_fee_payer'] ?? 0,
      paymentGatewayFeePayer: json['payment_gateway_fee_payer'] ?? 0,
      bookingFee: json['booking_fee'] ?? 0,
      paymentGatewayFee: json['payment_gateway_fee'] ?? 0,
      totalPaidByBuyer: json['total_paid_by_buyer'] ?? 0,
      moneyToYou: json['money_to_you'] ?? 0,
      egDate: json['eg_date'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'days_type': daysType,
      'to_date': toDate,
      'only_today': onlyToday,
      'description': description,
      'available_qty': availableQty,
      'price': price,
      'persons': persons,
      'tc': tc,
      'img_path': imgPath,
      'end_time': endTime,
      'eventTitle': eventTitle,
      'status': status,
      'ticket_create_type': ticketCreateType,
      'booking_fee_payer': bookingFeePayer,
      'payment_gateway_fee_payer': paymentGatewayFeePayer,
      'booking_fee': bookingFee,
      'payment_gateway_fee': paymentGatewayFee,
      'total_paid_by_buyer': totalPaidByBuyer,
      'money_to_you': moneyToYou,
      'eg_date': egDate,
    };
  }
}
*/