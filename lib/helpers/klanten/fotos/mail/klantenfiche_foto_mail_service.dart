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
      final gebruikerResponse = await http.get(
        Uri.parse('https://graph.microsoft.com/v1.0/me'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      print('GEBRUIKER: ${gebruikerResponse.body}');

      if (token.startsWith('FOUT')) {
        return token;
      }
      print('ONTVANGER: $ontvanger');
      print('AANTAL FOTO\'S: ${fotos.length}');

      final attachments = <Map<String, dynamic>>[];

      for (final foto in fotos) {
        final bytes = await foto.readAsBytes();

        attachments.add({
          '@odata.type': '#microsoft.graph.fileAttachment',
          'name': foto.uri.pathSegments.last,
          'contentType': 'image/jpeg',
          'contentBytes': base64Encode(bytes),
        });
      }

      final body = {
        'message': {
          'subject': onderwerp,
          'body': {
            'contentType': 'Text',
            'content': bericht,
          },
          'toRecipients': [
            {
              'emailAddress': {
                'address': ontvanger,
              },
            },
          ],
          'attachments': attachments,
        },
        'saveToSentItems': true,
      };

      final response = await http.post(
        Uri.parse(
          'https://graph.microsoft.com/v1.0/me/sendMail',
        ),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(body),
      );

      return 'STATUS ${response.statusCode}\n${response.body}';
    } catch (e) {
      return 'MAIL_EXCEPTION: $e';
    }
  }
}
