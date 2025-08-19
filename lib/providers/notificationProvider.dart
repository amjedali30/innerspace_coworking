// import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

import '../models/notficationModel.dart';
import '../services/firebase_messaging_service.dart';

class NotificationProvider with ChangeNotifier {
  // final FirebaseMessagingService _messagingService;
  String? _deviceToken;
  List<NotificationModel> _notifications = [];
  // NotificationProvider(this._messagingService);

  String? get deviceToken => _deviceToken;
  List<NotificationModel> get notifications => _notifications;
  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  // Future<void> initialize() async {
  //   await _messagingService.initialize();
  //   _deviceToken = await _messagingService.getDeviceToken();

  //   // Listen for notification taps
  //   FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
  //     _handleNotificationTap(message);
  //   });
  // }

  Future<void> loadNotifications() async {
    // Load from Firestore or local storage
    // For now using mock data
    _notifications = [
      NotificationModel(
        id: '1',
        title: 'Booking Confirmed',
        message: 'Your booking at Hammerz Work Hub has been confirmed',
        type: NotificationType.booking,
        timestamp: DateTime.now().subtract(const Duration(minutes: 30)),
        isRead: false,
        bookingId: 'booking123',
        actionText: 'View Booking',
        icon: Icons.home,
      ),
      // Add more notifications
    ];
    notifyListeners();
  }

  Future<void> markAsRead(String notificationId) async {
    final index = _notifications.indexWhere((n) => n.id == notificationId);
    if (index != -1) {
      _notifications[index] = _notifications[index].copyWith(isRead: true);
      notifyListeners();
    }
  }

  Future<void> markAllAsRead() async {
    _notifications =
        _notifications.map((n) => n.copyWith(isRead: true)).toList();
    notifyListeners();
  }

  Future<void> addNotification(NotificationModel notification) async {
    _notifications.insert(0, notification);
    notifyListeners();
  }

  // void _handleNotificationTap(RemoteMessage message) {
  //   final bookingId = message.data['bookingId'];
  //   if (bookingId != null) {
  //     // Add to notifications list
  //     _notifications.insert(
  //         0,
  //         {
  //           'title': message.notification?.title ?? 'Booking Update',
  //           'body': message.notification?.body ?? '',
  //           'bookingId': bookingId,
  //           'timestamp': DateTime.now(),
  //         } as NotificationModel);
  //     notifyListeners();
  //   }
  // }

  void clearNotifications() {
    _notifications.clear();
    notifyListeners();
  }
}
