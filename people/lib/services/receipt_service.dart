import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';
import '../models/donation_receipt.dart';

class ReceiptService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Generate and save receipt
  Future<DonationReceipt> generateReceipt(String donationId) async {
    try {
      // Fetch donation data
      final donationDoc = await _firestore.collection('donations').doc(donationId).get();
      if (!donationDoc.exists) {
        throw Exception('Donation not found');
      }
      final donationData = donationDoc.data()!;

      // Fetch donor data
      final donorId = donationData['donorId'];
      final donorDoc = await _firestore.collection('users').doc(donorId).get();
      final donorData = donorDoc.data() ?? {};

      // Fetch NGO data
      final ngoId = donationData['ngoId'];
      final ngoDoc = await _firestore.collection('users').doc(ngoId).get();
      final ngoData = ngoDoc.data() ?? {};

      // Get next sequence number
      final sequenceNumber = await _getNextSequenceNumber();

      // Create receipt
      final receipt = DonationReceipt.fromDonation(
        donationId: donationId,
        donationData: donationData,
        donorData: donorData,
        ngoData: ngoData,
        sequenceNumber: sequenceNumber,
      );

      // Save receipt to Firestore
      final receiptRef = await _firestore.collection('receipts').add(receipt.toMap());
      final savedReceipt = receipt.copyWith(receiptId: receiptRef.id);
      await receiptRef.update({'receiptId': receiptRef.id});

      return savedReceipt;
    } catch (e) {
      throw Exception('Failed to generate receipt: $e');
    }
  }

  // Get next sequence number for receipt
  Future<int> _getNextSequenceNumber() async {
    final counterDoc = _firestore.collection('counters').doc('receipt_sequence');
    
    return await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(counterDoc);
      
      int newSequence = 1;
      if (snapshot.exists) {
        newSequence = (snapshot.data()?['value'] ?? 0) + 1;
      }
      
      transaction.set(counterDoc, {'value': newSequence}, SetOptions(merge: true));
      return newSequence;
    });
  }

  // Generate PDF from receipt
  Future<File> generatePDF(DonationReceipt receipt) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header
              _buildHeader(receipt),
              pw.SizedBox(height: 30),
              
              // Receipt Info
              _buildReceiptInfo(receipt),
              pw.SizedBox(height: 20),
              
              // Donor Info
              _buildSection('Donor Information', [
                _buildInfoRow('Name', receipt.donorName),
                _buildInfoRow('Email', receipt.donorEmail),
                if (receipt.donorPhone != null)
                  _buildInfoRow('Phone', receipt.donorPhone!),
                if (receipt.donorAddress != null)
                  _buildInfoRow('Address', receipt.donorAddress!),
              ]),
              pw.SizedBox(height: 20),
              
              // NGO Info
              _buildSection('Organization Information', [
                _buildInfoRow('Name', receipt.ngoName),
                if (receipt.ngoRegistrationNumber != null)
                  _buildInfoRow('Registration No.', receipt.ngoRegistrationNumber!),
                if (receipt.ngoEmail != null)
                  _buildInfoRow('Email', receipt.ngoEmail!),
                if (receipt.ngoPhone != null)
                  _buildInfoRow('Phone', receipt.ngoPhone!),
                if (receipt.ngoAddress != null)
                  _buildInfoRow('Address', receipt.ngoAddress!),
              ]),
              pw.SizedBox(height: 20),
              
              // Donation Details
              _buildSection('Donation Details', [
                _buildInfoRow('Type', receipt.donationType),
                _buildInfoRow('Title', receipt.donationTitle),
                _buildInfoRow('Value', receipt.donationValue),
                _buildInfoRow('Date', DateFormat('dd MMM yyyy').format(receipt.donationDate)),
                _buildInfoRow('Status', receipt.status),
                if (receipt.description != null)
                  _buildInfoRow('Description', receipt.description!),
              ]),
              pw.SizedBox(height: 20),
              
              // Tax Information (if applicable)
              if (receipt.isTaxExempt && receipt.amount != null) ...[
                _buildSection('Tax Information', [
                  _buildInfoRow('Tax Exemption', 'Yes'),
                  if (receipt.taxExemptionSection != null)
                    _buildInfoRow('Section', receipt.taxExemptionSection!),
                  _buildInfoRow('Financial Year', receipt.financialYear),
                ]),
                pw.SizedBox(height: 20),
              ],
              
              pw.Spacer(),
              
              // Footer
              _buildFooter(receipt),
            ],
          );
        },
      ),
    );

    // Save PDF to device
    final output = await getTemporaryDirectory();
    final file = File('${output.path}/receipt_${receipt.receiptNumber.replaceAll('/', '_')}.pdf');
    await file.writeAsBytes(await pdf.save());
    
    return file;
  }

  // Build PDF Header
  pw.Widget _buildHeader(DonationReceipt receipt) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(20),
      decoration: pw.BoxDecoration(
        color: PdfColors.blue50,
        borderRadius: pw.BorderRadius.circular(10),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'DONATION RECEIPT',
            style: pw.TextStyle(
              fontSize: 28,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.blue900,
            ),
          ),
          pw.SizedBox(height: 8),
          pw.Text(
            'People for People',
            style: pw.TextStyle(
              fontSize: 16,
              color: PdfColors.blue700,
            ),
          ),
        ],
      ),
    );
  }

  // Build Receipt Info
  pw.Widget _buildReceiptInfo(DonationReceipt receipt) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(15),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'Receipt Number',
                style: pw.TextStyle(
                  fontSize: 10,
                  color: PdfColors.grey600,
                ),
              ),
              pw.SizedBox(height: 4),
              pw.Text(
                receipt.receiptNumber,
                style: pw.TextStyle(
                  fontSize: 14,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ],
          ),
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Text(
                'Issue Date',
                style: pw.TextStyle(
                  fontSize: 10,
                  color: PdfColors.grey600,
                ),
              ),
              pw.SizedBox(height: 4),
              pw.Text(
                DateFormat('dd MMM yyyy').format(receipt.issueDate),
                style: pw.TextStyle(
                  fontSize: 14,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Build Section
  pw.Widget _buildSection(String title, List<pw.Widget> children) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Container(
          padding: const pw.EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          decoration: pw.BoxDecoration(
            color: PdfColors.grey200,
            borderRadius: pw.BorderRadius.circular(6),
          ),
          child: pw.Text(
            title,
            style: pw.TextStyle(
              fontSize: 14,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.grey800,
            ),
          ),
        ),
        pw.SizedBox(height: 10),
        pw.Container(
          padding: const pw.EdgeInsets.all(12),
          decoration: pw.BoxDecoration(
            border: pw.Border.all(color: PdfColors.grey300),
            borderRadius: pw.BorderRadius.circular(6),
          ),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: children,
          ),
        ),
      ],
    );
  }

  // Build Info Row
  pw.Widget _buildInfoRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 4),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(
            width: 150,
            child: pw.Text(
              '$label:',
              style: pw.TextStyle(
                fontSize: 11,
                color: PdfColors.grey700,
              ),
            ),
          ),
          pw.Expanded(
            child: pw.Text(
              value,
              style: pw.TextStyle(
                fontSize: 11,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Build Footer
  pw.Widget _buildFooter(DonationReceipt receipt) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(15),
      decoration: pw.BoxDecoration(
        border: pw.Border(
          top: pw.BorderSide(color: PdfColors.grey300, width: 2),
        ),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Thank you for your generous contribution!',
            style: pw.TextStyle(
              fontSize: 12,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.blue700,
            ),
          ),
          pw.SizedBox(height: 8),
          pw.Text(
            'This is a computer-generated receipt and does not require a signature.',
            style: const pw.TextStyle(
              fontSize: 9,
              color: PdfColors.grey600,
            ),
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            'For any queries, please contact the organization directly.',
            style: const pw.TextStyle(
              fontSize: 9,
              color: PdfColors.grey600,
            ),
          ),
        ],
      ),
    );
  }

  // Get receipt by donation ID
  Future<DonationReceipt?> getReceiptByDonationId(String donationId) async {
    try {
      final snapshot = await _firestore
          .collection('receipts')
          .where('donationId', isEqualTo: donationId)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) return null;

      return DonationReceipt.fromMap(snapshot.docs.first.data());
    } catch (e) {
      return null;
    }
  }

  // Get all receipts for current user
  Future<List<DonationReceipt>> getUserReceipts() async {
    final user = _auth.currentUser;
    if (user == null) return [];

    try {
      final snapshot = await _firestore
          .collection('receipts')
          .where('donorId', isEqualTo: user.uid)
          .orderBy('issueDate', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => DonationReceipt.fromMap(doc.data()))
          .toList();
    } catch (e) {
      return [];
    }
  }
}
