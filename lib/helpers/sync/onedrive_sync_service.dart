import 'dart:convert';
import 'package:http/http.dart' as http;

import 'onedrive_auth_service.dart';

class OneDriveSyncService {
  Future<bool> uploadTestbestand() async {
    try {
      final token = await OneDriveAuthService().login();

      if (token == null) {
        return false;
      }

      final naam = 'test_${DateTime.now().year}.json';

      final inhoud = jsonEncode({
        'test': true,
        'datum': DateTime.now().toIso8601String(),
      });

      final url =
          'https://graph.microsoft.com/v1.0/me/drive/root:/ThimacoApp/$naam:/content';

      final response = await http.put(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: inhoud,
      );

      return response.statusCode == 201 || response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }
}
