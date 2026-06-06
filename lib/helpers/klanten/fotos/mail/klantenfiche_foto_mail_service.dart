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

      final body = {
        'subject': 'TEST CONCEPT THIMACO',
        'body': {
          'contentType': 'Text',
          'content': 'Dit is een testconcept vanuit de Thimaco app.',
        },
        'toRecipients': [
          {
            'emailAddress': {
              'address': ontvanger,
            },
          },
        ],
      };

      final response = await http.post(
        Uri.parse(
          'https://graph.microsoft.com/v1.0/me/messages',
        ),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(body),
      );

      return '''
CONCEPT STATUS: ${response.statusCode}

${response.body}
''';
    } catch (e) {
      return 'MAIL_EXCEPTION: $e';
    }
  }
}
