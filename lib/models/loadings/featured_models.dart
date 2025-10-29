class FeaturedEventModels {
  final int id;
  final String title;
  final String slug;
  final String fromDate;
  final String toDate;
  final String onlyToday;
  final String imgPath;
  final String startTime;
  final String endTime;
  final String etype;
  final int featured;

  FeaturedEventModels({
    required this.id,
    required this.title,
    required this.slug,
    required this.fromDate,
    required this.toDate,
    required this.onlyToday,
    required this.imgPath,
    required this.startTime,
    required this.endTime,
    required this.etype,
    required this.featured,
  });

  factory FeaturedEventModels.fromJson(Map<String, dynamic> json) {
    return FeaturedEventModels(
      id: json['id'],
      title: json['title'],
      slug: json['slug'],
      fromDate: json['from_date'], // fixed key
      toDate: json['to_date'],
      onlyToday: json['only_today'],
      imgPath: json['img_path'],
      startTime: json['start_time'],
      endTime: json['end_time'],
      etype: json['etype'],
      featured: json['featured'],
    );
  }
}

class FeaturedDealModels {
  final int id;
  final int restaurentId;
  final int creatorId;
  final String title;
  final String imgPath;
  final String description;
  final String price;
  final String discount;
  final String discountType;
  final int actualPrice;
  final String entryFreeUpto;
  final String daysType;
  final String startTime;
  final String endTime;
  final String onlyToday;
  final String offerStartDate;
  final String offerEndDate;
  final String offerDays;
  final String to;
  final int dealCreateType;
  final String createDate;
  final String updateDate;
  final int status;
  final int featured;
  final String slug;
  final int onelinkDisplayStatus;
  final int bookingFee;
  final int paymentGatewayFee;
  final int totalPaidByBuyer;
  final int moneyToYou;
  final int bookingFeePayer;
  final int paymentGatewayFeePayer;
  final int isPrivate;
  final String clubTitle;
  final int clubId;

  FeaturedDealModels({
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
    required this.to,
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

  factory FeaturedDealModels.fromJson(Map<String, dynamic> json) {
    return FeaturedDealModels(
      id: json['id'],
      restaurentId: json['restaurent_id'],
      creatorId: json['creator_id'],
      title: json['title'],
      imgPath: json['img_path'],
      description: json['description'],
      price: json['price'],
      discount: json['discount'],
      discountType: json['discount_type'],
      actualPrice: json['actual_price'],
      entryFreeUpto: json['entry_free_upto'],
      daysType: json['days_type'],
      startTime: json['start_time'],
      endTime: json['end_time'],
      onlyToday: json['only_today'],
      offerStartDate: json['offer_start_date'],
      offerEndDate: json['offer_end_date'],
      offerDays: json['offer_days'],
      to: json['to'],
      dealCreateType: json['deal_create_type'],
      createDate: json['create_date'],
      updateDate: json['update_date'],
      status: json['status'],
      featured: json['featured'],
      slug: json['slug'],
      onelinkDisplayStatus: json['onelink_display_status'],
      bookingFee: json['booking_fee'],
      paymentGatewayFee: json['payment_gateway_fee'],
      totalPaidByBuyer: json['total_paid_by_buyer'],
      moneyToYou: json['money_to_you'],
      bookingFeePayer: json['booking_fee_payer'],
      paymentGatewayFeePayer: json['payment_gateway_fee_payer'],
      isPrivate: json['is_private'],
      clubTitle: json['club_title'],
      clubId: json['club_id'],
    );
  }
}
