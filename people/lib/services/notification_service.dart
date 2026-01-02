import 'package:flutter/material.dart';
import '../models/notification_model.dart';

class NotificationService {
  // Singleton pattern
  static final NotificationService _instance = NotificationService._internal();
  static NotificationService get instance => _instance;

  NotificationService._internal();

  // Observable state for unread notifications
  final ValueNotifier<bool> hasUnreadNotifications = ValueNotifier<bool>(false);

  // In-memory list of notifications (initially empty)
  final List<NotificationModel> _notifications = [];

  List<NotificationModel> get notifications =>
      List.unmodifiable(_notifications);

  // Mark all notifications as read
  void markAllAsRead() {
    hasUnreadNotifications.value = false;
    for (var _ in _notifications) {
      // In a real app, we would update the model's isRead property here
      // But since models are immutable, we'd need to replace them or handle it in the backend
    }
  }

  // Method to trigger a new notification
  void addNotification(NotificationModel notification) {
    _notifications.insert(0, notification); // Add to top
    hasUnreadNotifications.value = true;
  }
}
