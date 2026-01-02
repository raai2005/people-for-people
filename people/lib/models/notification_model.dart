import 'package:flutter/material.dart';

enum NotificationType {
  donation, // Money received or sent
  impact, // "Your donation helped X"
  account, // Profile approved, password changed
  urgent, // "Urgent help needed near you"
  general, // Welcome meesage, app updates
}

class NotificationModel {
  final String id;
  final String title;
  final String body;
  final DateTime timestamp;
  final bool isRead;
  final NotificationType type;
  final Map<String, dynamic>?
  data; // Extra data for navigation (e.g., transactionID)

  NotificationModel({
    required this.id,
    required this.title,
    required this.body,
    required this.timestamp,
    this.isRead = false,
    required this.type,
    this.data,
  });

  // Factory for Firestore (placeholder)
  factory NotificationModel.fromMap(String id, Map<String, dynamic> map) {
    return NotificationModel(
      id: id,
      title: map['title'] ?? '',
      body: map['body'] ?? '',
      timestamp: (map['timestamp'] as dynamic)?.toDate() ?? DateTime.now(),
      isRead: map['isRead'] ?? false,
      type: NotificationType.values.firstWhere(
        (e) => e.toString() == 'NotificationType.${map['type']}',
        orElse: () => NotificationType.general,
      ),
      data: map['data'],
    );
  }

  // Helper to get icon based on type
  IconData get icon {
    switch (type) {
      case NotificationType.donation:
        return Icons.volunteer_activism;
      case NotificationType.impact:
        return Icons.favorite;
      case NotificationType.account:
        return Icons.person;
      case NotificationType.urgent:
        return Icons.warning_amber_rounded;
      case NotificationType.general:
        return Icons.notifications;
    }
  }

  // Helper to get color based on type
  Color get color {
    switch (type) {
      case NotificationType.donation:
        return Colors.green;
      case NotificationType.impact:
        return Colors.pink;
      case NotificationType.account:
        return Colors.blue;
      case NotificationType.urgent:
        return Colors.orange;
      case NotificationType.general:
        return Colors.purple;
    }
  }
}

// Dummy Data for Testing
List<NotificationModel> getDummyNotifications() {
  return [
    NotificationModel(
      id: '1',
      title: 'Donation Successful!',
      body: 'Thank you for donating ₹500 to "Save the Children".',
      timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
      type: NotificationType.donation,
      isRead: false,
    ),
    NotificationModel(
      id: '2',
      title: 'Impact Update',
      body: 'Your donation helped provide food for 3 families today.',
      timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      type: NotificationType.impact,
      isRead: false,
    ),
    NotificationModel(
      id: '3',
      title: 'Profile Approved',
      body: 'Your NGO profile has been verified by the admin.',
      timestamp: DateTime.now().subtract(const Duration(days: 1)),
      type: NotificationType.account,
      isRead: true,
    ),
    NotificationModel(
      id: '4',
      title: 'Winter Drive Alert',
      body: 'Urgent: Winter clothes needed for the upcoming drive on Sunday.',
      timestamp: DateTime.now().subtract(const Duration(days: 2)),
      type: NotificationType.urgent,
      isRead: true,
    ),
  ];
}
