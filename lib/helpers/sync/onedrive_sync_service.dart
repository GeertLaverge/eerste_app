import 'dart:convert';

import 'package:http/http.dart' as http;

import 'onedrive_auth_service.dart';

class OneDriveSyncService {
  Future<String> uploadTestbestand() async {
    try {
      final token = await OneDriveAuthService().login();

      if (token.startsWith('FOUT') || token.startsWith('SILENT_FOUT')) {
        return token;
      }

      final naam = 'test_${DateTime.now().year}.json';

      final inhoud = jsonEncode({
        'test': true,
        'datum': DateTime.now().toIso8601String(),
      });

      final url =
          'https://graph.microsoft.com/v1.0/me/drive/special/approot:/$naam:/content';

      final response = await http.put(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: inhoud,
      );

      return '''
STATUS ${response.statusCode}

${response.body}
''';
    } catch (e) {
      return 'UPLOAD_FOUT: $e';
    }
  }
}
