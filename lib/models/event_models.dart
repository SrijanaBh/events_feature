//import 'package:flutter/material.dart';
import 'package:events_feature/models/ticket_model.dart';

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
  final List<TicketModel> ticketDetails;

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
    required this.ticketDetails,
  });

  factory EventModel.fromJson(Map<String, dynamic> json) {
    return EventModel(
      id: json['id'],
      title: json['title'],
      slug: json['slug'],
      fromDate: DateTime.parse(json['from_date']),
      toDate: DateTime.parse(json['to_date']),
      startTime: json['start_time'],
      endTime: json['end_time'],
      etype: json['etype'],
      imgPath: json['img_path'],
      ticketDetails: (json['ticket_details'] as List)
          .map((e) => TicketModel.fromJson(e))
          .toList(),
    );
  }
}
