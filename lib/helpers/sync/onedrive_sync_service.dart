import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'onedrive_auth_service.dart';

class OneDriveSyncService {
  static bool _backupBezig = false;
  static bool _backupOpnieuwNodig = false;

  Future<String> uploadBackup() async {
    try {
      final token = await OneDriveAuthService().login();

      if (token.startsWith('FOUT')) {
        return token;
      }

      final prefs = await SharedPreferences.getInstance();

      final backup = {
        'backupDatum': DateTime.now().toIso8601String(),
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

  Future<void> uploadBackupOpAchtergrond() async {
    if (_backupBezig) {
      _backupOpnieuwNodig = true;
      return;
    }

    _backupBezig = true;

    try {
      await uploadBackup();
    } catch (_) {
      // Geen crash veroorzaken bij achtergrondsync.
    } finally {
      _backupBezig = false;
    }

    if (_backupOpnieuwNodig) {
      _backupOpnieuwNodig = false;
      await uploadBackupOpAchtergrond();
    }
  }

  Future<String> downloadBackup() async {
    try {
      final token = await OneDriveAuthService().login();

      if (token.startsWith('FOUT')) {
        return token;
      }

      final url =
          'https://graph.microsoft.com/v1.0/me/drive/special/approot:/thimaco_backup.json:/content';

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode != 200) {
        return 'IMPORT_FOUT ${response.statusCode}\n${response.body}';
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      final prefs = await SharedPreferences.getInstance();

      final agendaItems = data['agendaItems'];
      final dagtaakTemplates = data['dagtaakTemplates'];

      if (agendaItems is String) {
        await prefs.setString('agenda_items_nieuw', agendaItems);
      }

      if (dagtaakTemplates is String) {
        await prefs.setString('dagtaak_templates', dagtaakTemplates);
      }

      return 'IMPORT_OK';
    } catch (e) {
      return 'IMPORT_EXCEPTION: $e';
    }
  }
}
