import 'package:cloud_firestore/cloud_firestore.dart';

class DonationReceipt {
  final String receiptId;
  final String donationId;
  final DateTime issueDate;
  
  // Donor Information
  final String donorId;
  final String donorName;
  final String donorEmail;
  final String? donorPhone;
  final String? donorAddress;
  
  // NGO Information
  final String ngoId;
  final String ngoName;
  final String? ngoRegistrationNumber;
  final String? ngoAddress;
  final String? ngoEmail;
  final String? ngoPhone;
  
  // Donation Details
  final String donationType; // Money, Clothes, Food, etc.
  final String donationTitle;
  final double? amount;
  final int? quantity;
  final String? description;
  final DateTime donationDate;
  final String status; // Completed, Pending, etc.
  
  // Tax Information (for money donations)
  final bool isTaxExempt;
  final String? taxExemptionSection; // 80G, etc.
  final String? panNumber;
  
  // Receipt Metadata
  final String financialYear;
  final String receiptNumber; // Formatted: RCP/2024/001234

  DonationReceipt({
    required this.receiptId,
    required this.donationId,
    required this.issueDate,
    required this.donorId,
    required this.donorName,
    required this.donorEmail,
    this.donorPhone,
    this.donorAddress,
    required this.ngoId,
    required this.ngoName,
    this.ngoRegistrationNumber,
    this.ngoAddress,
    this.ngoEmail,
    this.ngoPhone,
    required this.donationType,
    required this.donationTitle,
    this.amount,
    this.quantity,
    this.description,
    required this.donationDate,
    required this.status,
    this.isTaxExempt = false,
    this.taxExemptionSection,
    this.panNumber,
    required this.financialYear,
    required this.receiptNumber,
  });

  // Generate receipt number
  static String generateReceiptNumber(DateTime date, int sequenceNumber) {
    final year = date.year;
    final paddedSequence = sequenceNumber.toString().padLeft(6, '0');
    return 'RCP/$year/$paddedSequence';
  }

  // Calculate financial year (Apr-Mar)
  static String getFinancialYear(DateTime date) {
    final year = date.year;
    final month = date.month;
    if (month >= 4) {
      return '$year-${year + 1}';
    } else {
      return '${year - 1}-$year';
    }
  }

  // Format amount for display
  String get formattedAmount {
    if (amount == null) return 'N/A';
    return '₹${amount!.toStringAsFixed(2)}';
  }

  // Format quantity for display
  String get formattedQuantity {
    if (quantity == null) return 'N/A';
    return '$quantity items';
  }

  // Get donation value description
  String get donationValue {
    if (amount != null) return formattedAmount;
    if (quantity != null) return formattedQuantity;
    return 'N/A';
  }

  // Convert to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'receiptId': receiptId,
      'donationId': donationId,
      'issueDate': Timestamp.fromDate(issueDate),
      'donorId': donorId,
      'donorName': donorName,
      'donorEmail': donorEmail,
      'donorPhone': donorPhone,
      'donorAddress': donorAddress,
      'ngoId': ngoId,
      'ngoName': ngoName,
      'ngoRegistrationNumber': ngoRegistrationNumber,
      'ngoAddress': ngoAddress,
      'ngoEmail': ngoEmail,
      'ngoPhone': ngoPhone,
      'donationType': donationType,
      'donationTitle': donationTitle,
      'amount': amount,
      'quantity': quantity,
      'description': description,
      'donationDate': Timestamp.fromDate(donationDate),
      'status': status,
      'isTaxExempt': isTaxExempt,
      'taxExemptionSection': taxExemptionSection,
      'panNumber': panNumber,
      'financialYear': financialYear,
      'receiptNumber': receiptNumber,
    };
  }

  // Create from Firestore Map
  factory DonationReceipt.fromMap(Map<String, dynamic> map) {
    return DonationReceipt(
      receiptId: map['receiptId'] ?? '',
      donationId: map['donationId'] ?? '',
      issueDate: (map['issueDate'] as Timestamp).toDate(),
      donorId: map['donorId'] ?? '',
      donorName: map['donorName'] ?? '',
      donorEmail: map['donorEmail'] ?? '',
      donorPhone: map['donorPhone'],
      donorAddress: map['donorAddress'],
      ngoId: map['ngoId'] ?? '',
      ngoName: map['ngoName'] ?? '',
      ngoRegistrationNumber: map['ngoRegistrationNumber'],
      ngoAddress: map['ngoAddress'],
      ngoEmail: map['ngoEmail'],
      ngoPhone: map['ngoPhone'],
      donationType: map['donationType'] ?? '',
      donationTitle: map['donationTitle'] ?? '',
      amount: map['amount']?.toDouble(),
      quantity: map['quantity'],
      description: map['description'],
      donationDate: (map['donationDate'] as Timestamp).toDate(),
      status: map['status'] ?? '',
      isTaxExempt: map['isTaxExempt'] ?? false,
      taxExemptionSection: map['taxExemptionSection'],
      panNumber: map['panNumber'],
      financialYear: map['financialYear'] ?? '',
      receiptNumber: map['receiptNumber'] ?? '',
    );
  }

  // Create receipt from donation data
  factory DonationReceipt.fromDonation({
    required String donationId,
    required Map<String, dynamic> donationData,
    required Map<String, dynamic> donorData,
    required Map<String, dynamic> ngoData,
    required int sequenceNumber,
  }) {
    final now = DateTime.now();
    final donationDate = (donationData['createdAt'] as Timestamp?)?.toDate() ?? now;
    
    return DonationReceipt(
      receiptId: '', // Will be set by Firestore
      donationId: donationId,
      issueDate: now,
      donorId: donationData['donorId'] ?? '',
      donorName: donorData['name'] ?? donorData['fullName'] ?? 'Unknown Donor',
      donorEmail: donorData['email'] ?? '',
      donorPhone: donorData['phone'],
      donorAddress: donorData['address'],
      ngoId: donationData['ngoId'] ?? '',
      ngoName: donationData['ngoName'] ?? 'Unknown NGO',
      ngoRegistrationNumber: ngoData['registrationNumber'],
      ngoAddress: ngoData['address'],
      ngoEmail: ngoData['email'],
      ngoPhone: ngoData['phone'],
      donationType: donationData['type'] ?? 'Money',
      donationTitle: donationData['title'] ?? 'Donation',
      amount: donationData['amount']?.toDouble(),
      quantity: donationData['quantity'],
      description: donationData['description'],
      donationDate: donationDate,
      status: donationData['status'] ?? 'Completed',
      isTaxExempt: ngoData['isTaxExempt'] ?? false,
      taxExemptionSection: ngoData['taxExemptionSection'],
      panNumber: donorData['panNumber'],
      financialYear: getFinancialYear(donationDate),
      receiptNumber: generateReceiptNumber(now, sequenceNumber),
    );
  }

  // Copy with method
  DonationReceipt copyWith({
    String? receiptId,
    String? donationId,
    DateTime? issueDate,
    String? donorId,
    String? donorName,
    String? donorEmail,
    String? donorPhone,
    String? donorAddress,
    String? ngoId,
    String? ngoName,
    String? ngoRegistrationNumber,
    String? ngoAddress,
    String? ngoEmail,
    String? ngoPhone,
    String? donationType,
    String? donationTitle,
    double? amount,
    int? quantity,
    String? description,
    DateTime? donationDate,
    String? status,
    bool? isTaxExempt,
    String? taxExemptionSection,
    String? panNumber,
    String? financialYear,
    String? receiptNumber,
  }) {
    return DonationReceipt(
      receiptId: receiptId ?? this.receiptId,
      donationId: donationId ?? this.donationId,
      issueDate: issueDate ?? this.issueDate,
      donorId: donorId ?? this.donorId,
      donorName: donorName ?? this.donorName,
      donorEmail: donorEmail ?? this.donorEmail,
      donorPhone: donorPhone ?? this.donorPhone,
      donorAddress: donorAddress ?? this.donorAddress,
      ngoId: ngoId ?? this.ngoId,
      ngoName: ngoName ?? this.ngoName,
      ngoRegistrationNumber: ngoRegistrationNumber ?? this.ngoRegistrationNumber,
      ngoAddress: ngoAddress ?? this.ngoAddress,
      ngoEmail: ngoEmail ?? this.ngoEmail,
      ngoPhone: ngoPhone ?? this.ngoPhone,
      donationType: donationType ?? this.donationType,
      donationTitle: donationTitle ?? this.donationTitle,
      amount: amount ?? this.amount,
      quantity: quantity ?? this.quantity,
      description: description ?? this.description,
      donationDate: donationDate ?? this.donationDate,
      status: status ?? this.status,
      isTaxExempt: isTaxExempt ?? this.isTaxExempt,
      taxExemptionSection: taxExemptionSection ?? this.taxExemptionSection,
      panNumber: panNumber ?? this.panNumber,
      financialYear: financialYear ?? this.financialYear,
      receiptNumber: receiptNumber ?? this.receiptNumber,
    );
  }
}
