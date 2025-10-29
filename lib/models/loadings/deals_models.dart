import 'package:events_feature/models/ticket_model.dart';

class DealsModel {
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
  final String entryFeeUpto;
  final String daysType;
  final String startTime;
  final String endTime;
  final String onlyToday;
  final DateTime offerStartDate;
  final DateTime offerEndDate;
  final String offerDays;
  final int dealCreateType;
  final String createDate;
  final String updateDate;
  final int status;
  final int featured;
  final String slug;
  final int onelinkDisplayStatus;
  final int totalPaidByBuyer;
  final int moneyToYou;
  final int bookingFeePayer;
  final int paymentGatewayFeePayer;
  final int isPrivate;
  final String clubTitle;
  final int clubId;
  final List<TicketModel> ticketDetails;

  DealsModel({
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
    required this.entryFeeUpto,
    required this.daysType,
    required this.startTime,
    required this.endTime,
    required this.onlyToday,
    required this.offerStartDate,
    required this.offerEndDate,
    required this.offerDays,
    required this.dealCreateType,
    required this.createDate,
    required this.updateDate,
    required this.status,
    required this.featured,
    required this.slug,
    required this.onelinkDisplayStatus,
    required this.totalPaidByBuyer,
    required this.moneyToYou,
    required this.bookingFeePayer,
    required this.paymentGatewayFeePayer,
    required this.isPrivate,
    required this.clubTitle,
    required this.clubId,
    required this.ticketDetails,
  });

  factory DealsModel.fromJson(Map<String, dynamic> json) {
    return DealsModel(
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
      entryFeeUpto: json['entry_fee_upto'],
      daysType: json['days_type'],
      startTime: json['start_time'],
      endTime: json['end_time'],
      onlyToday: json['only_today'],
      offerStartDate: DateTime.parse(json['offer_start_date']),
      offerEndDate: DateTime.parse(json['offer_end_date']),
      offerDays: json['offer_days'],
      dealCreateType: json['deal_create_type'],
      createDate: json['create_date'],
      updateDate: json['update_date'],
      status: json['status'],
      featured: json['featured'],
      slug: json['slug'],
      onelinkDisplayStatus: json['onelink_display_status'],
      totalPaidByBuyer: json['total_paid_by_buyer'],
      moneyToYou: json['money_to_you'],
      bookingFeePayer: json['booking_fee_payer'],
      paymentGatewayFeePayer: json['payment_gateway_fee_payer'],
      isPrivate: json['is_private'],
      clubTitle: json['club_title'],
      clubId: json['club_id'],
      ticketDetails: (json['ticket_details'] as List)
          .map((e) => TicketModel.fromJson(e))
          .toList(),
    );
  }
}
