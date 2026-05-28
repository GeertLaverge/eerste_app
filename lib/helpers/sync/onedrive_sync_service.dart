import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../app_storage.dart';
import 'onedrive_auth_service.dart';

class OneDriveSyncService {
  Future<String> uploadBackup() async {
    try {
      final token = await OneDriveAuthService().login();

      if (token.startsWith('FOUT')) {
        return token;
      }

      final prefs = await SharedPreferences.getInstance();

      final backup = {
        'backupDatum': DateTime.now().toIso8601String(),
        'klanten': prefs.getString('klanten'),
        'leveranciers': prefs.getString('leveranciers'),
        'vakantieDagen': prefs.getString('vakantieDagen'),
        'agendaActies': prefs.getString('agendaActies'),
        'agendaActieTemplates': prefs.getString('agendaActieTemplates'),
        'notities': prefs.getString('notities_bureau'),
        'notitieActies': prefs.getString('notitie_acties_bureau'),
        'afspraken': prefs.getStringList('afspraken_klanten'),
        'agendaItems': prefs.getString('agenda_items_nieuw'),
        'dagtaakTemplates': prefs.getString('dagtaak_templates'),
      };

      final inhoud = jsonEncode(backup);

      final url =
          'https://graph.microsoft.com/v1.0/me/drive/special/approot:/thimaco_backup.json:/content';

      final response = await http.put(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: inhoud,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return 'BACKUP_OK';
      }

      return 'BACKUP_FOUT ${response.statusCode}\n${response.body}';
    } catch (e) {
      return 'BACKUP_EXCEPTION: $e';
    }
  }
}
