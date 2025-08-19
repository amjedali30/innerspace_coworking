import 'package:flutter/material.dart';
import 'package:innerspace_coworking/constatnt/colors.dart';
import 'package:intl/intl.dart';

import '../../models/notficationModel.dart';

class NotificationsScreen extends StatelessWidget {
  final List<NotificationModel> notifications = [
    NotificationModel(
        id: '1',
        title: 'Booking Confirmed',
        message:
            'Your booking at Hammerz Work Hub for May 15, 2023 has been confirmed',
        type: NotificationType.booking,
        timestamp: DateTime.now().subtract(const Duration(minutes: 30)),
        isRead: false,
        icon: Icons.calendar_today,
        actionText: 'View Booking',
        bookingId: ""),
    NotificationModel(
        id: '2',
        title: 'Payment Received',
        message:
            'Payment of ₹199 for your booking has been processed successfully',
        type: NotificationType.payment,
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
        isRead: true,
        icon: Icons.payment,
        bookingId: ""),
    NotificationModel(
        id: '3',
        title: 'Workspace Update',
        message:
            'New amenities added to your booked workspace - check them out!',
        type: NotificationType.update,
        timestamp: DateTime.now().subtract(const Duration(days: 1)),
        isRead: true,
        icon: Icons.update,
        actionText: 'See Details',
        bookingId: ""),
  ];

  NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: ColorsData.primaryColor,
        title:
            const Text('Notifications', style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            icon: const Icon(Icons.mark_email_read),
            onPressed: () {
              // Mark all as read functionality
            },
          ),
        ],
      ),
      body: notifications.isEmpty
          ? const Center(
              child: Text('No notifications yet'),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: notifications.length,
              separatorBuilder: (context, index) => const Divider(height: 16),
              itemBuilder: (context, index) {
                final notification = notifications[index];
                return _NotificationCard(notification: notification);
              },
            ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  final NotificationModel notification;

  const _NotificationCard({required this.notification});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: notification.isRead ? Colors.grey[100] : Colors.blue[50],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          // Handle notification tap
          _handleNotificationAction(context);
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _getNotificationColor(notification.type),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  notification.icon,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          notification.title,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: notification.isRead
                                ? Colors.grey[800]
                                : Colors.blue[800],
                          ),
                        ),
                        Text(
                          _formatTime(notification.timestamp),
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      notification.message,
                      style: TextStyle(
                        color: Colors.grey[700],
                      ),
                    ),
                    if (notification.actionText != null) ...[
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () => _handleNotificationAction(context),
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                          ),
                          child: Text(
                            notification.actionText!,
                            style: TextStyle(
                              color: _getNotificationColor(notification.type),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getNotificationColor(NotificationType type) {
    switch (type) {
      case NotificationType.booking:
        return Colors.green;
      case NotificationType.payment:
        return Colors.blue;
      case NotificationType.update:
        return Colors.orange;
    }
  }

  String _formatTime(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return DateFormat('MMM d').format(timestamp);
    }
  }

  void _handleNotificationAction(BuildContext context) {
    switch (notification.type) {
      case NotificationType.booking:
        // Navigate to booking details
        break;
      case NotificationType.payment:
        // Navigate to payment details
        break;
      case NotificationType.update:
        // Show update details
        break;
    }
  }
}
