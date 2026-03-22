import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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

  // Send notification to Firestore
  Future<void> sendNotification({
    required String userId,
    required String title,
    required String message,
    required String type,
  }) async {
    try {
      await FirebaseFirestore.instance.collection('notifications').add({
        'userId': userId,
        'title': title,
        'message': message,
        'type': type,
        'isRead': false,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error sending notification: $e');
    }
  }

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
