import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'onedrive_auth_service.dart';

import '/helpers/Agenda/agenda_item.dart';
import '/helpers/klanten/fiche/klantenfiche_model.dart';
import 'sync_merge_service.dart';
import '../app_storage.dart';

class OneDriveSyncService {
  static const String _backupDatumKey = 'laatste_backup_datum';

  static const String _lokaleWijzigingOpenstaandKey =
      'lokale_wijziging_openstaand';

  static bool _backupBezig = false;
  static bool _backupOpnieuwNodig = false;
  static String laatsteSyncActie = 'Nog geen sync uitgevoerd';

  static Future<void> registreerLokaleWijziging() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_lokaleWijzigingOpenstaandKey, true);
  }

  Future<String> uploadBackup() async {
    try {
      final token = await OneDriveAuthService().tokenSilent();

      if (token.startsWith('FOUT')) {
        laatsteSyncActie = 'Upload niet uitgevoerd: geen silent token';
        return token;
      }

      final prefs = await SharedPreferences.getInstance();
      final backupDatum = DateTime.now().toIso8601String();

      const url =
          'https://graph.microsoft.com/v1.0/me/drive/special/approot:/thimaco_backup.json:/content';

      Map<String, dynamic> cloudBackup = {};

      final cloudResponse = await http.get(
        Uri.parse(url),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (cloudResponse.statusCode == 200) {
        cloudBackup = jsonDecode(cloudResponse.body) as Map<String, dynamic>;
      }

      Map<String, List<AgendaItem>> decodeAgenda(String? jsonString) {
        if (jsonString == null || jsonString.isEmpty) return {};

        final data = jsonDecode(jsonString) as Map<String, dynamic>;

        return data.map((datumKey, lijst) {
          final items = (lijst as List<dynamic>)
              .map(
                (item) => AgendaItem.fromJson(Map<String, dynamic>.from(item)),
              )
              .toList();

          return MapEntry(datumKey, items);
        });
      }

      String encodeAgenda(Map<String, List<AgendaItem>> data) {
        final jsonMap = data.map((datumKey, items) {
          return MapEntry(
            datumKey,
            items.map((item) => item.toJson()).toList(),
          );
        });

        return jsonEncode(jsonMap);
      }

      List<KlantenficheModel> decodeKlanten(String? jsonString) {
        if (jsonString == null || jsonString.isEmpty) return [];

        final lijst = jsonDecode(jsonString) as List<dynamic>;

        return lijst
            .map(
              (item) =>
                  KlantenficheModel.fromJson(Map<String, dynamic>.from(item)),
            )
            .toList();
      }

      String encodeKlanten(List<KlantenficheModel> fiches) {
        return jsonEncode(fiches.map((fiche) => fiche.toJson()).toList());
      }

      final lokaleAgenda = await AppStorage.laadAgendaItemsNieuwVoorSync();

      final cloudAgenda = decodeAgenda(
        cloudBackup['agendaItems'] is String
            ? cloudBackup['agendaItems']
            : null,
      );

      final mergedAgenda = SyncMergeService.mergeAgendaMap(
        lokaleAgenda,
        cloudAgenda,
      );

      final lokaleKlanten = decodeKlanten(prefs.getString('klanten_fiches'));

      final cloudKlanten = decodeKlanten(
        cloudBackup['klantenFiches'] is String
            ? cloudBackup['klantenFiches']
            : null,
      );

      final mergedKlanten = SyncMergeService.mergeKlantenFiches(
        lokaleKlanten,
        cloudKlanten,
      );

      final backup = {
        'backupDatum': backupDatum,
        'agendaItems': encodeAgenda(mergedAgenda),
        'dagtaakTemplates': prefs.getString('dagtaak_templates'),
        'leveranciers': prefs.getString('leveranciers_lijst'),
        'klantenFiches': encodeKlanten(mergedKlanten),
        'notities': prefs.getString('thimaco_notities'),
        'notitieActies': prefs.getString('thimaco_notitie_acties'),
      };

      final response = await http.put(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(backup),
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        return 'BACKUP_FOUT ${response.statusCode}\n${response.body}';
      }

      await AppStorage.bewaarAgendaItemsNieuwVoorSync(mergedAgenda);

      await AppStorage.bewaarKlantenFichesVoorSync(
        mergedKlanten.map((fiche) => fiche.toJson()).toList(),
      );

      final fotoResultaat = await _uploadKlantenFotos(token);

      await prefs.setString(_backupDatumKey, backupDatum);
      await prefs.setBool(_lokaleWijzigingOpenstaandKey, false);

      laatsteSyncActie = 'Merge upload uitgevoerd';

      if (!fotoResultaat.startsWith('FOTOS_OK')) {
        return 'BACKUP_OK_FOTOS_LATER\n$fotoResultaat';
      }

      return 'BACKUP_OK';
    } catch (e) {
      return 'BACKUP_EXCEPTION: $e';
    }
  }

  Future<String> _uploadKlantenFotos(String token) async {
    try {
      final appMap = await getApplicationDocumentsDirectory();
      final fotosMap = Directory('${appMap.path}/klanten_fotos');

      if (!await fotosMap.exists()) {
        await _uploadFotoManifest(token: token, bestanden: []);
        return 'FOTOS_OK_GEEN_FOTOS';
      }

      final bestanden = <Map<String, String>>[];
      final entities = fotosMap.listSync(recursive: true, followLinks: false);

      for (final entity in entities) {
        if (entity is! File) continue;

        final relatiefPad = entity.path
            .replaceFirst('${fotosMap.path}/', '')
            .replaceAll('\\', '/');

        bestanden.add({'pad': relatiefPad});

        final encodedPad = _encodeOneDrivePath('klanten_fotos/$relatiefPad');

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

      await _uploadFotoManifest(token: token, bestanden: bestanden);

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

  Future<String> downloadBackupMetToken(String token) async {
    try {
      if (token.startsWith('FOUT')) {
        return token;
      }

      const url =
          'https://graph.microsoft.com/v1.0/me/drive/special/approot:/thimaco_backup.json:/content';

      final response = await http.get(
        Uri.parse(url),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode != 200) {
        return 'IMPORT_FOUT ${response.statusCode}\n${response.body}';
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final prefs = await SharedPreferences.getInstance();

      Map<String, List<AgendaItem>> decodeAgenda(String? jsonString) {
        if (jsonString == null || jsonString.isEmpty) return {};

        final data = jsonDecode(jsonString) as Map<String, dynamic>;

        return data.map((datumKey, lijst) {
          final items = (lijst as List<dynamic>)
              .map(
                (item) => AgendaItem.fromJson(Map<String, dynamic>.from(item)),
              )
              .toList();

          return MapEntry(datumKey, items);
        });
      }

      List<KlantenficheModel> decodeKlanten(String? jsonString) {
        if (jsonString == null || jsonString.isEmpty) return [];

        final lijst = jsonDecode(jsonString) as List<dynamic>;

        return lijst
            .map(
              (item) =>
                  KlantenficheModel.fromJson(Map<String, dynamic>.from(item)),
            )
            .toList();
      }

      final cloudAgenda = decodeAgenda(
        data['agendaItems'] is String ? data['agendaItems'] : null,
      );

      final lokaleAgenda = await AppStorage.laadAgendaItemsNieuwVoorSync();

      final mergedAgenda = SyncMergeService.mergeAgendaMap(
        lokaleAgenda,
        cloudAgenda,
      );

      final cloudKlanten = decodeKlanten(
        data['klantenFiches'] is String ? data['klantenFiches'] : null,
      );

      final lokaleKlanten = decodeKlanten(prefs.getString('klanten_fiches'));

      final mergedKlanten = SyncMergeService.mergeKlantenFiches(
        lokaleKlanten,
        cloudKlanten,
      );

      await AppStorage.bewaarAgendaItemsNieuwVoorSync(mergedAgenda);

      await AppStorage.bewaarKlantenFichesVoorSync(
        mergedKlanten.map((fiche) => fiche.toJson()).toList(),
      );

      if (data['dagtaakTemplates'] is String) {
        await prefs.setString('dagtaak_templates', data['dagtaakTemplates']);
      }

      if (data['leveranciers'] is String) {
        await prefs.setString('leveranciers_lijst', data['leveranciers']);
      }

      if (data['notities'] is String) {
        await prefs.setString('thimaco_notities', data['notities']);
      }

      if (data['notitieActies'] is String) {
        await prefs.setString('thimaco_notitie_acties', data['notitieActies']);
      }

      if (data['backupDatum'] is String) {
        await prefs.setString(_backupDatumKey, data['backupDatum']);
      }

      await _downloadKlantenFotos(token);

      laatsteSyncActie = 'Download met login-token uitgevoerd';

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
      headers: {'Authorization': 'Bearer $token'},
    );

    if (manifestResponse.statusCode != 200) {
      return;
    }

    final manifest = jsonDecode(manifestResponse.body) as Map<String, dynamic>;
    final bestanden = manifest['bestanden'];

    if (bestanden is! List) return;

    final appMap = await getApplicationDocumentsDirectory();
    final fotosMap = Directory('${appMap.path}/klanten_fotos');

    if (!await fotosMap.exists()) {
      await fotosMap.create(recursive: true);
    }

    for (final item in bestanden) {
      if (item is! Map) continue;

      final pad = item['pad'];

      if (pad is! String || pad.trim().isEmpty) continue;

      final encodedPad = _encodeOneDrivePath('klanten_fotos/$pad');

      final url =
          'https://graph.microsoft.com/v1.0/me/drive/special/approot:/$encodedPad:/content';

      final response = await http.get(
        Uri.parse(url),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode != 200) continue;

      final lokaalBestand = File('${fotosMap.path}/$pad');
      final parent = lokaalBestand.parent;

      if (!await parent.exists()) {
        await parent.create(recursive: true);
      }

      await lokaalBestand.writeAsBytes(response.bodyBytes, flush: true);
    }
  }

  String _encodeOneDrivePath(String pad) {
    return pad.split('/').map(Uri.encodeComponent).join('/');
  }

  Future<String?> lokaleBackupDatum() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_backupDatumKey);
  }

  Future<String?> oneDriveBackupDatum({bool magLoginVragen = false}) async {
    try {
      final token = magLoginVragen
          ? await OneDriveAuthService().loginInteractief()
          : await OneDriveAuthService().tokenSilent();

      if (token.startsWith('FOUT')) {
        return null;
      }

      const url =
          'https://graph.microsoft.com/v1.0/me/drive/special/approot:/thimaco_backup.json:/content';

      final response = await http.get(
        Uri.parse(url),
        headers: {'Authorization': 'Bearer $token'},
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

  Future<String> syncDebugInfo() async {
    final prefs = await SharedPreferences.getInstance();

    final lokaal = await lokaleBackupDatum();
    final oneDrive = await oneDriveBackupDatum();
    final openstaand = prefs.getBool(_lokaleWijzigingOpenstaandKey) ?? false;

    return '''
LOKAAL:
$lokaal

ONEDRIVE:
$oneDrive

LOKALE WIJZIGING OPENSTAAND:
$openstaand

BACKUP BEZIG:
$_backupBezig

LAATSTE SYNC ACTIE:
$laatsteSyncActie
''';
  }

  Future<String> slimmeSync({bool magLoginVragen = false}) async {
    final prefs = await SharedPreferences.getInstance();

    if (_backupBezig) {
      _backupOpnieuwNodig = true;
      laatsteSyncActie = 'Upload bezig, geen download uitgevoerd';
      return 'SYNC_UPLOAD_BEZIG';
    }

    final lokaleWijzigingOpenstaand =
        prefs.getBool(_lokaleWijzigingOpenstaandKey) ?? false;

    final lokaleDatumString = await lokaleBackupDatum();

    final oneDriveDatumString = await oneDriveBackupDatum(
      magLoginVragen: magLoginVragen,
    );

    if (oneDriveDatumString == null) {
      laatsteSyncActie = 'Geen OneDrive login of geen OneDrive backup gevonden';

      if (lokaleWijzigingOpenstaand) {
        laatsteSyncActie =
            'Lokale wijziging openstaand, maar geen OneDrive login';
        return 'SYNC_GEEN_ONEDRIVE_LOGIN_UPLOAD_OVERGESLAGEN';
      }

      return 'SYNC_GEEN_ONEDRIVE_LOGIN';
    }

    if (lokaleWijzigingOpenstaand) {
      laatsteSyncActie = 'Lokale wijziging openstaand, upload uitgevoerd';
      return await uploadBackup();
    }

    if (lokaleDatumString == null) {
      laatsteSyncActie = 'Geen lokale datum, download uitgevoerd';

      final token = await OneDriveAuthService().tokenSilent();

      if (token.startsWith('FOUT')) {
        laatsteSyncActie = 'Download niet uitgevoerd: geen silent token';
        return token;
      }

      return await downloadBackupMetToken(token);
    }

    final lokaleDatum = DateTime.tryParse(lokaleDatumString);
    final oneDriveDatum = DateTime.tryParse(oneDriveDatumString);

    if (lokaleDatum == null || oneDriveDatum == null) {
      laatsteSyncActie = 'Datumfout, geen sync uitgevoerd';
      return 'SYNC_DATUM_FOUT';
    }

    if (oneDriveDatum.isAfter(lokaleDatum)) {
      laatsteSyncActie = 'OneDrive nieuwer, download uitgevoerd';

      final token = await OneDriveAuthService().tokenSilent();

      if (token.startsWith('FOUT')) {
        laatsteSyncActie = 'Download niet uitgevoerd: geen silent token';
        return token;
      }

      return await downloadBackupMetToken(token);
    }

    if (lokaleDatum.isAfter(oneDriveDatum)) {
      laatsteSyncActie = 'Lokaal nieuwer, merge upload uitgevoerd';
      return await uploadBackup();
    }

    laatsteSyncActie = 'Geen wijziging, niets uitgevoerd';
    return 'SYNC_OK_GEEN_WIJZIGING';
  }
}
