import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class EmailService {
  static const String _apiUrl = 'https://api.emailjs.com/api/v1.0/email/send';

  // EmailJS credentials - Add these to .env file

  static final String _serviceId = dotenv.env['EMAILJS_SERVICE_ID'] ?? '';
  static final String _templateId = dotenv.env['EMAILJS_TEMPLATE_ID'] ?? '';
  static final String _publicKey = dotenv.env['EMAILJS_PUBLIC_KEY'] ?? '';

  static Future<void> sendApprovalEmail({
    required String toEmail,
    required String userName,
    required String role,
  }) async {
    final emailData = {
      'service_id': _serviceId,
      'template_id': _templateId,
      'user_id': _publicKey,
      'template_params': {
        'to_email': toEmail,
        'to_name': userName,
        'subject': 'Account Approved - People for People',
        'message': _getApprovalMessage(userName, role),
      },
    };

    try {
      await http.post(
        Uri.parse(_apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(emailData),
      );
    } catch (e) {
      print('Error sending approval email: $e');
    }
  }

  static Future<void> sendRejectionEmail({
    required String toEmail,
    required String userName,
    required String role,
    required String reason,
  }) async {
    final emailData = {
      'service_id': _serviceId,
      'template_id': _templateId,
      'user_id': _publicKey,
      'template_params': {
        'to_email': toEmail,
        'to_name': userName,
        'subject': 'Account Application Update - People for People',
        'message': _getRejectionMessage(userName, role, reason),
      },
    };

    try {
      await http.post(
        Uri.parse(_apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(emailData),
      );
    } catch (e) {
      print('Error sending rejection email: $e');
    }
  }

  static Future<void> sendDocumentVerificationEmail({
    required String toEmail,
    required String userName,
    required Map<String, bool> documentStatus,
  }) async {
    final emailData = {
      'service_id': _serviceId,
      'template_id': _templateId,
      'user_id': _publicKey,
      'template_params': {
        'to_email': toEmail,
        'to_name': userName,
        'subject': 'Document Verification Update - People for People',
        'message': _getDocumentVerificationMessage(userName, documentStatus),
      },
    };

    try {
      await http.post(
        Uri.parse(_apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(emailData),
      );
    } catch (e) {
      print('Error sending document verification email: $e');
    }
  }

  static String _getApprovalMessage(String userName, String role) {
    return '''
Dear $userName,

Congratulations! Your ${role.toUpperCase()} account has been approved by our admin team.

You can now access all features of the People for People platform. Log in to your account to get started.

Thank you for joining our community and helping us make a difference!

Best regards,
People for People Team
''';
  }

  static String _getRejectionMessage(
    String userName,
    String role,
    String reason,
  ) {
    return '''
Dear $userName,

Thank you for your interest in joining People for People as a ${role.toUpperCase()}.

Unfortunately, we are unable to approve your account at this time.

Reason: $reason

If you believe this is an error or would like to reapply with corrected information, please contact our support team.

Best regards,
People for People Team
''';
  }

  static String _getDocumentVerificationMessage(
    String userName,
    Map<String, bool> documentStatus,
  ) {
    final verified = <String>[];
    final rejected = <String>[];

    documentStatus.forEach((doc, isVerified) {
      if (isVerified) {
        verified.add(doc);
      } else {
        rejected.add(doc);
      }
    });

    String message = 'Dear $userName,\n\n';
    message += 'We have reviewed your submitted documents:\n\n';

    if (verified.isNotEmpty) {
      message += '✅ VERIFIED DOCUMENTS:\n';
      for (var doc in verified) {
        message += '  • $doc\n';
      }
      message += '\n';
    }

    if (rejected.isNotEmpty) {
      message += '❌ DOCUMENTS REQUIRING ATTENTION:\n';
      for (var doc in rejected) {
        message += '  • $doc\n';
      }
      message +=
          '\nPlease re-upload the rejected documents with correct information.\n\n';
    }

    message += 'Best regards,\nPeople for People Team';
    return message;
  }
}
