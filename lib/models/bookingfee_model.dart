class BookingFeeModel {
  final bool success;
  final String message;
  final BookingFeeData data; // ✅ this is correct

  BookingFeeModel({
    required this.success,
    required this.message,
    required this.data,
  });

  factory BookingFeeModel.fromJson(Map<String, dynamic> json) {
    return BookingFeeModel(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: BookingFeeData.fromJson(json['data'] ?? {}),
    );
  }
}

class BookingFeeData {
  final double bookingFee;
  final int bookingFeePayer;
  final int paymentGatewayFeePayer;
  final double gst;

  BookingFeeData({
    required this.bookingFee,
    required this.bookingFeePayer,
    required this.paymentGatewayFeePayer,
    required this.gst,
  });

  factory BookingFeeData.fromJson(Map<String, dynamic> json) {
    return BookingFeeData(
      bookingFee: (json['booking_fee'] ?? 0).toDouble(),
      bookingFeePayer: json['booking_fee_payer'] ?? 0,
      paymentGatewayFeePayer: json['payment_gateway_fee_payer'] ?? 0,
      gst: (json['gst'] ?? 0).toDouble(),
    );
  }
}
