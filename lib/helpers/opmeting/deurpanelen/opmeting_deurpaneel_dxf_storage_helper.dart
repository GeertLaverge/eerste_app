import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../sync/onedrive_sync_service.dart';

class OpmetingDeurpaneelDxfStorageHelper {
  const OpmetingDeurpaneelDxfStorageHelper._();

  static const String opslagSleutel = 'thimaco_deurpanelen_dxf_bibliotheek';

  static const String gewijzigdOpSleutel =
      'thimaco_deurpanelen_dxf_bibliotheek_gewijzigd_op';

  static Future<void> _registreerWijzigingVoorSync() async {
    await OneDriveSyncService.registreerLokaleWijziging();
    OneDriveSyncService().uploadBackupOpAchtergrond();
  }

  static Future<Map<String, String>?> laadDxfs() async {
    final prefs = await SharedPreferences.getInstance();
    final tekst = prefs.getString(opslagSleutel);

    if (tekst == null || tekst.trim().isEmpty) {
      return null;
    }

    final decoded = jsonDecode(tekst);

    if (decoded is! Map) {
      return null;
    }

    final resultaat = <String, String>{};

    decoded.forEach((key, value) {
      final bestandsnaam = key.toString().trim().toLowerCase();
      final inhoud = value?.toString() ?? '';

      if (bestandsnaam.isEmpty || inhoud.trim().isEmpty) {
        return;
      }

      resultaat[bestandsnaam] = inhoud;
    });

    return resultaat;
  }

  static Future<void> bewaarDxfs(Map<String, String> dxfs) async {
    final prefs = await SharedPreferences.getInstance();
    final opgeschoond = <String, String>{};

    dxfs.forEach((key, value) {
      final bestandsnaam = key.trim().toLowerCase();
      final inhoud = value;

      if (bestandsnaam.isEmpty || inhoud.trim().isEmpty) {
        return;
      }

      opgeschoond[bestandsnaam] = inhoud;
    });

    await prefs.setString(opslagSleutel, jsonEncode(opgeschoond));
    await prefs.setString(gewijzigdOpSleutel, DateTime.now().toIso8601String());

    await _registreerWijzigingVoorSync();
  }

  static Future<void> bewaarDxfsVoorSync({
    required String? jsonTekst,
    required String? gewijzigdOp,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    final tekst = jsonTekst?.trim() ?? '';

    if (tekst.isEmpty) {
      await prefs.remove(opslagSleutel);
    } else {
      await prefs.setString(opslagSleutel, tekst);
    }

    final datum = gewijzigdOp?.trim() ?? '';

    if (datum.isEmpty) {
      await prefs.remove(gewijzigdOpSleutel);
    } else {
      await prefs.setString(gewijzigdOpSleutel, datum);
    }
  }

  static Future<void> wisDxfs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(opslagSleutel);
    await prefs.setString(gewijzigdOpSleutel, DateTime.now().toIso8601String());

    await _registreerWijzigingVoorSync();
  }
}
