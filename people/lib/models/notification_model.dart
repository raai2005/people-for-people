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
