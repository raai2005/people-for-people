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

// NGO Profile Model
class NGOProfile {
  final String organizationName;
  final String address;
  final String bio;
  final String planOfAction;
  final String profileImage;
  final List<String> certifications;
  final int projectsCompleted;
  final double rating;

  NGOProfile({
    this.organizationName = "",
    this.address = "",
    this.bio = "",
    this.planOfAction = "",
    this.profileImage = "",
    this.certifications = const [],
    this.projectsCompleted = 0,
    this.rating = 0.0,
  });

  Map<String, dynamic> toMap() {
    return {
      'organizationName': organizationName,
      'address': address,
      'bio': bio,
      'planOfAction': planOfAction,
      'profileImage': profileImage,
      'certifications': certifications,
      'projectsCompleted': projectsCompleted,
      'rating': rating,
    };
  }

  factory NGOProfile.fromMap(Map<String, dynamic>? map) {
    if (map == null) {
      return NGOProfile();
    }
    return NGOProfile(
      organizationName: map['organizationName'] ?? "",
      address: map['address'] ?? "",
      bio: map['bio'] ?? "",
      planOfAction: map['planOfAction'] ?? "",
      profileImage: map['profileImage'] ?? "",
      certifications: List<String>.from(map['certifications'] ?? []),
      projectsCompleted: map['projectsCompleted'] ?? 0,
      rating: (map['rating'] ?? 0.0).toDouble(),
    );
  }
}

// NGO/Organisation Model
class NGOUser extends BaseUser {
  final String organizationName;
  final String organizationPhone;
  final String organizationEmail;
  final String address;
  final String govtVerifiedDocUrl;
  final String headOfOrgName;
  final String headOfOrgEmail;
  final String headOfOrgPhone;
  final String? headOfOrgId; // Optional: No longer collected via text field
  final String headOfOrgIdUrl;
  final String?
  headOfOrgEmployeeId; // Optional: No longer collected via text field
  final String? bio;
  final String? profileImageUrl;
  final NGOProfile ngoProfile;

  NGOUser({
    required super.id,
    required super.name,
    required super.phone,
    required super.email,
    required super.location,
    required super.verifiedIdUrl,
    required this.organizationName,
    required this.organizationPhone,
    required this.organizationEmail,
    required this.address,
    required this.govtVerifiedDocUrl,
    required this.headOfOrgName,
    required this.headOfOrgEmail,
    required this.headOfOrgPhone,
    this.headOfOrgId,
    required this.headOfOrgIdUrl,
    this.headOfOrgEmployeeId,
    this.bio,
    this.profileImageUrl,
    super.isApproved,
    super.createdAt,
    super.profileCompletion,
    super.verification,
    NGOProfile? ngoProfile,
  }) : ngoProfile = ngoProfile ?? NGOProfile(),
       super(role: UserRole.ngo);

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
      'organizationPhone': organizationPhone,
      'organizationEmail': organizationEmail,
      'address': address,
      'govtVerifiedDocUrl': govtVerifiedDocUrl,
      'headOfOrgName': headOfOrgName,
      'headOfOrgEmail': headOfOrgEmail,
      'headOfOrgPhone': headOfOrgPhone,
      'headOfOrgId': headOfOrgId,
      'headOfOrgIdUrl': headOfOrgIdUrl,
      'headOfOrgEmployeeId': headOfOrgEmployeeId,
      'bio': bio,
      'profileImageUrl': profileImageUrl,
      'ngoProfile': ngoProfile.toMap(),
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
      organizationPhone: map['organizationPhone'] ?? '',
      organizationEmail: map['organizationEmail'] ?? '',
      address: map['address'] ?? '',
      govtVerifiedDocUrl: map['govtVerifiedDocUrl'] ?? '',
      headOfOrgName: map['headOfOrgName'] ?? '',
      headOfOrgEmail: map['headOfOrgEmail'] ?? '',
      headOfOrgPhone: map['headOfOrgPhone'] ?? '',
      headOfOrgId: map['headOfOrgId'] ?? '',
      headOfOrgIdUrl: map['headOfOrgIdUrl'] ?? '',
      headOfOrgEmployeeId: map['headOfOrgEmployeeId'] ?? '',
      bio: map['bio'],
      profileImageUrl: map['profileImageUrl'],
      isApproved: map['isApproved'] ?? false,
      createdAt: parsedCreatedAt,
      profileCompletion: map['profileCompletion'] ?? 0,
      verification: VerificationStatus.fromMap(map['verification']),
      ngoProfile: NGOProfile.fromMap(map['ngoProfile']),
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

// Volunteer Profile Model
class VolunteerProfile {
  final String bio;
  final String qualification;
  final String profileImage;
  final List<String> skills;
  final int hoursVolunteered;
  final double rating;

  VolunteerProfile({
    this.bio = "",
    this.qualification = "",
    this.profileImage = "",
    this.skills = const [],
    this.hoursVolunteered = 0,
    this.rating = 0.0,
  });

  Map<String, dynamic> toMap() {
    return {
      'bio': bio,
      'qualification': qualification,
      'profileImage': profileImage,
      'skills': skills,
      'hoursVolunteered': hoursVolunteered,
      'rating': rating,
    };
  }

  factory VolunteerProfile.fromMap(Map<String, dynamic>? map) {
    if (map == null) {
      return VolunteerProfile();
    }
    return VolunteerProfile(
      bio: map['bio'] ?? "",
      qualification: map['qualification'] ?? "",
      profileImage: map['profileImage'] ?? "",
      skills: List<String>.from(map['skills'] ?? []),
      hoursVolunteered: map['hoursVolunteered'] ?? 0,
      rating: (map['rating'] ?? 0.0).toDouble(),
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
  final String? bio;
  final String? profileImageUrl;
  final VolunteerProfile volunteerProfile;

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
    this.bio,
    this.profileImageUrl,
    super.isApproved,
    super.createdAt,
    super.profileCompletion,
    super.verification,
    VolunteerProfile? volunteerProfile,
  }) : volunteerProfile = volunteerProfile ?? VolunteerProfile(),
       super(role: UserRole.volunteer);

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
      'bio': bio,
      'profileImageUrl': profileImageUrl,
      'volunteerProfile': volunteerProfile.toMap(),
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
      bio: map['bio'],
      profileImageUrl: map['profileImageUrl'],
      isApproved: map['isApproved'] ?? false,
      createdAt: parsedCreatedAt,
      profileCompletion: map['profileCompletion'] ?? 0,
      verification: VerificationStatus.fromMap(map['verification']),
      volunteerProfile: VolunteerProfile.fromMap(map['volunteerProfile']),
    );
  }
}
