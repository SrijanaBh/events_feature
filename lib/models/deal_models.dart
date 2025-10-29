class DealModel {
  final int id;
  final int restaurentId;
  final int creatorId;
  final String title;
  final String imgPath;
  final String description;
  final String price;
  final String discount;
  final String discountType;
  final double actualPrice;
  final String entryFreeUpto;
  final String daysType;
  final String startTime;
  final String endTime;
  final String onlyToday;
  final String offerStartDate;
  final String offerEndDate;
  final String offerDays;
  final String tc;
  final int dealCreateType;
  final String createDate;
  final String updateDate;
  final int status;
  final int featured;
  final String slug;
  final int onelinkDisplayStatus;
  final double bookingFee;
  final double paymentGatewayFee;
  final double totalPaidByBuyer;
  final double moneyToYou;
  final int bookingFeePayer;
  final int paymentGatewayFeePayer;
  final int isPrivate;
  final String clubTitle;
  final int clubId;

  DealModel({
    required this.id,
    required this.restaurentId,
    required this.creatorId,
    required this.title,
    required this.imgPath,
    required this.description,
    required this.price,
    required this.discount,
    required this.discountType,
    required this.actualPrice,
    required this.entryFreeUpto,
    required this.daysType,
    required this.startTime,
    required this.endTime,
    required this.onlyToday,
    required this.offerStartDate,
    required this.offerEndDate,
    required this.offerDays,
    required this.tc,
    required this.dealCreateType,
    required this.createDate,
    required this.updateDate,
    required this.status,
    required this.featured,
    required this.slug,
    required this.onelinkDisplayStatus,
    required this.bookingFee,
    required this.paymentGatewayFee,
    required this.totalPaidByBuyer,
    required this.moneyToYou,
    required this.bookingFeePayer,
    required this.paymentGatewayFeePayer,
    required this.isPrivate,
    required this.clubTitle,
    required this.clubId,
  });

  factory DealModel.fromJson(Map<String, dynamic> json) {
    return DealModel(
      id: json['id'] ?? 0,
      restaurentId: json['restaurent_id'] ?? 0,
      creatorId: json['creator_id'] ?? 0,
      title: json['title'] ?? '',
      imgPath: json['img_path'] ?? '',
      description: json['description'] ?? '',
      price: json['price']?.toString() ?? '0',
      discount: json['discount']?.toString() ?? '0',
      discountType: json['discount_type'] ?? '',
      actualPrice: (json['actual_price'] is num)
          ? (json['actual_price']).toDouble()
          : double.tryParse(json['actual_price'].toString()) ?? 0.0,
      entryFreeUpto: json['entry_free_upto']?.toString() ?? '',
      daysType: json['days_type'] ?? '',
      startTime: json['start_time'] ?? '',
      endTime: json['end_time'] ?? '',
      onlyToday: json['only_today'] ?? '',
      offerStartDate: json['offer_start_date'] ?? '',
      offerEndDate: json['offer_end_date'] ?? '',
      offerDays: json['offer_days'] ?? '',
      tc: json['tc'] ?? '',
      dealCreateType: json['deal_create_type'] ?? 0,
      createDate: json['create_date'] ?? '',
      updateDate: json['update_date'] ?? '',
      status: json['status'] ?? 0,
      featured: json['featured'] ?? 0,
      slug: json['slug'] ?? '',
      onelinkDisplayStatus: json['onelink_display_status'] ?? 0,
      bookingFee: (json['booking_fee'] is num)
          ? (json['booking_fee']).toDouble()
          : double.tryParse(json['booking_fee'].toString()) ?? 0.0,
      paymentGatewayFee: (json['payment_gateway_fee'] is num)
          ? (json['payment_gateway_fee']).toDouble()
          : double.tryParse(json['payment_gateway_fee'].toString()) ?? 0.0,
      totalPaidByBuyer: (json['total_paid_by_buyer'] is num)
          ? (json['total_paid_by_buyer']).toDouble()
          : double.tryParse(json['total_paid_by_buyer'].toString()) ?? 0.0,
      moneyToYou: (json['money_to_you'] is num)
          ? (json['money_to_you']).toDouble()
          : double.tryParse(json['money_to_you'].toString()) ?? 0.0,
      bookingFeePayer: json['booking_fee_payer'] ?? 0,
      paymentGatewayFeePayer: json['payment_gateway_fee_payer'] ?? 0,
      isPrivate: json['is_private'] ?? 0,
      clubTitle: json['club_title'] ?? '',
      clubId: json['club_id'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'restaurent_id': restaurentId,
      'creator_id': creatorId,
      'title': title,
      'img_path': imgPath,
      'description': description,
      'price': price,
      'discount': discount,
      'discount_type': discountType,
      'actual_price': actualPrice,
      'entry_free_upto': entryFreeUpto,
      'days_type': daysType,
      'start_time': startTime,
      'end_time': endTime,
      'only_today': onlyToday,
      'offer_start_date': offerStartDate,
      'offer_end_date': offerEndDate,
      'offer_days': offerDays,
      'tc': tc,
      'deal_create_type': dealCreateType,
      'create_date': createDate,
      'update_date': updateDate,
      'status': status,
      'featured': featured,
      'slug': slug,
      'onelink_display_status': onelinkDisplayStatus,
      'booking_fee': bookingFee,
      'payment_gateway_fee': paymentGatewayFee,
      'total_paid_by_buyer': totalPaidByBuyer,
      'money_to_you': moneyToYou,
      'booking_fee_payer': bookingFeePayer,
      'payment_gateway_fee_payer': paymentGatewayFeePayer,
      'is_private': isPrivate,
      'club_title': clubTitle,
      'club_id': clubId,
    };
  }
}
