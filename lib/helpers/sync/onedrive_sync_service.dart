import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'onedrive_auth_service.dart';

class OneDriveSyncService {
  static const String _backupDatumKey = 'laatste_backup_datum';

  static const String _lokaleWijzigingOpenstaandKey =
      'lokale_wijziging_openstaand';

  static bool _backupBezig = false;
  static bool _backupOpnieuwNodig = false;

  static Future<void> registreerLokaleWijziging() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setBool(
      _lokaleWijzigingOpenstaandKey,
      true,
    );
  }

  Future<String> uploadBackup() async {
    try {
      final token = await OneDriveAuthService().login();

      if (token.startsWith('FOUT')) {
        return token;
      }

      final prefs = await SharedPreferences.getInstance();
      final backupDatum = DateTime.now().toIso8601String();

      final backup = {
        'backupDatum': backupDatum,
        'agendaItems': prefs.getString('agenda_items_nieuw'),
        'dagtaakTemplates': prefs.getString('dagtaak_templates'),
        'leveranciers': prefs.getString('leveranciers_lijst'),
        'klantenFiches': prefs.getString('klanten_fiches'),
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

      if (response.statusCode != 200 && response.statusCode != 201) {
        return 'BACKUP_FOUT ${response.statusCode}\n${response.body}';
      }

      final fotoResultaat = await _uploadKlantenFotos(token);

      if (!fotoResultaat.startsWith('FOTOS_OK')) {
        return fotoResultaat;
      }

      await prefs.setString(
        _backupDatumKey,
        backupDatum,
      );

      await prefs.setBool(
        _lokaleWijzigingOpenstaandKey,
        false,
      );

      return 'BACKUP_OK';
    } catch (e) {
      return 'BACKUP_EXCEPTION: $e';
    }
  }

  Future<String> _uploadKlantenFotos(String token) async {
    try {
      final appMap = await getApplicationDocumentsDirectory();

      final fotosMap = Directory(
        '${appMap.path}/klanten_fotos',
      );

      if (!await fotosMap.exists()) {
        await _uploadFotoManifest(
          token: token,
          bestanden: [],
        );

        return 'FOTOS_OK_GEEN_FOTOS';
      }

      final bestanden = <Map<String, String>>[];

      final entities = fotosMap.listSync(
        recursive: true,
        followLinks: false,
      );

      for (final entity in entities) {
        if (entity is! File) continue;

        final relatiefPad = entity.path
            .replaceFirst('${fotosMap.path}/', '')
            .replaceAll('\\', '/');

        bestanden.add({
          'pad': relatiefPad,
        });

        final encodedPad = _encodeOneDrivePath(
          'klanten_fotos/$relatiefPad',
        );

        final url =
            'https://graph.microsoft.com/v1.0/me/drive/special/approot:/$encodedPad:/content';

        final bytes = await entity.readAsBytes();

        final response = await http.put(
          Uri.parse(url),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/octet-stream',
          },
          body: bytes,
        );

        if (response.statusCode != 200 && response.statusCode != 201) {
          return 'FOTOS_UPLOAD_FOUT ${response.statusCode}\n${response.body}';
        }
      }

      await _uploadFotoManifest(
        token: token,
        bestanden: bestanden,
      );

      return 'FOTOS_OK ${bestanden.length}';
    } catch (e) {
      return 'FOTOS_EXCEPTION: $e';
    }
  }

  Future<void> _uploadFotoManifest({
    required String token,
    required List<Map<String, String>> bestanden,
  }) async {
    final manifest = {
      'datum': DateTime.now().toIso8601String(),
      'bestanden': bestanden,
    };

    const url =
        'https://graph.microsoft.com/v1.0/me/drive/special/approot:/klanten_fotos_manifest.json:/content';

    await http.put(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(manifest),
    );
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
      final leveranciers = data['leveranciers'];
      final klantenFiches = data['klantenFiches'];
      final backupDatum = data['backupDatum'];

      if (agendaItems is String) {
        await prefs.setString('agenda_items_nieuw', agendaItems);
      }

      if (dagtaakTemplates is String) {
        await prefs.setString('dagtaak_templates', dagtaakTemplates);
      }

      if (leveranciers is String) {
        await prefs.setString(
          'leveranciers_lijst',
          leveranciers,
        );
      }

      if (klantenFiches is String) {
        await prefs.setString(
          'klanten_fiches',
          klantenFiches,
        );
      }

      if (backupDatum is String) {
        await prefs.setString(
          _backupDatumKey,
          backupDatum,
        );
      }

      await _downloadKlantenFotos(token);

      return 'IMPORT_OK';
    } catch (e) {
      return 'IMPORT_EXCEPTION: $e';
    }
  }

  Future<void> _downloadKlantenFotos(String token) async {
    const manifestUrl =
        'https://graph.microsoft.com/v1.0/me/drive/special/approot:/klanten_fotos_manifest.json:/content';

    final manifestResponse = await http.get(
      Uri.parse(manifestUrl),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (manifestResponse.statusCode != 200) {
      return;
    }

    final manifest = jsonDecode(manifestResponse.body) as Map<String, dynamic>;

    final bestanden = manifest['bestanden'];

    if (bestanden is! List) return;

    final appMap = await getApplicationDocumentsDirectory();

    final fotosMap = Directory(
      '${appMap.path}/klanten_fotos',
    );

    if (!await fotosMap.exists()) {
      await fotosMap.create(
        recursive: true,
      );
    }

    for (final item in bestanden) {
      if (item is! Map) continue;

      final pad = item['pad'];

      if (pad is! String || pad.trim().isEmpty) continue;

      final encodedPad = _encodeOneDrivePath(
        'klanten_fotos/$pad',
      );

      final url =
          'https://graph.microsoft.com/v1.0/me/drive/special/approot:/$encodedPad:/content';

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode != 200) continue;

      final lokaalBestand = File(
        '${fotosMap.path}/$pad',
      );

      final parent = lokaalBestand.parent;

      if (!await parent.exists()) {
        await parent.create(
          recursive: true,
        );
      }

      await lokaalBestand.writeAsBytes(
        response.bodyBytes,
        flush: true,
      );
    }
  }

  String _encodeOneDrivePath(String pad) {
    return pad.split('/').map(Uri.encodeComponent).join('/');
  }

  Future<String?> lokaleBackupDatum() async {
    final prefs = await SharedPreferences.getInstance();

    return prefs.getString(_backupDatumKey);
  }

  Future<String?> oneDriveBackupDatum() async {
    try {
      final token = await OneDriveAuthService().login();

      if (token.startsWith('FOUT')) {
        return null;
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
        return null;
      }

      final data = jsonDecode(response.body);

      return data['backupDatum'];
    } catch (_) {
      return null;
    }
  }

  Future<String> slimmeSync() async {
    final prefs = await SharedPreferences.getInstance();

    if (_backupBezig) {
      _backupOpnieuwNodig = true;
      return 'SYNC_UPLOAD_BEZIG';
    }

    final lokaleWijzigingOpenstaand =
        prefs.getBool(_lokaleWijzigingOpenstaandKey) ?? false;

    if (lokaleWijzigingOpenstaand) {
      return await uploadBackup();
    }

    final lokaleDatumString = await lokaleBackupDatum();
    final oneDriveDatumString = await oneDriveBackupDatum();

    if (oneDriveDatumString == null) {
      return await uploadBackup();
    }

    if (lokaleDatumString == null) {
      return await downloadBackup();
    }

    final lokaleDatum = DateTime.tryParse(lokaleDatumString);
    final oneDriveDatum = DateTime.tryParse(oneDriveDatumString);

    if (lokaleDatum == null || oneDriveDatum == null) {
      return 'SYNC_DATUM_FOUT';
    }

    if (oneDriveDatum.isAfter(lokaleDatum)) {
      final lokaleWijzigingOpenstaand =
          prefs.getBool(_lokaleWijzigingOpenstaandKey) ?? false;

      if (lokaleWijzigingOpenstaand) {
        return await uploadBackup();
      }

      return await downloadBackup();
    }

    if (lokaleDatum.isAfter(oneDriveDatum)) {
      return await uploadBackup();
    }

    return 'SYNC_OK_GEEN_WIJZIGING';
  }
}
