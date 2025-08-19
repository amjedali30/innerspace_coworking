import 'package:flutter/material.dart';

enum NotificationType { booking, payment, update }

class NotificationModel {
  final String id;
  final String title;
  final String message;
  final NotificationType type;
  final DateTime timestamp;
  final bool isRead;
  final IconData icon;
  final String? actionText;
  final String bookingId;

  const NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.timestamp,
    required this.isRead,
    required this.icon,
    this.actionText,
    required this.bookingId,
  });

  NotificationModel copyWith(
      {String? id,
      String? title,
      String? message,
      NotificationType? type,
      DateTime? timestamp,
      bool? isRead,
      IconData? icon,
      String? actionText,
      String? bookingId}) {
    return NotificationModel(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      type: type ?? this.type,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
      icon: icon ?? this.icon,
      actionText: actionText ?? this.actionText,
      bookingId: bookingId ?? this.bookingId,
    );
  }
}
