import 'dart:convert';

class SeatMapResponse {
  final int status;
  final List<TableResult> result;

  SeatMapResponse({
    required this.status,
    required this.result,
  });

  factory SeatMapResponse.fromJson(Map<String, dynamic> json) {
    return SeatMapResponse(
      status: json['status'] ?? 0,
      result: (json['result'] as List<dynamic>?)
              ?.map((e) => TableResult.fromJson(e))
              .toList() ??
          [],
    );
  }
}

class TableResult {
  final int id;
  final int clubId;
  final int layoutId;
  final TableData? tableData;
  final int status;
  final int isBlocked;
  final int reservationTime;
  final String tableId;
  final int eventId;
  final int source;
  final int availability;
  final int seatMapId;
  final List<SeatPoint> seatMapJsonData;
  final String identityDate;
  final String identityTime;

  TableResult({
    required this.id,
    required this.clubId,
    required this.layoutId,
    this.tableData,
    required this.status,
    required this.isBlocked,
    required this.reservationTime,
    required this.tableId,
    required this.eventId,
    required this.source,
    required this.availability,
    required this.seatMapId,
    required this.seatMapJsonData,
    required this.identityDate,
    required this.identityTime,
  });

  factory TableResult.fromJson(Map<String, dynamic> json) {
    // Parse nested JSON strings safely
    final tableDataStr = json['table_data'];
    final seatMapStr = json['seat_map_json_data'];

    return TableResult(
      id: json['id'] ?? 0,
      clubId: json['club_id'] ?? 0,
      layoutId: json['layout_id'] ?? 0,
      tableData: tableDataStr != null
          ? TableData.fromJson(jsonDecode(tableDataStr))
          : null,
      status: json['status'] ?? 0,
      isBlocked: json['is_blocked'] ?? 0,
      reservationTime: json['reservation_time'] ?? 0,
      tableId: json['table_id'] ?? '',
      eventId: json['event_id'] ?? 0,
      source: json['source'] ?? 0,
      availability: json['availability'] ?? 0,
      seatMapId: json['seat_map_id'] ?? 0,
      seatMapJsonData: seatMapStr != null
          ? (jsonDecode(seatMapStr) as List)
              .map((e) => SeatPoint.fromJson(e))
              .toList()
          : [],
      identityDate: json['identity_date'] ?? '',
      identityTime: json['identity_time'] ?? '',
    );
  }
}

class TableData {
  final String type;
  final int id;
  final double x;
  final double y;
  final String label;
  final String tabIndex;
  final String minBilling;
  final String inclusions;
  final double width;
  final double height;
  final double cornerRadius;
  final double rotationAngle;
  final int seats;

  TableData({
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
  });

  factory TableData.fromJson(Map<String, dynamic> json) => TableData(
        type: json['type'] ?? '',
        id: json['id'] ?? 0,
        x: (json['x'] ?? 0).toDouble(),
        y: (json['y'] ?? 0).toDouble(),
        label: json['label'] ?? '',
        tabIndex: json['tabIndex'] ?? '',
        minBilling: json['minBilling']?.toString() ?? '',
        inclusions: json['inclusions'] ?? '',
        width: (json['width'] ?? 0).toDouble(),
        height: (json['height'] ?? 0).toDouble(),
        cornerRadius: (json['cornerRadius'] ?? 0).toDouble(),
        rotationAngle: (json['rotationAngle'] ?? 0).toDouble(),
        seats: json['seats'] ?? 0,
      );
}

class SeatPoint {
  final String type;
  final int id;
  final double x;
  final double y;
  final String label;
  final String tabIndex;
  final String minBilling;
  final String inclusions;
  final double width;
  final double height;
  final double cornerRadius;
  final double rotationAngle;
  final int seats;

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
  });

  factory SeatPoint.fromJson(Map<String, dynamic> json) => SeatPoint(
        type: json['type'] ?? '',
        id: json['id'] ?? 0,
        x: (json['x'] ?? 0).toDouble(),
        y: (json['y'] ?? 0).toDouble(),
        label: json['label'] ?? '',
        tabIndex: json['tabIndex'] ?? '',
        minBilling: json['minBilling']?.toString() ?? '',
        inclusions: json['inclusions'] ?? '',
        width: (json['width'] ?? 0).toDouble(),
        height: (json['height'] ?? 0).toDouble(),
        cornerRadius: (json['cornerRadius'] ?? 0).toDouble(),
        rotationAngle: (json['rotationAngle'] ?? 0).toDouble(),
        seats: json['seats'] ?? 0,
      );
}
