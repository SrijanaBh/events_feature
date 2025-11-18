import 'dart:convert';

class EventSeatMapResponse {
  final bool success;
  final String message;
  final List<EventSeatMapData> data;

  EventSeatMapResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory EventSeatMapResponse.fromJson(Map<String, dynamic> json) {
    return EventSeatMapResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: (json['data'] as List<dynamic>?)
              ?.map((item) => EventSeatMapData.fromJson(item))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() => {
        'success': success,
        'message': message,
        'data': data.map((item) => item.toJson()).toList(),
      };
}

class EventSeatMapData {
  final int id;
  final int clubId;
  final int seatMapId;
  final int eventId;
  final int status;
  final String? seatMapSvgData;
  final List<SeatPoint> seatMapJsonData;
  final String identityDate;
  final String identityTime;
  final String saleEndTime;
  final String imgPath;

  EventSeatMapData({
    required this.id,
    required this.clubId,
    required this.seatMapId,
    required this.eventId,
    required this.status,
    this.seatMapSvgData,
    required this.seatMapJsonData,
    required this.identityDate,
    required this.identityTime,
    required this.saleEndTime,
    required this.imgPath,
  });

  factory EventSeatMapData.fromJson(Map<String, dynamic> json) {
    return EventSeatMapData(
      id: json['id'] ?? 0,
      clubId: json['club_id'] ?? 0,
      seatMapId: json['seat_map_id'] ?? 0,
      eventId: json['event_id'] ?? 0,
      status: json['status'] ?? 0,
      seatMapSvgData: json['seat_map_svg_data'],
      seatMapJsonData: (json['seat_map_json_data'] as List<dynamic>?)
              ?.map((item) => SeatPoint.fromJson(item))
              .toList() ??
          [],
      identityDate: json['identity_date'] ?? '',
      identityTime: json['identity_time'] ?? '',
      saleEndTime: json['sale_end_time'] ?? '',
      imgPath: json['img_path'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'club_id': clubId,
        'seat_map_id': seatMapId,
        'event_id': eventId,
        'status': status,
        'seat_map_svg_data': seatMapSvgData,
        'seat_map_json_data': seatMapJsonData.map((e) => e.toJson()).toList(),
        'identity_date': identityDate,
        'identity_time': identityTime,
        'sale_end_time': saleEndTime,
        'img_path': imgPath,
      };
}

class SeatPoint {
  final String type;
  final int id;
  final double x;
  final double y;
  final String label;
  final dynamic tabIndex;
  final String minBilling;
  final String inclusions;
  final double width;
  final double height;
  final double cornerRadius;
  final double rotationAngle;
  final dynamic seats;
  final int status;
  final int isBlocked;
  final int isBooked;

  SeatPoint({
    required this.type,
    required this.id,
    required this.x,
    required this.y,
    required this.label,
    required this.tabIndex,
    required this.minBilling,
    required this.inclusions,
    required this.width,
    required this.height,
    required this.cornerRadius,
    required this.rotationAngle,
    required this.seats,
    required this.status,
    required this.isBlocked,
    required this.isBooked,
  });

  factory SeatPoint.fromJson(Map<String, dynamic> json) {
    return SeatPoint(
      type: json['type'] ?? '',
      id: json['id'] ?? 0,
      x: (json['x'] ?? 0).toDouble(),
      y: (json['y'] ?? 0).toDouble(),
      label: json['label'] ?? '',
      tabIndex: json['tabIndex'] ?? '',
      minBilling: json['minBilling'] ?? '',
      inclusions: json['inclusions'] ?? '',
      width: (json['width'] ?? 0).toDouble(),
      height: (json['height'] ?? 0).toDouble(),
      cornerRadius: (json['cornerRadius'] ?? 0).toDouble(),
      rotationAngle: (json['rotationAngle'] ?? 0).toDouble(),
      seats: json['seats'] ?? 0,
      status: json['status'] ?? 0,
      isBlocked: json['is_blocked'] ?? 0,
      isBooked: json['is_booked'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'type': type,
        'id': id,
        'x': x,
        'y': y,
        'label': label,
        'tabIndex': tabIndex,
        'minBilling': minBilling,
        'inclusions': inclusions,
        'width': width,
        'height': height,
        'cornerRadius': cornerRadius,
        'rotationAngle': rotationAngle,
        'seats': seats,
        'status': status,
        'is_blocked': isBlocked,
        'is_booked': isBooked,
      };
}
