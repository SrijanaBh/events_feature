import 'package:events_feature/models/get_tickets_price_events.dart';

class EventModel {
  final int id;
  final String title;
  final String slug;
  final DateTime fromDate;
  final DateTime toDate;
  final String startTime;
  final String endTime;
  final String etype;
  final String imgPath;
  final String venue;
  final String description;
  final List<GetEventTicketDetails> ticketDetails;

  EventModel({
    required this.id,
    required this.title,
    required this.slug,
    required this.fromDate,
    required this.toDate,
    required this.startTime,
    required this.endTime,
    required this.etype,
    required this.imgPath,
    required this.venue,
    required this.description,
    required this.ticketDetails,
  });

  factory EventModel.fromJson(Map<String, dynamic> json) {
    final event = json['event'] ?? {};
    final ticketsData = json['tickets'] as List<dynamic>? ?? [];

    return EventModel(
      id: event['id'],
      title: event['title'] ?? "",
      slug: event['slug'] ?? "",
      fromDate: DateTime.parse(event['from_date']),
      toDate: DateTime.parse(event['to_date']),
      startTime: event['start_time'] ?? "",
      endTime: event['end_time'] ?? "",
      etype: event['event_type'] ?? "",
      imgPath: event['img_path'] ?? "",
      venue: event['event_venue'] ?? "",
      description: event['description'] ?? "",
      ticketDetails: ticketsData
          .map((t) => GetEventTicketDetails.fromJson(t))
          .toList(),
    );
  }
}
