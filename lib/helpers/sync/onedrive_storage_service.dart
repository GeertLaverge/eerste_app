import 'dart:convert';

import 'package:http/http.dart' as http;

class OneDriveStorageService {
  Future<bool> uploadTestbestand(String accessToken) async {
    try {
      final url =
          'https://graph.microsoft.com/v1.0/me/drive/special/approot:/thimaco_test.json:/content';

      final inhoud = jsonEncode({
        'status': 'werkt',
        'datum': DateTime.now().toIso8601String(),
      });

      final response = await http.put(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
        body: inhoud,
      );

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (_) {
      return false;
    }
  }
}
