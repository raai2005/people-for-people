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
  final String donorName;
  final String itemName;
  final String quantity;
  final TransactionStatus status;
  final bool isDonorDelivering;
  final String? volunteerId;
  final String? volunteerName;
  final DateTime date;
  final List<VolunteerPreview> interestedVolunteers;

  Transaction({
    required this.id,
    required this.donorName,
    required this.itemName,
    required this.quantity,
    required this.status,
    required this.isDonorDelivering,
    this.volunteerId,
    this.volunteerName,
    required this.date,
    this.interestedVolunteers = const [],
  });

  // Mock data generator
  static List<Transaction> getMockTransactions() {
    return [
      Transaction(
        id: '1',
        donorName: 'John Doe',
        itemName: 'Winter Jackets',
        quantity: '50 Pcs',
        status: TransactionStatus.incoming,
        isDonorDelivering: false,
        date: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      Transaction(
        id: '2',
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
        donorName: 'Mike Johnson',
        itemName: 'School Books',
        quantity: '200 Sets',
        status: TransactionStatus.pendingDelivery,
        isDonorDelivering: true,
        date: DateTime.now().subtract(const Duration(hours: 5)),
      ),
      Transaction(
        id: '4',
        donorName: 'Emily Brown',
        itemName: 'Canned Food',
        quantity: '50 Cans',
        status: TransactionStatus.completed,
        isDonorDelivering: true,
        date: DateTime.now().subtract(const Duration(days: 3)),
      ),
      Transaction(
        id: '5',
        donorName: 'David Lee',
        itemName: 'Blankets',
        quantity: '30 Pcs',
        status: TransactionStatus.volunteerAssigned,
        isDonorDelivering: false,
        volunteerId: 'vol_1',
        volunteerName: 'Alex Volunteer',
        date: DateTime.now().subtract(const Duration(hours: 12)),
      ),
    ];
  }
}
