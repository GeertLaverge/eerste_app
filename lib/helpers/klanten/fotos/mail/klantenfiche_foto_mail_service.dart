import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../../../sync/onedrive_auth_service.dart';

class KlantenficheFotoMailService {
  Future<String> verstuurMail({
    required List<File> fotos,
    required String ontvanger,
    required String onderwerp,
    required String bericht,
  }) async {
    try {
      final token = await OneDriveAuthService().login();

      if (token.startsWith('FOUT')) {
        return token;
      }

      final conceptBody = {
        'subject': 'TEST CONCEPT SEND THIMACO',
        'body': {
          'contentType': 'Text',
          'content': 'Dit concept wordt aangemaakt en daarna verzonden.',
        },
        'toRecipients': [
          {
            'emailAddress': {
              'address': ontvanger,
            },
          },
        ],
      };

      final conceptResponse = await http.post(
        Uri.parse(
          'https://graph.microsoft.com/v1.0/me/messages',
        ),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(conceptBody),
      );

      if (conceptResponse.statusCode != 201) {
        return '''
CONCEPT FOUT: ${conceptResponse.statusCode}

${conceptResponse.body}
''';
      }

      final conceptData =
          jsonDecode(conceptResponse.body) as Map<String, dynamic>;

      final messageId = conceptData['id'];

      if (messageId is! String || messageId.isEmpty) {
        return 'CONCEPT FOUT: geen message id gevonden';
      }

      final sendResponse = await http.post(
        Uri.parse(
          'https://graph.microsoft.com/v1.0/me/messages/$messageId/send',
        ),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      return '''
CONCEPT STATUS: ${conceptResponse.statusCode}
MESSAGE ID: $messageId

SEND STATUS: ${sendResponse.statusCode}

${sendResponse.body}
''';
    } catch (e) {
      return 'MAIL_EXCEPTION: $e';
    }
  }
}
