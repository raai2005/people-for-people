import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class DonationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Create a new donation
  Future<String> createDonation({
    required String ngoId,
    required String ngoName,
    required String title,
    required String type,
    String? description,
    double? amount,
    int? quantity,
    String status = 'Pending',
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    final donationData = {
      'donorId': user.uid,
      'ngoId': ngoId,
      'ngoName': ngoName,
      'title': title,
      'type': type,
      'description': description,
      'status': status,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };

    // Add amount or quantity based on donation type
    if (amount != null) {
      donationData['amount'] = amount;
    }
    if (quantity != null) {
      donationData['quantity'] = quantity;
    }

    final docRef = await _firestore.collection('donations').add(donationData);
    return docRef.id;
  }

  // Fetch all donations for current user
  Future<List<Map<String, dynamic>>> getUserDonations() async {
    final user = _auth.currentUser;
    if (user == null) return [];

    final snapshot = await _firestore
        .collection('donations')
        .where('donorId', isEqualTo: user.uid)
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      return {
        'id': doc.id,
        'title': data['title'] ?? 'Donation',
        'type': data['type'] ?? 'Money',
        'ngo': data['ngoName'] ?? 'Unknown NGO',
        'amount': data['amount'] != null
            ? '₹${_formatAmount(data['amount'])}'
            : null,
        'quantity': data['quantity'],
        'date': _formatDate(data['createdAt']),
        'status': data['status'] ?? 'Pending',
        'description': data['description'],
        'ngoId': data['ngoId'],
        'donorId': data['donorId'],
      };
    }).toList();
  }

  // Get real-time stream of user donations
  Stream<List<Map<String, dynamic>>> getUserDonationsStream() {
    final user = _auth.currentUser;
    if (user == null) return Stream.value([]);

    return _firestore
        .collection('donations')
        .where('donorId', isEqualTo: user.uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            final data = doc.data();
            return {
              'id': doc.id,
              'title': data['title'] ?? 'Donation',
              'type': data['type'] ?? 'Money',
              'ngo': data['ngoName'] ?? 'Unknown NGO',
              'amount': data['amount'] != null
                  ? '₹${_formatAmount(data['amount'])}'
                  : null,
              'quantity': data['quantity'],
              'date': _formatDate(data['createdAt']),
              'status': data['status'] ?? 'Pending',
              'description': data['description'],
              'ngoId': data['ngoId'],
              'donorId': data['donorId'],
            };
          }).toList();
        });
  }

  // Update donation status
  Future<void> updateDonationStatus(String donationId, String status) async {
    await _firestore.collection('donations').doc(donationId).update({
      'status': status,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // Cancel donation (only if pending)
  Future<void> cancelDonation(String donationId) async {
    final doc = await _firestore.collection('donations').doc(donationId).get();
    if (doc.exists && doc.data()?['status'] == 'Pending') {
      await updateDonationStatus(donationId, 'Cancelled');
    } else {
      throw Exception('Cannot cancel this donation');
    }
  }

  // Get donation statistics
  Future<Map<String, dynamic>> getDonationStats() async {
    final user = _auth.currentUser;
    if (user == null) {
      return {
        'totalAmount': 0.0,
        'totalDonations': 0,
        'completedDonations': 0,
        'pendingDonations': 0,
      };
    }

    final snapshot = await _firestore
        .collection('donations')
        .where('donorId', isEqualTo: user.uid)
        .get();

    double totalAmount = 0;
    int totalDonations = snapshot.docs.length;
    int completedDonations = 0;
    int pendingDonations = 0;

    for (var doc in snapshot.docs) {
      final data = doc.data();

      // Sum up money donations
      if (data['amount'] != null) {
        totalAmount += (data['amount'] as num).toDouble();
      }

      // Count by status
      final status = data['status'] ?? 'Pending';
      if (status == 'Completed') {
        completedDonations++;
      } else if (status == 'Pending' || status == 'In Progress') {
        pendingDonations++;
      }
    }

    return {
      'totalAmount': totalAmount,
      'totalDonations': totalDonations,
      'completedDonations': completedDonations,
      'pendingDonations': pendingDonations,
    };
  }

  // Helper: Format amount with commas
  String _formatAmount(num amount) {
    final formatter = NumberFormat('#,##,###');
    return formatter.format(amount);
  }

  // Helper: Format timestamp to readable date
  String _formatDate(dynamic timestamp) {
    if (timestamp == null) return 'Unknown';

    try {
      DateTime date;
      if (timestamp is Timestamp) {
        date = timestamp.toDate();
      } else if (timestamp is DateTime) {
        date = timestamp;
      } else {
        return 'Unknown';
      }

      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inDays == 0) {
        return 'Today';
      } else if (difference.inDays == 1) {
        return 'Yesterday';
      } else if (difference.inDays < 7) {
        return '${difference.inDays} days ago';
      } else {
        return DateFormat('MMM dd, yyyy').format(date);
      }
    } catch (e) {
      return 'Unknown';
    }
  }
}
