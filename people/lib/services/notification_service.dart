import 'package:flutter/material.dart';

class NotificationService {
  // Singleton pattern
  static final NotificationService _instance = NotificationService._internal();
  static NotificationService get instance => _instance;

  NotificationService._internal();

  // Observable state for unread notifications
  // Initially true to show the dot for demonstration
  final ValueNotifier<bool> hasUnreadNotifications = ValueNotifier<bool>(true);

  // Mark all notifications as read
  void markAllAsRead() {
    hasUnreadNotifications.value = false;
  }

  // Method to trigger a new notification (for future use)
  void triggerNewNotification() {
    hasUnreadNotifications.value = true;
  }
}
