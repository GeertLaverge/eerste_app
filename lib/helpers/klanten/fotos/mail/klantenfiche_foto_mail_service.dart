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

      final gebruikerResponse = await http.get(
        Uri.parse(
          'https://graph.microsoft.com/v1.0/me',
        ),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      return '''
STATUS: ${gebruikerResponse.statusCode}

${gebruikerResponse.body}
''';
    } catch (e) {
      return 'MAIL_EXCEPTION: $e';
    }
  }
}
