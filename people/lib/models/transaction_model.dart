enum TransactionStatus {
  incoming, // New donation
  pendingDelivery, // Donor will deliver
  needsVolunteer, // Needs volunteer pickup
  volunteerAssigned, // Volunteer accepted
  completed, // Donation delivered
}

class VolunteerPreview {
  final String id;
  final String name;
  final double rating;
  final String? profileImage;

  VolunteerPreview({
    required this.id,
    required this.name,
    required this.rating,
    this.profileImage,
  });
}

class Transaction {
  final String id;
  final String donorId;
  final String donorName;
  final String itemName;
  final String quantity;
  final TransactionStatus status;
  final bool isDonorDelivering;
  final String? volunteerId;
  final String? volunteerName;
  final String? verificationCode;
  final DateTime date;
  final List<VolunteerPreview> interestedVolunteers;

  Transaction({
    required this.id,
    required this.donorId,
    required this.donorName,
    required this.itemName,
    required this.quantity,
    required this.status,
    required this.isDonorDelivering,
    this.volunteerId,
    this.volunteerName,
    this.verificationCode,
    required this.date,
    this.interestedVolunteers = const [],
  });

  // Mock data generator
  static List<Transaction> getMockTransactions() {
    return [
      Transaction(
        id: '1',
        donorId: 'donor_001',
        donorName: 'John Doe',
        itemName: 'Winter Jackets',
        quantity: '50 Pcs',
        status: TransactionStatus.incoming,
        isDonorDelivering: false,
        date: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      Transaction(
        id: '2',
        donorId: 'donor_002',
        donorName: 'Sarah Smith',
        itemName: 'Rice Bags',
        quantity: '100 Kg',
        status: TransactionStatus.needsVolunteer,
        isDonorDelivering: false,
        date: DateTime.now().subtract(const Duration(days: 1)),
        interestedVolunteers: [
          VolunteerPreview(id: 'v1', name: 'Alex Johnson', rating: 4.8),
          VolunteerPreview(id: 'v2', name: 'Maria Garcia', rating: 4.9),
          VolunteerPreview(id: 'v3', name: 'Sam Wilson', rating: 4.5),
        ],
      ),
      Transaction(
        id: '3',
        donorId: 'donor_003',
        donorName: 'Mike Johnson',
        itemName: 'School Books',
        quantity: '200 Sets',
        status: TransactionStatus.pendingDelivery,
        isDonorDelivering: true,
        verificationCode: 'MJ-4827',
        date: DateTime.now().subtract(const Duration(hours: 5)),
      ),
      Transaction(
        id: '4',
        donorId: 'donor_004',
        donorName: 'Emily Brown',
        itemName: 'Canned Food',
        quantity: '50 Cans',
        status: TransactionStatus.completed,
        isDonorDelivering: true,
        verificationCode: 'EB-9351',
        date: DateTime.now().subtract(const Duration(days: 3)),
      ),
      Transaction(
        id: '5',
        donorId: 'donor_005',
        donorName: 'David Lee',
        itemName: 'Blankets',
        quantity: '30 Pcs',
        status: TransactionStatus.volunteerAssigned,
        isDonorDelivering: false,
        volunteerId: 'vol_1',
        volunteerName: 'Alex Volunteer',
        verificationCode: 'DL-7623',
        date: DateTime.now().subtract(const Duration(hours: 12)),
      ),
    ];
  }
}
