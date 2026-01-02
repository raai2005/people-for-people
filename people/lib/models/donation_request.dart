import 'package:cloud_firestore/cloud_firestore.dart';

// Donation Category Enum
enum DonationCategory { money, food, clothes, medical, education, other }

// Urgency Level Enum
enum UrgencyLevel { low, medium, high, critical }

// Request Status Enum
enum RequestStatus { active, completed, cancelled, expired }

// Donation Request Model
class DonationRequest {
  final String id;
  final String ngoId;
  final String ngoName;
  final String title;
  final String description;
  final DonationCategory category;
  final UrgencyLevel urgency;
  final RequestStatus status;

  // For monetary donations
  final double? targetAmount;
  final double currentAmount;

  // For item donations
  final int? targetQuantity;
  final int currentQuantity;

  final List<String> images;
  final String location;
  final DateTime? deadline;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Optional fields
  final String? contactPerson;
  final String? contactPhone;
  final String? contactEmail;

  DonationRequest({
    required this.id,
    required this.ngoId,
    required this.ngoName,
    required this.title,
    required this.description,
    required this.category,
    this.urgency = UrgencyLevel.medium,
    this.status = RequestStatus.active,
    this.targetAmount,
    this.currentAmount = 0.0,
    this.targetQuantity,
    this.currentQuantity = 0,
    this.images = const [],
    required this.location,
    this.deadline,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.contactPerson,
    this.contactPhone,
    this.contactEmail,
  }) : createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  // Convert to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'ngoId': ngoId,
      'ngoName': ngoName,
      'title': title,
      'description': description,
      'category': category.name,
      'urgency': urgency.name,
      'status': status.name,
      'targetAmount': targetAmount,
      'currentAmount': currentAmount,
      'targetQuantity': targetQuantity,
      'currentQuantity': currentQuantity,
      'images': images,
      'location': location,
      'deadline': deadline?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'contactPerson': contactPerson,
      'contactPhone': contactPhone,
      'contactEmail': contactEmail,
    };
  }

  // Create from Firestore Map
  factory DonationRequest.fromMap(Map<String, dynamic> map) {
    DateTime? parsedCreatedAt;
    DateTime? parsedUpdatedAt;
    DateTime? parsedDeadline;

    if (map['createdAt'] != null) {
      if (map['createdAt'] is Timestamp) {
        parsedCreatedAt = (map['createdAt'] as Timestamp).toDate();
      } else if (map['createdAt'] is String) {
        parsedCreatedAt = DateTime.tryParse(map['createdAt']);
      }
    }

    if (map['updatedAt'] != null) {
      if (map['updatedAt'] is Timestamp) {
        parsedUpdatedAt = (map['updatedAt'] as Timestamp).toDate();
      } else if (map['updatedAt'] is String) {
        parsedUpdatedAt = DateTime.tryParse(map['updatedAt']);
      }
    }

    if (map['deadline'] != null) {
      if (map['deadline'] is Timestamp) {
        parsedDeadline = (map['deadline'] as Timestamp).toDate();
      } else if (map['deadline'] is String) {
        parsedDeadline = DateTime.tryParse(map['deadline']);
      }
    }

    return DonationRequest(
      id: map['id'] ?? '',
      ngoId: map['ngoId'] ?? '',
      ngoName: map['ngoName'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      category: DonationCategory.values.firstWhere(
        (e) => e.name == map['category'],
        orElse: () => DonationCategory.other,
      ),
      urgency: UrgencyLevel.values.firstWhere(
        (e) => e.name == map['urgency'],
        orElse: () => UrgencyLevel.medium,
      ),
      status: RequestStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => RequestStatus.active,
      ),
      targetAmount: map['targetAmount']?.toDouble(),
      currentAmount: (map['currentAmount'] ?? 0.0).toDouble(),
      targetQuantity: map['targetQuantity'],
      currentQuantity: map['currentQuantity'] ?? 0,
      images: List<String>.from(map['images'] ?? []),
      location: map['location'] ?? '',
      deadline: parsedDeadline,
      createdAt: parsedCreatedAt,
      updatedAt: parsedUpdatedAt,
      contactPerson: map['contactPerson'],
      contactPhone: map['contactPhone'],
      contactEmail: map['contactEmail'],
    );
  }

  // Helper method to calculate progress percentage
  double get progressPercentage {
    if (category == DonationCategory.money &&
        targetAmount != null &&
        targetAmount! > 0) {
      return (currentAmount / targetAmount!) * 100;
    } else if (targetQuantity != null && targetQuantity! > 0) {
      return (currentQuantity / targetQuantity!) * 100;
    }
    return 0.0;
  }

  // Check if request is expired
  bool get isExpired {
    if (deadline == null) return false;
    return DateTime.now().isAfter(deadline!);
  }

  // Check if goal is reached
  bool get isGoalReached {
    if (category == DonationCategory.money && targetAmount != null) {
      return currentAmount >= targetAmount!;
    } else if (targetQuantity != null) {
      return currentQuantity >= targetQuantity!;
    }
    return false;
  }

  // Copy with method for updates
  DonationRequest copyWith({
    String? id,
    String? ngoId,
    String? ngoName,
    String? title,
    String? description,
    DonationCategory? category,
    UrgencyLevel? urgency,
    RequestStatus? status,
    double? targetAmount,
    double? currentAmount,
    int? targetQuantity,
    int? currentQuantity,
    List<String>? images,
    String? location,
    DateTime? deadline,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? contactPerson,
    String? contactPhone,
    String? contactEmail,
  }) {
    return DonationRequest(
      id: id ?? this.id,
      ngoId: ngoId ?? this.ngoId,
      ngoName: ngoName ?? this.ngoName,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      urgency: urgency ?? this.urgency,
      status: status ?? this.status,
      targetAmount: targetAmount ?? this.targetAmount,
      currentAmount: currentAmount ?? this.currentAmount,
      targetQuantity: targetQuantity ?? this.targetQuantity,
      currentQuantity: currentQuantity ?? this.currentQuantity,
      images: images ?? this.images,
      location: location ?? this.location,
      deadline: deadline ?? this.deadline,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      contactPerson: contactPerson ?? this.contactPerson,
      contactPhone: contactPhone ?? this.contactPhone,
      contactEmail: contactEmail ?? this.contactEmail,
    );
  }
}
