// User Role Enum
enum UserRole { ngo, donor, volunteer }

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
  }) : createdAt = createdAt ?? DateTime.now();
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
      'organizationName': organizationName,
      'address': address,
      'govtVerifiedDocUrl': govtVerifiedDocUrl,
      'headOfOrgId': headOfOrgId,
      'headOfOrgIdUrl': headOfOrgIdUrl,
    };
  }

  factory NGOUser.fromMap(Map<String, dynamic> map) {
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
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'])
          : null,
    );
  }
}

// Donor Model
class DonorUser extends BaseUser {
  final String qualification;

  DonorUser({
    required super.id,
    required super.name,
    required super.phone,
    required super.email,
    required super.location,
    required super.verifiedIdUrl,
    required this.qualification,
    super.isApproved,
    super.createdAt,
  }) : super(role: UserRole.donor);

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
      'qualification': qualification,
    };
  }

  factory DonorUser.fromMap(Map<String, dynamic> map) {
    return DonorUser(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      phone: map['phone'] ?? '',
      email: map['email'] ?? '',
      location: map['location'] ?? '',
      verifiedIdUrl: map['verifiedIdUrl'] ?? '',
      qualification: map['qualification'] ?? '',
      isApproved: map['isApproved'] ?? false,
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'])
          : null,
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
      'qualification': qualification,
      'isWorkingInNGO': isWorkingInNGO,
      'ngoName': ngoName,
      'ngoPhone': ngoPhone,
      'employeeId': employeeId,
      'isAdminApproved': isAdminApproved,
    };
  }

  factory VolunteerUser.fromMap(Map<String, dynamic> map) {
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
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'])
          : null,
    );
  }
}
