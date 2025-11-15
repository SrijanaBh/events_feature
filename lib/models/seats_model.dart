class Seat {
  int count = 0;

  // Visual Properties
  final double x;
  final double y;
  final double width;
  final double height;
  final double cornerRadius;
  final double rotationAngle;
  final String? label;

  // Data Properties
  final String? type;
  final num? id;
  final dynamic tabIndex;
  final num minBilling; // keep as num (could be "1000" string from API)
  final String? inclusions;
  final int? seats; // number of people the table can accommodate

  // New fields from API
  final int? status;
  final int isBlocked;
  final int isBooked;

  Seat({
    // Visual
    required this.x,
    required this.y,
    required this.width,
    required this.height,
    required this.cornerRadius,
    required this.rotationAngle,
    this.label,
    // Data
    this.type,
    this.id,
    this.tabIndex,
    required this.minBilling,
    this.inclusions,
    this.seats,
    this.status,
    required this.isBlocked,
    required this.isBooked,
  });

  /// Robust parsing helper for seats (int or string)
  static int? _parseSeats(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    if (value is num) return value.toInt();
    return null;
  }

  factory Seat.fromJson(Map<String, dynamic> json) {
    // minBilling can come as "1000" or numeric; default to 0
    final num parsedMinBilling =
        num.tryParse(json['minBilling']?.toString() ?? '') ?? 0;

    return Seat(
      x: (json['x'] as num? ?? 0).toDouble(),
      y: (json['y'] as num? ?? 0).toDouble(),
      width: (json['width'] as num? ?? 60).toDouble(),
      height: (json['height'] as num? ?? 60).toDouble(),
      cornerRadius: (json['cornerRadius'] as num? ?? 10).toDouble(),
      rotationAngle: (json['rotationAngle'] as num? ?? 0).toDouble(),
      label: json['label'] as String?,
      type: json['type'] as String?,
      id: json['id'] as num?,
      tabIndex: json['tabIndex'],
      minBilling: parsedMinBilling,
      inclusions: json['inclusions'] as String?,
      seats: _parseSeats(json['seats']),
      status: (json['status'] is num) ? (json['status'] as num).toInt() : null,
      isBlocked: json['is_blocked'],
      isBooked: json['is_booked'],
    );
  }
}

class SeatMapDetails {
  final List<Seat> seats;
  final String? identityDate;
  final String? identityTime;
  final String? saleEndTime;
  final String? imgPath;

  SeatMapDetails({
    required this.seats,
    this.identityDate,
    this.identityTime,
    this.saleEndTime,
    this.imgPath,
  });

  factory SeatMapDetails.fromJson(Map<String, dynamic> json) {
    final List<dynamic> seatMapJson = json['seat_map_json_data'] ?? [];

    final seats =
        seatMapJson
            .map((s) => Seat.fromJson(Map<String, dynamic>.from(s)))
            .toList();

    return SeatMapDetails(
      seats: seats,
      identityDate: json['identity_date'] as String?,
      identityTime: json['identity_time'] as String?,
      saleEndTime: json['sale_end_time'] as String?,
      imgPath: json['img_path'] as String?,
    );
  }
}
