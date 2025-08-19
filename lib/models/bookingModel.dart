import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

enum BookingStatus { upcoming, completed, cancelled }

class BookingModel {
  final String? id;
  final String userId;
  final String username;
  final String phoneNumber;
  final String branchId;
  final String branchName;
  final DateTime date;
  final TimeOfDay startTime;
  final TimeOfDay endTime;
  final double pricePerHour;
  final BookingStatus status;
  final DateTime? createdAt;

  BookingModel({
    this.id,
    required this.userId,
    required this.username,
    required this.phoneNumber,
    required this.branchId,
    required this.branchName,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.pricePerHour,
    this.status = BookingStatus.upcoming,
    this.createdAt,
    String? deviceToken,
  });

  String get formattedDate => DateFormat('MMM dd, yyyy').format(date);

  String get formattedTime {
    final startHour = startTime.hourOfPeriod;
    final startMinute = startTime.minute.toString().padLeft(2, '0');
    final startPeriod = startTime.period == DayPeriod.am ? 'AM' : 'PM';

    final endHour = endTime.hourOfPeriod;
    final endMinute = endTime.minute.toString().padLeft(2, '0');
    final endPeriod = endTime.period == DayPeriod.am ? 'AM' : 'PM';

    return '$startHour:$startMinute $startPeriod - $endHour:$endMinute $endPeriod';
  }

  String get formattedDateTime => '$formattedDate, $formattedTime';

  double get totalPrice {
    final hours = endTime.hour - startTime.hour;
    final minutes = endTime.minute - startTime.minute;
    return pricePerHour * (hours + minutes / 60);
  }

  Color get statusColor {
    switch (status) {
      case BookingStatus.upcoming:
        return Colors.blue;
      case BookingStatus.completed:
        return Colors.green;
      case BookingStatus.cancelled:
        return Colors.red;
    }
  }

  IconData get statusIcon {
    switch (status) {
      case BookingStatus.upcoming:
        return Icons.access_time;
      case BookingStatus.completed:
        return Icons.check_circle;
      case BookingStatus.cancelled:
        return Icons.cancel;
    }
  }

  factory BookingModel.fromMap(Map<String, dynamic> data, String docId) {
    return BookingModel(
      id: docId,
      userId: data['userId'] ?? '',
      username: data['username'] ?? '',
      phoneNumber: data['phoneNumber'] ?? '',
      branchId: data['branchId'] ?? '',
      branchName: data['branchName'] ?? '',
      date: (data['date'] as Timestamp).toDate(),
      startTime: _timeFromString(data['startTime']),
      endTime: _timeFromString(data['endTime']),
      pricePerHour: (data['pricePerHour'] as num).toDouble(),
      status: _statusFromString(data['status']),
      createdAt: data['createdAt'] != null
          ? (data['createdAt'] as Timestamp).toDate()
          : null,
    );
  }

  static TimeOfDay _timeFromString(String time) {
    final parts = time.split(':');
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }

  static BookingStatus _statusFromString(String status) {
    switch (status) {
      case 'completed':
        return BookingStatus.completed;
      case 'cancelled':
        return BookingStatus.cancelled;
      default:
        return BookingStatus.upcoming;
    }
  }

  Map<String, dynamic> toMap() {
    return {
      "userId": userId,
      "username": username,
      "phoneNumber": phoneNumber,
      "branchId": branchId,
      "branchName": branchName,
      "date": Timestamp.fromDate(date),
      "startTime": "${startTime.hour}:${startTime.minute}",
      "endTime": "${endTime.hour}:${endTime.minute}",
      "pricePerHour": pricePerHour,
      "status": status.toString().split('.').last,
      "createdAt": createdAt != null
          ? Timestamp.fromDate(createdAt!)
          : FieldValue.serverTimestamp(),
    };
  }
}
