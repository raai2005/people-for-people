// User Role Enum
import 'package:cloud_firestore/cloud_firestore.dart';

enum UserRole { ngo, donor, volunteer }

// Verification Status Model
class VerificationStatus {
  final bool email;
  final bool phone;
  final bool governmentId;

  VerificationStatus({
    this.email = false,
    this.phone = false,
    this.governmentId = false,
  });

  Map<String, dynamic> toMap() {
    return {'email': email, 'phone': phone, 'governmentId': governmentId};
  }

  factory VerificationStatus.fromMap(Map<String, dynamic>? map) {
    if (map == null) {
      return VerificationStatus();
    }
    return VerificationStatus(
      email: map['email'] ?? false,
      phone: map['phone'] ?? false,
      governmentId: map['governmentId'] ?? false,
    );
  }
}

// Base User class
abstract class BaseUser {
  final String id;
  final String name;
  final String phone;
  final String email;
  final String location;
  final String verifiedIdUrl;
  final UserRole role;
  final bool isApproved;
  final DateTime createdAt;
  final int profileCompletion;
  final VerificationStatus verification;

  BaseUser({
    required this.id,
    required this.name,
    required this.phone,
    required this.email,
    required this.location,
    required this.verifiedIdUrl,
    required this.role,
    this.isApproved = false,
    DateTime? createdAt,
    this.profileCompletion = 0,
    VerificationStatus? verification,
  }) : createdAt = createdAt ?? DateTime.now(),
       verification = verification ?? VerificationStatus();
}

// NGO/Organisation Model
class NGOUser extends BaseUser {
  final String organizationName;
  final String address;
  final String govtVerifiedDocUrl;
  final String headOfOrgId;
  final String headOfOrgIdUrl;

  NGOUser({
    required super.id,
    required super.name,
    required super.phone,
    required super.email,
    required super.location,
    required super.verifiedIdUrl,
    required this.organizationName,
    required this.address,
    required this.govtVerifiedDocUrl,
    required this.headOfOrgId,
    required this.headOfOrgIdUrl,
    super.isApproved,
    super.createdAt,
    super.profileCompletion,
    super.verification,
  }) : super(role: UserRole.ngo);

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'email': email,
      'location': location,
      'verifiedIdUrl': verifiedIdUrl,
      'role': 'ngo',
      'isApproved': isApproved,
      'createdAt': createdAt.toIso8601String(),
      'profileCompletion': profileCompletion,
      'verification': verification.toMap(),
      'organizationName': organizationName,
      'address': address,
      'govtVerifiedDocUrl': govtVerifiedDocUrl,
      'headOfOrgId': headOfOrgId,
      'headOfOrgIdUrl': headOfOrgIdUrl,
    };
  }

  factory NGOUser.fromMap(Map<String, dynamic> map) {
    DateTime? parsedCreatedAt;
    if (map['createdAt'] != null) {
      if (map['createdAt'] is Timestamp) {
        parsedCreatedAt = (map['createdAt'] as Timestamp).toDate();
      } else if (map['createdAt'] is String) {
        parsedCreatedAt = DateTime.tryParse(map['createdAt']);
      }
    }

    return NGOUser(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      phone: map['phone'] ?? '',
      email: map['email'] ?? '',
      location: map['location'] ?? '',
      verifiedIdUrl: map['verifiedIdUrl'] ?? '',
      organizationName: map['organizationName'] ?? '',
      address: map['address'] ?? '',
      govtVerifiedDocUrl: map['govtVerifiedDocUrl'] ?? '',
      headOfOrgId: map['headOfOrgId'] ?? '',
      headOfOrgIdUrl: map['headOfOrgIdUrl'] ?? '',
      isApproved: map['isApproved'] ?? false,
      createdAt: parsedCreatedAt,
      profileCompletion: map['profileCompletion'] ?? 0,
      verification: VerificationStatus.fromMap(map['verification']),
    );
  }
}

// Donor Profile Model
class DonorProfile {
  final String bio;
  final String occupation;
  final String location;
  final String profileImage;
  final List<String> badges;
  final int donationCount;
  final double rating;

  DonorProfile({
    this.bio = "",
    this.occupation = "",
    this.location = "",
    this.profileImage = "",
    this.badges = const [],
    this.donationCount = 0,
    this.rating = 0.0,
  });

  Map<String, dynamic> toMap() {
    return {
      'bio': bio,
      'occupation': occupation,
      'location': location,
      'profileImage': profileImage,
      'badges': badges,
      'donationCount': donationCount,
      'rating': rating,
    };
  }

  factory DonorProfile.fromMap(Map<String, dynamic>? map) {
    if (map == null) {
      return DonorProfile();
    }
    return DonorProfile(
      bio: map['bio'] ?? "",
      occupation: map['occupation'] ?? "",
      location: map['location'] ?? "",
      profileImage: map['profileImage'] ?? "",
      badges: List<String>.from(map['badges'] ?? []),
      donationCount: map['donationCount'] ?? 0,
      rating: (map['rating'] ?? 0.0).toDouble(),
    );
  }
}

// Donor Model
class DonorUser extends BaseUser {
  final String qualification;
  final String? profileImageUrl;
  final String? bio;
  final String? occupation;
  final DonorProfile donorProfile;

  DonorUser({
    required super.id,
    required super.name,
    required super.phone,
    required super.email,
    required super.location,
    required super.verifiedIdUrl,
    required this.qualification,
    this.profileImageUrl,
    this.bio,
    this.occupation,
    super.isApproved,
    super.createdAt,
    super.profileCompletion,
    super.verification,
    DonorProfile? donorProfile,
  }) : donorProfile = donorProfile ?? DonorProfile(),
       super(role: UserRole.donor);

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'email': email,
      'location': location,
      'verifiedIdUrl': verifiedIdUrl,
      'role': 'donor',
      'isApproved': isApproved,
      'createdAt': createdAt.toIso8601String(),
      'profileCompletion': profileCompletion,
      'verification': verification.toMap(),
      'qualification': qualification,
      'profileImageUrl': profileImageUrl,
      'bio': bio,
      'occupation': occupation,
      'donorProfile': donorProfile.toMap(),
    };
  }

  factory DonorUser.fromMap(Map<String, dynamic> map) {
    DateTime? parsedCreatedAt;
    if (map['createdAt'] != null) {
      if (map['createdAt'] is Timestamp) {
        parsedCreatedAt = (map['createdAt'] as Timestamp).toDate();
      } else if (map['createdAt'] is String) {
        parsedCreatedAt = DateTime.tryParse(map['createdAt']);
      }
    }

    return DonorUser(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      phone: map['phone'] ?? '',
      email: map['email'] ?? '',
      location: map['location'] ?? '',
      verifiedIdUrl: map['verifiedIdUrl'] ?? '',
      qualification: map['qualification'] ?? '',
      profileImageUrl: map['profileImageUrl'],
      bio: map['bio'],
      occupation: map['occupation'],
      isApproved: map['isApproved'] ?? false,
      createdAt: parsedCreatedAt,
      profileCompletion: map['profileCompletion'] ?? 0,
      verification: VerificationStatus.fromMap(map['verification']),
      donorProfile: DonorProfile.fromMap(map['donorProfile']),
    );
  }
}

// Volunteer Model
class VolunteerUser extends BaseUser {
  final String qualification;
  final bool isWorkingInNGO;
  final String? ngoName;
  final String? ngoPhone;
  final String? employeeId;
  final bool isAdminApproved;

  VolunteerUser({
    required super.id,
    required super.name,
    required super.phone,
    required super.email,
    required super.location,
    required super.verifiedIdUrl,
    required this.qualification,
    this.isWorkingInNGO = false,
    this.ngoName,
    this.ngoPhone,
    this.employeeId,
    this.isAdminApproved = false,
    super.isApproved,
    super.createdAt,
    super.profileCompletion,
    super.verification,
  }) : super(role: UserRole.volunteer);

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'email': email,
      'location': location,
      'verifiedIdUrl': verifiedIdUrl,
      'role': 'volunteer',
      'isApproved': isApproved,
      'createdAt': createdAt.toIso8601String(),
      'profileCompletion': profileCompletion,
      'verification': verification.toMap(),
      'qualification': qualification,
      'isWorkingInNGO': isWorkingInNGO,
      'ngoName': ngoName,
      'ngoPhone': ngoPhone,
      'employeeId': employeeId,
      'isAdminApproved': isAdminApproved,
    };
  }

  factory VolunteerUser.fromMap(Map<String, dynamic> map) {
    DateTime? parsedCreatedAt;
    if (map['createdAt'] != null) {
      if (map['createdAt'] is Timestamp) {
        parsedCreatedAt = (map['createdAt'] as Timestamp).toDate();
      } else if (map['createdAt'] is String) {
        parsedCreatedAt = DateTime.tryParse(map['createdAt']);
      }
    }

    return VolunteerUser(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      phone: map['phone'] ?? '',
      email: map['email'] ?? '',
      location: map['location'] ?? '',
      verifiedIdUrl: map['verifiedIdUrl'] ?? '',
      qualification: map['qualification'] ?? '',
      isWorkingInNGO: map['isWorkingInNGO'] ?? false,
      ngoName: map['ngoName'],
      ngoPhone: map['ngoPhone'],
      employeeId: map['employeeId'],
      isAdminApproved: map['isAdminApproved'] ?? false,
      isApproved: map['isApproved'] ?? false,
      createdAt: parsedCreatedAt,
      profileCompletion: map['profileCompletion'] ?? 0,
      verification: VerificationStatus.fromMap(map['verification']),
    );
  }
}
